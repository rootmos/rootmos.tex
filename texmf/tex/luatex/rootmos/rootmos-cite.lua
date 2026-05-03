local M = {
    fields = { "page", "part", "chapter", "paragraph", "line" },
    delims = {
        between_fields = "\\addcomma\\addspace",
        after_prenote = "\\addcomma",
    }
}

local def = require("rootmos-utils").def

local number = lpeg.R"09"^1 / tonumber
local range = number * lpeg.P"-" * number / function(...) local t = table.pack(...) t.n = nil return t end
local value = range + number

-- TODO LuaUnit tests
assert(value:match("19") == 19)
--print(value:match("1-3"))

local page = (lpeg.P"p" * value) / function(...) return { page = ... } end
local chapter = (lpeg.P"ch" * value) / function(...) return { chapter = ... } end
local line = (lpeg.P"l" * value) / function(...) return { line = ... } end
local part = (lpeg.P"P" * value) / function(...) return { part = ... } end
local paragraph = (lpeg.P"s" * value) / function(...) return { paragraph = ... } end
local field = page + part + chapter + paragraph + line
local pattern = field^1

--print(field:match("p12-3").page)
--print(field:match("ch2").chapter)

function M.parse(input)
    local fs = {}
    for _, f in ipairs({pattern:match(input)}) do
        for k, v in pairs(f) do
            fs[k] = v
        end
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

function M.citloc(s)
    local fs = match(s)
    local r = ""
    local i = 0
    for _, k in ipairs(M.fields) do
        local v = fs[k]
        if v then
            local s, plural = render_value(v)
            if i > 0 then
                r = r .. M.delims.between_fields
            end
            r = r .. string.format("\\bibstring{%s%s}~", k, plural and "s" or "")
            r = r .. s
            i = i + 1
        end
    end
    return r
end

function M.setup_notes_commands()
    local lparse = require("lparse")

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
