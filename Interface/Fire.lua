local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 2 then
    return
end

if Rotation.GetClass() ~= "MAGE" then
    return
end

-- Category
Rotation.Category = Caffeine.Interface.Category:New("|cffffffffDreams|cff00B5FFScripts|cffffffff: Fire")

-- Config
Rotation.Config = Rotation.Category.config

-- Initialize the Hotbar Toggle too false
Rotation.Config:Write("aoe", false)
Rotation.Config:Write("autoTarget", false)

Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hello! Rotation successfully initialized.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Version: 1.0.0")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - If you need any help or have suggestions.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Discord: |cffeb6ee9https://discord.gg/dJ2upysMcW")

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
        Module = Caffeine:FindModule("fire")
        if Module then
            Module.enabled = not Module.enabled
            if Module.enabled then
                Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Fire Enabled")
            else
                Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Fire Disabled")
            end
        end
    end,
})

Hotbar:AddButton({
    name = "Toggle AoE",
    texture = "Interface\\ICONS\\Ability_Mage_LivingBomb",
    tooltip =
    "Use Mind Sear, Vampiric Touch, Shadow Word: Pain on nearby Enemies, Rotation adapts itself too the amount of Enemies",
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
    tooltip = "Enable or disable the use of Mind Blast in the rotation. Tip: Turn off if you have T10 4 Piece.",
    default = true,
    disabled = false
})

-- Items
Rotation.Category:AddSubsection("|cffFFFFFFItems")
Rotation.Category:Checkbox({
    category = "items",
    var = "engineeringGloves",
    name = "Engineering Gloves",
    tooltip = "Enable or disable the use of Engineering Gloves in the rotation. Requires Target.",
    default = true,
    disabled = false
})

Rotation.Category:Checkbox({
    category = "items",
    var = "saroniteBomb",
    name = "Saronite Bomb",
    tooltip = "Enable or disable the use of Saronite Bomb in the rotation. Requires Target.",
    default = true,
    disabled = false
})

Rotation.Category:Register()
