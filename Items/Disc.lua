local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 1 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

local ItemBook = Caffeine.Globals.ItemBook

-- Get ItemID from Inventory Slot 
local function getItemID(slot)
	local ItemID = GetInventoryItemID("player", slot)
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
	saroniteBomb = ItemBook:GetItem(41119),
	healthstone1 = ItemBook:GetItem(36892),
	healthstone2 = ItemBook:GetItem(36893),
	healthstone3 = ItemBook:GetItem(36894),
}
