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

function test_tail_space()
    lu.assertEquals(L.parse("p1 foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse("p2-34 foo"), { page={2,34}, tail="foo" })
    lu.assertEquals(L.parse("p1ch2 foo"), { page=1, chapter=2, tail="foo" })
    lu.assertEquals(L.parse("17 foo"), { page=17, tail="foo" })
    lu.assertEquals(L.parse("2-34 foo"), { page={2,34, tail="foo" } })
end

function test_tail_comma()
    lu.assertEquals(L.parse("p1,foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse("p1, foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse("p2-34, foo"), { page={2,34}, tail="foo" })
    lu.assertEquals(L.parse("p1ch2, foo"), { page=1, chapter=2, tail="foo" })
    lu.assertEquals(L.parse("17, foo"), { page=17, tail="foo" })
    lu.assertEquals(L.parse("2-34, foo"), { page={2,34, tail="foo" } })
end

function test_tail_none()
    lu.assertEquals(L.parse("foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse(" foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse(",foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse(", foo"), { page=1, tail="foo" })
    lu.assertEquals(L.parse(",p1"), { tail="p1" })
    lu.assertEquals(L.parse(", p1, \\emph{foo}"), { tail="p1, \\emph{foo}" })
end

os.exit(lu.LuaUnit.run())
