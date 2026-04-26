---@diagnostic disable: undefined-field, undefined-global

if CLIENT then return end

Contractor = {}
Contractor.Path = table.pack(...)[1]

local function LoadModule(path, name)
    local fullPath = Contractor.Path .. "/" .. path
    local success, err = pcall(function()
        dofile(fullPath)
    end)
    if success then
        print("[Contractor] Loaded: " .. name)
        return true
    else
        print("[Contractor] ERROR loading " .. name .. ": " .. tostring(err))
        return false
    end
end

local modulesLoaded = 0
local modulesFailed = 0

local modules = {
    {path = "Lua/Lib/hexlib.lua", name = "HexLib"},
    {path = "Lua/Contracts/data.lua", name = "Contract Data"},
    {path = "Lua/Contracts/contracts.lua", name = "Contracts"},
}

print("[Contractor] Loading modules...")

for _, mod in ipairs(modules) do
    if LoadModule(mod.path, mod.name) then
        modulesLoaded = modulesLoaded + 1
    else
        modulesFailed = modulesFailed + 1
    end
end

print("[Contractor] " .. modulesLoaded .. " modules loaded, " .. modulesFailed .. " failed")