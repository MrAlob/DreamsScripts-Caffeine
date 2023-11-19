local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 1 then
    return
end

-- Module
local Module = Caffeine.Module:New('disc')

-- Units
local Player = Caffeine.UnitManager:Get('player')
local Target = Caffeine.UnitManager:Get('target')
local Focus = Caffeine.UnitManager:Get('focus')
local None = Caffeine.UnitManager:Get('none')

-- Spells
local spells = Rotation.Spells

-- items
local items = Rotation.Items
-- APLs
local PreCombatAPL = Caffeine.APL:New('precombat')
local DefaultAPL = Caffeine.APL:New('default')

-- Lowest
local Lowest = Caffeine.UnitManager:CreateCustomUnit('lowest', function(unit)
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

        local hp = unit:GetHP()
        if hp < lowestHP then
            lowest = unit
            lowestHP = hp
        end
    end)

    if lowest == nil then
        lowest = None
    end

    return lowest
end)

-- Tank
local Tank = Caffeine.UnitManager:CreateCustomUnit('tank', function(unit)
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

-- Dispel
local PreShield = Caffeine.UnitManager:CreateCustomUnit('preShield', function(unit)
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

        if unit:IsTank() then
            return false
        end

        if not unit:IsDead() and Player:CanSee(unit) and not unit:IsTank()
            and not unit:GetAuras():FindAny(spells.powerWordShield):IsUp()
            and not unit:GetAuras():FindAny(spells.weakenedSoul):IsUp() then
            preShield = unit
        end
    end)

    if preShield == nil then
        preShield = None
    end

    return preShield
end)

-- Dispel
local Dispel = Caffeine.UnitManager:CreateCustomUnit('dispel', function(unit)
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

        if not unit:IsDead() and Player:CanSee(unit)
            and (unit:GetAuras():HasAnyDispelableAura(spells.dispelMagic)
                or unit:GetAuras():HasAnyDispelableAura(spells.cureDisease)) then
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
local DungeonLogic = Caffeine.UnitManager:CreateCustomUnit('dungeonLogic', function(unit)
    local dungeonLogic = nil

    Caffeine.UnitManager:EnumUnits(function(unit)
        if unit:IsDead() then
            return false
        end

        if Player:GetDistance(unit) > 40 then
            return false
        end

        if not (unit:GetID() == 28619 or unit:GetName() == "Mirror Image") then
            return false
        end

        if unit:GetID() == 28619 or unit:GetName() == "Mirror Image" then
            dungeonLogic = unit
            return true
        end
    end)

    if dungeonLogic == nil then
        dungeonLogic = None
    end

    return dungeonLogic
end)

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
    spells.innerFire:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and not Player:GetAuras():FindMy(spells.innerFire):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Player)
)

-- DungeonLogic: Web Wrap & Mirror Image
DefaultAPL:AddSpell(
    spells.holyFire:CastableIf(function(self)
        local useDungeonLogic = Rotation.Config:Read("toggles_dungeonLogic", true)
        return useDungeonLogic
            and self:IsKnownAndUsable()
            and DungeonLogic:Exists()
    end):SetTarget(DungeonLogic)
)

DefaultAPL:AddSpell(
    spells.mindBlast:CastableIf(function(self)
        local useDungeonLogic = Rotation.Config:Read("toggles_dungeonLogic", true)
        return useDungeonLogic
            and self:IsKnownAndUsable()
            and DungeonLogic:Exists()
    end):SetTarget(DungeonLogic)
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
        local saroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
        return saroniteBomb
            and self:IsUsable()
            and not self:IsOnCooldown()
            and Target:Exists()
            and Target:IsBoss()
            and Target:IsHostile()
            and Player:GetDistance(Target) < 28
            and not Target:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None):PreUse(function(self)
        local targetPosition = Target:GetPosition()
        self:Click(targetPosition)
    end)
)

-- Shadowfiend
DefaultAPL:AddSpell(
    spells.shadowfiend:CastableIf(function(self)
        return Target:Exists()
            and self:IsKnownAndUsable()
            and Target:IsHostile()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and Player:GetPP() < Rotation.Config:Read("spells_shadowfiend", 40)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Target)
)

-- Pain Supression
DefaultAPL:AddSpell(
    spells.painSupression:CastableIf(function(self)
        return Tank:Exists()
            and self:IsKnownAndUsable()
            and Tank:GetHP() < Rotation.Config:Read("spells_painSupression", 40)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Tank)
)

