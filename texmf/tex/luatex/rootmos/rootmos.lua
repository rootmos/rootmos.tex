local M = {
    meta = {
        buildinfo = true,
        final = {
            wordcount = {
                sum = { "text", "other" },
            },
        },
        draft = {
            wordcount = {
                sub = { "text", "other" },
            },
        },
    },
}

local def = require("rootmos-utils").def
local luaaux = require("rootmos-utils").luaaux
local sha256 = require("rootmos-utils").sha256

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

local seen_bibresources = {}

function M.addbibresource(p)
    if not p:find("%.bib$") then
        --texio.write_nl(string.format("ignoring non-bib file: %s\n", e))
        return
    end
    local h = sha256(p)

    if seen_bibresources[h] then
        texio.write_nl(string.format("skipping duplicate bib resource: %s [%s]\n", p, h:sub(1,7)))
        return
    end
    seen_bibresources[h] = p

    texio.write_nl(string.format("adding bib resource: %s [%s]\n", p, h:sub(1,7)))
    tex.print("\\addbibresource{" .. p .. "}")
end

function M.setup_addbibresources()
    def("addbibresources", function()
        local path = lparse.scan("o") or lfs.currentdir()
        texio.write_nl(string.format("scanning for local .bib files: %s\n", path))
        for e in lfs.dir(path) do
            M.addbibresource(path .. "/" .. e)
        end

        local binder = os.getenv("BINDER")
        if binder ~= nil and lfs.attributes(binder, "mode") then
            texio.write_nl(string.format("binder directory: %s\n", binder))
            for e in lfs.dir(binder) do
                if e ~= "." and e ~= ".." then
                    local r = binder .. "/" .. e .. "/"
                    local b = r .. "binder.lua"
                    if lfs.attributes(b, "mode") then
                        texio.write_nl(string.format("binder manifest: %s\n", b))
                        for _, fn in ipairs(dofile(b)) do
                            M.addbibresource(r .. fn)
                        end
                    end
                end
            end
        end
    end)
end

function M.buildinfo(path)
    local B = luaaux(path, "build-info.lua")
    local s = string.format("\\href{%s}{\\tt %s}", B.git_commit_url, B.time)
    s = s .. string.format(" \\href{%s}{\\tt %s}", B.git_commit_url, B.git_ref)
    if B.git_dirty then
        s = s .. " {\\tt(dirty)}"
    end
    return s
end

function M.wordcount(path, cfg)
    local W = luaaux(path, "wc")

    local s = ""

    local sum = cfg.sum
    if sum then
        local acc = 0
        for _, k in ipairs(sum) do
            local w = W[k] or 0
            acc = acc + w
        end
        s = tostring(acc)
    end

    local sub = cfg.sub
    if sub then
        local acc = 0
        local t = ""
        for _, k in ipairs(sub) do
            local w = W[k] or 0
            acc = acc + w
            if t ~= "" then
                t = t .. "+"
            end
            t = t .. tostring(w)
        end
        if s == "" then
            s = string.format("%s=%d", t, acc)
        else
            s = s .. string.format(" (%s=%d)", t, acc)
        end
    end

    return s
end

function M.setup()
    M.setup_jobtype()
    M.setup_addbibresources()
end

function M.print_meta()
    local meta = M.meta
    if not meta then
        return
    end
    jt = meta[M.jobtype] or {}

    local function cfg(k)
        local v = jt[k]
        if v ~= nil then
            return v
        end
        return meta[k]
    end

    local wc = cfg("wordcount")
    if wc then
        tex.print {
            [[\footnotetext{]],
            [[\iftoggle{@swedish}{Antal ord}{Word count}:]],
            M.wordcount(nil, wc),
            [[}]],
        }
    end

    local bi = cfg("buildinfo")
    if bi then
        tex.print {
            [[\footnotetext{]],
            M.buildinfo(),
            [[}]],
        }
    end

end

return M
