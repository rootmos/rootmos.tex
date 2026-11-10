local M = {}

local capitalize = require("rootmos-utils").capitalize

M.styles = {}

M.styles.english = {
    eg = "e.g.",
    ie = "i.e.",
    etc = "etc.",

    w = "with",
    wo = "without",
}

M.styles.fancy = {
    etc = "\\&c.",
}

-- https://www.isof.se/utforska/publikationer/publikationer/2024-01-22-snabba-skrivregler
M.styles.swedish = {
    ang = "angående",
    bla = "bl.a.",
    dvs = "dvs.",
    etc = "etc.",
    ev = "ev.",
    iaf = { "i", "alla", "fall" },
    iom = { "i", "och", "med" },
    jfm = { "jfr", "m." },
    jfr = "jfr",
    mao = { "med", "andra", "ord" },
    mm = "m.m.",
    obs = "obs.",
    osv = "osv.",
    resp = "resp.",
    pga = "p.g.a.",
    sk = "s.k.",
    tex = "t.ex.",
    tom = { "t.", "o.", "m." },
}

M.styles.formal = {
    bla = { "bland", "annat" },
    dvs = { "det", "vill", "säga" },
    jfm = { "jämför", "med" },
    jfr = { "jämför" },
    obs = { "observera" },
    osv = { "och", "så", "vidare" },
    resp = "respektive",
    pga = { "på", "grund", "av" }
    tex = { "till", "exempel" },
    tex = { "till", "och", "med" },
}

M.styles.informal = {
    ang = "ang.",
    iaf = "iaf",
    iom = "iom",
    jfm = "jfm",
    mao = "mao",
    tom = "tom",

    w = "w/",
    wo = "w/o",
}

local undefined = {}

function M.insert(language, cmd, abbrev, formal, informal, fancy)
end

function M:language(key)
    local l = self[key]
    if l == nil then
        l = {
            insert = M.insert,
        }
        self[key] = l
    end
    return l
end

local swedish = M:language("swedish")
swedish:insert("ang", "angående", nil, "ang.")
swedish:insert("bla", undefined, "bl.a.")
swedish:insert("iaf", "i alla fall", nil, "iaf")
swedish:insert("tex", "till exempel", "t.ex.")

local def = require("rootmos-utils").def
local lparse = require("lparse")

local function abbrev(m, cap1)
    if type(m) == "string" then
        m = { m }
    end

    local s = ""

    for i, w in ipairs(m) do
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

local did_common_setup = false
local function do_common_setup()
    if did_common_setup then
        return
    end

    def("abbrev", function()
        tex.print(abbrev(lparse.scan("m")))
    end)

    did_common_setup = true
end

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

local function apply(s)
    for k, v in pairs(s) do
        local w = abbrev(v)
        def(k, function() tex.print(w) end)
        local W = abbrev(v, true)
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
        apply(s)
    end
end

return M
