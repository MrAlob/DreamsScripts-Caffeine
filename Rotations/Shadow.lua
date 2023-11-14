local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 3 then
    return
end

-- Module
local Module = Caffeine.Module:New('shadow')

-- Units
local Player = Caffeine.UnitManager:Get('player')
local Target = Caffeine.UnitManager:Get('target')
local None = Caffeine.UnitManager:Get('none')

-- Spells
local spells = Rotation.Spells

-- items
local items = Rotation.Items

-- APLs
local PreCombatAPL = Caffeine.APL:New('precombat')
local DefaultAPL = Caffeine.APL:New('default')

local LowestEnemy = Caffeine.UnitManager:CreateCustomUnit('lowest', function(unit)
    local lowest = nil
    local lowestHP = math.huge

    Caffeine.UnitManager:EnumEnemies(function(unit)
        if unit:IsDead() then
            return
        end

        if Player:GetDistance(unit) > 36 then
            return
        end

        if not Player:CanSee(unit) then
            return
        end

        if not unit:IsAffectingCombat() then
            return
        end

        if not unit:IsHostile() then
            return
        end

        local hp = unit:GetHP()
        if hp < lowestHP then
            lowest = unit
            lowestHP = hp
        end
    end)

    if not lowest then
        lowest = None
    end

    return lowest
end)

local DungeonLogicTarget = Caffeine.UnitManager:CreateCustomUnit('dungeonLogic', function(unit)
    local dungeonLogic = nil

    Caffeine.UnitManager:EnumUnits(function(unit)
        if unit:IsDead() then
            return
        end

        if Player:GetDistance(unit) > 36 then
            return
        end

        if not unit:GetID() == 28619 or not unit:GetName() == "Mirror Image" then
            return
        end

        if unit:GetID() == 28619 or unit:GetName() == "Mirror Image" then
            dungeonLogic = unit
        end
    end)

    if dungeonLogic == nil then
        dungeonLogic = None
    end

    return dungeonLogic
end)

local VampireTouchTarget = Caffeine.UnitManager:CreateCustomUnit('vampireTouch', function(unit)
    local vampiricTouch = nil

    Caffeine.UnitManager:EnumEnemies(function(unit)
        if unit:IsDead() then
            return
        end

        if Player:GetDistance(unit) > 36 then
            return
        end

        if not Player:CanSee(unit) then
            return
        end

        if not unit:IsAffectingCombat() then
            return
        end

        if not unit:IsHostile() then
            return
        end

        if not unit:IsDead()
            and Player:CanSee(unit)
            and not unit:GetAuras():FindMy(spells.vampiricTouch):IsUp() then
            vampiricTouch = unit
        end
    end)

    if vampiricTouch == nil then
        vampiricTouch = None
    end

    return vampiricTouch
end)

local ShadowWordPainTarget = Caffeine.UnitManager:CreateCustomUnit('shadowWordPain', function(unit)
    local shadowWordPain = nil

    Caffeine.UnitManager:EnumEnemies(function(unit)
        if unit:IsDead() then
            return
        end

        if Player:GetDistance(unit) > 36 then
            return
        end

        if not Player:CanSee(unit) then
            return
        end

        if not unit:IsAffectingCombat() then
            return
        end

        if not unit:IsHostile() then
            return
        end

        if not unit:IsDead()
            and Player:CanSee(unit)
            and not unit:GetAuras():FindMy(spells.shadowWordPain):IsUp()
            and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5 then
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
        if not Target:IsUnit(unit) and Target:IsWithinCombatDistance(unit, range) and unit:IsAlive() and Target:CanSee(unit) and
            unit:IsEnemy() and unit:GetAuras():FindMy(spells.vampiricTouch):IsUp() then
            count = count + 1
        end
    end)
    return count
end

function Caffeine.Unit:IsDungeonBoss()
    if UnitClassification(self:GetOMToken()) == "elite"
        and UnitLevel(self:GetOMToken()) == 82
        and Player:GetAuras():FindMy(spells.luckoftheDraw):IsUp() then
        return true
    end
    return false
end

-- PreCombatAPL
PreCombatAPL:AddSpell(
    spells.shadowform:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.shadowform):IsUp()
    end):SetTarget(Player)
)

PreCombatAPL:AddSpell(
    spells.innerFire:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.innerFire):IsUp()
    end):SetTarget(Player)
)

PreCombatAPL:AddSpell(
    spells.vampiricEmbrace:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.vampiricEmbrace):IsUp()
    end):SetTarget(Player)
)

-- Mind Flay (Web Wrap)
DefaultAPL:AddSpell(
    spells.devouringPlague:CastableIf(function(self)
        return DungeonLogicTarget:Exists()
    end):SetTarget(DungeonLogicTarget)
)

-- Mind Sear (AoE)
DefaultAPL:AddSpell(
    spells.mindSear:CastableIf(function(self)
        local isAoeEnabled = Rotation.Config:Read("toggleAoe", true)
        return isAoeEnabled
            and self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and Target:GetEnemies(12) >= 7
    end):SetTarget(Target)
)

