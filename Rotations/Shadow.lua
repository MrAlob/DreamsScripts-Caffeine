local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 3 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

-- Module
local Module = Caffeine.Module:New("shadow")

-- Units
local Player = Caffeine.UnitManager:Get("player")
local Target = Caffeine.UnitManager:Get("target")
local None = Caffeine.UnitManager:Get("none")

-- Spells
local spells = Rotation.Spells

-- items
local items = Rotation.Items

-- APLs
local PreCombatAPL = Caffeine.APL:New("precombat")
local DefaultAPL = Caffeine.APL:New("default")

local blacklistUnitById = {
	[37695] = true, -- Drudge Ghoul: 37695
	[37698] = true, -- Shambling Horror: 37698
	[28926] = true, -- Spark of lonar: 28926
	[28584] = true, -- Unbound Firestorm: 28584
	[27737] = true, -- Risen Zombie: 27737
	[27651] = true, -- Phtasmal Fire: 27651
	[37232] = true, -- Nerub'ar Broodling
	[37799] = true, -- Vile Spirit: 37799
	[38104] = true, -- Plagued Zombie: 38104
	[37907] = true, -- Rot Worm: 37907
	[36633] = true, -- Ice Sphere: 36734
	[39190] = true, -- Wicked Spirit: 39190
}

local HighestEnemy = Caffeine.UnitManager:CreateCustomUnit("highest", function(unit)
	local highest = nil
	local highestHP = 0

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 41 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsAffectingCombat() then
			return false
		end

		if not unit:IsEnemy() then
			return false
		end

		if not unit:IsHostile() then
			return false
		end

		if blacklistUnitById[unit:GetID()] then
			return false
		end

		local hp = unit:GetHP()
		if hp > highestHP then -- Change this line to check for higher HP
			highest = unit
			highestHP = hp
		end
	end)

	if not highest then
		highest = None
	end

	return highest
end)

local DungeonLogic = Caffeine.UnitManager:CreateCustomUnit("dungeonLogic", function(unit)
	local dungeonLogic = nil

	Caffeine.UnitManager:EnumUnits(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 36 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsEnemy() then
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

local ShadowWordPainRefresh = Caffeine.UnitManager:CreateCustomUnit("shadowWordPainRefresh", function(unit)
	local shadowWordPainRefresh = nil

	Caffeine.UnitManager:EnumUnits(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 36 then
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

		if not unit:CustomIsBoss() then
			return false
		end

		if not unit:GetAuras():FindMy(spells.shadowWordPain):IsUp() then
			return false
		end

		if Player:CanSee(unit) and Player:IsFacing(unit) and unit:GetAuras():FindMy(spells.shadowWordPain):GetRemainingTime() < 4 then
			shadowWordPainRefresh = unit
		end
	end)

	if shadowWordPainRefresh == nil then
		shadowWordPainRefresh = None
	end

	return shadowWordPainRefresh
end)

local VampireTouchTarget = Caffeine.UnitManager:CreateCustomUnit("vampireTouch", function(unit)
	local vampiricTouch = nil

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 36 then
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

		if unit:CustomTimeToDie() < 10 then
			return false
		end

		if blacklistUnitById[unit:GetID()] then
			return false
		end

		if unit:GetAuras():FindAny(spells.shroudOfTheOccult):IsUp() or unit:GetAuras():FindAny(spells.shroudOfSpellWarding):IsUp() then
			return false
		end

		if unit:IsCreatureType("Critter") then
			return false
		end

		if unit:GetAuras():FindMy(spells.vampiricTouch):IsUp() then
			return false
		end

		if unit:GetID() == 36609 and unit:GetHP() < 99 then
			return false
		end

		if not unit:IsDead() and unit:IsEnemy() and Player:CanSee(unit) and not unit:GetAuras():FindMy(spells.vampiricTouch):IsUp() then
			vampiricTouch = unit
		end
	end)

	if vampiricTouch == nil then
		vampiricTouch = None
	end

	return vampiricTouch
end)

local ShadowWordPainTarget = Caffeine.UnitManager:CreateCustomUnit("shadowWordPain", function(unit)
	local shadowWordPain = nil

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 36 then
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

		if unit:CustomTimeToDie() < 10 then
			return false
		end

		if blacklistUnitById[unit:GetID()] then
			return false
		end

		if unit:GetAuras():FindAny(spells.shroudOfTheOccult):IsUp() or unit:GetAuras():FindAny(spells.shroudOfSpellWarding):IsUp() then
			return false
		end

		if unit:IsCreatureType("Critter") then
			return false
		end

		if unit:GetAuras():FindMy(spells.shadowWordPain):IsUp() then
			return false
		end

		if unit:GetID() == 36609 and unit:GetHP() < 99 then
			return false
		end

		if
			not unit:IsDead()
			and Player:CanSee(unit)
			and unit:IsEnemy()
			and not unit:GetAuras():FindMy(spells.shadowWordPain):IsUp()
			and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
		then
			shadowWordPain = unit
		end
	end)

	if shadowWordPain == nil then
		shadowWordPain = None
	end

	return shadowWordPain
end)

