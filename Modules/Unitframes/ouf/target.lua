print("|cff00ff00MilaUI Target Unitframe Loaded|r") -- Bright green message

local oUF = oUF
if not oUF then
    print("|cffff0000MilaUI: oUF not found!|r") -- Bright red error
    return
end
print("|cff00ff00MilaUI: oUF found.|r")

-- Define the addon namespace FIRST
local MilaUI = _G.MilaUI or {}
_G.MilaUI = MilaUI -- Make it global if it isn't already

-- If colors aren't defined yet (in case target.lua loads before player.lua)
if not MilaUI.colors then
    MilaUI.colors = {
        power = {
            ["MANA"] = {0, 0.82, 1},       -- Blue
            ["RAGE"] = {0.69, 0.31, 0.31},       -- Red
            ["FOCUS"] = {0.71, 0.43, 0.27},      -- Orange/Brown
            ["ENERGY"] = {0.65, 0.63, 0.35},     -- Yellow
            ["RUNIC_POWER"] = {0, 0.82, 1},      -- Light Blue
            ["LUNAR_POWER"] = {0.3, 0.52, 0.9},  -- Light Blue/Purple
            ["MAELSTROM"] = {0, 0.5, 1},         -- Blue
            ["INSANITY"] = {0.4, 0, 0.8},        -- Purple
            ["FURY"] = {0.78, 0.26, 0.99},       -- Purple/Pink
            ["PAIN"] = {1, 0.61, 0},             -- Orange
            ["SOUL_SHARDS"] = {0.5, 0.32, 0.55}, -- Purple
            ["HOLY_POWER"] = {0.95, 0.9, 0.6},   -- Light Yellow
            ["COMBO_POINTS"] = {1, 0.96, 0.41},  -- Yellow
            ["CHI"] = {0.71, 1, 0.92},           -- Light Green
            ["ARCANE_CHARGES"] = {0.1, 0.1, 0.98}, -- Blue
            ["ESSENCE"] = {0.4, 0.8, 0.9}        -- Light Blue
        }
    }
end

-- Define or extend media files for target frame
if not MilaUI.media then
    MilaUI.media = {}
end

-- Add target-specific media if not already defined
MilaUI.media.targetStatusbarTexture = MilaUI.media.targetStatusbarTexture or "Interface\\AddOns\\MilaUI\\media\\statusbars\\Mila7"
MilaUI.media.targetPowerbarTexture = MilaUI.media.targetPowerbarTexture or "Interface\\AddOns\\MilaUI\\media\\statusbars\\Mila6"
MilaUI.media.font = MilaUI.media.font or "Interface\\AddOns\\MilaUI\\media\\fonts\\Black Desert.ttf"

-- Add target-specific masks
if not MilaUI.media.masks then
    MilaUI.media.masks = {}
end

-- Target-specific masks - you can change these to different files
MilaUI.media.masks.targetHealthbar = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Masks\\Mila_Health_mask_target.tga"
MilaUI.media.masks.targetPowerbar = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Masks\\Mila_Power_Mask_target.tga" -- Mask for the actual power bar
MilaUI.media.masks.targetPowerbackdrop = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Masks\\Mila_Health_Mask.tga" -- Mask for the backdrop

print("|cff00ff00MilaUI: Target media defined.|r")

