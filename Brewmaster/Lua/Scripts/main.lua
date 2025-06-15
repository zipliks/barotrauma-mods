local itemFunctions = {}


Hook.Add("item.applyTreatment", "itemused", function(item, source, target, limb)
	local id = item.Prefab.Identifier.Value
	local func = itemFunctions[id]

	print("Item Used: " .. id)
	print(limb)

	if (func ~= nil) then
		print("func")
		return func(item, source, target, limb)
	end
end)

-- Назначает функцию предмету, исполняемую при его применении в Health Menu
function Main.SetItemFunction(id, func)
	if id == nil or func == nil then
		Utils.ThrowError("Bad argument", 1)
	end
	itemFunctions[id] = func
	print("INIT: Initialized ItemFunction for item \"" .. id .. "\"")
end

Main.SetItemFunction("strangebrew", function(item, source, target, limb)
	local targetPos = target.WorldPosition
	local skills = {"medical", "weapons", "mechanical", "electrical", "helm"}
	
	-- Define actions in a table
	local actions = {
		[5] = function() target.Kill(CauseOfDeathType.Unknown) end, -- Kills
		[30] = function() target.TeleportTo(target_pos + Vector2(math.random(-500, 500), math.random(-500, 500))) end, -- Teleports a character randomly
		[15] = function() Utils.SpawnRandomCount(4, 8, "crawler", target_pos + Vector2(math.random(-200, 200), math.random(-200, 200))) end,
		[60] = function() Utils.SpawnRandomCount(1, 1, "mudraptor_pet", target_pos)  end,
		[3] = function() Game.Explode(target_pos, 100, 10, 0, 100, 0, 200, 0) end,
		[4] = function() Game.Explode(target_pos, 500, 100, 10, 200, 0, 0, 0) end,
		[2] = function() Game.Explode(target_pos, 500, 500, 500, 500, 500, 500, 500) end,
		[17] = function() Utils.RespawnAsCharacter(target, "husk") end,
		[10] = function() Utils.RespawnAsCharacter(target, "mudraptor") end,
		[75] = function() target.GiveMoney(math.random(0, 1000)) end,
		[40] = function() target.Info.SetSkillLevel(skills[math.random(#skills)], math.random(-50, 100)) end,
	}
	local choice = Utils.PickWeight(actions)

	choice()
	Utils.RemoveItem(item)
end)



