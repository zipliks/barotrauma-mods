math.randomseed(os.time())

Utils = {}

function Utils.ThrowError(text, level)
	if level == nil then level = 0 end
	error("Custom Error: " .. text, 2 + level)
end

function Utils.RemoveItem(item)
	if item == nil or item.Removed then return end

	if not SERVER then
		return item.Remove()
	end
	return Entity.Spawner.AddEntityToRemoveQueue(item)
end

-- Weighted random, easier to control
function Utils.PickWeight(table)
	local total_weight = 0
	for weight, _ in pairs(table) do
		total_weight = total_weight + weight
	end

	local random_weight = math.random() * total_weight
	local accumulated_weight = 0

	for weight, item in pairs(table) do
		accumulated_weight = accumulated_weight + weight
		if accumulated_weight >= random_weight then
			return item
		end
	end
end

-- Used to spawn all creatures
function Utils.SpawnRandomCount(min_times, max_times, identifier, position)
	local random_times = math.random(min_times, max_times)
	for i = 1, random_times do
		Entity.Spawner.AddCharacterToSpawnQueue(identifier, position)
	end
end


-- Respawns player as a playable %creaturename%. New creature will be hostile for NPCs.
function Utils.RespawnAsCharacter(character, identifier)
	Game.EnableControlHusk(true)

	Entity.Spawner.AddCharacterToSpawnQueue(identifier, character.WorldPosition, function(newCharacter)
		local client = nil
		for _, value in pairs(Client.ClientList) do
			if value.Character == character then
				client = value
			end
		end

		Entity.Spawner.AddEntityToRemoveQueue(character)

		if client == nil then
			return
		end

		newCharacter.TeamID = character.TeamID
		client.SetClientCharacter(newCharacter)
	end)
end
