local RANGE = 100
local notified = {}
local lastTriggerTime = 0


local function printArrow(source_x, source_y, target_x, target_y)
    local min_x = target_x - RANGE
    local max_x = target_x + RANGE

    if source_x < min_x or source_x > max_x then
        if source_x < target_x then
            return string.format(">>> [%s, %s]", target_x, target_y)
        elseif source_x == target_x then
            return string.format("Here")
        else
            return string.format("<<< [%s, %s]", target_x, target_y)
        end
    else
        -- Up and down arrows, the game doesn't support unicode
        if source_y < target_y then
            return "/\\ /\\ /\\"
        elseif source_x == target_x then
            return string.format("Here")
        else
            return "\\/ \\/ \\/"
        end
    end
end


-- This shit works perfect but Baro says "Fuck you and your aligned strings"
-- -- Function to align multiple strings by the "|" character
-- function BSJob.AlignStringsByPipe(strings)
--     -- Calculate the maximum position of the first "|"
--     local maxPipePosition = 0
--     for _, str in ipairs(strings) do
--         local pipePosition = str:find("|") or 0
--         maxPipePosition = math.max(maxPipePosition, pipePosition)
--     end

--     -- Create aligned strings by adding spaces before the first "|"
--     local alignedStrings = {}
--     for _, str in ipairs(strings) do
--         local pipePosition = str:find("|") or 0
--         local spacesToAdd = maxPipePosition - pipePosition
--         local alignedString = string.rep(" ", spacesToAdd) .. str
--         table.insert(alignedStrings, alignedString)
--     end

--     return alignedStrings
-- end


function BSJob.HandleTracker(player)
    local crew = {}
    local sender = nil
    for _, crewmate in pairs(Character.CharacterList) do
        if crewmate == nil then return end
        local item = crewmate.Inventory.GetItemInLimbSlot(InvSlotType.Card)
        if crewmate.TeamID == player.TeamID and item then
            local statusString = crewmate.Name

            if crewmate.Health > 0 and crewmate.Health <= crewmate.MaxHealth then
                statusString = statusString .. " | Alive"
            elseif crewmate.Health <= 0 and crewmate.Health > -crewmate.MaxHealth then
                statusString = statusString .. " | Critical"
            else
                statusString = statusString .. " | Dead"
            end
            statusString = statusString .. string.format(" (%s) | ", tostring(math.floor(crewmate.Health)))
                ..
                printArrow(math.floor(player.WorldPosition.X), math.floor(player.WorldPosition.Y),
                    math.floor(crewmate.WorldPosition.X), math.floor(crewmate.WorldPosition.Y))
                .. "\n"

            table.insert(crew, statusString)
        end
    end

    if SERVER then
        for _, client in pairs(Client.ClientList) do
            if client.Name == player.Name then
                sender = client
            end
        end
    else
        sender = player
    end

    -- local alignedNames = BSJob.AlignStringsByPipe(crew)
    local statusMsg = table.concat(crew) -- Concatenate the aligned strings
    if sender then
        Utils.DMClient(sender, "Crew Tracker", statusMsg, Color(0, 255, 255, 255))
    end
end


local function sendMessageToAll(messageAuthor, message, color)
    if SERVER then
        for _, client in pairs(Client.ClientList) do
            Utils.DMClient(client, messageAuthor, message, color)
        end
        return
    else
        Utils.PrintChat(message, title, color)
    end
end


local function onCharacterDeath(character)
    if not character then return end
    if not Utils.HasAffliction(character, "deathalarm") then return end

    local location = "somewhere"
    local message = nil
    if character.CurrentHull ~= nil then
        location = tostring(character.CurrentHull.DisplayName)
        message = string.format("%s has died at %s", character.Name, location)
    else
        message = string.format("%s has died on the open sea", character.Name)
    end

    sendMessageToAll("Death Alarm", message, Color(255, 0, 0, 255))
    Utils.RemoveElementByName(notified, character)
end


local function onCharacterCritical(_, _, character, _, _)
    if Utils.IsInTable(notified, character) then return end

    local location = "somewhere"
    local message = nil
    if character.CurrentHull ~= nil then
        location = tostring(character.CurrentHull.DisplayName)
        message = string.format("%s is in critical at %s", character.Name, location)
    else
        message = string.format("%s is in critical on the open sea", character.Name)
    end
    
    sendMessageToAll("Death Alarm", message, Color(255, 255, 0, 255))
    table.insert(notified, character)
end


local function onCharacterRevive(_, usingCharacter, targetCharacter, _)
    if usingCharacter == targetCharacter then return end
    if targetCharacter.Health < 10 then
        return
    end
    if Utils.IsInTable(notified, targetCharacter) then
        Utils.RemoveElementByName(notified, targetCharacter)
    end
end


Hook.Add("character.death", "deathalarmdead", onCharacterDeath)
Hook.Add("character.critical", "deathalarmcrit", onCharacterCritical)
Hook.Add("item.applyTreatment", "deathalarmrevive", onCharacterRevive)

Hook.Add("item.secondaryUse", "crewtracker.use", function(item, itemUser, _)
    local cooldownDuration = 1.5
    local currentTime = os.time()
    if currentTime - lastTriggerTime >= cooldownDuration then
        if item.HasIdentifierOrTags({ "crewtracker" }) then
            BSJob.HandleTracker(itemUser)
            lastTriggerTime = currentTime
        end
    end
end)
