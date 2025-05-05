--[[
    MilaUI - Configuration Menu
    Provides a GUI for configuring MilaUI settings using AceGUI
]]

local addonName, ns = ...

-- Create addon using Ace3
local MilaUI = LibStub("AceAddon-3.0"):NewAddon("MilaUI", "AceConsole-3.0")
ns.MilaUI = MilaUI

-- Default settings
local defaults = {
    profile = {
        unitFrames = {
            player = {
                healthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram.tga",
                powerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para.tga",
                healthBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                },
                powerBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                }
            },
            target = {
                healthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram2.tga",
                powerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para2.tga",
                healthBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                },
                powerBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                }
            },
            focus = {
                healthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram.tga",
                powerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para.tga",
                healthBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                },
                powerBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                }
            },
            pet = {
                healthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram.tga",
                powerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para.tga",
                healthBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                },
                powerBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                }
            },
            boss = {
                healthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram.tga",
                powerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para.tga",
                healthBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                },
                powerBorder = {
                    enabled = true,
                    thickness = 1,
                    texture = "Interface\\Buttons\\WHITE8X8",
                    color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}
                }
            }
        },
        general = {
            debug = false
        }
    }
}

-- Apply settings from the DB to the SUF module
function MilaUI:ApplySettingsToSUF()
    if not ns.SUF_Masks then 
        print("|cff1784d1MilaUI|r: |cffff0000Error:|r SUF_Masks module not found")
        return 
    end
    
    -- In suf.lua, the config is a local variable, not a property of SUF_Masks
    -- We need to check if the functions we need are available
    if not ns.SUF_Masks.ApplyMasksToAllFrames then
        print("|cff1784d1MilaUI|r: |cffff0000Error:|r Could not apply settings - SUF_Masks module is not fully loaded")
        return
    end
    
    print("|cff1784d1MilaUI|r: Applying settings to SUF module")
    
    -- Update player settings
    if self.db.profile.unitFrames.player.healthMask then
        print("|cff1784d1MilaUI|r: Setting player health mask: " .. self.db.profile.unitFrames.player.healthMask)
        ns.SUF_Masks:SetPlayerHealthMask(self.db.profile.unitFrames.player.healthMask)
    end
    
    if self.db.profile.unitFrames.player.powerMask then
        print("|cff1784d1MilaUI|r: Setting player power mask: " .. self.db.profile.unitFrames.player.powerMask)
        ns.SUF_Masks:SetPlayerPowerMask(self.db.profile.unitFrames.player.powerMask)
    end
    
    if self.db.profile.unitFrames.player.healthBorder then
        print("|cff1784d1MilaUI|r: Setting player health border: " .. tostring(self.db.profile.unitFrames.player.healthBorder.enabled))
        ns.SUF_Masks:SetPlayerHealthBorder(
            self.db.profile.unitFrames.player.healthBorder.enabled, 
            self.db.profile.unitFrames.player.healthBorder.color,
            self.db.profile.unitFrames.player.healthBorder.texture
        )
    end
    
    if self.db.profile.unitFrames.player.powerBorder then
        print("|cff1784d1MilaUI|r: Setting player power border: " .. tostring(self.db.profile.unitFrames.player.powerBorder.enabled))
        ns.SUF_Masks:SetPlayerPowerBorder(
            self.db.profile.unitFrames.player.powerBorder.enabled, 
            self.db.profile.unitFrames.player.powerBorder.color,
            self.db.profile.unitFrames.player.powerBorder.texture
        )
    end
    
    -- Update target settings
    local targetSettings = self.db.profile.unitFrames.target or {}
    local targetDefaults = defaults.profile.unitFrames.target or {}

    -- Use DB value or default if DB value is nil for Health Mask
    local healthMask = targetSettings.healthMask or targetDefaults.healthMask
    if healthMask then
        print("|cff1784d1MilaUI|r: Setting target health mask: " .. healthMask)
        ns.SUF_Masks:SetTargetHealthMask(healthMask)
    else
        print("|cff1784d1MilaUI|r: Warning: No target health mask found in DB or defaults.")
        ns.SUF_Masks:SetTargetHealthMask(nil) -- Use SUF's internal default
    end

    -- Use DB value or default if DB value is nil for Power Mask
    local powerMask = targetSettings.powerMask or targetDefaults.powerMask
    if powerMask then
        print("|cff1784d1MilaUI|r: Setting target power mask: " .. powerMask)
        ns.SUF_Masks:SetTargetPowerMask(powerMask)
    else
         print("|cff1784d1MilaUI|r: Warning: No target power mask found in DB or defaults.")
         ns.SUF_Masks:SetTargetPowerMask(nil) -- Use SUF's internal default
    end
    
    -- Use DB value or default if DB value is nil for Health Border
    local healthBorder = targetSettings.healthBorder or targetDefaults.healthBorder
    if healthBorder then
         print("|cff1784d1MilaUI|r: Setting target health border: " .. tostring(healthBorder.enabled))
         ns.SUF_Masks:SetTargetHealthBorder(
             healthBorder.enabled,
             healthBorder.color,
             healthBorder.texture
         )
    else
         print("|cff1784d1MilaUI|r: Warning: No target health border settings found in DB or defaults.")
         ns.SUF_Masks:SetTargetHealthBorder(false, nil, nil) -- Disable border if no config
    end
    
    -- Use DB value or default if DB value is nil for Power Border
    local powerBorder = targetSettings.powerBorder or targetDefaults.powerBorder
    if powerBorder then
         print("|cff1784d1MilaUI|r: Setting target power border: " .. tostring(powerBorder.enabled))
         ns.SUF_Masks:SetTargetPowerBorder(
             powerBorder.enabled,
             powerBorder.color,
             powerBorder.texture
         )
    else
         print("|cff1784d1MilaUI|r: Warning: No target power border settings found in DB or defaults.")
         ns.SUF_Masks:SetTargetPowerBorder(false, nil, nil) -- Disable border if no config
    end
    
    -- Update focus settings
    if self.db.profile.unitFrames.focus.healthBorder then
        ns.SUF_Masks:SetUnitHealthBorder(
            "focus", 
            self.db.profile.unitFrames.focus.healthBorder.enabled, 
            self.db.profile.unitFrames.focus.healthBorder.color,
            self.db.profile.unitFrames.focus.healthBorder.texture
        )
    end
    
    if self.db.profile.unitFrames.focus.powerBorder then
        ns.SUF_Masks:SetUnitPowerBorder(
            "focus", 
            self.db.profile.unitFrames.focus.powerBorder.enabled, 
            self.db.profile.unitFrames.focus.powerBorder.color,
            self.db.profile.unitFrames.focus.powerBorder.texture
        )
    end
    
    -- Update pet settings
    if self.db.profile.unitFrames.pet.healthBorder then
        ns.SUF_Masks:SetUnitHealthBorder(
            "pet", 
            self.db.profile.unitFrames.pet.healthBorder.enabled, 
            self.db.profile.unitFrames.pet.healthBorder.color,
            self.db.profile.unitFrames.pet.healthBorder.texture
        )
    end
    
    if self.db.profile.unitFrames.pet.powerBorder then
        ns.SUF_Masks:SetUnitPowerBorder(
            "pet", 
            self.db.profile.unitFrames.pet.powerBorder.enabled, 
            self.db.profile.unitFrames.pet.powerBorder.color,
            self.db.profile.unitFrames.pet.powerBorder.texture
        )
    end
    
    -- Update boss settings
    if self.db.profile.unitFrames.boss.healthBorder then
        ns.SUF_Masks:SetUnitHealthBorder(
            "boss", 
            self.db.profile.unitFrames.boss.healthBorder.enabled, 
            self.db.profile.unitFrames.boss.healthBorder.color,
            self.db.profile.unitFrames.boss.healthBorder.texture
        )
    end
    
    if self.db.profile.unitFrames.boss.powerBorder then
        ns.SUF_Masks:SetUnitPowerBorder(
            "boss", 
            self.db.profile.unitFrames.boss.powerBorder.enabled, 
            self.db.profile.unitFrames.boss.powerBorder.color,
            self.db.profile.unitFrames.boss.powerBorder.texture
        )
    end
    
    -- Update debug setting
    ns.SUF_Masks:SetDebugMode(self.db.profile.general.debug)
    
    -- Apply settings to all frames
    print("|cff1784d1MilaUI|r: Applying masks to all frames")
    ns.SUF_Masks:ApplyMasksToAllFrames()
