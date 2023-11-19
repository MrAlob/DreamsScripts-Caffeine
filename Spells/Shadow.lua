local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 3 then
    return
end

local SpellBook = Caffeine.Globals.SpellBook

Rotation.Spells = {
    -- Buffs
    shadowform      = SpellBook:GetSpell(15473),
    innerFire       = SpellBook:GetSpell(48168),
    vampiricEmbrace = SpellBook:GetSpell(15286),
    innerFocus      = SpellBook:GetSpell(14751),

    -- Damage Spells
    mindBlast       = SpellBook:GetSpell(48127),
    mindFlay        = SpellBook:GetSpell(48156),
    vampiricTouch   = SpellBook:GetSpell(48160),
    devouringPlague = SpellBook:GetSpell(48300),
    shadowWordPain  = SpellBook:GetSpell(48125),
    mindSear        = SpellBook:GetSpell(53023),
    shadowfiend     = SpellBook:GetSpell(34433),
    shadowWordDeath = SpellBook:GetSpell(48158),

    -- Auras
    shadowWeaving   = SpellBook:GetSpell(15258),
    replenishment   = SpellBook:GetSpell(57669),
    luckoftheDraw   = SpellBook:GetSpell(72221),
    refreshmentAuras = SpellBook:GetList(43183, 57073)
}
