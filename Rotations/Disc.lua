local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 1 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

-- Module
local Module = Caffeine.Module:New("disc")

-- Units
local Player = Caffeine.UnitManager:Get("player")
local Target = Caffeine.UnitManager:Get("target")
local Focus = Caffeine.UnitManager:Get("focus")
local None = Caffeine.UnitManager:Get("none")

-- Spells
local spells = Rotation.Spells

-- items
local items = Rotation.Items

-- APLs
local PreCombatAPL = Caffeine.APL:New("precombat")
local DefaultAPL = Caffeine.APL:New("default")

-- Lowest
local Lowest = Caffeine.UnitManager:CreateCustomUnit("lowest", function(unit)
	local lowest = nil
	local lowestHP = math.huge

	Caffeine.UnitManager:EnumFriends(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 40 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsDead() and Player:CanSee(unit) then
			local hp = unit:GetHP()
			if hp < lowestHP then
				lowest = unit
				lowestHP = hp
			end
		end
	end)

	if lowest == nil then
		lowest = None
	end

	return lowest
end)

-- Tank
local Tank = Caffeine.UnitManager:CreateCustomUnit("tank", function(unit)
	local tank = nil
	local tankHP = math.huge

	Caffeine.UnitManager:EnumFriends(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 40 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsTank() then
			return false
		end

		if unit:IsTank() and Player:CanSee(unit) and not unit:IsDead() then
			local hp = unit:GetHP()
			if hp < tankHP then
				tank = unit
				tankHP = hp
			end
		end
	end)

	if tank == nil then
		tank = None
	end

	return tank
end)

-- PreShield
local PreShield = Caffeine.UnitManager:CreateCustomUnit("preShield", function(unit)
	local preShield = nil

	Caffeine.UnitManager:EnumFriends(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 40 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if unit:GetAuras():FindAny(spells.powerWordShield):IsUp() then
			return false
		end

		if unit:GetAuras():FindAny(spells.weakenedSoul):IsUp() then
			return false
		end

		if unit:IsTank() then
			return false
		end

		if
			not unit:IsDead()
			and Player:CanSee(unit)
			and not unit:IsTank()
			and not unit:GetAuras():FindAny(spells.powerWordShield):IsUp()
			and not unit:GetAuras():FindAny(spells.weakenedSoul):IsUp()
		then
			preShield = unit
		end
	end)

	if preShield == nil then
		preShield = None
	end

	return preShield
end)

-- Dispel
local Dispel = Caffeine.UnitManager:CreateCustomUnit("dispel", function(unit)
	local dispel = nil
	local dispelHP = math.huge

	Caffeine.UnitManager:EnumFriends(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 40 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if
			not unit:IsDead()
			and Player:CanSee(unit)
			and (unit:GetAuras():HasAnyDispelableAura(spells.dispelMagic) or unit:GetAuras():HasAnyDispelableAura(spells.cureDisease))
		then
			local hp = unit:GetHP()
			if hp < dispelHP then
				dispel = unit
				dispelHP = hp
			end
		end
	end)

	if dispel == nil then
		dispel = None
	end

	return dispel
end)

-- DungeonLogic
local DungeonLogic = Caffeine.UnitManager:CreateCustomUnit("dungeonLogic", function(unit)
	local dungeonLogic = nil

	Caffeine.UnitManager:EnumUnits(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 40 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsEnemy() then
			return false
		end

		if not unit:IsHostile() then
			return false
		end

		if not Player:IsFacing(unit) then
			return false
		end

		if not unit:GetID() == 28619 or not unit:GetName() == "Mirror Image" then
			return false
		end

		if Player:CanSee(unit) and Player:IsFacing(unit) and (unit:GetID() == 28619 or unit:GetName() == "Mirror Image") then
			dungeonLogic = unit
		end
	end)

	if dungeonLogic == nil then
		dungeonLogic = None
	end

	return dungeonLogic
end)

-- Inner Fire
PreCombatAPL:AddSpell(spells.innerFire
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and not Player:GetAuras():FindMy(spells.innerFire):IsUp() and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- Healthstone
DefaultAPL:AddItem(items.healthstone1
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None))

