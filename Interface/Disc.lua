local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 1 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

-- Category
Rotation.Category = Caffeine.Interface.Category:New("|cffffffffDreams|cff00B5FFScripts|cffffffff: Disc")

-- Config
Rotation.Config = Rotation.Category.config

-- Initialize the Hotbar Toggle too false
Rotation.Config:Write("preShield", false)
Rotation.Config:Write("flashHeal", false)
Rotation.Config:Write("dispel", false)
Rotation.Config:Write("outOfCombat", false)

Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hello! Rotation successfully initialized.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Version: 2.0.4")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - If you need any help or have suggestions.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Discord: |cffeb6ee9https://discord.gg/Pm4wQpMDKh")

-- Hotbar
Hotbar = Caffeine.Interface.Hotbar:New({
	name = "|cffffffffDreams|cff00B5FFScripts|cffffffff",
	options = Rotation.Category,
	buttonCount = 5,
})

Hotbar:AddButton({
	name = "Toggle Rotation",
	texture = "Interface\\ICONS\\Ability_Rogue_FindWeakness",
	tooltip = "Enable Rotation",
	toggle = true,
	onClick = function()
		Module = Caffeine:FindModule("disc")
		if Module then
			Module.enabled = not Module.enabled
			if Module.enabled then
				Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Disc Enabled")
			else
				Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Disc Disabled")
			end
		end
	end,
})

Hotbar:AddButton({
	name = "Toggle Pre-Shield",
	texture = "Interface\\ICONS\\Spell_Holy_PowerWordShield",
	tooltip = "Pre-Shield the entire Raid.",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("preShield", false)
		local setting = not getSetting
		Rotation.Config:Write("preShield", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Pre-Shield Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Pre-Shield Disabled")
		end
	end,
})

Hotbar:AddButton({
	name = "Toggle Dispel",
	texture = "Interface\\ICONS\\SPELL_HOLY_DISPELMAGIC",
	tooltip = "Use Dispel or Cure Disease if any Debuff is up.",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("dispel", false)
		local setting = not getSetting
		Rotation.Config:Write("dispel", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Dispel Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Dispel Disabled")
		end
	end,
})

Hotbar:AddButton({
	name = "Toggle Flash Heal",
	texture = "Interface\\ICONS\\Spell_Holy_FlashHeal",
	tooltip = "Use Flash Heal. Tip: You dont use Flash Heal in 25man normally.",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("flashHeal", false)
		local setting = not getSetting
		Rotation.Config:Write("flashHeal", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Flash Heal Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Flash Heal Disabled")
		end
	end,
})

Hotbar:AddButton({
	name = "Toggle Out of Combat",
	texture = "Interface\\ICONS\\Ability_Vanish",
	tooltip = "Use Spells Out of Combat.",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("outOfCombat", false)
		local setting = not getSetting
		Rotation.Config:Write("outOfCombat", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Out of Combat Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Out of Combat Disabled")
		end
	end,
})

-- Spells
Rotation.Category:AddSubsection("|cffFFFFFFSpells")
-- Pain Supression
Rotation.Category:Slider({
	category = "spells",
	var = "painSupression",
	name = "Pain Supression (Tank)",
	tooltip = "Use Pain Supression if the Tank is below Health Percentage the value. High priority.",
	default = 40,
	min = 0,
	max = 100,
	step = 5,
})

-- Power Word: Shield (Tank - Safe)
Rotation.Category:Slider({
	category = "spells",
	var = "powerWordShieldTankSafe",
	name = "Power Word: Shield (Tank)",
	tooltip =
	"Use Power Word: Shield on Tank if their Health Percentage is below the set value. High priority. Tip: Too high value is counterproductive for Rupture.",
	default = 40,
	min = 0,
	max = 100,
	step = 5,
})

-- Power Word: Shield (Safe)
Rotation.Category:Slider({
	category = "spells",
	var = "powerWordShieldSafe",
	name = "Power Word: Shield",
	tooltip =
	"Use Power Word: Shield on the lowest health unit if their Health Percentage falls below the set value. Excluding tanks.",
	default = 80,
	min = 0,
	max = 100,
	step = 5,
})

-- Penance (Tank)
Rotation.Category:Slider({
	category = "spells",
	var = "penanceTank",
	name = "Penance (Tank)",
	tooltip = "Use Penance on the tank if their Health Percentage falls below the set value. High priority.",
	default = 80,
	min = 0,
	max = 100,
	step = 5,
})

-- Penance
Rotation.Category:Slider({
	category = "spells",
	var = "penance",
	name = "Penance",
	tooltip = "Use Penance on the unit with the lowest health if their Health Percentage falls below the set value.",
	default = 80,
	min = 0,
	max = 100,
	step = 5,
})

-- Binding Heal
Rotation.Category:Slider({
	category = "spells",
	var = "bindingHeal",
	name = "Binding Heal",
	tooltip =
	"Use Binding Heal if the player's and the lowest health unit's Health Percentage falls below the set value.",
	default = 60,
	min = 0,
	max = 100,
	step = 5,
})

-- Flash Heal
Rotation.Category:Slider({
	category = "spells",
	var = "flashHeal",
	name = "Flash Heal",
	tooltip =
	"Use Flash Heal on the lowest health unit if their Health Percentage falls below the set value. Tip: You dont use Flash Heal in 25man.",
	default = 80,
	min = 0,
	max = 100,
	step = 5,
})

-- Desperate Prayer
Rotation.Category:Slider({
	category = "spells",
	var = "desperatePrayer",
	name = "Desperate Prayer",
	tooltip = "Use Desperate Prayer if your Health Percentage is below the value.",
	default = 40,
	min = 0,
	max = 100,
	step = 5,
})

-- Shadowfiend
Rotation.Category:Slider({
	category = "spells",
	var = "shadowfiend",
	name = "Shadowfiend",
	tooltip = "Use Shadowfiend if the Mana Percentage falls below the set value. Requires Target.",
	default = 40,
	min = 0,
	max = 100,
	step = 5,
})

-- Toggles
Rotation.Category:AddSubsection("|cffFFFFFFToggles")
Rotation.Category:Checkbox({
	category = "toggles",
	var = "powerInfustion",
	name = "Power Infusion",
	tooltip = "Enable or disable the use of Power Infusion in the rotation. Set your unit as Focus Target.",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "toggles",
	var = "dungeonLogic",
	name = "Dungeon Logic (Gamma)",
	tooltip =
	"Use of Dungeon Logic in Gamma Dungeons. This will use Holy Fire and Mind Blast at Mirror Images and Web Wraps.",
	default = true,
	disabled = false,
})

-- Items
Rotation.Category:AddSubsection("|cffFFFFFFItems")
Rotation.Category:Checkbox({
	category = "items",
	var = "engineeringGloves",
	name = "Engineering Gloves",
	tooltip = "Enable or disable the use of Engineering Gloves in the rotation. Requires Target.",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "saroniteBomb",
	name = "Saronite Bomb",
	tooltip = "Enable or disable the use of Saronite Bomb in the rotation. Requires Target.",
	default = true,
	disabled = false,
})

Rotation.Category:Register()
