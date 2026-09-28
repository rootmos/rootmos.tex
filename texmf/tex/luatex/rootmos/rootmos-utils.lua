local M = {}

function M.def(name, f)
    local ft = lua.get_functions_table()
    local fid = #ft + 1
    ft[fid] = f
    token.set_lua(name, fid)
end

function M.luaaux(path, suffix)
    if not path then
        path = status.filename .. "." .. suffix
    end
    return dofile(kpse.find_file(path, true))
end

function M.to_hex(str)
  return (str:gsub('.', function (c)
      return string.format('%02x', string.byte(c))
  end))
end

function M.sha256(p)
    local f = io.open(p)
    local bs = f:read("*a")
    local h = sha2.digest256(bs)
    f:close()
    return M.to_hex(h)
end

return M