DefaultAPL:AddItem(items.healthstone2
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None))

DefaultAPL:AddItem(items.healthstone3
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None))

-- DungeonLogic: Web Wrap & Mirror Image
DefaultAPL:AddSpell(spells.holyFire
	:CastableIf(function(self)
		local useDungeonLogic = Rotation.Config:Read("toggles_dungeonLogic", true)
		return self:IsKnownAndUsable() and DungeonLogic:Exists() and useDungeonLogic and Player:IsFacing(DungeonLogic) and not Player:IsMoving()
	end)
	:SetTarget(DungeonLogic))

-- DungeonLogic: Web Wrap & Mirror Image
DefaultAPL:AddSpell(spells.mindBlast
	:CastableIf(function(self)
		local useDungeonLogic = Rotation.Config:Read("toggles_dungeonLogic", true)
		return self:IsKnownAndUsable() and DungeonLogic:Exists() and useDungeonLogic and Player:IsFacing(DungeonLogic) and not Player:IsMoving()
	end)
	:SetTarget(DungeonLogic))

-- Beserking
DefaultAPL:AddSpell(spells.beserking
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and Target:Exists() and Target:IsHostile() and Target:CustomIsBoss() and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Engineering Gloves
DefaultAPL:AddItem(items.inventorySlotGloves
	:UsableIf(function(self)
		local useEngineeringGloves = Rotation.Config:Read("items_engineeringGloves", true)
		return self:IsUsable()
			and Target:Exists()
			and useEngineeringGloves
			and Target:CustomIsBoss()
			and Target:IsHostile()
			and not self:IsOnCooldown()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Saronite Bomb
DefaultAPL:AddItem(items.saroniteBomb
	:UsableIf(function(self)
		local useSaroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
		return self:IsUsable()
			and Target:Exists()
			and useSaroniteBomb
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Player:GetDistance(Target) <= 29
			and not self:IsOnCooldown()
			and not Target:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnUse(function(self)
		local targetPosition = Target:GetPosition()
		self:Click(targetPosition)
	end))

-- Shadowfiend
DefaultAPL:AddSpell(spells.shadowfiend
	:CastableIf(function(self)
		local shadowfiendMP = Rotation.Config:Read("spells_shadowfiend", 40)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Target:CustomIsBoss()
			and Player:GetPP() < shadowfiendMP
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Pain Supression
DefaultAPL:AddSpell(spells.painSupression
	:CastableIf(function(self)
		local painSupressionHP = Rotation.Config:Read("spells_painSupression", 40)
		return self:IsKnownAndUsable() and Tank:Exists() and Tank:GetHP() < painSupressionHP and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Tank))

-- Desprate Prayer
DefaultAPL:AddSpell(spells.despratePrayer
	:CastableIf(function(self)
		local despratePrayerHP = Rotation.Config:Read("spells_desperatePrayer", 40)
		return self:IsKnownAndUsable() and Player:GetHP() < despratePrayerHP and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Power Word: Shield (Tank - Safe)
DefaultAPL:AddSpell(spells.powerWordShield
	:CastableIf(function(self)
		local shieldTankSafeHP = Rotation.Config:Read("spells_powerWordShieldTankSafe", 40)
		return not self:OnCooldown()
			and Tank:Exists()
			and Tank:GetHP() < shieldTankSafeHP
			and not Tank:GetAuras():FindAny(spells.powerWordShield):IsUp()
			and not Tank:GetAuras():FindAny(spells.weakenedSoul):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Tank))

-- Prayer of Mending (Tank)
DefaultAPL:AddSpell(spells.prayerOfMending
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Tank:Exists()
			and not Tank:GetAuras():FindMy(spells.prayerOfMendingAura):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Tank))

-- Penance (Tank)
DefaultAPL:AddSpell(spells.penance
	:CastableIf(function(self)
		local penanceTankHP = Rotation.Config:Read("spells_penanceTank", 80)
		return self:IsKnownAndUsable() and Tank:Exists() and Tank:GetHP() < penanceTankHP and not Player:IsMoving() and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Tank))

-- Power Word: Shield (Safe)
DefaultAPL:AddSpell(spells.powerWordShield
	:CastableIf(function(self)
		local shieldSafeHP = Rotation.Config:Read("spells_powerWordShieldSafe", 60)
		return not self:OnCooldown()
			and Lowest:Exists()
			and Lowest:GetHP() < shieldSafeHP
			and not Lowest:GetAuras():FindAny(spells.powerWordShield):IsUp()
			and not Lowest:GetAuras():FindAny(spells.weakenedSoul):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Lowest))

-- Penance
DefaultAPL:AddSpell(spells.penance
	:CastableIf(function(self)
		local penanceHP = Rotation.Config:Read("spells_penance", 80)
		return self:IsKnownAndUsable() and Lowest:Exists() and Lowest:GetHP() < penanceHP and not Player:IsMoving() and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Lowest))

-- Dispel Magic
DefaultAPL:AddSpell(spells.dispelMagic
	:CastableIf(function(self)
		local useDispel = Rotation.Config:Read("dispel", true)
		return self:IsKnownAndUsable()
			and Dispel:Exists()
			and useDispel
			and Dispel:GetAuras():HasAnyDispelableAura(spells.dispelMagic)
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Dispel))

-- Cure Disease
DefaultAPL:AddSpell(spells.cureDisease
	:CastableIf(function(self)
		local useDispel = Rotation.Config:Read("dispel", true)
		return self:IsKnownAndUsable()
			and Dispel:Exists()
			and useDispel
			and Dispel:GetAuras():HasAnyDispelableAura(spells.cureDisease)
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Dispel))

-- Power Infusion
DefaultAPL:AddSpell(spells.powerInfusion
	:CastableIf(function(self)
		local usePowerInfusion = Rotation.Config:Read("spells_powerInfusion", true)
		return self:IsKnownAndUsable()
			and Focus:Exists()
			and usePowerInfusion
			and Focus:IsAffectingCombat()
			and Target:CustomIsBoss()
			and not Focus:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Focus))

-- Binding Heal
DefaultAPL:AddSpell(spells.bindingHeal
	:CastableIf(function(self)
		local bindingHealHP = Rotation.Config:Read("spells_bindingHeal", 60)
		return self:IsKnownAndUsable()
			and Lowest:Exists()
			and Lowest:GetHP() < bindingHealHP
			and Player:GetHP() < bindingHealHP
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Lowest))

-- Flash Heal
DefaultAPL:AddSpell(spells.flashHeal
	:CastableIf(function(self)
		local isFlashHealEnabled = Rotation.Config:Read("flashHeal", true)
		return self:IsKnownAndUsable()
			and Lowest:Exists()
			and isFlashHealEnabled
			and Lowest:GetHP() < Rotation.Config:Read("spells_flashHeal", 80)
			and spells.penance:OnCooldown()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Lowest))

-- Power Word: Shield (Pre-Shield)
DefaultAPL:AddSpell(spells.powerWordShield
	:CastableIf(function(self)
		local isPreShieldEnabled = Rotation.Config:Read("preShield", true)
		return not self:OnCooldown()
			and PreShield:Exists()
			and isPreShieldEnabled
			and not Player:IsCastingOrChanneling()
			and not PreShield:GetAuras():FindAny(spells.powerWordShield):IsUp()
			and not PreShield:GetAuras():FindAny(spells.weakenedSoul):IsUp()
	end)
	:SetTarget(PreShield))

-- Sync
Module:Sync(function()
	if
		Player:IsDead()
		or IsMounted()
		or UnitInVehicle("player")
		or Player:IsCastingOrChanneling()
		or Player:GetAuras():FindAnyOfMy(spells.refreshmentAuras):IsUp()
	then
		return false
	end

	-- PreCombatAPL
	PreCombatAPL:Execute()

	local isOutOfCombatEnabled = Rotation.Config:Read("outOfCombat", true)
	if isOutOfCombatEnabled or Player:IsAffectingCombat() or Target:IsAffectingCombat() then
		-- DefaultAPL
		DefaultAPL:Execute()
	end
end)

-- Register
Caffeine:Register(Module)
