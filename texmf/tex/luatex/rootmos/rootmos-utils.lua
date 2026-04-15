local M = {}

function M.def(name, f)
    local ft = lua.get_functions_table()
    local fid = #ft + 1
    ft[fid] = f
    token.set_lua(name, fid)
end

return M
