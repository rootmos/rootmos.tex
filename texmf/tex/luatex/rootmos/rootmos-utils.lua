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

return M
