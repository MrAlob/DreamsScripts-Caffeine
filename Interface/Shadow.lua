local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 3 then
	return
end

if Caffeine.GetClass() ~= "PRIEST" then
	return
end

-- Category
Rotation.Category = Caffeine.Interface.Category:New("|cffffffffDreams|cff00B5FFScripts|cffffffff: Shadow")

-- Config
Rotation.Config = Rotation.Category.config

-- Initialize the Hotbar Toggle too false
Rotation.Config:Write("aoe", false)
Rotation.Config:Write("autoTarget", false)

Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hello! Rotation successfully initialized.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Version: 2.1.1")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - If you need any help or have suggestions.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Discord: |cffeb6ee9https://discord.gg/Pm4wQpMDKh")

-- Hotbar
Hotbar = Caffeine.Interface.Hotbar:New({
	name = "Dreams|cff00B5FFScripts",
	options = Rotation.Category,
	buttonCount = 3,
})

Hotbar:AddButton({
	name = "Toggle Rotation",
	texture = "Interface\\ICONS\\Ability_Rogue_FindWeakness",
	tooltip = "Enable Rotation",
	toggle = true,
	onClick = function()
		Module = Caffeine:FindModule("shadow")
		if Module then
			Module.enabled = not Module.enabled
			if Module.enabled then
				Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Shadow Enabled")
			else
				Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Shadow Disabled")
			end
		end
	end,
})

Hotbar:AddButton({
	name = "Toggle AoE",
	texture = "Interface\\ICONS\\Spell_Shadow_MindShear",
	tooltip = "Use Mind Sear, Vampiric Touch, Shadow Word: Pain on nearby Enemies, Rotation adapts itself too the amount of Enemies",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("aoe", false)
		local setting = not getSetting
		Rotation.Config:Write("aoe", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - AoE Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - AoE Disabled")
		end
	end,
})

Hotbar:AddButton({
	name = "Toggle Auto Target",
	texture = "Interface\\ICONS\\Ability_Hunter_MarkedForDeath",
	tooltip = "Use Auto Target, it will automatically Auto Target the lowest enemy nearby",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("autoTarget", false)
		local setting = not getSetting
		Rotation.Config:Write("autoTarget", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Disabled")
		end
	end,
})

-- Spells
Rotation.Category:AddSubsection("|cffFFFFFFSpells")
Rotation.Category:Checkbox({
	category = "spells",
	var = "mindBlast",
	name = "Mind Blast",
	tooltip = "Use of Mind Blast in the rotation. Tip: Turn off if you have T10 4 Piece.",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "spells",
	var = "shadowWordPain",
	name = "Shadow Word: Pain (AoE)",
	tooltip = "Use Shadow Word: Pain in the aoe rotation.",
	default = true,
	disabled = false,
})

-- Items
Rotation.Category:AddSubsection("|cffFFFFFFItems")
Rotation.Category:Checkbox({
	category = "items",
	var = "engineeringGloves",
	name = "Engineering Gloves",
	tooltip = "Use Engineering Gloves in the rotation. Requires Target.",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "saroniteBomb",
	name = "Saronite Bomb",
	tooltip = "Use Saronite Bomb in the rotation. Requires Target.",
	default = true,
	disabled = false,
})

Rotation.Category:Register()
