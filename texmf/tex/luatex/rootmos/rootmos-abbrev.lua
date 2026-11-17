local M = {
    level = 0,
    ambiguous = {},
    styles = {},
    applied = {},
}

local ambiguous = M.ambiguous
local capitalize = require("rootmos-utils").capitalize
local def = require("rootmos-utils").def
local words = require("rootmos-utils").words

--M.styles.english = {
    --eg = "e.g.",
    --ie = "i.e.",
    --etc = "etc.",

    --w = "with",
    --wo = "without",
--}

--M.styles.fancy = {
    --etc = "\\&c.",
--}

---- https://www.isof.se/utforska/publikationer/publikationer/2024-01-22-snabba-skrivregler
--M.styles.swedish = {
    --ang = "angående",
    --bla = "bl.a.",
    --dvs = "dvs.",
    --etc = "etc.",
    --ev = "ev.",
    --iaf = { "i", "alla", "fall" },
    --iom = { "i", "och", "med" },
    --jfm = { "jfr", "m." },
    --jfr = "jfr",
    --mao = { "med", "andra", "ord" },
    --mm = "m.m.",
    --obs = "obs.",
    --osv = "osv.",
    --resp = "resp.",
    --pga = "p.g.a.",
    --sk = "s.k.",
    --tex = "t.ex.",
    --tom = { "t.", "o.", "m." },
--}

--M.styles.formal = {
    --bla = { "bland", "annat" },
    --dvs = { "det", "vill", "säga" },
    --jfm = { "jämför", "med" },
    --jfr = { "jämför" },
    --obs = { "observera" },
    --osv = { "och", "så", "vidare" },
    --resp = "respektive",
    --pga = { "på", "grund", "av" },
    --tex = { "till", "exempel" },
    --tex = { "till", "och", "med" },
--}

--M.styles.informal = {
    --ang = "ang.",
    --iaf = "iaf",
    --iom = "iom",
    --jfm = "jfm",
    --mao = "mao",
    --tom = "tom",

    --w = "w/",
    --wo = "w/o",
--}

function M.render(words, cap1)
    local s = ""

    for i, w in ipairs(words) do
        if cap1 and i == 1 then
            w = capitalize(w)
        end
        if w:sub(-1) == "." then
            s = s .. string.format([[\xperiodafter{%s}]], w:sub(1, -2))
        else
            s = s .. string.format([[%s\xspace ]], w)
        end
    end

    return s
end

local mk_macro, is_macro = (function()
    local __fn = {}
    local __mt = { __index = __fn }

    function __mt:__tostring()
        return "\\" .. self.name
        -- TODO: pretty print nil and ambiguous
        --local s = "\\" .. self.name .. "{"
        --for i = 1,self.n do
            --if i > 1 then
                --s = s .. ","
            --end
            --s = s .. string.format("%d=%s", i, self.defs[i])
        --end
        --return s .. "}"
    end

    function __fn:expand(level, cap1)
        if level < 0 then
            error("negative level")
        end

        local l = math.min(level + 1, self.n)
        local a = self.defs[l]
        if a == ambiguous then
            error(string.format("abbreviation macro (\\%s) is ambiguous at level %d", self.name, l - 1))
        end

        while l > 0 do
            a = self.defs[l]
            if type(a) == "table" then
                return a
            end
            l = l - 1
        end

        if a == ambiguous then
            error(string.format("abbreviation macro (\\%s) is ambiguous", self.name))
        end
        assert(a == nil)
        error(string.format("abbreviation macro (\\%s) is undefined", self.name))
    end

    function __fn:render(level, cap1)
        return M.render(self:expand(level, cap1))
    end

    return function(name, ...)
        local args = table.pack(...)
        local defs = {}
        for i = 1,args.n do
            local a = args[i]
            if type(a) == "string" then
                defs[i] = words(a)
            elseif a == nil or a == ambiguous then
                defs[i] = a
            else
                error(string.format("unexpected macro (%s) expansion [%d]: %s", name, i, a))
            end
        end

        return setmetatable({
            name = name,
            defs = defs,
            n = args.n,
        }, __mt)
    end, function(x)
        return getmetatable(x) == __mt
    end
end)()

local mk_style, is_style = (function()
    local __fn = {}
    local __mt = { __index = __fn }

    function __mt:__tostring()
        return self.key
    end

    function __fn:insert(macro, ...)
        local m = mk_macro(macro, ...)
        self.macros[macro] = m
        return m
    end

    function __fn:macro(name)
        return self.macros[name]
    end

    return function(key)
        local S = {
            key = key,
            macros = {},
        }
        return setmetatable(S, __mt)
    end, function(x)
        return getmetatable(x) == __mt
    end
end)()

function M.style(key)
    local l = M.styles[key]
    if l == nil then
        l = mk_style(key)
        M.styles[key] = l
    end
    return l
end

local swedish = M:style("swedish")
swedish:insert("ang", "angående", "ang.")
swedish:insert("bla", ambiguous, "bl.a.", "bla")
swedish:insert("iaf", "i alla fall", nil, "iaf")
swedish:insert("tex", "till exempel", "t.ex.", "tex")

local did_common_setup = false
local function do_common_setup()
    if did_common_setup then
        return
    end
    local lparse = require("lparse")

    def("abbrev", function()
        tex.print(M.abbrev(lparse.scan("m")))
    end)

    did_common_setup = true
end

function M.enable(s)
    for k, v in pairs(s) do
        local w = M.abbrev(v)
        def(k, function() tex.print(w) end)
        local W = M.abbrev(v, true)
        def(capitalize(k), function() tex.print(W) end)
    end
end

function M.setup(styles)
    do_common_setup()

    for _, s in ipairs(styles or {}) do
        if type(s) == "string" then
            texio.write_nl(string.format("applying abbreviation style: %s\n", s))
            s = M.styles[s]
        end
        M.enable(s)
    end
end

return M
