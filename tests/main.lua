local lu = require("luaunit")
local L = require("rootmos-cite")

function test_single_field()
    lu.assertEquals(L.parse("p1"), { page=1 })
    lu.assertEquals(L.parse("p01"), { page=1 })
    lu.assertEquals(L.parse("p17"), { page=17 })
    lu.assertEquals(L.parse("p2-34"), { page={2,34} })
end

function test_multiple_fields()
    lu.assertEquals(L.parse("p1ch2"), { page=1, chapter=2 })
    lu.assertEquals(L.parse("ch2p1"), { page=1, chapter=2 })
end

function test_page_is_the_default_field()
    lu.assertEquals(L.parse("1"), { page=1 })
    lu.assertEquals(L.parse("17"), { page=17 })
    lu.assertEquals(L.parse("2-34"), { page={2,34} })
end

os.exit(lu.LuaUnit.run())
