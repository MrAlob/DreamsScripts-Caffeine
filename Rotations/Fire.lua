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

        if Player:GetDistance(unit) > 35 then
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

        if not unit:IsDead() and unit:IsEnemy() and Player:CanSee(unit) and not unit:GetAuras():FindMy(spells.livingBomb):IsUp() then
            livingBomb = unit
        end
    end)

    if livingBomb == nil then
        livingBomb = None
    end

    return livingBomb
end)

function Caffeine.Unit:IsDungeonBoss()
    if UnitClassification(self:GetOMToken()) == "elite"
        and UnitLevel(self:GetOMToken()) == 82
        and Player:GetAuras():FindMy(spells.luckoftheDraw):IsUp() then
        return true
    end
    return false
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
    end):SetTarget(Player)
)

-- Mana Gem
DefaultAPL:AddItem(
    items.manaGem:UsableIf(function(self)
        return self:IsUsable()
            and not self:IsOnCooldown()
            and items.manaGem:GetCharges() > 0
            and Player:GetPP() < 60
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- DungeonLogic: Web Wrap and Mirror Images
DefaultAPL:AddSpell(
    spells.iceLance:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and DungeonLogic:Exists()
            and Player:IsFacing(DungeonLogic)
    end):SetTarget(DungeonLogic)
)

-- Mirror Image
DefaultAPL:AddSpell(
    spells.mirrorImage:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Combustion
DefaultAPL:AddSpell(
    spells.combustion:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not self:IsOnCooldown()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
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

-- Saronite Bomb
DefaultAPL:AddItem(
    items.saroniteBomb:UsableIf(function(self)
        local useSaroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
        return useSaroniteBomb
            and self:IsUsable()
            and not self:IsOnCooldown()
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

-- Flame Cap

-- Scorch
DefaultAPL:AddSpell(
    spells.scorch:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and
            not (Target:GetAuras():FindAny(spells.improvedScorchAura):IsUp() or Target:GetAuras():FindAny(spells.shadowMasteryAura):IsUp()) -- Shadow Bolt crit aura
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Pyro Blast (Hot Streak)
DefaultAPL:AddSpell(
    spells.pyroblast:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and Player:GetAuras():FindMy(spells.hotStreakAura):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Living Bomb
DefaultAPL:AddSpell(
    spells.livingBomb:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and not Target:GetAuras():FindMy(spells.livingBomb):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Living Bomb (AoE)
DefaultAPL:AddSpell(
    spells.livingBomb:CastableIf(function(self)
        local useAoe = Rotation.Config:Read("aoe", true)
        return self:IsKnownAndUsable()
            and useAoe
            and LivingBomb:Exists()
            and LivingBomb:IsHostile()
            and not LivingBomb:GetAuras():FindMy(spells.livingBomb):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(LivingBomb)
)

-- Fire Blast
DefaultAPL:AddSpell(
    spells.fireBlast:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Target:Exists()
            and Target:IsHostile()
            and Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Fire Ball
DefaultAPL:AddSpell(
    spells.fireball:CastableIf(function(self)
        return self:IsKnownAndUsable()
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
    local isAutoTargetEnabled = Rotation.Config:Read("autoTarget", true)
    if isAutoTargetEnabled and (not Target:Exists() or Target:IsDead()) then
        TargetUnit(LowestEnemy:GetGUID())
    end

    PreCombatAPL:Execute()

    if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
        DefaultAPL:Execute()
    end
end)

-- Register
Caffeine:Register(Module)
