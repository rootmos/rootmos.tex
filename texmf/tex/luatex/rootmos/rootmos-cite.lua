local M = {
    fields = {
        ch = "chapter",
        p = "page",
        [""] = "page",
        l = "line",
        P = "part",
        s = "paragraph",
    },
    delims = {
        between_fields = "\\addcomma\\addspace",
        after_prenote = "\\addcomma",
    }
}

local def = require("rootmos-utils").def

function M.parse(str)
    local function whitespace(i)
        local _, j = str:find("^%s*", i)
        return j + 1
    end

    local function field(f, i)
        local j = i+#f
        if str:sub(i, j-1) ~= f then
            return nil, i
        end
        i = j

        _, j = str:find("^%d+", i)
        if j == nil then
            return nil, i
        end

        local x = tonumber(str:sub(i, j))
        i = j + 1

        _, j = str:find("^%-%d+", i)
        if j == nil then
            return x, i
        end

        local y = tonumber(str:sub(i+1, j))
        return {x, y}, j + 1
    end

    local fs = {}

    local i, v = whitespace(1), nil
    while true do
        local i0 = i
        for f, k in pairs(M.fields) do
            v, i = field(f, i)
            if v ~= nil then
                fs[k] = v
                i = whitespace(i)
            end
        end
        if i0 == i then
            break
        end
    end


    if str:sub(i, i) == "," then
        i = whitespace(i+1)
    end

    local tail = str:sub(i)
    if tail ~= "" then
        fs.tail = tail
    end

    return fs
end

local function render_value(v)
    if type(v) == "number" then
        return v, false
    elseif type(v) == "table" then
        return v[1] .. "-" .. v[2], true
    else
        error(string.format("unable to render value: %s", v))
    end
end

local function sanitize(s)
    return s:gsub("\\emph", "\\mkbibemph")
end

function M.citloc(s)
    texio.write_nl(string.format("FOO%%%s%%BAR\n", s))
    local fs, r = M.parse(s), ""
    for k, v in pairs(fs) do
        if k ~= "tail" then
            local s, plural = render_value(v)
            if r ~= "" then
                r = r .. M.delims.between_fields
            end
            r = r .. string.format("\\bibstring{%s%s}~", k, plural and "s" or "")
            r = r .. s
        end
    end

    if fs.tail then
        if r ~= "" then
            r = r .. M.delims.between_fields .. " "
        end
        r = r .. sanitize(fs.tail)
    end

    texio.write_nl(string.format("FOO%%%s%%BAR\n", r))

    return r
end

function M.setup_notes_commands()
    local lparse = require("lparse")

    def("foo", function()
        local n = lparse.scan("m")
        texio.write_nl(string.format("FOO%%%s%%BAR\n", n))
        tex.print(n)
        --tex.print(string.format("\\emph{%s}", n))
        --tex.print(string.format("\\emph{%s}", n))
    end)

    def("prenote", function()
        local n = lparse.scan("m")
        n = M.citloc(n)
        if n ~= "" then
            tex.print(n, M.delims.after_prenote)
        end
    end)

    def("postnote", function()
        local n = lparse.scan("m")
        n = M.citloc(n)
        tex.print(n)
    end)
end

function M.setup()
    M.setup_notes_commands()
end

return M
