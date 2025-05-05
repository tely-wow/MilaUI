--[[
	MilaUI - ShadowedUnitFrames Integration
	Applies custom masks to ShadowedUnitFrames health and power bars
]]

local addonName, ns = ...
local SUF_Masks = CreateFrame("Frame")
local ShadowUF = ShadowUF

-- Configuration
local config = {
    enabled = true,
    debug = false,
    media = {
        -- Default mask paths
        defaultHealthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram.tga",
        defaultPowerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para.tga",
        
        -- Unit-specific mask paths (override defaults)
        playerHealthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram.tga",
        playerPowerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para.tga",
        targetHealthMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\parallelogram2.tga",
        targetPowerMask = "Interface\\Addons\\MilaUI\\media\\Statusbars\\masks\\power_para2.tga",
        
        -- Border overlay textures
        borderTexture = "Interface\\Buttons\\WHITE8X8", -- Default border texture
        availableBorderTextures = {
            ["Interface\\Buttons\\WHITE8X8"] = "Solid",
            ["Interface\\DialogFrame\\UI-DialogBox-Border"] = "Dialog",
            ["Interface\\Tooltips\\UI-Tooltip-Border"] = "Tooltip",
            ["Interface\\PVPFrame\\UI-Character-PVP-Highlight"] = "PVP Highlight",
            ["Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Border"] = "Achievement"
        },
        
        -- Optional texture overrides
        healthTexture = nil, -- Set to a texture path to override the default texture
        powerTexture = nil, -- Set to a texture path to override the default texture
    },
    
    -- Border overlay settings
    border = {
        enabled = true,
        inset = 0, -- Inset from the edge of the bar
        thickness = 1, -- Border thickness
        texture = "Interface\\Buttons\\WHITE8X8", -- Border texture
        color = {r = 0.3, g = 0.3, b = 0.3, a = 1.0}, -- Border color
    },
    
    units = {
        player = { 
            enabled = true,
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
            enabled = true,
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
        targettarget = { enabled = true },
        focus = { 
            enabled = true,
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
            enabled = true,
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
        party = { enabled = true },
        raid = { enabled = true },
        boss = { 
            enabled = true,
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
    },
}

-- Debug print helper
local function DebugPrint(...)
    if config.debug then
        print("|cff1784d1MilaUI|r |cffceff00SUF Masks|r:", ...)
    end
end

-- Check if a file exists
local function FileExists(path)
    if not path or path == "" then return false end
    local tex = UIParent:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(path)
    local fileID = tex:GetTextureFileID()
    tex:Hide()
    return fileID ~= nil and fileID ~= 0
end

-- Apply a mask to a texture object
local function ApplyMask(texture, maskPath)
    if not texture then
        DebugPrint("ApplyMask: Texture object is nil")
        return
    end
    
    if not maskPath or maskPath == "" then
        DebugPrint("ApplyMask: No mask path provided, clearing mask.")
        texture:SetMask(nil) -- Clear existing mask if path is empty
        return
    end
    
    if not FileExists(maskPath) then
        DebugPrint("ApplyMask: Mask file doesn't exist:", maskPath)
        texture:SetMask(nil) -- Clear mask if file is invalid
        return
    end
    
    -- Apply the mask
    texture:SetMask(maskPath)
    DebugPrint("Applied mask:", maskPath, "to texture:", texture:GetName() or "(unnamed texture)")
end

-- Apply custom texture to a bar
local function ApplyTexture(bar, texturePath)
    if not bar or not texturePath then return end
    
    -- Check if the texture file exists
    if not FileExists(texturePath) then
        DebugPrint("Texture file doesn't exist:", texturePath)
        return
    end
    
    -- Apply the texture
    bar:SetStatusBarTexture(texturePath)
    DebugPrint("Applied texture:", texturePath)
end

-- Get the appropriate mask path for a unit
local function GetMaskPath(unitType, barType)
    -- Check for unit-specific masks first
    if unitType == "player" then
        if barType == "health" then
            return config.media.playerHealthMask
        elseif barType == "power" then
            return config.media.playerPowerMask
        end
    elseif unitType == "target" then
        if barType == "health" then
            return config.media.targetHealthMask
        elseif barType == "power" then
            return config.media.targetPowerMask
        end
    end
    
    -- Fall back to default masks
    if barType == "health" then
        return config.media.defaultHealthMask
    elseif barType == "power" then
        return config.media.defaultPowerMask
    end
    
    return nil
end

-- Update an existing border overlay
local function UpdateBorderOverlay(bar, unitType, barType)
    if not bar.borderOverlay then return end
    
    -- Get unit config
    local unitConfig = config.units[unitType]
    if not unitConfig or not unitConfig[barType .. "Border"] or not unitConfig[barType .. "Border"].enabled then
        bar.borderOverlay:Hide()
        return
    end
    
    -- Show the border
    bar.borderOverlay:Show()
    
    -- Get border settings
    local thickness = unitConfig[barType .. "Border"].thickness or config.border.thickness
    local texture = unitConfig[barType .. "Border"].texture or config.border.texture
    local color = unitConfig[barType .. "Border"].color or config.border.color
    
    -- Set border texture
    if texture == "Interface\\Buttons\\WHITE8X8" then
        -- Use a solid color for the default texture
        bar.borderOverlay.texture:SetColorTexture(color.r, color.g, color.b, color.a)
    else
        -- Use the specified texture
        bar.borderOverlay.texture:SetTexture(texture)
        bar.borderOverlay.texture:SetVertexColor(color.r, color.g, color.b, color.a)
    end
    
    -- Apply texture coordinates to properly show the border part of the texture
    bar.borderOverlay.texture:SetTexCoord(0, 1, 0, 1)
end

-- Apply a border overlay to a bar
local function ApplyBorderOverlay(bar, unitType, barType)
    -- If the bar already has a border overlay, just update it
    if bar.borderOverlay then
        UpdateBorderOverlay(bar, unitType, barType)
        return
    end
    
    -- Create a frame for the border overlay
    bar.borderOverlay = CreateFrame("Frame", nil, bar)
    bar.borderOverlay:SetFrameLevel(bar:GetFrameLevel() + 5) -- Above the bar
    bar.borderOverlay:SetAllPoints(bar)
    
    -- Create border texture
    bar.borderOverlay.texture = bar.borderOverlay:CreateTexture(nil, "OVERLAY")
    bar.borderOverlay.texture:SetAllPoints(bar.borderOverlay)
    
    -- Update the border overlay
    UpdateBorderOverlay(bar, unitType, barType)
end

-- Apply mask to health bar
local function ApplyHealthMask(frame)
    -- Skip target frame if no unit exists
    if frame.unitType == "target" and not UnitExists("target") then
        DebugPrint("ApplyHealthMask: Skipping target frame, no unit exists.")
        -- Optionally: Add code here to apply a default/empty mask if needed when target is lost
        -- Example: ApplyMask(frame.healthBar:GetStatusBarTexture(), nil) -- Clear mask
        return
    end

    if not frame or not frame.healthBar then return end
    
    local healthBar = frame.healthBar
    local texture = healthBar:GetStatusBarTexture()
    
    if texture then
        local maskPath = GetMaskPath(frame.unitType, "health")
        ApplyMask(texture, maskPath)
        
        -- Apply custom texture if specified
        if config.media.healthTexture then
            ApplyTexture(healthBar, config.media.healthTexture)
            -- Re-get the texture after setting it
            texture = healthBar:GetStatusBarTexture()
            ApplyMask(texture, maskPath)
        end
        
        -- Apply border overlay
        ApplyBorderOverlay(healthBar, frame.unitType, "health")
    end
end

-- Apply mask to power bar
local function ApplyPowerMask(frame)
    -- Skip target frame if no unit exists
    if frame.unitType == "target" and not UnitExists("target") then
         DebugPrint("ApplyPowerMask: Skipping target frame, no unit exists.")
         -- Optionally: Add code here to apply a default/empty mask if needed when target is lost
         -- Example: ApplyMask(frame.powerBar:GetStatusBarTexture(), nil) -- Clear mask
         return
    end

    if not frame or not frame.powerBar then return end
    
    local powerBar = frame.powerBar
    local texture = powerBar:GetStatusBarTexture()
    
    if texture then
        local maskPath = GetMaskPath(frame.unitType, "power")
        ApplyMask(texture, maskPath)
        
        -- Apply custom texture if specified
        if config.media.powerTexture then
            ApplyTexture(powerBar, config.media.powerTexture)
            -- Re-get the texture after setting it
            texture = powerBar:GetStatusBarTexture()
            ApplyMask(texture, maskPath)
        end
        
        -- Apply border overlay
        ApplyBorderOverlay(powerBar, frame.unitType, "power")
    end
end

-- Apply masks to a frame
local function ApplyMasks(frame)
    if not frame or not frame.unitType then 
        DebugPrint("ApplyMasks: Skipping frame with no unitType:", frame:GetName() or "unnamed")
        return 
    end
    
    DebugPrint("ApplyMasks: Processing frame:", frame:GetName() or "unnamed", "UnitType:", frame.unitType)
    
    -- Check if this unit type is enabled
    local unitConfig = config.units[frame.unitType]
    
    local enabled_status = "nil"
    if unitConfig then
        enabled_status = tostring(unitConfig.enabled)
    end
    DebugPrint("ApplyMasks: Checking enabled status for", frame.unitType, "-", enabled_status) 
    
    if not unitConfig or not unitConfig.enabled then 
        DebugPrint("ApplyMasks: Skipping disabled unit type:", frame.unitType)
        return 
    end
    
    DebugPrint("Applying masks to", frame.unitType, frame:GetName() or "unnamed")
    
    -- Apply masks to health and power bars
    ApplyHealthMask(frame)
    ApplyPowerMask(frame)
end

-- Hook into ShadowUF's CreateBar function to apply masks to newly created bars
local originalCreateBar
local function HookCreateBar()
    if not originalCreateBar then
        originalCreateBar = ShadowUF.Units.CreateBar
        
        ShadowUF.Units.CreateBar = function(self, parent, ...)
            local bar = originalCreateBar(self, parent, ...)
            
            -- Schedule a delayed mask application to ensure the texture is created
            C_Timer.After(0.1, function()
                if parent and parent.unitType then
                    if bar == parent.healthBar then
                        ApplyHealthMask(parent)
                    elseif bar == parent.powerBar then
                        ApplyPowerMask(parent)
                    end
                end
            end)
            
            return bar
        end
        
        DebugPrint("Hooked CreateBar function")
    end
end

-- Hook into ShadowUF's Update functions to reapply masks when bars are updated
local function HookUpdateFunctions()
    -- Hook Health:Update
    local originalHealthUpdate
    if ShadowUF.modules.healthBar and ShadowUF.modules.healthBar.Update then
        originalHealthUpdate = ShadowUF.modules.healthBar.Update
        
        ShadowUF.modules.healthBar.Update = function(self, frame, ...)
            originalHealthUpdate(self, frame, ...)
            
            -- Reapply mask after update
            C_Timer.After(0.1, function()
                ApplyHealthMask(frame)
            end)
        end
        
        DebugPrint("Hooked Health:Update function")
    end
    
    -- Hook Power:Update
    local originalPowerUpdate
    if ShadowUF.modules.powerBar and ShadowUF.modules.powerBar.Update then
        originalPowerUpdate = ShadowUF.modules.powerBar.Update
        
        ShadowUF.modules.powerBar.Update = function(self, frame, ...)
            originalPowerUpdate(self, frame, ...)
            
            -- Reapply mask after update
            C_Timer.After(0.1, function()
                ApplyPowerMask(frame)
            end)
        end
        
        DebugPrint("Hooked Power:Update function")
    end
end

-- Apply masks to all existing frames
local function ApplyMasksToAllFrames()
    for frame in pairs(ShadowUF.Units.frameList) do
        if frame.unit then
            ApplyMasks(frame)
        end
    end
    
    DebugPrint("Applied masks to all existing frames")
end

-- Initialize the addon
function SUF_Masks:OnInitialize()
    if not config.enabled then return end
    
    HookCreateBar()
    HookUpdateFunctions()
    
    -- Apply masks to existing frames after a short delay
    C_Timer.After(1, ApplyMasksToAllFrames) 
    
    -- Handle target changes
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "HandleTargetChanged")
    
    DebugPrint("Initialized")
end

-- Event handler for target changes
function SUF_Masks:HandleTargetChanged()
    DebugPrint("PLAYER_TARGET_CHANGED event fired")
    
    -- Find the target frame (ShadowUF often stores frames in ShadowUF.Units)
    local targetFrame = ShadowUF.Units and ShadowUF.Units.target
    if not targetFrame then 
        DebugPrint("HandleTargetChanged: Could not find target frame object.")
        return
    end

    if UnitExists("target") then
        DebugPrint("HandleTargetChanged: Target acquired, applying masks.")
        -- Target exists, ensure masks are applied
        ApplyHealthMask(targetFrame)
        ApplyPowerMask(targetFrame)
    else
        DebugPrint("HandleTargetChanged: Target lost, clearing masks.")
        -- Target lost, clear the masks by applying nil
        if targetFrame.healthBar then
            local texture = targetFrame.healthBar:GetStatusBarTexture()
            if texture then ApplyMask(texture, nil) end
        end
        if targetFrame.powerBar then
            local texture = targetFrame.powerBar:GetStatusBarTexture()
            if texture then ApplyMask(texture, nil) end
        end
        -- Optionally clear borders too if needed
        -- Example: if targetFrame.healthBar.borderOverlay then targetFrame.healthBar.borderOverlay:Hide() end
    end
end

-- API functions exposed via ns.SUF_Masks
-- (SetPlayerHealthMask, SetPlayerPowerMask, etc.)
function SUF_Masks:SetPlayerHealthMask(maskPath)
    config.media.playerHealthMask = maskPath
    if config.debug then
        print("|cff1784d1MilaUI|r: Set player health mask to " .. maskPath)
    end
end

function SUF_Masks:SetPlayerPowerMask(maskPath)
    config.media.playerPowerMask = maskPath
    if config.debug then
        print("|cff1784d1MilaUI|r: Set player power mask to " .. maskPath)
    end
end

function SUF_Masks:SetTargetHealthMask(maskPath)
    config.media.targetHealthMask = maskPath
    if config.debug then
        print("|cff1784d1MilaUI|r: Set target health mask to " .. maskPath)
    end
end

function SUF_Masks:SetTargetPowerMask(maskPath)
    config.media.targetPowerMask = maskPath
    if config.debug then
        print("|cff1784d1MilaUI|r: Set target power mask to " .. maskPath)
    end
end

function SUF_Masks:SetPlayerHealthBorder(enabled, color, texture)
    if not config.units.player.healthBorder then
        config.units.player.healthBorder = {}
    end
    config.units.player.healthBorder.enabled = enabled
    if color then
        config.units.player.healthBorder.color = color
    end
    if texture then
        config.units.player.healthBorder.texture = texture
    end
    if config.debug then
        print("|cff1784d1MilaUI|r: Set player health border enabled: " .. tostring(enabled))
        if texture then
            print("|cff1784d1MilaUI|r: Set player health border texture: " .. texture)
        end
    end
end

function SUF_Masks:SetPlayerPowerBorder(enabled, color, texture)
    if not config.units.player.powerBorder then
        config.units.player.powerBorder = {}
    end
    config.units.player.powerBorder.enabled = enabled
    if color then
        config.units.player.powerBorder.color = color
    end
    if texture then
        config.units.player.powerBorder.texture = texture
    end
    if config.debug then
        print("|cff1784d1MilaUI|r: Set player power border enabled: " .. tostring(enabled))
        if texture then
            print("|cff1784d1MilaUI|r: Set player power border texture: " .. texture)
        end
    end
end

function SUF_Masks:SetTargetHealthBorder(enabled, color, texture)
    if not config.units.target.healthBorder then
        config.units.target.healthBorder = {}
    end
    config.units.target.healthBorder.enabled = enabled
    if color then
        config.units.target.healthBorder.color = color
    end
    if texture then
        config.units.target.healthBorder.texture = texture
    end
    if config.debug then
        print("|cff1784d1MilaUI|r: Set target health border enabled: " .. tostring(enabled))
        if texture then
            print("|cff1784d1MilaUI|r: Set target health border texture: " .. texture)
        end
    end
end

function SUF_Masks:SetTargetPowerBorder(enabled, color, texture)
    if not config.units.target.powerBorder then
        config.units.target.powerBorder = {}
    end
    config.units.target.powerBorder.enabled = enabled
    if color then
        config.units.target.powerBorder.color = color
    end
    if texture then
        config.units.target.powerBorder.texture = texture
    end
    if config.debug then
        print("|cff1784d1MilaUI|r: Set target power border enabled: " .. tostring(enabled))
        if texture then
            print("|cff1784d1MilaUI|r: Set target power border texture: " .. texture)
        end
    end
end

function SUF_Masks:SetUnitHealthBorder(unitType, enabled, color, texture)
    if not config.units[unitType] then
        config.units[unitType] = { enabled = true }
    end
    
    if not config.units[unitType].healthBorder then
        config.units[unitType].healthBorder = {}
    end
    
    config.units[unitType].healthBorder.enabled = enabled
    if color then
        config.units[unitType].healthBorder.color = color
    end
    if texture then
        config.units[unitType].healthBorder.texture = texture
    end
    if config.debug then
        print("|cff1784d1MilaUI|r: Set " .. unitType .. " health border enabled: " .. tostring(enabled))
        if texture then
            print("|cff1784d1MilaUI|r: Set " .. unitType .. " health border texture: " .. texture)
        end
    end
end

function SUF_Masks:SetUnitPowerBorder(unitType, enabled, color, texture)
    if not config.units[unitType] then
        config.units[unitType] = { enabled = true }
    end
    
    if not config.units[unitType].powerBorder then
        config.units[unitType].powerBorder = {}
    end
    
    config.units[unitType].powerBorder.enabled = enabled
    if color then
        config.units[unitType].powerBorder.color = color
    end
    if texture then
        config.units[unitType].powerBorder.texture = texture
    end
    if config.debug then
        print("|cff1784d1MilaUI|r: Set " .. unitType .. " power border enabled: " .. tostring(enabled))
        if texture then
            print("|cff1784d1MilaUI|r: Set " .. unitType .. " power border texture: " .. texture)
        end
    end
end

-- Get available border textures
function SUF_Masks:GetAvailableBorderTextures()
    return config.media.availableBorderTextures
end

function SUF_Masks:SetDebugMode(enabled)
    config.debug = enabled
    print("|cff1784d1MilaUI|r: Debug mode " .. (enabled and "enabled" or "disabled"))
end

-- Make ApplyMasksToAllFrames accessible as a method
function SUF_Masks:ApplyMasksToAllFrames()
    ApplyMasksToAllFrames()
end

-- Register for ADDON_LOADED to initialize after ShadowUF is loaded
SUF_Masks:RegisterEvent("ADDON_LOADED")
SUF_Masks:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and (addon == "ShadowedUnitFrames" or addon == "MilaUI") then
        -- Wait for both addons to be loaded
        if IsAddOnLoaded("ShadowedUnitFrames") and IsAddOnLoaded("MilaUI") then
            self:UnregisterEvent("ADDON_LOADED")
            C_Timer.After(1, function() SUF_Masks:OnInitialize() end)
        end
    end
end)

-- Make the module accessible via the namespace
ns.SUF_Masks = SUF_Masks