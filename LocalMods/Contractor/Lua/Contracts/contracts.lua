---@diagnostic disable: undefined-field, undefined-global

Contracts = {}

local activeContracts = {}
local contractPool = {}
local lastTriggerTime = {}
local COOLDOWN_SECONDS = 3

function Contracts.getCharacterByID(id)
    for _, char in pairs(Character.CharacterList) do
        if char.ID == id then return char end
    end
    return nil
end

function Contracts.findClientByCharacter(character)
    if not character then return nil end
    for _, client in pairs(Client.ClientList) do
        if client.Character == character then
            return client
        end
    end
    return nil
end

function Contracts.sendToClient(client, title, message, titleColor)
    local color = titleColor or Color(255, 215, 0, 255)
    if SERVER then
        if client == nil then return end
        title = title or ""
        local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Default, nil)
        chatMessage.Color = color
        Game.SendDirectChatMessage(chatMessage, client)
    end
end

function Contracts.getTotalWeight(availableCreatures)
    local total = 0
    for _, creature in ipairs(availableCreatures) do
        total = total + creature.weight
    end
    return total
end

function Contracts.selectWeightedCreature(availableCreatures)
    if #availableCreatures == 0 then return nil end
    local totalWeight = Contracts.getTotalWeight(availableCreatures)
    local random = math.random() * totalWeight
    local cumulative = 0
    for _, creature in ipairs(availableCreatures) do
        cumulative = cumulative + creature.weight
        if random <= cumulative then
            return creature
        end
    end
    return availableCreatures[#availableCreatures]
end

function Contracts.countCreaturesOnMap(speciesName)
    local count = 0
    for _, char in pairs(Character.CharacterList) do
        if char and not char.IsPlayer and not char.IsDead and char.SpeciesName == speciesName then
            count = count + 1
        end
    end
    return count
end

function Contracts.getAvailableCreatures()
    local available = {}
    for _, creature in ipairs(ContractData.CREATURE_TABLE) do
        local count = Contracts.countCreaturesOnMap(creature.species)
        if count > 0 then
            table.insert(available, creature)
        end
    end
    return available
end

function Contracts.getCrewMembers()
    local crew = {}
    for _, char in pairs(Character.CharacterList) do
        if char.IsPlayer and not char.IsDead then
            table.insert(crew, char)
        end
    end
    return crew
end

function Contracts.getHostileHumans()
    local hostiles = {}
    for _, char in pairs(Character.CharacterList) do
        if char.IsHuman and not char.IsPlayer and not char.IsDead and char.SpeciesName == "human" then
            local isCrew = false
            for _, client in pairs(Client.ClientList) do
                if client.Character == char then
                    isCrew = true
                    break
                end
            end
            if not isCrew then
                table.insert(hostiles, char)
            end
        end
    end
    return hostiles
end

function Contracts.calculateReward(baseReward, difficulty, targetCount)
    local multiplier = 1 + (difficulty - 1) * 0.3
    local multiTargetBonus = 1 + (targetCount - 1) * 0.15
    return math.floor(baseReward * multiplier * multiTargetBonus)
end

function Contracts.generateContractPool(contractor)
    local availableCreatures = Contracts.getAvailableCreatures()
    local hostiles = Contracts.getHostileHumans()
    local crew = Contracts.getCrewMembers()

    local pool = {}
    local usedCreatures = {}
    local contractCount = 0
    local targetContracts = 6
    local contractTypes = { "creature", "poison", "elimination" }

    while contractCount < targetContracts do
        local contractType = contractTypes[math.random(#contractTypes)]

        if contractType == "creature" and #availableCreatures > 0 then
            local creatureData = Contracts.selectWeightedCreature(availableCreatures)
            if not creatureData then break end

            if usedCreatures[creatureData.species] then
                local attempts = 0
                while attempts < 10 do
                    local retryData = Contracts.selectWeightedCreature(availableCreatures)
                    if retryData and not usedCreatures[retryData.species] then
                        creatureData = retryData
                        break
                    end
                    attempts = attempts + 1
                end
                if usedCreatures[creatureData.species] then
                    contractType = nil
                end
            end

            if creatureData and not usedCreatures[creatureData.species] then
                usedCreatures[creatureData.species] = true

                local maxOnMap = Contracts.countCreaturesOnMap(creatureData.species)
                local targetCount = 1
                if maxOnMap >= 3 and math.random() < 0.4 then
                    targetCount = math.random(2, math.min(3, maxOnMap))
                end

                local reward = Contracts.calculateReward(creatureData.baseReward, creatureData.difficulty, targetCount)

                table.insert(pool, {
                    type = "kill",
                    targetType = "creature",
                    targetName = creatureData.name,
                    targetSpecies = creatureData.species,
                    reward = reward,
                    description = "Kill " .. targetCount .. "x " .. creatureData.name,
                    completed = false,
                    progress = 0,
                    required = targetCount,
                    difficulty = creatureData.difficulty,
                })
                contractCount = contractCount + 1
            end

        elseif contractType == "poison" and #crew > 1 then
            local targetPlayer = crew[math.random(#crew)]
            if targetPlayer == contractor then
                targetPlayer = nil
                for _, p in ipairs(crew) do
                    if p ~= contractor then
                        targetPlayer = p
                        break
                    end
                end
            end

            if targetPlayer then
                local poisonType = ContractData.POISON_TYPES[math.random(#ContractData.POISON_TYPES)]
                table.insert(pool, {
                    type = "poison",
                    targetType = "crew",
                    targetId = targetPlayer.ID,
                    targetName = targetPlayer.Name,
                    poisonName = poisonType.name,
                    poisonIdentifier = poisonType.identifier,
                    reward = poisonType.reward,
                    description = "Poison " .. targetPlayer.Name .. " with " .. poisonType.name,
                    completed = false,
                    poisoned = false,
                    difficulty = 2,
                })
                contractCount = contractCount + 1
            end

        elseif contractType == "elimination" and #hostiles > 0 then
            local targetHostile = hostiles[math.random(#hostiles)]

            local isDuplicate = false
            for _, c in ipairs(pool) do
                if c.type == "elimination" and c.targetId == targetHostile.ID then
                    isDuplicate = true
                    break
                end
            end

            if not isDuplicate then
                table.insert(pool, {
                    type = "elimination",
                    targetType = "human",
                    targetId = targetHostile.ID,
                    targetName = targetHostile.Name or "Hostile Human",
                    reward = 350,
                    description = "Eliminate hostile: " .. (targetHostile.Name or "Hostile Human"),
                    completed = false,
                    difficulty = 3,
                })
                contractCount = contractCount + 1
            end
        end

        if #availableCreatures == 0 and #hostiles == 0 and #crew <= 1 then
            break
        end
    end

    return pool
end

local function colorize(text, color)
    if not color then return text end
    local r = color.R or 255
    local g = color.G or 255
    local b = color.B or 255
    return string.format("‖color:%d,%d,%d‖%s‖color:end‖", r, g, b, text)
end

function Contracts.showContracts(character)
    local client = Contracts.findClientByCharacter(character)
    if not client then return end

    local pool = contractPool[character.ID]
    if not pool or #pool == 0 then
        contractPool[character.ID] = Contracts.generateContractPool(character)
        pool = contractPool[character.ID]
    else
        contractPool[character.ID] = Contracts.generateContractPool(character)
        pool = contractPool[character.ID]
    end

    if #pool == 0 then
        Contracts.sendToClient(client, "Contracts", "No contracts available - no targets on map yet!", Color(255, 200, 100, 255))
        return
    end

    local lines = {}
    table.insert(lines, colorize("Available contracts:", Color(255, 215, 0, 255)))

    for i, contract in ipairs(pool) do
        local status = "Pending"

        if contract.completed then
            status = "COMPLETED"
        elseif contract.type == "kill" then
            status = contract.progress .. "/" .. contract.required
        elseif contract.type == "poison" and contract.poisoned then
            status = "Applied"
        end

        local line = colorize("[" .. i .. "]", Color(128, 128, 128, 255))
            .. " " .. colorize(contract.description, Color(255, 0, 0, 255))
            .. " - " .. colorize(contract.reward .. " cr", Color(255, 255, 0, 255))
            .. " " .. colorize("(" .. status .. ")", Color(128, 128, 128, 255))
        table.insert(lines, line)
    end

    table.insert(lines, colorize("Type /accept [number] to accept", Color(150, 150, 150, 255)))

    Contracts.sendToClient(client, "Contracts", table.concat(lines, "\n"), Color(255, 215, 0, 255))
end

function Contracts.acceptContract(character, contractIndex)
    local client = Contracts.findClientByCharacter(character)
    if not client then return end

    local pool = contractPool[character.ID]
    if not pool or contractIndex < 1 or contractIndex > #pool then
        Contracts.sendToClient(client, "Contracts", "Invalid contract number.", Color(255, 100, 100, 255))
        return
    end

    local contract = pool[contractIndex]

    if contract.type == "kill" then
        local currentCount = Contracts.countCreaturesOnMap(contract.targetSpecies)
        if currentCount < contract.required then
            Contracts.sendToClient(client, "Contracts", "Not enough " .. contract.targetName .. " on map! Need " .. contract.required .. ", found " .. currentCount, Color(255, 100, 100, 255))
            return
        end
    end

    if contract.type == "elimination" then
        local target = Contracts.getCharacterByID(contract.targetId)
        if not target or target.IsDead then
            Contracts.sendToClient(client, "Contracts", "Target already eliminated!", Color(255, 100, 100, 255))
            return
        end
    end

    if activeContracts[character.ID] then
        Contracts.sendToClient(client, "Contracts", "You already have an active contract!", Color(255, 100, 100, 255))
        return
    end

    activeContracts[character.ID] = contract
    table.remove(pool, contractIndex)

    local diffColor = ContractData.getDifficultyColor(contract.difficulty or 1)
    local titleColor = Color(diffColor.R, diffColor.G, diffColor.B, 255)
    local acceptMsg = colorize("Target: ", Color(128, 128, 128, 255))
        .. colorize(contract.description, Color(255, 0, 0, 255))
        .. " | " .. colorize("Reward: ", Color(128, 128, 128, 255))
        .. colorize(contract.reward .. " credits", Color(255, 255, 0, 255))
    Contracts.sendToClient(client, "Contract Accepted", acceptMsg, titleColor)
end

function Contracts.completeContract(character, contract)
    if contract.completed then return end
    contract.completed = true

    local client = Contracts.findClientByCharacter(character)
    if client then
        character:GiveMoney(contract.reward)
        Contracts.sendToClient(client, "Contract Complete!", "+" .. contract.reward .. " credits", Color(0, 255, 0, 255))
    end

    activeContracts[character.ID] = nil
end

function Contracts.failContract(character, reason)
    local client = Contracts.findClientByCharacter(character)
    if client then
        Contracts.sendToClient(client, "Contract Failed", reason, Color(255, 50, 50, 255))
    end
    activeContracts[character.ID] = nil
end

Hook.Add("ShowContracts", "ShowContracts", function(effect, deltaTime, item, targets, worldPosition, element)
    local character = nil
    if item and item.ParentInventory and item.ParentInventory.Owner then
        character = item.ParentInventory.Owner
    end
    if not character then
        for _, client in pairs(Client.ClientList) do
            if client.Character and not client.Character.IsDead then
                character = client.Character
                break
            end
        end
    end
    if not character then return end

    local now = os.time()
    local lastTime = lastTriggerTime[character.ID] or 0
    if now - lastTime < COOLDOWN_SECONDS then
        return
    end
    lastTriggerTime[character.ID] = now

    Contracts.showContracts(character)
end)

Hook.Add("roundStart", "Contractor.Init", function()
    activeContracts = {}
    contractPool = {}
    lastTriggerTime = {}
end)

Hook.Add("roundEnd", "Contractor.Cleanup", function()
    activeContracts = {}
    contractPool = {}
    lastTriggerTime = {}
end)

Hook.Add("characterDeath", "Contractor.OnKill", function(victim, affliction)
    local attacker = victim.LastAttacker

    for charId, contract in pairs(activeContracts) do
        local char = Contracts.getCharacterByID(charId)
        if not char then
        elseif contract.type == "kill" and contract.targetType == "creature" and victim.SpeciesName == contract.targetSpecies then
            contract.progress = contract.progress + 1

            if contract.progress >= contract.required then
                Contracts.completeContract(char, contract)
            else
                local client = Contracts.findClientByCharacter(char)
                if client then
                    local progressMsg = colorize("Kill progress: ", Color(128, 128, 128, 255))
                        .. colorize(contract.progress .. "/" .. contract.required, Color(255, 255, 0, 255))
                        .. " " .. colorize(contract.targetName, Color(255, 0, 0, 255))
                    Contracts.sendToClient(client, "Progress", progressMsg, Color(100, 200, 255, 255))
                end
            end

        elseif contract.type == "elimination" and contract.targetId == victim.ID then
            Contracts.completeContract(char, contract)

        elseif contract.type == "kill" and contract.targetType == "creature" then
            if attacker and attacker.IsPlayer then
                contract.progress = contract.progress + 1
                if contract.progress >= contract.required then
                    Contracts.completeContract(char, contract)
                end
            end
        end
    end
end)

Hook.Add("afflictionApplied", "Contractor.OnPoison", function(health, affliction, limb)
    local victim = health.Character
    if not victim or not victim.IsPlayer then return end

    for charId, contract in pairs(activeContracts) do
        if contract.type == "poison" and contract.targetId == victim.ID then
            if affliction.Identifier == contract.poisonIdentifier then
                contract.poisoned = true

                local char = Contracts.getCharacterByID(charId)
                if char then
                    Contracts.completeContract(char, contract)
                end
            end
        end
    end
end)

Hook.Add("chatMessage", "Contractor.ChatCommand", function(message, client)
    if not client then return end
    local char = client.Character
    if not char then return end

    local acceptMatch = string.match(message, "^/accept (%d+)$")
    if acceptMatch then
        Contracts.acceptContract(char, tonumber(acceptMatch))
        return true
    end
end)

Hook.Add("think", "Contractor.CheckTargets", function()
    for charId, contract in pairs(activeContracts) do
        local char = Contracts.getCharacterByID(charId)
        if not char then
        elseif contract.type == "kill" and contract.targetType == "creature" then
            local currentCount = Contracts.countCreaturesOnMap(contract.targetSpecies)
            if currentCount < contract.required and not contract.completed then
                Contracts.failContract(char, "Not enough " .. contract.targetName .. " remaining on map!")
            end
        elseif contract.type == "elimination" then
            local target = Contracts.getCharacterByID(contract.targetId)
            if not target or target.IsDead then
                Contracts.failContract(char, "Target already eliminated!")
            end
        end
    end
end)