-- Desprate Prayer
DefaultAPL:AddSpell(
    spells.despratePrayer:CastableIf(function(self)
        return self:IsKnownAndUsable()
            and Player:GetHP() < Rotation.Config:Read("spells_desperatePrayer", 40)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(None)
)

-- Power Word: Shield (Tank - Safe)
DefaultAPL:AddSpell(
    spells.powerWordShield:CastableIf(function(self)
        return Tank:Exists()
            and self:IsKnownAndUsable()
            and not Tank:GetAuras():FindAny(spells.powerWordShield):IsUp()
            and not Tank:GetAuras():FindAny(spells.weakenedSoul):IsUp()
            and Tank:GetHP() < Rotation.Config:Read("spells_powerWordShieldTankSafe", 40)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Tank)
)

-- Penance (Tank)
DefaultAPL:AddSpell(
    spells.penance:CastableIf(function(self)
        return Tank:Exists()
            and self:IsKnownAndUsable()
            and Tank:GetHP() < Rotation.Config:Read("spells_penanceTank", 80)
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Tank)
)

-- Prayer of Mending (Tank)
DefaultAPL:AddSpell(
    spells.prayerOfMending:CastableIf(function(self)
        return Tank:Exists()
            and self:IsKnownAndUsable()
            and not Tank:GetAuras():FindMy(spells.prayerOfMendingAura):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Tank)
)

-- Power Word: Shield (Safe)
DefaultAPL:AddSpell(
    spells.powerWordShield:CastableIf(function(self)
        return Lowest:Exists()
            and self:IsKnownAndUsable()
            and not Lowest:GetAuras():FindAny(spells.powerWordShield):IsUp()
            and not Lowest:GetAuras():FindAny(spells.weakenedSoul):IsUp()
            and Lowest:GetHP() < Rotation.Config:Read("spells_powerWordShieldSafe", 60)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Lowest)
)

-- Penance
DefaultAPL:AddSpell(
    spells.penance:CastableIf(function(self)
        return Lowest:Exists()
            and self:IsKnownAndUsable()
            and Lowest:GetHP() < Rotation.Config:Read("spells_penance", 80)
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Lowest)
)

-- Power Infusion
DefaultAPL:AddSpell(
    spells.powerInfusion:CastableIf(function(self)
        local usePowerInfusion = Rotation.Config:Read("spells_powerInfusion", true)
        return usePowerInfusion
            and Focus:Exists()
            and self:IsKnownAndUsable()
            and Focus:IsAffectingCombat()
            and (Target:IsBoss() or Target:IsDungeonBoss())
            and not Focus:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Focus)
)

-- Dispel Magic
DefaultAPL:AddSpell(
    spells.dispelMagic:CastableIf(function(self)
        local isDispelEnabled = Rotation.Config:Read("dispel", true)
        return isDispelEnabled
            and Dispel:Exists()
            and self:IsKnownAndUsable()
            and Dispel:GetAuras():HasAnyDispelableAura(spells.dispelMagic)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Dispel)
)

-- Cure Disease
DefaultAPL:AddSpell(
    spells.cureDisease:CastableIf(function(self)
        local isDispelEnabled = Rotation.Config:Read("dispel", true)
        return isDispelEnabled
            and Dispel:Exists()
            and self:IsKnownAndUsable()
            and Dispel:GetAuras():HasAnyDispelableAura(spells.cureDisease)
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Dispel)
)

-- Binding Heal
DefaultAPL:AddSpell(
    spells.bindingHeal:CastableIf(function(self)
        return Lowest:Exists()
            and self:IsKnownAndUsable()
            and Lowest:GetHP() < Rotation.Config:Read("spells_bindingHeal", 60)
            and Player:GetHP() < Rotation.Config:Read("spells_bindingHeal", 60)
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Lowest)
)

-- Flash Heal
DefaultAPL:AddSpell(
    spells.flashHeal:CastableIf(function(self)
        local isFlashHealEnabled = Rotation.Config:Read("flashHeal", true)
        return isFlashHealEnabled
            and Lowest:Exists()
            and self:IsKnownAndUsable()
            and Lowest:GetHP() < Rotation.Config:Read("spells_flashHeal", 80)
            and spells.penance:OnCooldown()
            and not Player:IsMoving()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Lowest)
)

-- Renew (Tank)
DefaultAPL:AddSpell(
    spells.renew:CastableIf(function(self)
        return Tank:Exists()
            and self:IsKnownAndUsable()
            and not Tank:GetAuras():FindMy(spells.renew):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(Tank)
)

-- Power Word: Shield (Pre-Shield)
DefaultAPL:AddSpell(
    spells.powerWordShield:CastableIf(function(self)
        local isPreShieldEnabled = Rotation.Config:Read("preShield", false)
        return isPreShieldEnabled
            and PreShield:Exists()
            and self:IsKnownAndUsable()
            and not PreShield:GetAuras():FindAny(spells.powerWordShield):IsUp()
            and not PreShield:GetAuras():FindAny(spells.weakenedSoul):IsUp()
            and not Player:IsCastingOrChanneling()
    end):SetTarget(PreShield)
)

local waitingForDelay = false
local endTime = 0
local function RandomDelay(apl, minDelayMs, maxDelayMs)
    if not waitingForDelay then
        local delay = math.random(minDelayMs, maxDelayMs) / 1000
        endTime = GetTime() + delay
        waitingForDelay = true
    elseif GetTime() >= endTime then
        apl:Execute()
        waitingForDelay = false
    end
end

-- Sync
Module:Sync(function()
    if Player:IsDead() then
        return
    end
    if Player:IsMounted() then
        return
    end
    if Player:IsCastingOrChanneling() then
        return
    end
    if Player:GetAuras():FindMy(spells.drinkAuras):IsUp() then
        return
    end

    PreCombatAPL:Execute()

    local isOutOfCombatEnabled = Rotation.Config:Read("outOfCombat", true)
    if isOutOfCombatEnabled or Player:IsAffectingCombat() or Target:IsAffectingCombat() then
        RandomDelay(DefaultAPL, 10, 250) -- Execute with a delay between 10 and 100 milliseconds
    end
end)

-- Register
Caffeine:Register(Module)
