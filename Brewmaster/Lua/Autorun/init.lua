---@diagnostic disable: undefined-global
IS_ENABLED = Game.GetEnabledContentPackages()
Main = {}

print("*gulp*")
print("Aahhh... Welcome to Mother-Russia!")

if (Game.IsMultiplayer and SERVER) then
	for _, value in pairs(IS_ENABLED) do
		require("Scripts.main")
		require("Scripts.utils")
	end
end