--[[ Style Function for Target Frame ]]--
local function StyleTargetFrame(self, unit)
    print("|cffffcc00MilaUI: Styling frame for unit:", unit, "|r") -- Yellow message

    -- This 'self' refers to the unit frame object created by oUF.
    -- The 'unit' is the specific unit this frame represents (target)

    -- Make the frame movable in configuration mode (optional)
    self:SetAttribute("type", "target")
    self:RegisterForDrag("LeftButton")
    self:EnableMouse(true)
    
    -- Set the overall size of the frame
    self:SetSize(383, 34)

    -- Create a backdrop using BackdropTemplate (modern WoW method)
    local backdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
    backdrop:SetAllPoints(self)
    backdrop:SetBackdrop({
        bgFile = MilaUI.media.masks.targetHealthbar, -- Use target-specific background
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    backdrop:SetBackdropColor(0, 0, 0, 0.8) -- Black, 80% alpha
    self.Backdrop = backdrop -- Store reference to the backdrop

    --[[ Health Bar ]]--
    -- Create a container for the health bar to control its positioning
    local HealthContainer = CreateFrame("Frame", nil, self)
    HealthContainer:SetHeight(34) -- Set the height
    HealthContainer:SetWidth(295) -- Set explicit width
    HealthContainer:SetPoint("TOP", self, "TOP", 0, 0) -- Position it with a single anchor point
    
    -- Create the actual health bar
    local Health = CreateFrame("StatusBar", nil, HealthContainer)
    Health:SetStatusBarTexture(MilaUI.media.targetStatusbarTexture)
    
    -- Set explicit size for the health bar
    Health:SetHeight(34)
    Health:SetWidth(295) -- Can be different from container width
    Health:SetPoint("TOPLEFT", HealthContainer, "TOPLEFT", 0, 0) -- Anchor to top-left for target
    
    -- Apply mask to the health bar if mask texture exists
    if MilaUI.media.masks and MilaUI.media.masks.targetHealthbar then
        local texture = Health:GetStatusBarTexture()
        if texture and texture.SetMask then
            texture:SetMask(MilaUI.media.masks.targetHealthbar)
            print("|cff00ff00MilaUI: Applied mask to target health bar|r")
        else
            print("|cffff0000MilaUI: SetMask method not available for target health bar texture|r")
        end
    end
    
    Health:SetStatusBarColor(0, 1, 0) -- Green color for health

    -- Add health text (optional)
    Health.Text = Health:CreateFontString(nil, "OVERLAY")
    Health.Text:SetFont(MilaUI.media.font, 12, "OUTLINE")
    Health.Text:SetPoint("CENTER", Health, "CENTER")
    Health.Text:SetText("Health") -- Placeholder, oUF handles updating this

    -- Tell oUF this is the Health element
    self.Health = Health

    --[[ Power Bar ]]--
    -- First create a container frame to hold both the backdrop and power bar
    local PowerContainer = CreateFrame("Frame", nil, self)
    PowerContainer:SetHeight(34) -- Height for the container
    PowerContainer:SetWidth(295) -- Explicit width for container
    
    -- Position the container but don't use SetPoint with both LEFT and RIGHT anchors
    PowerContainer:SetPoint("TOP", HealthContainer, "BOTTOM", 0, -5)
    
    -- Create the backdrop first (full parallelogram)
    local PowerBackdrop = PowerContainer:CreateTexture(nil, 'BACKGROUND')
    PowerBackdrop:SetAllPoints(PowerContainer)
    PowerBackdrop:SetTexture(MilaUI.media.targetPowerbarTexture)
    PowerBackdrop:SetVertexColor(0.1, 0.1, 0.1, 0.8) -- Dark color
    
    -- Apply mask to the backdrop
    if MilaUI.media.masks and MilaUI.media.masks.targetPowerbackdrop then
        if PowerBackdrop.SetMask then
            PowerBackdrop:SetMask(MilaUI.media.masks.targetPowerbackdrop)
            print("|cff00ff00MilaUI: Applied mask to target power backdrop|r")
        end
    end
    
    -- Now create the actual power bar (only top half)
    local Power = CreateFrame("StatusBar", nil, PowerContainer)
    Power:SetStatusBarTexture(MilaUI.media.targetPowerbarTexture)
    print("|cff00ff00MilaUI: Target power bar texture set to:", MilaUI.media.targetPowerbarTexture, "|r")
    
    -- Set the power bar to only use the top half of the container with explicit width
    Power:SetHeight(17) -- Half the height of the container
    Power:SetWidth(278) -- Explicit width for power bar
    Power:SetPoint("TOPLEFT", PowerContainer, "TOPLEFT", 0, 0)
    
    -- Apply mask to the power bar
    if MilaUI.media.masks and MilaUI.media.masks.targetPowerbar then
        local texture = Power:GetStatusBarTexture()
        if texture and texture.SetMask then
            texture:SetMask(MilaUI.media.masks.targetPowerbar)
            print("|cff00ff00MilaUI: Applied mask to target power bar|r")
        else
            print("|cffff0000MilaUI: SetMask method not available for target power bar texture|r")
        end
    end

    -- Add power text (optional)
    Power.Text = Power:CreateFontString(nil, "OVERLAY")
    Power.Text:SetFont(MilaUI.media.font, 10, "OUTLINE")
    Power.Text:SetPoint("CENTER", Power, "CENTER")
    Power.Text:SetText("Power") -- Placeholder, oUF handles updating this

    -- Enable oUF coloring options - these might override your texture colors
    Power.colorTapping = false      -- DISABLED - we'll use our custom colors
    Power.colorDisconnected = true  -- Keep this for disconnected units
    Power.colorPower = false        -- DISABLED - we'll use our custom colors instead
    
    -- Use our custom colors instead of oUF's default colors
    Power.useAtlasSize = false -- Don't use the atlas size
    
    -- Override the PostUpdate function to apply our custom colors
    Power.PostUpdate = function(power, unit)
        if not unit then return end
        
        -- Don't color if unit is disconnected (let oUF handle that)
        if not UnitIsConnected(unit) then
            return
        end
        
        local powerType, powerToken = UnitPowerType(unit)
        local color = MilaUI.colors.power[powerToken]
        
        if color then
            -- Force our custom color
            power:SetStatusBarColor(unpack(color))
            print("|cff00ff00MilaUI: Target power color set for", powerToken, ":", color[1], color[2], color[3], "|r")
        else
            -- Fallback to a default blue color if we don't have a custom color for this power type
            power:SetStatusBarColor(0, 0.55, 1)
            print("|cffff9900MilaUI: Unknown target power type:", powerToken, "- using default blue|r")
        end
    end
    
    -- Also add a custom color update function that runs when the power type changes
    Power.UpdateColor = function(power, unit)
        if not unit then return end
        
        -- Call our PostUpdate function to apply the color
        if power.PostUpdate then
            power:PostUpdate(unit)
        end
    end
    
    -- Make the background darker
    local Background = PowerBackdrop
    Background.multiplier = 0.3 -- Lower value = darker background
    
    -- Register background with oUF - THIS IS CRITICAL
    Power.bg = Background

    -- Tell oUF this is the Power element
    self.Power = Power
    
    --[[ Power Bar Borders ]]--
    -- Get the next frame strata level for power borders
    local powerStrata = PowerContainer:GetFrameStrata()
    local powerStrataLevels = {
        "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"
    }
    
    local powerCurrentLevel = 1
    for i, level in ipairs(powerStrataLevels) do
        if level == powerStrata then
            powerCurrentLevel = i
            break
        end
    end
    
    local powerNextStrata = powerStrataLevels[powerCurrentLevel + 1] or "TOOLTIP"
    if powerCurrentLevel == #powerStrataLevels then
        powerNextStrata = powerStrataLevels[#powerStrataLevels]
    end
    
    -- Create a frame one strata higher for power borders
    local powerOverlayFrame = CreateFrame("Frame", nil, PowerContainer)
    powerOverlayFrame:SetAllPoints(PowerContainer)
    powerOverlayFrame:SetFrameStrata(powerNextStrata)
    
    -- Create top border texture for power
    local powerTopBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
    powerTopBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    powerTopBorder:SetPoint("TOPLEFT", powerOverlayFrame, "TOPLEFT", 3, 3)
    powerTopBorder:SetSize(264, 6)
    powerTopBorder:SetVertexColor(1, 1, 1, 0.8)
    
    -- Create bottom border texture for power
    local powerBottomBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
    powerBottomBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    powerBottomBorder:SetPoint("BOTTOMLEFT", powerOverlayFrame, "BOTTOMLEFT", -3, -3)
    powerBottomBorder:SetSize(264, 6)
    powerBottomBorder:SetVertexColor(1, 1, 1, 0.8)
    
    -- Create left border texture with rotation for power
    local powerLeftBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
    powerLeftBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    powerLeftBorder:SetSize(45, 6)
    
    -- Set rotation angle for power left border
    local powerAngle = math.rad(135)
    powerLeftBorder:SetRotation(powerAngle)
    
    -- Calculate offset to position the rotated texture correctly
    local powerWidth, powerHeight = powerLeftBorder:GetSize()
    local powerOffsetX = -8
    local powerOffsetY = -14
    
    powerLeftBorder:SetPoint("TOPLEFT", powerOverlayFrame, "TOPLEFT", powerOffsetX, powerOffsetY)
    powerLeftBorder:SetVertexColor(1, 1, 1, 0.8)
    
    -- Create right border texture with rotation for power
    local powerRightBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
    powerRightBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    powerRightBorder:SetSize(45, 6)
    
    -- Set rotation angle for power right border
    local powerRightAngle = math.rad(135)
    powerRightBorder:SetRotation(powerRightAngle)
    
    -- Calculate offset to position the rotated texture correctly
    local powerRightWidth, powerRightHeight = powerRightBorder:GetSize()
    local powerRightOffsetX = 8
    local powerRightOffsetY = -14
    
    powerRightBorder:SetPoint("TOPRIGHT", powerOverlayFrame, "TOPRIGHT", powerRightOffsetX, powerRightOffsetY)
    powerRightBorder:SetVertexColor(1, 1, 1, 0.8)
    
    -- Store reference to the power border elements
    self.PowerBorder = {
        frame = powerOverlayFrame,
        top = powerTopBorder,
        bottom = powerBottomBorder,
        left = powerLeftBorder,
        right = powerRightBorder
    }

    --[[ Name Text ]]--
    -- Add a name text element (not in player frame)
    local Name = Health:CreateFontString(nil, "OVERLAY")
    Name:SetFont(MilaUI.media.font, 14, "OUTLINE")
    Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
    Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
    Name:SetJustifyH("LEFT")
    
    -- Tell oUF this is the Name element
    self.Name = Name

    --[[ Custom Border ]]--
    -- Get the next frame strata level
    local strata = self:GetFrameStrata()
    local strataLevels = {
        "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"
    }
    
    local currentLevel = 1
    for i, level in ipairs(strataLevels) do
        if level == strata then
            currentLevel = i
            break
        end
    end
    
    local nextStrata = strataLevels[currentLevel + 1] or "TOOLTIP"
    if currentLevel == #strataLevels then
        nextStrata = strataLevels[#strataLevels]
    end
    
    -- Create a frame one strata higher
    local overlayFrame = CreateFrame("Frame", nil, self)
    overlayFrame:SetAllPoints(self)
    overlayFrame:SetFrameStrata(nextStrata)
    
    -- Create top border texture
    local topBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
    topBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    topBorder:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT", 3, 3) -- Mirrored from right to left
    topBorder:SetSize(264, 6)
    topBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
    
    -- Create bottom border texture
    local bottomBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
    bottomBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    bottomBorder:SetPoint("BOTTOMLEFT", overlayFrame, "BOTTOMLEFT", -3, -33) -- Mirrored from right to left
    bottomBorder:SetSize(264, 6)
    bottomBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
    
    -- Create left border texture with rotation
    local leftBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
    leftBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    leftBorder:SetSize(50, 6)
    
    -- Set rotation angle (45 degrees = top-left to bottom-right diagonal, mirrored from player frame)
    local angle = math.rad(45) -- Changed from 135 to 45 for mirroring
    leftBorder:SetRotation(angle)
    
    -- Calculate offset to position the rotated texture correctly
    local width, height = leftBorder:GetSize()
    local offsetX = -8 -- Positive instead of negative
    local offsetY = -14
    
    leftBorder:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT", offsetX, offsetY)
    leftBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
    
    -- Create right border texture with rotation
    local rightBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
    rightBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
    rightBorder:SetSize(50, 6)
    
    -- Set rotation angle (135 degrees = top-right to bottom-left diagonal, mirrored from player frame)
    local rightAngle = math.rad(45) -- Changed from 45 to 135 for mirroring
    rightBorder:SetRotation(rightAngle)
    
    -- Calculate offset to position the rotated texture correctly
    local rightWidth, rightHeight = rightBorder:GetSize()
    local rightOffsetX = 8 -- Negative instead of positive
    local rightOffsetY = -14
    
    rightBorder:SetPoint("TOPRIGHT", overlayFrame, "TOPRIGHT", rightOffsetX, rightOffsetY)
    rightBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
    
    -- Store reference to the border elements
    self.CustomBorder = {
        frame = overlayFrame,
        top = topBorder,
        bottom = bottomBorder,
        left = leftBorder,
        right = rightBorder
    }

    --[[ Add more elements here as needed (e.g., Castbar, Portraits, Auras, etc.) ]]--
end

oUF:RegisterStyle("MilaUITargetStyle", StyleTargetFrame)
print("|cff00ff00MilaUI: Target style registered.|r")
oUF:SetActiveStyle("MilaUITargetStyle")
print("|cff00ff00MilaUI: Target style activated.|r")

local targetFrame = oUF:Spawn("target", "MilaUITargetFrame")
print("|cff00ff00MilaUI: Target frame spawned:", targetFrame and targetFrame:GetName() or "ERROR/NIL", "|r")
targetFrame:SetPoint("CENTER", UIParent, "CENTER", 250, -150) -- Position on the right side