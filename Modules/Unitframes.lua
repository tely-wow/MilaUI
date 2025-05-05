--[[
    ElvUICustomTextures.lua
    Custom texture modification for ElvUI unit frames
    Author: Teliy
]]

local addonName, MilaUI = ...
local LSM = LibStub("LibSharedMedia-3.0")

-- Initialize MilaUI namespace if needed
if not MilaUI.modules then MilaUI.modules = {} end
if not MilaUI.modules.unitframes then MilaUI.modules.unitframes = {} end

local MilaUI_Textures = CreateFrame("Frame")
MilaUI_Textures.name = "MilaUI_Textures"

-- Helper function to get media from SharedMedia
local function GetSM(mediaType, name)
    if LSM then
        return LSM:Fetch(mediaType, name)
    end
    return name
end

-- Configuration
MilaUI.modules.unitframes.config = {
    enabled = true,
    player = {
        healthTexture = "a-Mila Health 01",
        powerTexture = "a-Mila Power 03",
        backdropTexture = "a-Mila Health 01",
        powerBackdropTexture = "a-Mila Power 03",
        healthLossTexture = "a-Mila Health Loss 01", -- Custom shaped health loss effect
        backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 1},
        borderColor = {r = 0, g = 0, b = 0, a = 0}, -- Transparent border
        healthBgMultiplier = 0.2, -- Controls the darkness of the health bar background
        removeBorders = true,
    },
    target = {
        healthTexture = "a-Mila Health Target 01",
        powerTexture = "a-Mila Power Target 03",
        backdropTexture = "a-Mila Health Target 01",
        powerBackdropTexture = "a-Mila Power Target 03",
        healthLossTexture = "a-Mila Health Loss 01", -- Custom shaped health loss effect
        backdropColor = {r = 0.1, g = 0.1, b = 0.1, a = 1},
        borderColor = {r = 0, g = 0, b = 0, a = 0},
        healthBgMultiplier = 0.5,
        removeBorders = true,
    },
}

local function ResetTextureFlag(unit)
    local frame = _G["ElvUF_" .. unit:gsub("^%l", string.upper)]
    if frame then
        frame._customTexturesApplied = nil
    end
end