-- Mind Sear (AoE)
DefaultAPL:AddSpell(
    spells.mindSear:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and GetEnemiesWithVampiricTouch(12) >= 3
    end):SetTarget(Target)
)

-- Vampiric Touch (AoE)
DefaultAPL:AddSpell(
    spells.vampiricTouch:CastableIf(function(self)
        local isAoeEnabled = Rotation.Config:Read("toggleAoe", true)
        return isAoeEnabled
            and self:IsKnownAndUsable()
            and VampireTouchTarget:Exists()
            and VampireTouchTarget:IsHostile()
            and
            (VampireTouchTarget:GetAuras():FindMy(spells.vampiricTouch):GetRemainingTime() < spells.vampiricTouch:GetCastLength() / 1000
                or not VampireTouchTarget:GetAuras():FindMy(spells.vampiricTouch):IsUp())
    end):SetTarget(VampireTouchTarget)
)

-- Shadow Word: Pain (AoE)
DefaultAPL:AddSpell(
    spells.shadowWordPain:CastableIf(function(self)
        local isAoeEnabled = Rotation.Config:Read("toggleAoe", true)
        return isAoeEnabled
            and self:IsKnownAndUsable()
            and ShadowWordPainTarget:Exists()
            and ShadowWordPainTarget:IsHostile()
            and not ShadowWordPainTarget:GetAuras():FindMy(spells.shadowWordPain):IsUp()
            and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
    end):SetTarget(ShadowWordPainTarget)
)

-- Engineering Gloves
DefaultAPL:AddItem(
    items.inventorySlotGloves:UsableIf(function(self)
        return self:IsEquippedAndUsable()
            and Target:Exists()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and Target:IsHostile()
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Vampiric Touch
DefaultAPL:AddSpell(
    spells.vampiricTouch:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:GetAuras():FindMy(spells.vampiricTouch):GetRemainingTime() < spells.vampiricTouch:GetCastLength() / 1000
                or not Target:GetAuras():FindMy(spells.vampiricTouch):IsUp())
    end):SetTarget(Target)
)

-- Shadowfiend
DefaultAPL:AddSpell(
    spells.shadowfiend:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and Target:IsHostile()
    end):SetTarget(Target)
)

-- Trinket
DefaultAPL:AddItem(
    items.inventorySlotTrinket0:UsableIf(function(self)
        return self:IsEquippedAndUsable()
            and Target:Exists()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Trinket
DefaultAPL:AddItem(
    items.inventorySlotTrinket1:UsableIf(function(self)
        return self:IsEquippedAndUsable()
            and Target:Exists()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Potion of Speed
DefaultAPL:AddItem(
    items.potionOfSpeed:UsableIf(function(self)
        return self:IsUsable()
            and Target:Exists()
            and Target:IsBoss()
            and Player:GetDistance(Target) < 36
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Saronite Bomb
DefaultAPL:AddItem(
    items.saroniteBomb:UsableIf(function(self)
        return self:IsUsable()
            and Target:Exists()
            and Target:IsBoss()
            and Target:IsHostile()
            and Player:GetDistance(Target) < 30
            and not Target:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None):PreUse(function(self)
        local targetPosition = Target:GetPosition()
        self:Click(targetPosition)
    end)
)

-- Devouring Plague
DefaultAPL:AddSpell(
    spells.devouringPlague:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:GetAuras():FindMy(spells.devouringPlague):GetRemainingTime() < 2
                or not Target:GetAuras():FindMy(spells.devouringPlague):IsUp())
    end):SetTarget(Target)
)

-- Shadow Word: Pain
DefaultAPL:AddSpell(
    spells.shadowWordPain:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and not Target:GetAuras():FindMy(spells.shadowWordPain):IsUp()
            and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
    end):SetTarget(Target)
)

-- Mind Blast
DefaultAPL:AddSpell(
    spells.mindBlast:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
    end):SetTarget(Target)
)

-- Mind Flay
DefaultAPL:AddSpell(
    spells.mindFlay:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:IsHostile()
            and Target:Exists()
            and not Player:IsMoving()
    end):SetTarget(Target):PreCast(function()
        if spells.innerFocus:IsKnownAndUsable()
            and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
            and (Target:IsBoss() or Target:IsDungeonBoss()) then
            spells.innerFocus:ForceCast(None)
        end
    end)
)

-- Sync
Module:Sync(function()
    if Player:IsMounted() then
        return
    end
    if Player:IsCastingOrChanneling() then
        return
    end

    -- Auto target
    local isAutoTargetEnabled = Rotation.Config:Read("toggleAutoTarget", true)
    if isAutoTargetEnabled then
        TargetUnit(LowestEnemy:GetGUID())
    end

    PreCombatAPL:Execute()
    if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
        DefaultAPL:Execute()
    end
end)

-- Register
Caffeine:Register(Module)