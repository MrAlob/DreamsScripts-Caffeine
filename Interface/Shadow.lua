local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 3 then
    return
end

-- Category
Rotation.Category = Caffeine.Interface.Category:New("|cffffffffDreams|cff00B5FFScripts|cffffffff: Shadow")

-- Config
Rotation.Config = Rotation.Category.config

-- Initialize the Hotbar Toggle too false
Rotation.Config:Write("toggleAoe", false)
Rotation.Config:Write("toggleAoe", false)
Rotation.Config:Write("toggleAutoTarget", false)

Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hello! Rotation successfully initialized.")
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
    texture = "Interface\\ICONS\\Ability_Parry",
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
    tooltip =
    "Use Mind Sear, Vampiric Touch, Shadow Word: Pain on nearby Enemies, Rotation adapts itself too the amount of Enemies",
    toggle = true,
    onClick = function()
        local getSetting = Rotation.Config:Read("toggleAoe", false)
        local setting = not getSetting
        Rotation.Config:Write("toggleAoe", setting)

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
        local getSetting = Rotation.Config:Read("toggleAutoTarget", false)
        local setting = not getSetting
        Rotation.Config:Write("toggleAutoTarget", setting)

        if setting then
            Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Enabled")
        else
            Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Disabled")
        end
    end,
})

Rotation.Category:Register()