end

-- Initialize the addon
function MilaUI:OnInitialize()
    -- Initialize the database
    self.db = LibStub("AceDB-3.0"):New("MilaUI_DB", defaults, true)
    
    -- Create options table
    local options = {
        name = "MilaUI",
        type = "group",
        args = {
            general = {
                name = "General",
                type = "group",
                order = 1,
                args = {
                    header = {
                        name = "General Settings",
                        type = "header",
                        order = 1,
                    },
                    debug = {
                        name = "Enable Debug Mode",
                        desc = "Enable debug output to help troubleshoot issues",
                        type = "toggle",
                        order = 2,
                        get = function() return self.db.profile.general.debug end,
                        set = function(_, value) 
                            self.db.profile.general.debug = value
                            self:ApplySettingsToSUF()
                        end,
                    },
                    applyButton = {
                        name = "Apply Settings",
                        type = "execute",
                        order = 3,
                        func = function() self:ApplySettingsToSUF() end,
                    },
                    resetButton = {
                        name = "Reset All Settings",
                        type = "execute",
                        order = 4,
                        confirm = true,
                        confirmText = "Are you sure you want to reset all settings to defaults?",
                        func = function()
                            self.db:ResetProfile()
                            self:ApplySettingsToSUF()
                            print("|cff1784d1MilaUI|r: Reset all settings to defaults")
                        end,
                    },
                },
            },
        },
    }
    
    -- Create unit frame configuration groups
    local unitTypes = {"player", "target", "focus", "pet", "boss"}
    local unitNames = {
        player = "Player",
        target = "Target",
        focus = "Focus",
        pet = "Pet",
        boss = "Boss"
    }
    
    for i, unitType in ipairs(unitTypes) do
        local displayName = unitNames[unitType]
        
        options.args[unitType] = {
            name = displayName,
            type = "group",
            order = i + 1,
            args = {
                header = {
                    name = displayName .. " Frame Settings",
                    type = "header",
                    order = 1,
                },
                healthMask = {
                    name = "Health Bar Mask",
                    desc = "Path to the mask texture for the health bar",
                    type = "input",
                    order = 2,
                    width = "full",
                    get = function() return self.db.profile.unitFrames[unitType].healthMask end,
                    set = function(_, value) 
                        self.db.profile.unitFrames[unitType].healthMask = value
                        self:ApplySettingsToSUF()
                    end,
                },
                powerMask = {
                    name = "Power Bar Mask",
                    desc = "Path to the mask texture for the power bar",
                    type = "input",
                    order = 3,
                    width = "full",
                    get = function() return self.db.profile.unitFrames[unitType].powerMask end,
                    set = function(_, value) 
                        self.db.profile.unitFrames[unitType].powerMask = value
                        self:ApplySettingsToSUF()
                    end,
                },
                healthBorderHeader = {
                    name = "Health Border Settings",
                    type = "header",
                    order = 4,
                },
                healthBorderEnabled = {
                    name = "Enable Health Border",
                    desc = "Show a border around the health bar",
                    type = "toggle",
                    order = 5,
                    get = function() return self.db.profile.unitFrames[unitType].healthBorder.enabled end,
                    set = function(_, value) 
                        self.db.profile.unitFrames[unitType].healthBorder.enabled = value
                        self:ApplySettingsToSUF()
                    end,
                },
                healthBorderTexture = {
                    name = "Health Border Texture",
                    desc = "Path to the texture to use for the health border",
                    type = "input",
                    order = 6,
                    width = "full",
                    get = function() return self.db.profile.unitFrames[unitType].healthBorder.texture end,
                    set = function(_, value) 
                        self.db.profile.unitFrames[unitType].healthBorder.texture = value
                        self:ApplySettingsToSUF()
                    end,
                },
                healthBorderColor = {
                    name = "Health Border Color",
                    desc = "Color of the health border",
                    type = "color",
                    order = 7,
                    hasAlpha = true,
                    get = function()
                        local color = self.db.profile.unitFrames[unitType].healthBorder.color
                        return color.r, color.g, color.b, color.a
                    end,
                    set = function(_, r, g, b, a)
                        local color = self.db.profile.unitFrames[unitType].healthBorder.color
                        color.r, color.g, color.b, color.a = r, g, b, a
                        self:ApplySettingsToSUF()
                    end,
                },
                powerBorderHeader = {
                    name = "Power Border Settings",
                    type = "header",
                    order = 8,
                },
                powerBorderEnabled = {
                    name = "Enable Power Border",
                    desc = "Show a border around the power bar",
                    type = "toggle",
                    order = 9,
                    get = function() return self.db.profile.unitFrames[unitType].powerBorder.enabled end,
                    set = function(_, value) 
                        self.db.profile.unitFrames[unitType].powerBorder.enabled = value
                        self:ApplySettingsToSUF()
                    end,
                },
                powerBorderTexture = {
                    name = "Power Border Texture",
                    desc = "Path to the texture to use for the power border",
                    type = "input",
                    order = 10,
                    width = "full",
                    get = function() return self.db.profile.unitFrames[unitType].powerBorder.texture end,
                    set = function(_, value) 
                        self.db.profile.unitFrames[unitType].powerBorder.texture = value
                        self:ApplySettingsToSUF()
                    end,
                },
                powerBorderColor = {
                    name = "Power Border Color",
                    desc = "Color of the power border",
                    type = "color",
                    order = 11,
                    hasAlpha = true,
                    get = function()
                        local color = self.db.profile.unitFrames[unitType].powerBorder.color
                        return color.r, color.g, color.b, color.a
                    end,
                    set = function(_, r, g, b, a)
                        local color = self.db.profile.unitFrames[unitType].powerBorder.color
                        color.r, color.g, color.b, color.a = r, g, b, a
                        self:ApplySettingsToSUF()
                    end,
                },
                applyButton = {
                    name = "Apply Settings",
                    type = "execute",
                    order = 12,
                    func = function() 
                        self:ApplySettingsToSUF()
                        print("|cff1784d1MilaUI|r: Applied settings for " .. displayName .. " frame")
                    end,
                },
                resetButton = {
                    name = "Reset " .. displayName .. " Settings",
                    type = "execute",
                    order = 13,
                    confirm = true,
                    confirmText = "Are you sure you want to reset " .. displayName .. " settings to defaults?",
                    func = function()
                        self.db.profile.unitFrames[unitType] = CopyTable(defaults.profile.unitFrames[unitType])
                        self:ApplySettingsToSUF()
                        print("|cff1784d1MilaUI|r: Reset settings for " .. displayName .. " frame")
                    end,
                },
            },
        }
    end
    
    -- Register options with AceConfig
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MilaUI", options)
    
    -- Create options panel
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MilaUI", "MilaUI")
    
    -- Register slash commands
    self:RegisterChatCommand("milaui", "SlashCommand")
    self:RegisterChatCommand("mui", "SlashCommand")
    
    -- Apply settings to SUF module
    self:ApplySettingsToSUF()
end

-- Handle slash commands
function MilaUI:SlashCommand(input)
    if input and input:trim() == "debug" then
        self.db.profile.general.debug = not self.db.profile.general.debug
        print("|cff1784d1MilaUI|r: Debug mode " .. (self.db.profile.general.debug and "enabled" or "disabled"))
        self:ApplySettingsToSUF()
    else
        -- Create a standalone config dialog instead of using the interface panel
        if not self.configFrame then
            self.configFrame = LibStub("AceConfigDialog-3.0"):Open("MilaUI")
        else
            if self.configFrame:IsShown() then
                self.configFrame:Hide()
            else
                self.configFrame:Show()
            end
        end
    end
end
