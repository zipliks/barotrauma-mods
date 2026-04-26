---@diagnostic disable: undefined-global, undefined-field
if CLIENT and Game.IsMultiplayer then return end
Utils = {}

---@param character Barotrauma.Character
---@param affliction string
---@return boolean
function Utils.HasAffliction(character, affliction)
	local aff = character.CharacterHealth.GetAffliction(affliction)
	if aff == nil then
		return false
	end
	return true
end

---@param array table
---@param value any
---@return boolean
function Utils.IsInTable(array, value)
	for _, v in ipairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

---@param array table
---@param value any
function Utils.RemoveElementByName(array, value)
	for i, v in ipairs(array) do
		if v == value then
			table.remove(array, i)
			break
		end
	end
end

---@param message string
---@param title string
---@param color Color
function Utils.PrintChat(message, title, color)
	if SERVER then
		-- use server method
		Game.SendMessage(message, ChatMessageType.Server)
	else
		-- use client method
		local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Server, nil)
		chatMessage.Color = color
		Game.ChatBox.AddMessage(chatMessage)
	end
end

function Utils.ClearTable(array)
	for _, _ in array do
		table.remove(array)
	end
end

---@param client Client
---@param title string
---@param message string
---@param color Color
function Utils.DMClient(client, title, message, color)
	if SERVER then
		if client == nil then return end
		if title == nil then
			title = ""
		end

		local chatMessage = ChatMessage.Create(title, message, ChatMessageType.Server, nil)
		chatMessage.Color = color

		Game.SendDirectChatMessage(chatMessage, client)
	else
		Utils.PrintChat(message, title, color)
	end
end
