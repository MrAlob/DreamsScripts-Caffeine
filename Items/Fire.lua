local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 2 then
	return
end

if Caffeine.GetClass() ~= "MAGE" then
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
	invetorySlotBoots = Caffeine.Globals.ItemBook:GetItem(getItemID(8)),
	manaGem = Caffeine.Globals.ItemBook:GetItem(33312),
	saroniteBomb = Caffeine.Globals.ItemBook:GetItem(41119),
	shardIfTheCrystalHeart = Caffeine.Globals.ItemBook:GetItem(48722),
}
