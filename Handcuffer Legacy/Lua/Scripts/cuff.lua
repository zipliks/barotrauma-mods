if CLIENT then
    local function canHandcuff(character)
        if character.IsUnconscious
            or character.Stun > 0.0
            or character.IsIncapacitated
            or character.IsRagdolled
            or character.LockHands
            or Character.DisableControls
        then
            return false
        end
        return true
    end

    local function canBeHandcuffed(target)
        if target.IsUnconscious
            or target.Stun > 0.0
            or target.IsRagdolled
            or target.IsBot
        then
            return true
        end
        return false
    end

    function Handcuffer.TargetHandler()
        -- Drop target's item to handcuff humans who hold item with both hands
        local target = Character.Controlled.SelectedCharacter
        local rightHand = target.Inventory.GetItemInLimbSlot(InvSlotType.RightHand)
        local leftHand = target.Inventory.GetItemInLimbSlot(InvSlotType.LeftHand)

        if not canBeHandcuffed(target) then
            return
        end

        if not rightHand and not leftHand then return end
        if rightHand.HasIdentifierOrTags({ "handcuffs", "handlocker" }) then return end
        if rightHand then
            rightHand.Drop(Character.Controlled)
        end
        if leftHand then
            leftHand.Drop(Character.Controlled)
        end
    end

    Hook.Add("keyUpdate", "cuffhotkey", function(keyargs)
        if not PlayerInput.KeyDown(Handcuffer.Key) then
            return
        end
        if Character.Controlled == nil or Character.Controlled.SelectedCharacter == nil then
            return
        end
        if not canHandcuff(Character.Controlled) then
            return
        end

        local cuffs = Character.Controlled.Inventory.FindItemByTag("handlocker", true)
        local handindex = Character.Controlled.SelectedCharacter.Inventory.FindLimbSlot(InvSlotType.RightHand)

        if cuffs then
            Handcuffer.TargetHandler()
            Character.Controlled.SelectedCharacter.Inventory.TryPutItem(cuffs, handindex, true, true,
                Character.Controlled, true, true)
        else
            local targetCuffs = Character.Controlled.SelectedCharacter.Inventory.FindItemByTag("handlocker", true)
            if not targetCuffs then
                return
            end
            Handcuffer.TargetHandler()
            Character.Controlled.SelectedCharacter.Inventory.TryPutItem(targetCuffs, handindex, true, true, Character.Controlled, true, true)
        end
    end)
end
