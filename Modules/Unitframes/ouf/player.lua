print("|cff00ff00MilaUI Unitframes.lua Loaded|r") -- Bright green message

local oUF = oUF
if not oUF then
    print("|cffff0000MilaUI: oUF not found!|r") -- Bright red error
    return
end
print("|cff00ff00MilaUI: oUF found.|r")

-- Define the addon namespace FIRST
local MilaUI = _G.MilaUI or {}
_G.MilaUI = MilaUI -- Make it global if it isn't already

-- Define custom power colors
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

--[[ Media Files ]]--
-- Store paths to your media files for easy access
MilaUI.media = {
	statusbarTexture = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Mila7", -- Removed .tga extension
    powerbarTexture = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Mila5", -- Removed .tga extension
	font = "Interface\\AddOns\\MilaUI\\media\\fonts\\Black Desert.ttf", -- Default WoW font, or use your own like: "Interface\\AddOns\\MyAddon\\media\\myfont.ttf"
	masks = {
		-- Add your mask textures here. You'll need to create these files.
		healthbar = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Mila_Health_backdrop_2.tga",
		powerbar = "Interface\\AddOns\\MilaUI\\media\\statusbars\\powertest.tga", -- Mask for the actual power bar
		powerbackdrop = "Interface\\AddOns\\MilaUI\\media\\statusbars\\Mila_target_backdrop.tga", -- Mask for the backdrop
	}
}
print("|cff00ff00MilaUI: Media table defined.|r")