-- Apply custom textures
function MilaUI_Textures:ApplyTextures(unit)
    if not MilaUI.modules.unitframes.config.enabled then
        print("Texture application disabled")
        return 
    end
    
    local textures = MilaUI.modules.unitframes.config[unit]
    if not textures then 
        print("No textures found for unit:", unit)
        return 
    end

    local frame = _G["ElvUF_" .. unit:gsub("^%l", string.upper)]
    if not frame then 
        print("No frame found for unit:", unit)
        return 
    end

    -- Prevent redundant texture applications
    --if frame._customTexturesApplied then return end
    frame._customTexturesApplied = true
    
    print("Applying textures to", unit, "frame")

    local function ApplyTexture(bar, textureName)
        if not bar then
            print("Bar is nil")
            return
        end
        
        if not bar:IsVisible() then
            print("Bar is not visible")
            return
        end
        
        if not textureName then
            print("Texture name is nil")
            return
        end
        
        local texture = LSM:Fetch("statusbar", textureName)
        if not texture then
            print("Failed to fetch texture:", textureName)
            return
        end
        
        print("Setting texture", textureName, "on bar")
        bar:SetStatusBarTexture(texture)
        
        if bar.bg then
            bar.bg:SetTexture(texture)
            local r, g, b = bar:GetStatusBarColor()
            local mult = unit == "player" and MilaUI.modules.unitframes.config.player.healthBgMultiplier or MilaUI.modules.unitframes.config.target.healthBgMultiplier
            if bar == frame.Health then
                bar.bg:SetVertexColor(r * mult, g * mult, b * mult, 1)
            end
        end
    end

    ApplyTexture(frame.Health, textures.healthTexture)
    ApplyTexture(frame.Power, textures.powerTexture)

    local function ApplyBackdrop(frame, textureName, backdropColor, borderColor)
        if not frame or not frame.backdrop or not frame.backdrop.SetBackdrop then
            print("Cannot apply backdrop - frame, backdrop or SetBackdrop missing")
            return
        end
        
        local texture = LSM:Fetch("statusbar", textureName)
        if not texture then
            print("Failed to fetch backdrop texture:", textureName)
            return
        end
        
        frame.backdrop:SetBackdrop(nil)
        frame.backdrop:SetBackdrop({ bgFile = texture })
        frame.backdrop:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
        frame.backdrop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end

    ApplyBackdrop(frame, textures.backdropTexture, textures.backdropColor, textures.borderColor)
    ApplyBackdrop(frame.Health, textures.backdropTexture, textures.backdropColor, textures.borderColor)
    ApplyBackdrop(frame.Power, textures.powerBackdropTexture, textures.backdropColor, textures.borderColor)

    local function CreateMaskedBackdrop(barName, textureName)
        local barFrame = _G["ElvUF_" .. unit:gsub("^%l", string.upper) .. "_" .. barName]
        if not barFrame then
            print("Bar frame not found:", barName)
            return
        end

        if barFrame.customBackdrop then
            barFrame.customBackdrop:Hide()
            barFrame.customBackdrop = nil
        end

        local backdrop = CreateFrame("Frame", nil, barFrame)
        backdrop:SetFrameLevel(barFrame:GetFrameLevel() - 1)
        backdrop:SetAllPoints(barFrame)
        barFrame.customBackdrop = backdrop

        local texture = LSM:Fetch("statusbar", textureName)
        local tex = backdrop:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints(backdrop)
        tex:SetTexture(texture)
        tex:SetVertexColor(
            textures.backdropColor.r,
            textures.backdropColor.g,
            textures.backdropColor.b,
            textures.backdropColor.a
        )
        backdrop.texture = tex

        if barFrame.backdropTex then
            barFrame.backdropTex:SetAlpha(0)
        end

        if backdrop.CreateMaskTexture then
            local mask = backdrop:CreateMaskTexture()
            mask:SetTexture(texture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(backdrop)
            tex:AddMaskTexture(mask)
            backdrop.mask = mask
        end

        return backdrop
    end

    if unit == "player" then
        CreateMaskedBackdrop("HealthBar", textures.healthTexture)
        -- Direct mask application to frame.Health
        if frame.Health and not frame.Health.customMask and frame.Health.CreateMaskTexture then
            local healthTex = frame.Health:GetStatusBarTexture()
            if healthTex then
                local mask = frame.Health:CreateMaskTexture()
                local texture = LSM:Fetch("statusbar", textures.healthTexture)
                mask:SetTexture(texture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                mask:SetAllPoints(frame.Health)
                if frame.Health.backdropTex then
                    frame.Health.backdropTex:AddMaskTexture(mask)
                    local backdropTexture = LSM:Fetch("statusbar", textures.backdropTexture)
                    frame.Health.backdropTex:SetTexture(backdropTexture)
                    frame.Health.backdropTex:SetVertexColor(
                        textures.backdropColor.r,
                        textures.backdropColor.g,
                        textures.backdropColor.b,
                        textures.backdropColor.a
                    )
                    frame.Health.customMask = mask
                end
            end
        end

        if _G["ElvUF_Player_PowerBar"] and _G["ElvUF_Player_PowerBar"].backdropTex then
            local powerBar = _G["ElvUF_Player_PowerBar"]
            local texture = LSM:Fetch("statusbar", textures.powerTexture)
            powerBar.backdropTex:SetTexture(texture)
            powerBar.backdropTex:SetVertexColor(
                textures.backdropColor.r,
                textures.backdropColor.g,
                textures.backdropColor.b,
                textures.backdropColor.a
            )
        end

    elseif unit == "target" then
        CreateMaskedBackdrop("HealthBar", textures.healthTexture)

        if frame.Health and not frame.Health.customMask and frame.Health.CreateMaskTexture then
            local healthTex = frame.Health:GetStatusBarTexture()
            if healthTex then
                local mask = frame.Health:CreateMaskTexture()
                local texture = LSM:Fetch("statusbar", textures.healthTexture)
                mask:SetTexture(texture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                mask:SetAllPoints(frame.Health)
                if frame.Health.backdropTex then
                    frame.Health.backdropTex:AddMaskTexture(mask)
                    local backdropTexture = LSM:Fetch("statusbar", textures.backdropTexture)
                    frame.Health.backdropTex:SetTexture(backdropTexture)
                    frame.Health.backdropTex:SetVertexColor(
                        textures.backdropColor.r,
                        textures.backdropColor.g,
                        textures.backdropColor.b,
                        textures.backdropColor.a
                    )
                    frame.Health.customMask = mask
                end
            end
        end

        if _G["ElvUF_Target_PowerBar"] and _G["ElvUF_Target_PowerBar"].backdropTex then
            local powerBar = _G["ElvUF_Target_PowerBar"]
            local texture = LSM:Fetch("statusbar", textures.powerTexture)
            powerBar.backdropTex:SetTexture(texture)
            powerBar.backdropTex:SetVertexColor(
                textures.backdropColor.r,
                textures.backdropColor.g,
                textures.backdropColor.b,
                textures.backdropColor.a
            )
        end
    end

    if frame.UpdateAllElements then
        frame:UpdateAllElements("Force")
    end
    
    print("Finished applying textures to", unit)
end

function MilaUI_Textures:ApplyAllTextures()
    self:ApplyTextures("player")
    self:ApplyTextures("target")
end

-- Initialize
function MilaUI_Textures:Initialize()
    -- Register all the events this addon listens to
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    self:SetScript("OnEvent", function(_, event, unit)
        if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
            print("MilaUI: Player login/entering world, applying textures")
            -- Using ElvUI hook system, setup a post hook after ElvUI updates the unit frames
            if ElvUI and ElvUI[1] and ElvUI[1].UnitFrames then
                print("MilaUI: Found ElvUI, setting up post hooks")
                local UF = ElvUI[1].UnitFrames
                if UF.CreateAndUpdateUF then
                    hooksecurefunc(UF, "CreateAndUpdateUF", function()
                        C_Timer.After(0.5, function() 
                            MilaUI_Textures:ApplyAllTextures()
                        end)
                    end)
                end
                
                if UF.CreateAndUpdateUFGroup then
                    hooksecurefunc(UF, "CreateAndUpdateUFGroup", function()
                        C_Timer.After(0.5, function() 
                            MilaUI_Textures:ApplyAllTextures()
                        end)
                    end)
                end
            end
            
            self:ApplyAllTextures()
        elseif event == "PLAYER_TARGET_CHANGED" then
            print("MilaUI: Target changed, resetting and applying textures")
            ResetTextureFlag("target")
            self:ApplyTextures("target")
        end
    end)
end

-- Add to MilaUI namespace for access by other modules
MilaUI.modules.unitframes.MilaUI_Textures = MilaUI_Textures

-- Initialize the module
MilaUI_Textures:Initialize()

-- Create a simpler command just for the GUI
SLASH_MILAUITEXTURES1 = '/muitex'
SlashCmdList['MILAUITEXTURES'] = function(msg)
    if msg == "reload" then
        ReloadUI()
    elseif msg == "debug" then
        -- Extra debug information
        print("|cFF00FF00MilaUI Texture Debug:|r")
        print("ElvUF_Player exists:", _G["ElvUF_Player"] ~= nil)
        print("ElvUF_Player.Health exists:", _G["ElvUF_Player"] and _G["ElvUF_Player"].Health ~= nil)
        print("ElvUF_Target exists:", _G["ElvUF_Target"] ~= nil)
        print("ElvUF_Player_HealthBar exists:", _G["ElvUF_Player_HealthBar"] ~= nil)
        print("ElvUF_Player_PowerBar exists:", _G["ElvUF_Player_PowerBar"] ~= nil)
        
        -- Check LibSharedMedia
        print("LSM:", LSM ~= nil)
        print("Texture exists:", LSM:IsValid("statusbar", "a-Mila Health 01"))
        print("LSM Fetch result:", LSM:Fetch("statusbar", "a-Mila Health 01"))
    else
        -- Print debug info about what's happening
        print("|cFF00FF00MilaUI:|r Applying textures...")
        if MilaUI.modules and MilaUI.modules.unitframes and MilaUI.modules.unitframes.config then
            local config = MilaUI.modules.unitframes.config
            print("Config enabled:", config.enabled)
            if config.player then
                print("Player textures:")
                print("  Health:", config.player.healthTexture)
                print("  Power:", config.player.powerTexture)
            end
            if config.target then
                print("Target textures:")
                print("  Health:", config.target.healthTexture)
                print("  Power:", config.target.powerTexture)
            end
        else
            print("|cFFFF0000MilaUI:|r Config not found!")
        end
        
        -- Force reapply textures
        if MilaUI_Textures then
            -- Reset texture flags to force reapplication
            ResetTextureFlag("player")
            ResetTextureFlag("target")
            MilaUI_Textures:ApplyAllTextures()
            print("|cFF00FF00MilaUI:|r Textures applied.")
            
            -- Show if frames exist
            print("Player frame exists:", _G["ElvUF_Player"] ~= nil)
            print("Target frame exists:", _G["ElvUF_Target"] ~= nil)
        else
            print("|cFFFF0000MilaUI:|r MilaUI_Textures not found!")
        end
    end
end
