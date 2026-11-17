local lu = require("luaunit")
local A = require("rootmos-abbrev")

function test_levels()
    local m = A:style("swedish"):macro("tex")
    lu.assertItemsEquals(m:expand(0), { "till", "exempel" })
    lu.assertItemsEquals(m:expand(1), { "t.ex." })
    lu.assertItemsEquals(m:expand(2), { "tex" })
end

function test_cap1()
    local m = A:style("swedish"):macro("tex")
    lu.assertItemsEquals(m:expand(0, true), { "Till", "exempel" })
    lu.assertItemsEquals(m:expand(1, true), { "T.ex." })
    lu.assertItemsEquals(m:expand(2, true), { "Tex" })
end

function test_fallthrough()
    local m = A:style("swedish"):macro("iaf")
    lu.assertItemsEquals(m:expand(0), { "i", "alla", "fall" })
    lu.assertItemsEquals(m:expand(1), { "i", "alla", "fall" })
    lu.assertItemsEquals(m:expand(2), { "iaf" })
end

function test_ambiguous()
    local m = A:style("swedish"):macro("bla")
    lu.assertError(function() m:expand(0) end)
    lu.assertItemsEquals(m:expand(1), { "bl.a." })
    lu.assertItemsEquals(m:expand(2), { "bla" })
end

os.exit(lu.LuaUnit.run())
