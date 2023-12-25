local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 3 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

-- Get ItemID from Inventory Slot
local function getItemID(slot)
	local ItemID = GetInventoryItemID("player", slot)
	return ItemID
end

-- Items
Rotation.Items = {
	inventorySlotGloves = Caffeine.Globals.ItemBook:GetItem(getItemID(10)),
	inventorySlotTrinket0 = Caffeine.Globals.ItemBook:GetItem(getItemID(13)),
	inventorySlotTrinket1 = Caffeine.Globals.ItemBook:GetItem(getItemID(14)),
	potionOfSpeed = Caffeine.Globals.ItemBook:GetItem(40211),
	saroniteBomb = Caffeine.Globals.ItemBook:GetItem(41119),
}
