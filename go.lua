-- http://lua-users.org/wiki/StringRecipes
local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

print(capitalize("foo"))