function GetEnemiesWithVampiricTouch(range)
	local count = 0
	Caffeine.UnitManager:EnumEnemies(function(unit)
		if
			not Target:IsUnit(unit)
			and Target:IsWithinCombatDistance(unit, range)
			and unit:IsAlive()
			and Target:CanSee(unit)
			and unit:IsEnemy()
			and unit:GetAuras():FindMy(spells.vampiricTouch):IsUp()
		then
			count = count + 1
		end
	end)
	return count
end

local wasCasting = {}
function WasCastingCheck()
	local time = GetTime()
	if Player:IsCasting() then
		wasCasting[Player:GetCastingOrChannelingSpell()] = time
	end
	for spell, when in pairs(wasCasting) do
		if time - when > 0.100 + 0.1 then
			wasCasting[spell] = nil
		end
	end
end

local function BossBehaviors()
	-- Festergut (36626)
	if Target:GetID() == 36626 then
		-- Stop Casting if Pungent Blight is being casted
		if Target:GetCastingOrChannelingSpell() == spells.pungentBlight then
			SpellStopCasting()
		end

		-- Canceling Dispersion and target not casting Pungent Blight
		if Player:GetAuras():FindAny(spells.dispersion):IsUp() and not Target:GetCastingOrChannelingSpell() == spells.pungentBlight then
			local i = 1
			repeat
				local name = UnitBuff("player", i)
				if name == "Dispersion" then
					CancelUnitBuff("player", i)
					break
				end
				i = i + 1
			until not name
		end
	end

	-- Sindragosa (36853)
	if Target:GetID() == 36853 then
		if spells.dispersion:OnCooldown() then
			return false
		end
		-- Stop Casting if we have more than 8 stacks of Instability and less than 2 seconds remaining
		if
			Player:GetAuras():FindAny(spells.instabilityAura):GetRemainingTime() <= 2.0
			and Player:GetAuras():FindAny(spells.instabilityAura):GetCount() >= 8
		then
			SpellStopCasting()
		end
	end

	return false
end

-- Shadowform
PreCombatAPL:AddSpell(spells.shadowform
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and not Player:GetAuras():FindMy(spells.shadowform):IsUp() and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- Inner Fire
PreCombatAPL:AddSpell(spells.innerFire
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and not Player:GetAuras():FindMy(spells.innerFire):IsUp() and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- Vampire Embrace
PreCombatAPL:AddSpell(spells.vampiricEmbrace
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and not Player:GetAuras():FindMy(spells.vampiricEmbrace):IsUp() and not Player:IsCastingOrChanneling()
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
	end)
	:SetTarget(None))

DefaultAPL:AddItem(items.healthstone2
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

DefaultAPL:AddItem(items.healthstone3
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- DungeonLogic: Web Wrap and Mirror Images
DefaultAPL:AddSpell(spells.mindFlay
	:CastableIf(function(self)
		return DungeonLogic:Exists() and self:IsKnownAndUsable() and self:IsInRange(DungeonLogic) and Player:IsFacing(DungeonLogic) and not Player:IsMoving()
	end)
	:SetTarget(DungeonLogic))

-- Mind Flay
DefaultAPL:AddSpell(spells.mindFlay
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(ShadowWordPainRefresh)
			and ShadowWordPainRefresh:Exists()
			and ShadowWordPainRefresh:GetAuras():FindMy(spells.shadowWordPain):GetRemainingTime() <= 4.0
			and Player:IsFacing(ShadowWordPainRefresh)
			and not Player:IsMoving()
	end)
	:SetTarget(ShadowWordPainRefresh))

-- Dispersion - Fetsergut
DefaultAPL:AddSpell(spells.dispersion
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and Target:GetID() == 36626 and Target:Exists() and Target:GetCastingOrChannelingSpell() == spells.pungentBlight
	end)
	:SetTarget(Player)
	:OnCast(function(self)
		Caffeine.Notifications:AddNotification(spells.dispersion:GetIcon(), "Dispersion (Pungent Blight)")
	end))

-- Dispersion - Sindragosa
DefaultAPL:AddSpell(spells.dispersion
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:GetID() == 36853
			and Player:GetAuras():FindAny(spells.instabilityAura):GetRemainingTime() <= 2.0
			and Player:GetAuras():FindAny(spells.instabilityAura):GetCount() >= 8
	end)
	:SetTarget(Player)
	:OnCast(function(self)
		Caffeine.Notifications:AddNotification(spells.dispersion:GetIcon(), "Dispersion (Instability)")
	end))

