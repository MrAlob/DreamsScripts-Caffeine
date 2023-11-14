local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 1 then
    return
end

local ItemBook = Caffeine.Globals.ItemBook

-- Get ItemID from Inventory Slot
local function getItemID(slot)
    ItemID = GetInventoryItemID("player", slot)
    return ItemID
end

-- Items 
Rotation.Items = {
    inventorySlotGloves = ItemBook:GetItem(getItemID(10)),
    inventorySlotTrinket0 = ItemBook:GetItem(getItemID(13)),
    inventorySlotTrinket1 = ItemBook:GetItem(getItemID(14)),
    potionOfSpeed = ItemBook:GetItem(40211),
    runicManaPotion = ItemBook:GetItem(33448),
    manaInjector = ItemBook:GetItem(42545),
    saroniteBomb = ItemBook:GetItem(41119)
}
