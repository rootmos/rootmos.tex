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
    bla = "bl.a.",
    tex = "t.ex.",
    pga = "p.g.a.",
    ev = "ev.",
    sk = "s.k.",

    jfr = "jfr",
    jfm = { "jfr", "m." },

    dvs = "dvs.",
    osv = "osv.",
    etc = "etc.",
    ang = "angående",

    iaf = { "i", "alla", "fall" },
    iom = { "i", "och", "med" },
    tom = { "till", "och", "med" },
    mao = { "med", "andra", "ord" },
}

M.styles.formal = {
    dvs = { "det", "vill", "säga" },
    osv = { "och", "så", "vidare" },
}

M.styles.informal = {
    iaf = "iaf",
    iom = "iom",
    tom = "tom",
    jfm = "jfm",
    mao = "mao.",
    ang = "ang.",

    w = "w/",
    wo = "w/o",
}

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
            s = s .. string.format([[\xperiodafter{\mbox{%s}}]], w:sub(1, -2))
        else
            s = s .. string.format([[\mbox{%s}\xspace]], w)
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
