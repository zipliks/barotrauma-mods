---@diagnostic disable: undefined-global, undefined-doc-name, undefined-field

local IAffliction = {}
local ITable = {}
local IItem = {}
local IEnum = {}
local IGame = {}
local ICharacter = {}
local IChat = {}

IEnum.InvSlotType = {
    None = 0,
    Any = 1,
    LeftHand = 4,
    RightHand = 2,
    Head = 8,
    InnerClothes = 16,
    OuterClothes = 32,
    Headset = 64,
    Card = 128,
    Bag = 256,
    HealthInterface = 512,
}

IEnum.Color = {
    Red = Color(255, 0, 0, 255),
    Green = Color(0, 255, 0, 255),
    Blue = Color(0, 0, 255, 255),
    Yellow = Color(255, 255, 0, 255),
    Cyan = Color(0, 255, 255, 255),
    Magenta = Color(255, 0, 255, 255),
    White = Color(255, 255, 255, 255),
    Black = Color(0, 0, 0, 255),
    Orange = Color(255, 165, 0, 255),
    Gray = Color(128, 128, 128, 255),
    LightGray = Color(211, 211, 211, 255),
    DarkGray = Color(64, 64, 64, 255)
}

function IAffliction.HasAffliction(character, affliction)
    local aff = character.CharacterHealth.GetAffliction(affliction)
    return aff ~= nil
end

function IAffliction.GiveAffliction(character, limb, identifier, strength)
    local affPrefab = AfflictionPrefab.Prefabs[identifier]
    if character == nil then return end
    if not limb then
        limb = LimbType.Body
    end
    character.CharacterHealth.ApplyAffliction(limb, affPrefab.Instantiate(strength))
    return true
end

function ITable.IsInTable(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function ITable.RemoveElementByName(array, value)
    for i, v in ipairs(array) do
        if v == value then
            table.remove(array, i)
            break
        end
    end
end

function ITable.ClearTable(array)
    for i = #array, 1, -1 do
        table.remove(array, i)
    end
end

function ICharacter.GetCharacterColor(character)
    if character and character.IsHuman and character.JobIdentifier then
        local prefab = JobPrefab.Get(character.JobIdentifier)
        if prefab and prefab.UIColor then
            return prefab.UIColor
        end
    end
    if character and not character.IsHuman then
        return Color(200, 50, 50)
    end
    return Color.White
end

function ICharacter.FindClientByCharacter(character)
    if not character then return nil end
    for _, client in pairs(Client.ClientList) do
        if client.Character == character then
            return client
        end
    end
    return nil
end

function IChat.Colorize(text, color)
    if not color then return text end
    local r = color.R or 255
    local g = color.G or 255
    local b = color.B or 255
    return string.format("‖color:%d,%d,%d‖%s‖color:end‖", r, g, b, text)
end

function IChat.PrintChat(message, title, color)
    local color = color or IEnum.Color.White
    local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Default, nil)
    chatMessage.Color = color
    Game.ChatBox.AddMessage(chatMessage)
end

function IChat.DMClient(client, title, message, color)
    local color = color or IEnum.Color.White
    if SERVER then
        if client == nil then return end
        title = title or ""
        local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Default, nil)
        chatMessage.Color = color
        Game.SendDirectChatMessage(chatMessage, client)
    else
        IChat.PrintChat(message, title, color)
    end
end

function IChat.SendMessageToAll(messageAuthor, message, color)
    local color = color or IEnum.Color.White
    if SERVER then
        Game.SendMessage(message, ChatMessageType.Server)
    else
        IChat.PrintChat(message, messageAuthor, color)
    end
end

function IChat.SendColoredMessageToAll(title, message, color)
    local chatMsg = ChatMessage.Create(title, message, ChatMessageType.Default, nil)
    chatMsg.Color = color or Color.White

    for _, client in pairs(Client.ClientList) do
        Game.SendDirectChatMessage(chatMsg, client)
    end
end

function IItem.FindItemByIdentifier(character, identifier)
    if not character or not identifier then return nil end
    if not character.Inventory then return nil end
    return character.Inventory.FindItemByIdentifier(identifier, true)
end

function IItem.GetItemInLimbSlot(character, limbSlot)
    if not character or not limbSlot then return nil end
    if not character.Inventory then return nil end
    return character.Inventory.GetItemInLimbSlot(limbSlot)
end

function IItem.HasIdentifierOrTags(item, identifiersOrTags)
    if not item or not identifiersOrTags then return false end
    if type(identifiersOrTags) == "string" then
        return item.HasIdentifierOrTags({ identifiersOrTags })
    end
    return item.HasIdentifierOrTags(identifiersOrTags)
end

function IGame.IsPaused()
    if SERVER then
        return false
    end

    return Game.Paused
end

return {
    IAffliction = IAffliction,
    ITable = ITable,
    IChat = IChat,
    IItem = IItem,
    IEnum = IEnum,
    IGame = IGame,
    ICharacter = ICharacter
}