-- Mind Sear (AoE)
DefaultAPL:AddSpell(spells.mindSear
	:CastableIf(function(self)
		local isAoeEnabled = Rotation.Config:Read("aoe", true)
		return isAoeEnabled
			and self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Target:GetEnemies(12) >= 8
			and Player:CanSee(Target)
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Mind Sear (AoE)
DefaultAPL:AddSpell(spells.mindSear
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and GetEnemiesWithVampiricTouch(12) >= 4
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Vampiric Touch (AoE)
DefaultAPL:AddSpell(spells.vampiricTouch
	:CastableIf(function(self)
		local isAoeEnabled = Rotation.Config:Read("aoe", true)
		return self:IsKnownAndUsable()
			and isAoeEnabled
			and VampireTouchTarget:Exists()
			and VampireTouchTarget:CustomTimeToDie() > 10
			and (VampireTouchTarget:GetAuras():FindMy(spells.vampiricTouch):GetRemainingTime() < spells.vampiricTouch:GetCastLength() / 1000 or not VampireTouchTarget
				:GetAuras()
				:FindMy(spells.vampiricTouch)
				:IsUp())
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(VampireTouchTarget))

-- Engineering Gloves
DefaultAPL:AddItem(items.inventorySlotGloves
	:UsableIf(function(self)
		local useEngineeringGloves = Rotation.Config:Read("items_engineeringGloves", true)
		return useEngineeringGloves
			and self:IsUsable()
			and not self:IsOnCooldown()
			and Target:Exists()
			and Target:CustomIsBoss()
			and Target:IsHostile()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Beserking
DefaultAPL:AddSpell(spells.beserking
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Vampiric Touch
DefaultAPL:AddSpell(spells.vampiricTouch
	:CastableIf(function(self)
		if wasCasting[spells.vampiricTouch] then
			return false
		end
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomTimeToDie() > 10
			and (Target:GetAuras():FindMy(spells.vampiricTouch):GetRemainingTime() < spells.vampiricTouch:GetCastLength() / 1000 or not Target:GetAuras()
				:FindMy(spells.vampiricTouch)
				:IsUp())
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Shadowfiend
DefaultAPL:AddSpell(spells.shadowfiend
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Saronite Bomb
DefaultAPL:AddItem(items.saroniteBomb
	:UsableIf(function(self)
		local useSaroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and useSaroniteBomb
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Player:GetDistance(Target) <= 29
			and not Target:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnUse(function(self)
		local targetPosition = Target:GetPosition()
		self:Click(targetPosition)
	end))

-- Devouring Plague
DefaultAPL:AddSpell(spells.devouringPlague
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomTimeToDie() > 10
			and (Target:GetAuras():FindMy(spells.devouringPlague):GetRemainingTime() < 1.75 or not Target:GetAuras():FindMy(spells.devouringPlague):IsUp())
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Shadow Word: Pain
DefaultAPL:AddSpell(spells.shadowWordPain
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomTimeToDie() > 10
			and not Target:GetAuras():FindMy(spells.shadowWordPain):IsUp()
			and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Shadow Word: Pain (AoE)
DefaultAPL:AddSpell(spells.shadowWordPain
	:CastableIf(function(self)
		local useAoe = Rotation.Config:Read("aoe", true)
		local useShadowWordPain = Rotation.Config:Read("spells_shadowWordPain", true)
		return useAoe
			and useShadowWordPain
			and self:IsKnownAndUsable()
			and self:IsInRange(ShadowWordPainTarget)
			and ShadowWordPainTarget:Exists()
			and ShadowWordPainTarget:CustomTimeToDie() > 10
			and not ShadowWordPainTarget:GetAuras():FindMy(spells.shadowWordPain):IsUp()
			and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(ShadowWordPainTarget))

-- Shadow Word: Death
DefaultAPL:AddSpell(spells.shadowWordDeath
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:GetHP() > 60
			and Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Mind Blast
DefaultAPL:AddSpell(spells.mindBlast
	:CastableIf(function(self)
		local useMindBlast = Rotation.Config:Read("spells_mindBlast", true)
		return useMindBlast
			and self:IsInRange(Target)
			and self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Mind Flay
DefaultAPL:AddSpell(spells.mindFlay
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:IsHostile()
			and Target:Exists()
			and Player:CanSee(Target)
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
	:PreCast(function()
		if spells.innerFocus:IsKnownAndUsable() and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5 and Target:CustomIsBoss() then
			spells.innerFocus:ForceCast(None)
		end
	end))

-- Sync
Module:Sync(function()
	if Player:IsDead() or IsMounted() or UnitInVehicle("player") or Player:GetAuras():FindAnyOfMy(spells.refreshmentAuras):IsUp() then
		return false
	end

	-- Auto Target
	local isAutoTargetEnabled = Rotation.Config:Read("autoTarget", true)
	if isAutoTargetEnabled and (not Target:Exists() or Target:IsDead()) then
		TargetUnit(HighestEnemy:GetGUID())
	end

	-- Boss Behaviors
	BossBehaviors()

	-- PreCombatAPL
	PreCombatAPL:Execute()

	if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
		WasCastingCheck()
		-- DefaultAPL
		DefaultAPL:Execute()
	end
end)

-- Register
Caffeine:Register(Module)
