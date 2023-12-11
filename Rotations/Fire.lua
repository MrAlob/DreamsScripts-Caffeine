local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 2 then
    return
end

if Rotation.GetClass() ~= "MAGE" then
    return
end

-- Module
local Module = Caffeine.Module:New('fire')

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

        if not unit:IsHostile() then
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

local LivingBomb = Caffeine.UnitManager:CreateCustomUnit('livingBomb', function(unit)
    local livingBomb = nil

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

        if unit:CustomTimeToDie() < 12 then
            return false
        end

        -- Lich King
        -- Drudge Ghoul: 37695
        -- Shambling Horror: 37698
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

        if not unit:IsDead() and unit:IsEnemy() and Player:CanSee(unit) and not unit:GetAuras():FindMy(spells.livingBomb):IsUp() then
            livingBomb = unit
        end
    end)

    if livingBomb == nil then
        livingBomb = None
    end

    return livingBomb
end)

-- Decurse
local Decurse = Caffeine.UnitManager:CreateCustomUnit('decurse', function(unit)
    local decurse = nil

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

        if not unit:IsDead() and Player:CanSee(unit) and unit:GetAuras():HasAnyDispelableAura(spells.removeCurse) then
            decurse = unit
        end
    end)

    if decurse == nil then
        decurse = None
    end

    return decurse
end)

-- Spellsteal
local Spellsteal = Caffeine.UnitManager:CreateCustomUnit('spellsteal', function(unit)
    local spellsteal = nil

    Caffeine.UnitManager:EnumEnemies(function(unit)
        if unit:IsDead() then
            return false
        end

        if Player:GetDistance(unit) > 30 then
            return false
        end

        if not Player:CanSee(unit) then
            return false
        end

        if not unit:GetAuras():HasAnyStealableAura() then
            return false
        end

        if not unit:IsDead() and Player:CanSee(unit) and unit:GetAuras():HasAnyStealableAura() then
            spellsteal = unit
        end
    end)

    if spellsteal == nil then
        spellsteal = None
    end

    return spellsteal
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

-- Molten Fire
PreCombatAPL:AddSpell(
    spells.moltenFire:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.moltenFire):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Player)
)

-- Conjure Mana Gem
PreCombatAPL:AddSpell(
    spells.conjureManaGem:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and items.manaGem:GetCharges() < 2
            and not Player:IsAffectingCombat()
            and not Player:IsCastingOrChanneling()
            and not Player:IsMoving()
    end):SetTarget(Player)
)

