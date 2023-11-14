local Unlocker, Caffeine, Rotation = ...

-- Loader
if Rotation.GetSpec() ~= 3 then
    return
end

Rotation.Settings = Caffeine.Interface.Category:New("DreamsScripts - Shadow")

Config = Rotation.Settings.Config

Hotbar = Caffeine.Interface.Hotbar:New({
    name = "Dreams|cff00B5FFScripts",
    options = Rotation.Settings,
    buttonCount = 3,
})

Hotbar:AddButton({
    name = "Toggle Rotation",
    texture = "Interface\\ICONS\\Spell_Shadow_Shadowform",
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
    tooltip = "Enable AoE, it will use Mind Sear, Vampiric Touch, Shadow Word: Pain, Rotation adapts itself too the amount of Enemies",
    toggle = true,
    onClick = function()
        local currentSetting = Rotation.Settings.config:Read("toggleAoe", false)
        local newSetting = not currentSetting
        Rotation.Settings.config:Write("toggleAoe", newSetting)

        if newSetting then
            Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - AoE Enabled")
        else
            Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - AoE Disabled")
        end
    end,
})

Hotbar:AddButton({
    name = "Toggle Auto Target",
    texture = "Interface\\ICONS\\Ability_Hunter_MarkedForDeath",
    tooltip = "Enable Auto Target, it will automatically Auto Target the lowest enemy",
    toggle = true,
    onClick = function()
        local currentSetting = Rotation.Settings.config:Read("toggleAutoTarget", false)
        local newSetting = not currentSetting
        Rotation.Settings.config:Write("toggleAutoTarget", newSetting)

        if newSetting then
            Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Enabled")
        else
            Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Disabled")
        end
    end,
})

Rotation.Settings:Register()
