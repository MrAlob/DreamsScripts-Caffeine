local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 3 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

local SpellBook = Caffeine.Globals.SpellBook

Rotation.Spells = {
	-- Buffs
	shadowform = SpellBook:GetSpell(15473),
	innerFire = SpellBook:GetSpell(48168),
	vampiricEmbrace = SpellBook:GetSpell(15286),
	innerFocus = SpellBook:GetSpell(14751),

	-- Spells
	mindBlast = SpellBook:GetSpell(48127),
	mindFlay = SpellBook:GetSpell(48156),
	vampiricTouch = SpellBook:GetSpell(48160),
	devouringPlague = SpellBook:GetSpell(48300),
	shadowWordPain = SpellBook:GetSpell(48125),
	mindSear = SpellBook:GetSpell(53023),
	shadowfiend = SpellBook:GetSpell(34433),
	shadowWordDeath = SpellBook:GetSpell(48158),
	dispersion = SpellBook:GetSpell(47585),

	-- Racials
	beserking = SpellBook:GetSpell(26297),

	-- Auras
	shadowWeaving = SpellBook:GetSpell(15258),
	shroudOfTheOccult = SpellBook:GetSpell(70768),
	replenishment = SpellBook:GetSpell(57669),
	luckOfTheDrawAura = SpellBook:GetSpell(72221),
	refreshmentAuras = SpellBook:GetList(43183, 57073),
	pungentBlight = SpellBook:GetSpell(69195),
	unchainedMagicAura = SpellBook:GetSpell(69762),
	instabilityAura = SpellBook:GetSpell(69766),
}
