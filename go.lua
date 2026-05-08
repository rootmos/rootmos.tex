local fields = {
    ch = "chapter",
    p = "page",
    [""] = "page",
    l = "line",
    P = "part",
    s = "paragraph",
}

--local str = "   foo bar"
--local str = " 	p17"
--local str = "p17"
--local str = ""
local str = "p7-12 l17, foo"

local function whitespace(i)
    local _, j = str:find("^%s*", i)
    return j + 1
end


local function field(f, i)
    local j = i+#f
    if str:sub(i, j-1) ~= f then
        return nil, i
    end
    i = j

    _, j = str:find("^%d+", i)
    if j == nil then
        return nil, i
    end

    local x = tonumber(str:sub(i, j))
    i = j + 1

    _, j = str:find("^%-%d+", i)
    if j == nil then
        return x, i
    end

    local y = tonumber(str:sub(i+1, j))
    return {x, y}, j + 1
end

local fs = {}

local i, v = whitespace(1), nil
while true do
    local i0 = i
    for f, k in pairs(fields) do
        v, i = field(f, i)
        if v ~= nil then
            print(string.format("field %s: %s", f, v))
            fs[k] = v
            i = whitespace(i)
        end
    end
    if i0 == i then
        break
    end
end


if str:sub(i, i) == "," then
    i = whitespace(i+1)
end

local tail = str:sub(i)
if tail ~= "" then
    fs.tail = tail
end
