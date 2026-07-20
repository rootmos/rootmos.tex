local M = {}

M.styles = {}

M.styles.english = {
    eg = "e.g.",
    ie = "i.e.",
    etc = "etc.",
}

-- https://www.isof.se/utforska/publikationer/publikationer/2024-01-22-snabba-skrivregler
M.styles.swedish = {
    bla = "bl.a.",
    tex = "t.ex.",
    pga = "p.g.a.",
    ev = "ev.",
    sk = "s.k.",

    jfr = "jfr",
    jfm = "jfr m.",

    dvs = "dvs.",
    osv = "osv.",
    etc = "etc.",
    ang = "ang.",
}

M.styles.fancy = {
    etc = "\\&c.",
}

local def = require("rootmos-utils").def
local lparse = require("lparse")

local function abbrev(m)
    local w = function(x) return x end

    if m:sub(-1) == "." then
        w = function(x) return string.format("\\xperiodafter{%s}", x) end
        m = m:sub(1, -2)
    end

    return w(string.format("\\mbox{%s}",  m))
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

local function apply(s)
    for k, v in pairs(s) do
        local w = abbrev(v)
        def(k, function() tex.print(w) end)
    end
end

function M.setup(styles)
    do_common_setup()

    for _, s in ipairs(styles or {}) do
        if type(s) == "string" then
            s = M.styles[s]
        end
        apply(s)
    end
end

return M
