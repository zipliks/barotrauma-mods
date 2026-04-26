if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then
    BSJob = {}
    BSJob.Path = ...
    dofile(BSJob.Path .. "/Lua/Scripts/main.lua")
    dofile(BSJob.Path .. "/Lua/Scripts/utils.lua")
    -- dofile(BSJob.Path .. "/Lua/Modules/debug.lua")
end