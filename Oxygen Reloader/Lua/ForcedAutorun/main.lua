if SERVER then return end
require("config")

print(
    "--------\n" ..
    "Running Oxygen Reloader version: " .. Config.VERSION ..
    "\nCurrent reload button is: " .. tostring(Config.BUTTON) ..
    "\n--------"
)

Hook.Add("keyUpdate", "AutoReplaceOxygenTank", function(keyargs)
    if not PlayerInput.KeyDown(Config.BUTTON) or Character.DisableControls then
        return
    end

    local character = Character.Controlled
    if not character or not character.Inventory then
        return
    end

    local suitSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    local headSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

    if suitSlot ~= nil and (suitSlot.HasTag("diving") or suitSlot.HasTag("deepdiving")) then
        ReplaceTank(character, suitSlot)
    elseif headSlot ~= nil and headSlot.HasTag("diving") then
        ReplaceTank(character, headSlot)
    end
end)


-- Used if there is no tank in diving gear
function ReplaceAny(character, gearSlot)
    local variants = CollectAllTanks(character)
    if not variants or #variants == 0 then
        return
    end

    -- Find the best quality
    local max_quality = FindMaxQuality(variants)
    variants = RemoveLowQuality(variants, max_quality)

    local bestTank = FindBiggestCondition(variants)
    gearSlot.OwnInventory.TryPutItem(bestTank, 0, true, false, character)
end

-- Replace for better tank
function ReplaceTank(character, gearSlot)
    local gearTank = gearSlot.OwnInventory.FindItemByTag("oxygensource", true)

    if gearTank == nil then
        ReplaceAny(character, gearSlot)
        return
    elseif gearTank.Condition >= Config.MIN_SWAP_CONDITION then
        return
    end

    local variants = CollectAllTanks(character)
    if not variants or #variants == 0 then
        return
    end

    -- Find the best quality
    local max_quality = FindMaxQuality(variants)
    variants = RemoveLowQuality(variants, max_quality)

    local bestTank = FindBiggestCondition(variants)

    -- This one just to prevent annoying animation as if tank had been swapped but in fact it wasn't
    if bestTank == gearTank then
        return
    end
    gearSlot.OwnInventory.TryPutItem(bestTank, 0, true, false, character)
end