-- Mana Gem
DefaultAPL:AddItem(
    items.manaGem:UsableIf(function(self)
        return self:IsUsable()
            and not self:IsOnCooldown()
            and items.manaGem:GetCharges() > 0
            and Player:GetPP() < Rotation.Config:Read("items_manaGem", 90)
            and Player:IsAffectingCombat()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- DungeonLogic: Web Wrap and Mirror Images
DefaultAPL:AddSpell(
    spells.iceLance:CastableIf(function(self)
        local useDungeonLogic = Rotation.Config:Read("options_dungeonLogic", true)
        return self:IsKnownAndUsable()
            and self:IsInRange(DungeonLogic)
            and useDungeonLogic
            and DungeonLogic:Exists()
            and Player:IsFacing(DungeonLogic)
    end):SetTarget(DungeonLogic)
)

-- Ice Block
-- Deathbringer Saurfang
DefaultAPL:AddSpell(
    spells.iceBlock:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Player:GetAuras():FindAny(spells.bloodBoilAura):IsUp()
    end):SetTarget(Player)
)

-- Mirror Image
DefaultAPL:AddSpell(
    spells.mirrorImage:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Scorch
DefaultAPL:AddSpell(
    spells.scorch:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and spells.scorch:GetTimeSinceLastCast() > 4
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not (Target:GetAuras():FindAny(spells.improvedScorchAura):IsUp()
                or Target:GetAuras():FindAny(spells.shadowMasteryAura):IsUp())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Saronite Bomb
DefaultAPL:AddItem(
    items.saroniteBomb:UsableIf(function(self)
        local useSaroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
        return self:IsUsable()
            and not self:IsOnCooldown()
            and useSaroniteBomb
            and Target:Exists()
            and Target:IsHostile()
            and Target:IsBoss()
            and Player:GetDistance(Target) < 28
            and not Target:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None):PreUse(function(self)
        local targetPosition = Target:GetPosition()
        self:Click(targetPosition)
    end)
)

-- Combustion
DefaultAPL:AddSpell(
    spells.combustion:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not self:IsOnCooldown()
            and Target:Exists()
            and Target:IsHostile()
            and spells.combustion:GetTimeSinceLastCast() > 120
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and (Target:GetAuras():FindAny(spells.improvedScorchAura):IsUp()
                or Target:GetAuras():FindAny(spells.shadowMasteryAura):IsUp())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Player)
)

-- Beserking
DefaultAPL:AddSpell(
    spells.beserking:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Engineering Gloves
DefaultAPL:AddItem(
    items.inventorySlotGloves:UsableIf(function(self)
        local useEngineeringGloves = Rotation.Config:Read("items_engineeringGloves", true)
        return self:IsUsable()
            and not self:IsOnCooldown()
            and useEngineeringGloves
            and Target:Exists()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and Target:IsHostile()
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Pyro Blast (Hot Streak)
DefaultAPL:AddSpell(
    spells.pyroblast:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:GetAuras():FindMy(spells.hotStreakAura):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Remove Curse
DefaultAPL:AddSpell(
    spells.removeCurse:CastableIf(function(self)
        local useDecurse = Rotation.Config:Read("decurse", true)
        return self:IsKnownAndUsable()
            and self:IsInRange(Decurse)
            and useDecurse
            and Decurse:Exists()
            and Decurse:GetAuras():HasAnyDispelableAura(spells.removeCurse)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Decurse)
)

-- Spellsteal
DefaultAPL:AddSpell(
    spells.spellsteal:CastableIf(function(self)
        local useSpellsteal = Rotation.Config:Read("spellsteal", true)
        return self:IsKnownAndUsable()
            and self:IsInRange(Spellsteal)
            and useSpellsteal
            and Spellsteal:Exists()
            and Spellsteal:GetAuras():HasAnyStealableAura()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Spellsteal)
)

-- Fire Blast
DefaultAPL:AddSpell(
    spells.fireBlast:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Living Bomb
DefaultAPL:AddSpell(
    spells.livingBomb:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:CustomTimeToDie() > 12
            and not Target:GetAuras():FindMy(spells.livingBomb):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Living Bomb (AoE)
DefaultAPL:AddSpell(
    spells.livingBomb:CastableIf(function(self)
        local useAoe = Rotation.Config:Read("aoe", true)
        return self:IsKnownAndUsable()
            and self:IsInRange(LivingBomb)
            and useAoe
            and LivingBomb:Exists()
            and LivingBomb:IsHostile()
            and LivingBomb:CustomTimeToDie() > 12
            and not LivingBomb:GetAuras():FindMy(spells.livingBomb):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(LivingBomb)
)

-- Flamestrike
DefaultAPL:AddSpell(
    spells.flamestrike:CastableIf(function(self)
        local useFlamestrike = Rotation.Config:Read("flamestrike", true)
        local useAoe = Rotation.Config:Read("aoe", true)
        return self:IsKnownAndUsable()
            and useFlamestrike
            and useAoe
            and Target:Exists()
            and Target:IsHostile()
            and spells.flamestrike:GetTimeSinceLastCast() > 8
            and Target:GetEnemies(30) >= 2
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None):OnCast(function(self)
        local position = Caffeine.UnitManager:FindEnemiesCentroid(10, 30)
        self:Click(position)
    end)
)

-- Fire Ball
DefaultAPL:AddSpell(
    spells.fireball:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and self:IsInRange(Target)
            and Target:Exists()
            and Target:IsHostile()
            and not Player:IsCastingOrChanneling()
            and not Player:IsMoving()
    end):SetTarget(Target)
)

-- Sync
Module:Sync(function()
    if Player:IsDead() then
        return
    end
    if Player:IsCastingOrChanneling() then
        return
    end
    if IsMounted() then
        return
    end
    if UnitInVehicle("player") then
        return
    end
    if Player:GetAuras():FindAnyOfMy(spells.refreshmentAuras):IsUp() then
        return
    end

    -- Auto Target
    local useAutoTarget = Rotation.Config:Read("autoTarget", true)
    if useAutoTarget and (not Target:Exists() or Target:IsDead()) then
        TargetUnit(LowestEnemy:GetGUID())
    end

    PreCombatAPL:Execute()

    if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
        DefaultAPL:Execute()
    end
end)

-- Register
Caffeine:Register(Module)
