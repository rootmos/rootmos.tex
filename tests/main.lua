local lu = require("luaunit")
local L = require("rootmos-cite")

function test_simple()
    lu.assertEquals(L.parse("p1"), { page=1 })
    lu.assertEquals(L.parse("p01"), { page=1 })
    lu.assertEquals(L.parse("p17"), { page=17 })
    lu.assertEquals(L.parse("p2-34"), { page={2,34} })
end

os.exit(lu.LuaUnit.run())
