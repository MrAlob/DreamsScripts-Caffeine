local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 2 then
    return
end

if Rotation.GetClass() ~= "MAGE" then
    return
end

-- Get ItemID from Inventory Slot
local function getItemID(slot)
    ItemID = GetInventoryItemID("player", slot)
    return ItemID
end

-- Items 
Rotation.Items = {
    inventorySlotGloves = Caffeine.Globals.ItemBook:GetItem(getItemID(10)),
    manaGem = Caffeine.Globals.ItemBook:GetItem(33312),
    saroniteBomb = Caffeine.Globals.ItemBook:GetItem(41119)
}
