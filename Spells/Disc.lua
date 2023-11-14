local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 1 then
    return
end

local SpellBook = Caffeine.Globals.SpellBook

Rotation.Spells = {
    -- Buffs
    innerFire = SpellBook:GetSpell(48168),
    innerFocus = SpellBook:GetSpell(14751),
    fearWard = SpellBook:GetSpell(6346),
    powerInfusion = SpellBook:GetSpell(10060),

    -- Healing
    powerWordShield = SpellBook:GetSpell(48066),
    penance = SpellBook:GetSpell(53007),
    flashHeal = SpellBook:GetSpell(2061),
    prayerOfMending = SpellBook:GetSpell(48113),
    prayerOfHealing = SpellBook:GetSpell(48072),
    renew = SpellBook:GetSpell(48068),
    painSupression = SpellBook:GetSpell(33206),
    bindingHeal = SpellBook:GetSpell(48120),
    hymnOfDivine = SpellBook:GetSpell(64843),
    despratePrayer = SpellBook:GetSpell(48173),

    -- Damage
    devouringPlague = SpellBook:GetSpell(48300),

    -- Utility
    dispelMagic = SpellBook:GetSpell(988),
    massDispel = SpellBook:GetSpell(32375),
    cureDisease = SpellBook:GetSpell(528),
    shadowfiend = SpellBook:GetSpell(34433),
    hymnOfHope = SpellBook:GetSpell(64901),

    -- Auras
    weakenedSoul = SpellBook:GetSpell(6788),
    prayerOfMendingAura = SpellBook:GetSpell(41635),
    luckoftheDraw = SpellBook:GetSpell(72221),
    drinkAuras = SpellBook:GetSpell(43183, 43182)
}