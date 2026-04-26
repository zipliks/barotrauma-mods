function FindBiggestCondition(items)
    local max_ratio = items[1].Condition / items[1].MaxCondition
    local max_item = items[1]

    for i = 2, #items do
        local current_ratio = items[i].Condition / items[i].MaxCondition
        if (current_ratio > max_ratio) and (current_ratio ~= 0) and (items[i].Condition >= Config.MIN_SUITABLE_CONDITION) then
            max_ratio = current_ratio
            max_item = items[i]
        end
    end

    return max_item
end

function FindMaxQuality(tbl)
    local max_quality = 0
    for _, item in ipairs(tbl) do
        if (item.Quality > max_quality) and (item.Condition / item.MaxCondition ~= 0) then
            max_quality = item.Quality
        end
    end

    return max_quality
end

function RemoveLowQuality(variants, max_quality)
    -- Remove all tanks of lower quality
    local i = 1
    while i <= #variants do
        if variants[i].Quality < max_quality then
            table.remove(variants, i)
        else
            i = i + 1
        end
    end
    return variants
end

-- Searches for oxygen source recursively. If item has its own inventory - it will be searched.
function FindRecursively(container, iter, tbl)
    if container.OwnInventory == nil then
        return
    end
    for item in container.OwnInventory.AllItems do
        if item.OwnInventory ~= nil then
            FindRecursively(item, iter, tbl)
        end
        if item.HasTag("oxygensource") then
            table.insert(tbl, iter, item)
            iter = iter + 1
        end
    end
end

function CollectAllTanks(character)
    local variants = {}
    local iter = 1

    -- Collect all tanks from player's inventory
    for item in character.Inventory.AllItems do
        if item.HasTag("oxygensource") then
            table.insert(variants, iter, item)
            iter = iter + 1
        end
        if item.OwnInventory ~= nil then
            FindRecursively(item, iter, variants)
        end
    end

    -- Add opened container such as locker
    local openedContainer = character.SelectedItem
    if openedContainer ~= nil then
        FindRecursively(openedContainer, iter, variants)
    end

    return variants
end
