local M = {}

local def = require("rootmos-utils").def

local lparse = require("lparse")

function M.setup_jobtype()
    local jt = "final"
    for m in tex.jobname:gmatch([[%.(%w+)]]) do
        if m == "draft" or m == "final" then
            jt = m
        end
    end
    M.jobtype = jt

    def("jobtype", function() return tex.print(M.jobtype) end)
end

function M.setup_addbibresources()
    def("addbibresources", function()
        local path = lparse.scan("o") or lfs.currentdir()
        texio.write_nl(string.format("scanning for .bib files: %s\n", path))
        for e in lfs.dir(path) do
            if e:find("%.bib$") then
                texio.write_nl(string.format("adding bib resource: %s/%s\n", path, e))
                tex.print("\\addbibresource{" .. e .. "}")
            else
                --texio.write_nl(string.format("ignoring non-bib file: %s\n", e))
            end
        end
    end)
end

function M.buildinfo()
    local B = dofile(os.getenv("BUILD_INFO"))
    tex.print(string.format("\\href{%s}{\\tt %s}", B.git_commit_url, B.time))
    tex.print(string.format("\\href{%s}{\\tt %s}", B.git_commit_url, B.git_ref))
    if B.git_dirty then
        tex.print("{\\tt(dirty)}")
    end
end

function M.wordcount(path)
    if not path then
        path = kpse.find_file(status.filename .. ".wc")
    end
    local words
    for l in io.lines(path) do
        return tonumber(l)
    end
end

function M.setup()
    M.setup_jobtype()
    M.setup_addbibresources()
end

return M
