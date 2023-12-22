local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 3 then
    return
end

if Rotation.GetClass() ~= "PRIEST" then
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
            return false
        end

        if Player:GetDistance(unit) > 36 then
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

local DungeonLogic = Caffeine.UnitManager:CreateCustomUnit('dungeonLogic', function(unit)
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

local VampireTouchTarget = Caffeine.UnitManager:CreateCustomUnit('vampireTouch', function(unit)
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

        if not unit:IsAffectingCombat() then
            return false
        end

        if not unit:IsEnemy() then
            return false
        end

        if unit:CustomTimeToDie() < 10 then
            return false
        end

        -- Lich King
        -- Drudge Ghoul: 37695, Shambling Horror: 37698
        if unit:GetID() == 37695 or unit:GetID() == 37698 then
            return false
        end

        -- Lady Deathwhisper
        if unit:GetAuras():FindAny(spells.shroudOfTheOccult):IsUp() then
            return false
        end

        if unit:IsCreatureType("Critter") then
            return false
        end

        if unit:GetAuras():FindMy(spells.vampiricTouch):IsUp() then
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

local ShadowWordPainTarget = Caffeine.UnitManager:CreateCustomUnit('shadowWordPain', function(unit)
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

        if unit:CustomTimeToDie() < 10 then
            return false
        end

        -- Lich King
        -- Drudge Ghoul: 37695, Shambling Horror: 37698
        if unit:GetID() == 37695 or unit:GetID() == 37698 then
            return false
        end

        -- Lady Deathwhisper
        if unit:GetAuras():FindAny(spells.shroudOfTheOccult):IsUp() then
            return false
        end

        if unit:IsCreatureType("Critter") then
            return false
        end

        if unit:GetAuras():FindMy(spells.shadowWordPain):IsUp() then
            return false
        end

        if not unit:IsDead() and Player:CanSee(unit) and unit:IsEnemy()
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

function Caffeine.Unit:CustomTimeToDie()
    local timeToDie = self:TimeToDie()
    local healthPercent = self:GetHP()

    if timeToDie == 0 and healthPercent > 10 then
        return 200
    else
        return timeToDie
    end
end

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

function Caffeine.Unit:IsCreatureType(creatureType)
    local unitCreatureType = UnitCreatureType(self:GetOMToken())
    return unitCreatureType == creatureType
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

-- PreCombatAPL
PreCombatAPL:AddSpell(
    spells.shadowform:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.shadowform):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Player)
)

PreCombatAPL:AddSpell(
    spells.innerFire:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.innerFire):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Player)
)

PreCombatAPL:AddSpell(
    spells.vampiricEmbrace:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.vampiricEmbrace):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Player)
)

-- DungeonLogic: Web Wrap and Mirror Images
DefaultAPL:AddSpell(
    spells.mindFlay:CastableIf(function(self)
        return DungeonLogic:Exists()
            and self:IsKnownAndUsable()
            and self:IsInRange(DungeonLogic)
            and Player:IsFacing(DungeonLogic)
            and not Player:IsMoving()
    end):SetTarget(DungeonLogic)
)

-- Mind Sear (AoE)
DefaultAPL:AddSpell(
    spells.mindSear:CastableIf(function(self)
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
    end):SetTarget(Target)
)

-- Mind Sear (AoE)
DefaultAPL:AddSpell(
    spells.mindSear:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and GetEnemiesWithVampiricTouch(12) >= 4
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Engineering Gloves
DefaultAPL:AddItem(
    items.inventorySlotGloves:UsableIf(function(self)
        local useEngineeringGloves = Rotation.Config:Read("items_engineeringGloves", true)
        return useEngineeringGloves
            and self:IsUsable()
            and not self:IsOnCooldown()
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
        if wasCasting[spells.vampiricTouch] then
            return false
        end
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and Target:CustomTimeToDie() > 10
            and (Target:GetAuras():FindMy(spells.vampiricTouch):GetRemainingTime() < spells.vampiricTouch:GetCastLength() / 1000
                or not Target:GetAuras():FindMy(spells.vampiricTouch):IsUp())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Shadowfiend
DefaultAPL:AddSpell(
    spells.shadowfiend:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Beserking
DefaultAPL:AddSpell(
    spells.beserking:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Saronite Bomb
DefaultAPL:AddItem(
    items.saroniteBomb:UsableIf(function(self)
        local useSaroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
        return useSaroniteBomb
            and self:IsUsable()
            and not self:IsOnCooldown()
            and Target:Exists()
            and Target:IsBoss()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and Player:GetDistance(Target) < 28
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
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and Target:CustomTimeToDie() > 10
            and (Target:GetAuras():FindMy(spells.devouringPlague):GetRemainingTime() < 1.75
                or not Target:GetAuras():FindMy(spells.devouringPlague):IsUp())
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Shadow Word: Pain
DefaultAPL:AddSpell(
    spells.shadowWordPain:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and Target:CustomTimeToDie() > 10
            and not Target:GetAuras():FindMy(spells.shadowWordPain):IsUp()
            and Player:GetAuras():FindMy(spells.shadowWeaving):GetCount() == 5
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Vampiric Touch (AoE)
DefaultAPL:AddSpell(
    spells.vampiricTouch:CastableIf(function(self)
        local isAoeEnabled = Rotation.Config:Read("aoe", true)
        return self:IsKnownAndUsable()
            and self:IsInRange(VampireTouchTarget)
            and isAoeEnabled
            and VampireTouchTarget:Exists()
            and VampireTouchTarget:CustomTimeToDie() > 10
            and
            (VampireTouchTarget:GetAuras():FindMy(spells.vampiricTouch):GetRemainingTime() < spells.vampiricTouch:GetCastLength() / 1000
                or not VampireTouchTarget:GetAuras():FindMy(spells.vampiricTouch):IsUp())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(VampireTouchTarget)
)

-- Shadow Word: Pain (AoE)
DefaultAPL:AddSpell(
    spells.shadowWordPain:CastableIf(function(self)
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
    end):SetTarget(ShadowWordPainTarget)
)

-- Shadow Word: Death
DefaultAPL:AddSpell(
    spells.shadowWordDeath:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and Player:GetHP() > 60
            and Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Mind Blast
DefaultAPL:AddSpell(
    spells.mindBlast:CastableIf(function(self)
        local useMindBlast = Rotation.Config:Read("spells_mindBlast", true)
        return useMindBlast
            and self:IsInRange(Target)
            and self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and Player:CanSee(Target)
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Mind Flay
DefaultAPL:AddSpell(
    spells.mindFlay:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:IsHostile()
            and Target:Exists()
            and Player:CanSee(Target)
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
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
    if Player:IsDead() then
        return false
    end
    if IsMounted() then
        return false
    end
    if UnitInVehicle("player") then
        return false
    end
    if Player:GetAuras():FindAnyOfMy(spells.refreshmentAuras):IsUp() then
        return false
    end

    -- Auto Target
    local isAutoTargetEnabled = Rotation.Config:Read("autoTarget", true)
    if isAutoTargetEnabled and (not Target:Exists() or Target:IsDead()) then
        TargetUnit(LowestEnemy:GetGUID())
    end

    PreCombatAPL:Execute()

    if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
        WasCastingCheck()
        DefaultAPL:Execute()
    end
end)

-- Register
Caffeine:Register(Module)
