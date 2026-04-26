Hook.Add("chatMessage", "deathalarm.Debug", function(message, sender)
    if message ~= "!reviveall" then return end

    for _, crewmember in pairs(Character.CharacterList) do
        -- Skip this crewmember if they have no ID Card
        crewmember.Revive(true)
    end

    Utils.DMClient(sender, "Debug", "Revived All", Color(0, 255, 255, 255))
    return true
end)

if CLIENT and Game.IsMultiplayer then return end -- lets this run if on the server-side, if it's multiplayer, doesn't let it run on the client, and if it's singleplayer, lets it run on the client.

local crewtracker = ItemPrefab.GetItemPrefab("crewtracker")
local implanter = ItemPrefab.GetItemPrefab("implanter")
local alarmimplant = ItemPrefab.GetItemPrefab("implantdeathalarm")

Hook.Add("chatMessage", "shield.items", function (message, client)
    if message ~= ".giveitems" then return end

    local character
    if client == nil then
        character = Character.Controlled
    else
        character = client.Character
    end

    if character == nil then return end

    Entity.Spawner.AddItemToSpawnQueue(crewtracker, character.Inventory, nil, nil, function(item) end)
    Entity.Spawner.AddItemToSpawnQueue(implanter, character.Inventory, nil, nil, function(item2) end)
    Entity.Spawner.AddItemToSpawnQueue(alarmimplant, character.Inventory, nil, nil, function(item3) end)


    return true
end)


Hook.Add("chatMessage", "shield.me", function (message, client)
    if message ~= "!me" then return end

    local character
    if client == nil then
        character = Character.Controlled
    else
        character = client.Character
    end

    print(character.Name, character.CurrentHull.DisplayName)

    return true
end)


Hook.Add("chatMessage", "shield.subinfo", function (message, client)
    if message ~= "!submarine" then return end

    local character
    if client == nil then
        character = Character.Controlled
    else
        character = client.Character
    end

    local submarine
    submarine = Game.GameSession.submarine
    local hulls
    hulls = submarine.GetHulls(false)

    Utils.DMClient(client, "Debug", submarine, Color(0, 255, 255, 255))

    for _, value in pairs(hulls) do
        print(_, value)
    end


    return true
end)