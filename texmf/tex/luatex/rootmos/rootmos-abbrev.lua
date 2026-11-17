local M = {
    -- level 0: expand everything/strictly formal
    -- level 1: allow formally accepted abbreviations
    -- level 2: allow most widely accepted abbreviations
    -- level 3: allow informal abbreviations
    level = 1,
    ambiguous = {},
    styles = {},
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

function M.render(words)
    local s = ""

    for i, w in ipairs(words) do
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
                local w = a[1]
                if cap1 == true then
                    local W = {}
                    for i, w in ipairs(a) do
                        if i == 1 then
                            W[i] = capitalize(w)
                        else
                            W[i] = w
                        end
                    end
                    return W
                end
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

    function __fn:enable()
        texio.write_nl("enabling abbreviation macro: " .. self.name)
        def(self.name, function()
            tex.print(self:render(M.level))
        end)
        def(capitalize(self.name), function()
            tex.print(self:render(M.level, true))
        end)
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

    function __fn:enable()
        texio.write_nl("enabling abbreviation style: " .. self.key)
        for _, m in pairs(self.macros) do
            m:enable()
        end
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

function M:style(key)
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
swedish:insert("dvs", "det vill säga", nil, "m.")
swedish:insert("etc", "etcetera", "etc.", "etc")
swedish:insert("ev", ambiguous, "ev.", "ev")
swedish:insert("from", "från och med", "fr.o.m.")
swedish:insert("fd", "före detta", "f.d.")
swedish:insert("forts", "fortsättning", "forts.")
swedish:insert("fö", "för övrigt", "f.ö.")
swedish:insert("iaf", "i alla fall", nil, "iaf")
swedish:insert("jfm", "jämför med", "jfr. med", "jfr. m.", "jfm")
swedish:insert("jfr", "jämför", "jfr")
swedish:insert("m", "med", nil, "m.", "m")
swedish:insert("mao", "med andra ord", nil, "m.a.o.", "mao")
swedish:insert("mfl", "med flera", "m.fl.")
swedish:insert("mm", "med mera", "m.m.")
swedish:insert("obs", "observera", "obs.")
swedish:insert("osv", "och så vidare", "osv.", "osv")
swedish:insert("pga", "på grund av", "p.g.a.", "pga")
swedish:insert("resp", "respektive", "resp.")
swedish:insert("sk", ambiguous, "s.k.", "sk")
swedish:insert("tex", "till exempel", "t.ex.", "tex")
swedish:insert("tom", "till och med", "t.o.m.", "tom")

local english = M:style("english")
english:insert("eg", "for example", "e.g.", "eg")
english:insert("etc", "and so on", "etc.", "etc")
english:insert("ie", "that is", "i.e.", "ie")
english:insert("w", "with", nil, "w/")
english:insert("wo", "without", nil, "w/o")
english:insert("eo", "either/or", nil, "e/o")

return M