--[[ Style Function ]]--
-- This function defines how the elements of your unit frame look and behave.
local function StylePlayerFrame(self, unit)
    print("|cffffcc00MilaUI: Styling frame for unit:", unit, "|r") -- Yellow message

	-- This 'self' refers to the unit frame object created by oUF.
	-- The 'unit' is the specific unit this frame represents (e.g., "player", "target").

	-- Make the frame movable in configuration mode (optional)
	self:SetAttribute("type", "player")
	self:RegisterForDrag("LeftButton")
	self:EnableMouse(true)
	
	-- Set the overall size of the frame
	self:SetSize(383, 34)

	-- Create a backdrop using BackdropTemplate (modern WoW method)
	local backdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
	backdrop:SetAllPoints(self)
	backdrop:SetBackdrop({
		bgFile = MilaUI.media.masks.healthbar, -- Example background texture
		--insets = { left = 3, right = 3, top = 3, bottom = 3 }
	})
	backdrop:SetBackdropColor(0, 0, 0, 0.8) -- Black, 80% alpha
	self.Backdrop = backdrop -- Store reference to the backdrop

	--[[ Health Bar ]]--
	-- Create a container for the health bar to control its positioning
	local HealthContainer = CreateFrame("Frame", nil, self)
	HealthContainer:SetHeight(34) -- Set the height
	HealthContainer:SetWidth(383) -- Set explicit width
	HealthContainer:SetPoint("TOP", self, "TOP", 0, 0) -- Position it with a single anchor point
	
	-- Create the health bar
	local Health = CreateFrame("StatusBar", nil, HealthContainer)
	Health:SetStatusBarTexture(MilaUI.media.statusbarTexture)
	
	-- Set explicit size for the health bar
	Health:SetHeight(27)
	Health:SetWidth(285) -- Can be different from container width
	Health:SetPoint("TOPRIGHT", HealthContainer, "TOPRIGHT", 0, 0) -- Anchor to top-right
	
	-- Apply mask to the health bar if mask texture exists
	if MilaUI.media.masks and MilaUI.media.masks.healthbar then
		local texture = Health:GetStatusBarTexture()
		if texture.SetMask then -- Check if the method exists (for compatibility)
			texture:SetMask(MilaUI.media.masks.healthbar)
			print("|cff00ff00MilaUI: Applied mask to health bar|r")
		else
			print("|cffff0000MilaUI: SetMask method not available for health bar texture|r")
		end
	end
	
	-- Set health bar color to player's class color
	local _, playerClass = UnitClass("player")
	if playerClass and RAID_CLASS_COLORS[playerClass] then
		local c = RAID_CLASS_COLORS[playerClass]
		Health:SetStatusBarColor(c.r, c.g, c.b)
		print("|cff00ff00MilaUI: Applied class color to player health bar|r")
	else
		Health:SetStatusBarColor(0, 1, 0) -- Fallback to green if class color not found
	end
	
	-- Add health text (optional)
	Health.Text = Health:CreateFontString(nil, "OVERLAY")
	Health.Text:SetFont(MilaUI.media.font, 12, "OUTLINE") -- Use your font path here
	Health.Text:SetPoint("CENTER", Health, "CENTER")
	Health.Text:SetText("Health") -- Placeholder, oUF handles updating this

	-- Tell oUF this is the Health element
	self.Health = Health

	--[[ Power Bar ]]--
	-- First create a container frame to hold both the backdrop and power bar
	local PowerContainer = CreateFrame("Frame", nil, self)
	PowerContainer:SetHeight(34) -- Adjust height as needed
	PowerContainer:SetWidth(295) -- Set explicit width for container
	
	-- Position the container but don't use SetPoint with both LEFT and RIGHT anchors
	PowerContainer:SetPoint("TOP", HealthContainer, "BOTTOM", 0, -5)
	
	-- Create the backdrop first (full parallelogram)
	local PowerBackdrop = PowerContainer:CreateTexture(nil, 'BACKGROUND')
	PowerBackdrop:SetAllPoints(PowerContainer)
	PowerBackdrop:SetTexture(MilaUI.media.powerbarTexture)
	PowerBackdrop:SetVertexColor(0.1, 0.1, 0.1, 0.8) -- Dark color
	
	-- Apply mask to the backdrop
	if MilaUI.media.masks and MilaUI.media.masks.powerbackdrop then
		if PowerBackdrop.SetMask then
			PowerBackdrop:SetMask(MilaUI.media.masks.powerbackdrop)
			print("|cff00ff00MilaUI: Applied mask to power backdrop|r")
		end
	end
	
	-- Now create the actual power bar (only top half)
	local Power = CreateFrame("StatusBar", nil, PowerContainer)
	Power:SetStatusBarTexture(MilaUI.media.powerbarTexture)
	print("|cff00ff00MilaUI: Power bar texture set to:", MilaUI.media.powerbarTexture, "|r")
	
	-- Set the power bar to only use the top half of the container with explicit width
	Power:SetHeight(17) -- Half the height of the container
	Power:SetWidth(278) -- Set explicit width for power bar
	Power:SetPoint("TOPRIGHT", PowerContainer, "TOPRIGHT", 0, 0)
	
	-- Apply mask to the power bar
	if MilaUI.media.masks and MilaUI.media.masks.powerbar then
		local texture = Power:GetStatusBarTexture()
		if texture and texture.SetMask then
			texture:SetMask(MilaUI.media.masks.powerbar)
			print("|cff00ff00MilaUI: Applied mask to power bar|r")
		else
			print("|cffff0000MilaUI: SetMask method not available for power bar texture|r")
		end
	end

	-- Add power text (optional)
	Power.Text = Power:CreateFontString(nil, "OVERLAY")
	Power.Text:SetFont(MilaUI.media.font, 10, "OUTLINE") -- Use your font path here
	Power.Text:SetPoint("CENTER", Power, "CENTER")
	Power.Text:SetText("Power") -- Placeholder, oUF handles updating this

	-- Enable oUF coloring options - these might override your texture colors
	-- Comment out any you don't want to use
	Power.colorTapping = false      -- DISABLED - we'll use our custom colors
	Power.colorDisconnected = true  -- Keep this for disconnected units
	Power.colorPower = false        -- DISABLED - we'll use our custom colors instead
	-- Power.colorClass = false     -- Already disabled
	-- Power.colorReaction = false  -- Already disabled
	
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
			print("|cff00ff00MilaUI: Power color set for", powerToken, ":", color[1], color[2], color[3], "|r")
		else
			-- Fallback to a default blue color if we don't have a custom color for this power type
			power:SetStatusBarColor(0, 0.55, 1)
			print("|cffff9900MilaUI: Unknown power type:", powerToken, "- using default blue|r")
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
	powerTopBorder:SetPoint("TOPLEFT", powerOverlayFrame, "TOPLEFT", 1, 1)
	powerTopBorder:SetSize(264, 2)
	powerTopBorder:SetVertexColor(1, 1, 1, 0.8)
	
	-- Create bottom border texture for power
	local powerBottomBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
	powerBottomBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	powerBottomBorder:SetPoint("BOTTOMLEFT", powerOverlayFrame, "BOTTOMLEFT", -16, 16)
	powerBottomBorder:SetSize(264, 2)
	powerBottomBorder:SetVertexColor(1, 1, 1, 0.8)
	
	-- Create left border texture with rotation for power
	local powerLeftBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
	powerLeftBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	powerLeftBorder:SetSize(24, 2)
	
	-- Set rotation angle for power left border
	local powerAngle = math.rad(45)
	powerLeftBorder:SetRotation(powerAngle)
	
	-- Calculate offset to position the rotated texture correctly
	local powerWidth, powerHeight = powerLeftBorder:GetSize()
	local powerOffsetX = 14
	local powerOffsetY = -7
	
	powerLeftBorder:SetPoint("TOPLEFT", powerOverlayFrame, "TOPLEFT", powerOffsetX, powerOffsetY)
	powerLeftBorder:SetVertexColor(1, 1, 1, 0.8)
	
	-- Create right border texture with rotation for power
	local powerRightBorder = powerOverlayFrame:CreateTexture(nil, "OVERLAY")
	powerRightBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	powerRightBorder:SetSize(24, 2)
	
	-- Set rotation angle for power right border
	local powerRightAngle = math.rad(45)
	powerRightBorder:SetRotation(powerRightAngle)
	
	-- Calculate offset to position the rotated texture correctly
	local powerRightWidth, powerRightHeight = powerRightBorder:GetSize()
	local powerRightOffsetX = 4
	local powerRightOffsetY = -8
	
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

	-- Tell oUF this is the Power element
	self.Power = Power
	
	--[[ Custom Border Overlay ]]--
	-- Get current strata of the parent frame
	local currentStrata = self:GetFrameStrata()
	
	-- Map the strata to a table
	local strataOrder = {
		"BACKGROUND",
		"LOW",
		"MEDIUM",
		"HIGH",
		"DIALOG",
		"FULLSCREEN",
		"FULLSCREEN_DIALOG",
		"TOOLTIP"
	}
	
	-- Find index of the current strata
	local nextStrata = "TOOLTIP"  -- default fallback
	for i, strata in ipairs(strataOrder) do
		if strata == currentStrata and i < #strataOrder then
			nextStrata = strataOrder[i + 1]
			break
		end
	end
	
	-- Create a frame one strata higher
	local overlayFrame = CreateFrame("Frame", nil, self)
	overlayFrame:SetAllPoints(self)
	overlayFrame:SetFrameStrata(nextStrata)
	
	-- Create top border texture
	local topBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
	topBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	topBorder:SetPoint("TOPRIGHT", overlayFrame, "TOPRIGHT", -32, 1)
	topBorder:SetSize(264, 2)
	topBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
	
	-- Create bottom border texture
	local bottomBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
	bottomBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	bottomBorder:SetPoint("BOTTOMRIGHT", overlayFrame, "BOTTOMRIGHT", 2, -1)
	bottomBorder:SetSize(264, 2)
	bottomBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
	
	-- Create left border texture with rotation
	local leftBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
	leftBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	leftBorder:SetSize(47, 2)
	
	-- Set rotation angle (135 degrees = top-left to bottom-right diagonal)
	local angle = math.rad(135)
	leftBorder:SetRotation(angle)
	
	-- Calculate offset to position the rotated texture correctly
	local width, height = leftBorder:GetSize()
	local offsetX = -7
	local offsetY = -16
	
	leftBorder:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT", offsetX, offsetY)
	leftBorder:SetVertexColor(1, 1, 1, 0.8) -- White with 80% opacity
	
	-- Create right border texture with rotation
	local rightBorder = overlayFrame:CreateTexture(nil, "OVERLAY")
	rightBorder:SetTexture("Interface\\AddOns\\MilaUI\\Media\\Statusbars\\borders\\ttt.tga")
	rightBorder:SetSize(47, 2)
	
	-- Set rotation angle (45 degrees = top-right to bottom-left diagonal)
	local rightAngle = math.rad(135)
	rightBorder:SetRotation(rightAngle)
	
	-- Calculate offset to position the rotated texture correctly
	local rightWidth, rightHeight = rightBorder:GetSize()
	local rightOffsetX = 8
	local rightOffsetY = -16
	
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

	--[[ Add more elements here as needed (e.g., Castbar, Name, Portraits, Auras, etc.) ]]--

end

oUF:RegisterStyle("MilaUIPlayerStyle", StylePlayerFrame)
print("|cff00ff00MilaUI: Style registered.|r")
oUF:SetActiveStyle("MilaUIPlayerStyle")
print("|cff00ff00MilaUI: Style activated.|r")

local playerFrame = oUF:Spawn("player", "MilaUIPlayerFrame")
print("|cff00ff00MilaUI: Player frame spawned:", playerFrame and playerFrame:GetName() or "ERROR/NIL", "|r")
playerFrame:SetPoint("CENTER", UIParent, "CENTER", -250, -150)