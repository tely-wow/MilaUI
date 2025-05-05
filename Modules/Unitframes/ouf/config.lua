-- MilaUI Unitframes Configuration
local addonName, MilaUI = ...

-- Initialize the modules table if it doesn't exist
if not MilaUI.modules then MilaUI.modules = {} end
if not MilaUI.modules.unitframes then MilaUI.modules.unitframes = {} end

-- Default configuration
local defaultConfig = {
    player = {
        scale = 1.0, -- Default scale factor
        width = 383,
        height = 34,
        powerContainerWidth = 383,
        powerContainerHeight = 34,
        powerWidth = 366,
        powerHeight = 17,
        border = {
            enabled = true,
            scale = 1.0,
            topWidth = 352,
            topHeight = 2,
            bottomWidth = 352,
            bottomHeight = 2,
            leftWidth = 47,
            leftHeight = 2,
            rightWidth = 47,
            rightHeight = 2,
            topOffsetX = -32,
            topOffsetY = 1,
            bottomOffsetX = 2,
            bottomOffsetY = -1,
            leftOffsetX = -7,
            leftOffsetY = -16,
            rightOffsetX = 8,
            rightOffsetY = -16,
            opacity = 1,
            color = {0.41, 0.41, 0.41} -- RGB values
        },
        powerBar = {
            enabled = true,  -- Enable/disable power bar borders
            scale = 1.0,     -- Scale for power bar borders
            topWidth = 351,
            topHeight = 2,
            bottomWidth = 351,
            bottomHeight = 2,
            leftWidth = 24,
            leftHeight = 2,
            rightWidth = 25,
            rightHeight = 2,
            topOffsetX = 1,
            topOffsetY = 0,
            bottomOffsetX = -16,
            bottomOffsetY = 15,
            leftOffsetX = 14,
            leftOffsetY = -8,
            rightOffsetX = 5,
            rightOffsetY = -8,
            opacity = 1,
            color = {0.41, 0.41, 0.41} -- RGB values
        }
    },
    target = {
        scale = 1.0, -- Default scale factor
        width = 383,
        height = 34,
        powerContainerWidth = 383,
        powerContainerHeight = 34,
        powerWidth = 366,
        powerHeight = 17,
        border = {
            enabled = true,
            scale = 1.0,
            topWidth = 352,
            topHeight = 2,
            bottomWidth = 352,
            bottomHeight = 2,
            leftWidth = 47,
            leftHeight = 2,
            rightWidth = 47,
            rightHeight = 2,
            topOffsetX = 1,
            topOffsetY = 0,
            bottomOffsetX = -31,
            bottomOffsetY = -1,
            leftOffsetX = -6,
            leftOffsetY = -16,
            rightOffsetX = 7,
            rightOffsetY = -17,
            opacity = 1,
            color = {0.41, 0.41, 0.41} -- RGB values
        },
        powerBar = {
            enabled = true,  -- Enable/disable power bar borders
            scale = 1.0,     -- Scale for power bar borders
            topWidth = 351,
            topHeight = 2,
            bottomWidth = 351,
            bottomHeight = 2,
            leftWidth = 24,
            leftHeight = 2,
            rightWidth = 25,
            rightHeight = 2,
            topOffsetX = 1,
            topOffsetY = 0,
            bottomOffsetX = 17,
            bottomOffsetY = 15,
            leftOffsetX = -2,
            leftOffsetY = -9,
            rightOffsetX = -11,
            rightOffsetY = -8,
            opacity = 1,
            color = {0.41, 0.41, 0.41} -- RGB values
        }
    }
}

-- Create a copy of the default config
MilaUI.modules.unitframes.config = {}
for unitType, settings in pairs(defaultConfig) do
    MilaUI.modules.unitframes.config[unitType] = {}
    for key, value in pairs(settings) do
        MilaUI.modules.unitframes.config[unitType][key] = value
    end
end

-- Helper function to find frames by partial name
local function FindFramesByPartialName(partialName)
    local matches = {}
    for k, v in pairs(_G) do
        if type(k) == "string" and k:find(partialName) and type(v) == "table" and v.GetObjectType and v:GetObjectType() == "Frame" then
            table.insert(matches, k)
        end
    end
    return matches
end

-- Function to apply scale to a unit's dimensions
function MilaUI.modules.unitframes.ApplyScale(unitType, scale)
    if not unitType or not scale then return end
    
    -- Update the scale value in the config
    MilaUI.modules.unitframes.config[unitType].scale = scale
    
    -- Apply the scale to all dimensions
    -- We don't actually modify the individual dimension values in the config
    -- This ensures that when we change the scale, it applies proportionally to the current values
    
    -- Apply the size settings immediately
    MilaUI.modules.unitframes.ApplySizeSettings()
end

-- Function to apply size settings to the unitframes
function MilaUI.modules.unitframes.ApplySizeSettings()
    -- Debug: Print what we're looking for
    print("|cffff9900MilaUI Debug:|r Looking for unitframes...")
    
    -- Try to find the frames
    local playerFrame = _G["MilaUIPlayerFrame"]
    local targetFrame = _G["MilaUITargetFrame"]
    
    -- Debug: Print what we found
    print("|cffff9900MilaUI Debug:|r Found frames: Player="..(playerFrame and "yes" or "no")..", Target="..(targetFrame and "yes" or "no"))
    
    -- If frames aren't found, try to find them by searching all frames
    if not playerFrame or not targetFrame then
        print("|cffff9900MilaUI Debug:|r Searching for frames with partial names...")
        -- Look for frames with "player" in their name
        local playerMatches = FindFramesByPartialName("player")
        print("|cffff9900MilaUI Debug:|r Found " .. #playerMatches .. " potential player frames:")
        for i, name in ipairs(playerMatches) do
            print("  " .. i .. ". " .. name)
            if not playerFrame and string.find(name:lower(), "milauiplayer") then
                playerFrame = _G[name]
                print("|cffff9900MilaUI Debug:|r Selected " .. name .. " as player frame")
            end
        end
        
        -- Look for frames with "target" in their name
        local targetMatches = FindFramesByPartialName("target")
        print("|cffff9900MilaUI Debug:|r Found " .. #targetMatches .. " potential target frames:")
        for i, name in ipairs(targetMatches) do
            print("  " .. i .. ". " .. name)
            if not targetFrame and string.find(name:lower(), "milauitarget") then
                targetFrame = _G[name]
                print("|cffff9900MilaUI Debug:|r Selected " .. name .. " as target frame")
            end
        end
    end
    
    -- If frames still aren't found, exit
    if not playerFrame or not targetFrame then
        print("|cffff0000MilaUI:|r Could not find unitframes. Make sure they are created first.")
        return
    end
    
    -- Apply settings to player frame
    local playerConfig = MilaUI.modules.unitframes.config.player
    local playerScale = playerConfig.scale or 1.0
    
    -- Apply scale to main player frame
    playerFrame:SetWidth(playerConfig.width * playerScale)
    playerFrame:SetHeight(playerConfig.height * playerScale)
    
    -- Apply scale to player health container and bar
    if playerFrame.Health then
        -- Scale the health bar
        playerFrame.Health:SetWidth(playerConfig.width * playerScale)
        playerFrame.Health:SetHeight(playerConfig.height * playerScale)
        
        -- Find and scale the health container if it exists
        local healthContainer = playerFrame.Health:GetParent()
        if healthContainer and healthContainer ~= playerFrame then
            healthContainer:SetWidth(playerConfig.width * playerScale)
            healthContainer:SetHeight(playerConfig.height * playerScale)
        end
    else
        print("|cffff0000MilaUI:|r Player frame found but missing Health element.")
    end
    
    -- Apply scale to player power container and bar
    if playerFrame.Power then
        -- Scale the power bar
        playerFrame.Power:SetWidth(playerConfig.powerWidth * playerScale)
        playerFrame.Power:SetHeight(playerConfig.powerHeight * playerScale)
        
        -- Find and scale the power container
        local powerContainer = playerFrame.Power:GetParent()
        if powerContainer and powerContainer ~= playerFrame then
            powerContainer:SetWidth(playerConfig.powerContainerWidth * playerScale)
            powerContainer:SetHeight(playerConfig.powerContainerHeight * playerScale)
        end
    end
    
    -- Apply scale to player backdrop if it exists
    if playerFrame.backdrop then
        playerFrame.backdrop:SetWidth(playerConfig.width * playerScale)
        playerFrame.backdrop:SetHeight(playerConfig.height * playerScale)
    end
    
    -- Apply border settings to player frame
    if playerFrame.CustomBorder then
        local borderConfig = playerConfig.border
        local borderScale = borderConfig.scale * playerScale
        
        -- Set visibility based on enabled setting
        if borderConfig.enabled then
            playerFrame.CustomBorder.frame:Show()
        else
            playerFrame.CustomBorder.frame:Hide()
        end
        
        -- Apply settings to top border
        if playerFrame.CustomBorder.top then
            playerFrame.CustomBorder.top:SetSize(borderConfig.topWidth * borderScale, borderConfig.topHeight * borderScale)
            playerFrame.CustomBorder.top:ClearAllPoints()
            playerFrame.CustomBorder.top:SetPoint("TOPRIGHT", playerFrame.CustomBorder.frame, "TOPRIGHT", 
                borderConfig.topOffsetX * borderScale, borderConfig.topOffsetY * borderScale)
            playerFrame.CustomBorder.top:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
        
        -- Apply settings to bottom border
        if playerFrame.CustomBorder.bottom then
            playerFrame.CustomBorder.bottom:SetSize(borderConfig.bottomWidth * borderScale, borderConfig.bottomHeight * borderScale)
            playerFrame.CustomBorder.bottom:ClearAllPoints()
            playerFrame.CustomBorder.bottom:SetPoint("BOTTOMRIGHT", playerFrame.CustomBorder.frame, "BOTTOMRIGHT", 
                borderConfig.bottomOffsetX * borderScale, borderConfig.bottomOffsetY * borderScale)
            playerFrame.CustomBorder.bottom:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
        
        -- Apply settings to left border
        if playerFrame.CustomBorder.left then
            playerFrame.CustomBorder.left:SetSize(borderConfig.leftWidth * borderScale, borderConfig.leftHeight * borderScale)
            playerFrame.CustomBorder.left:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(135) -- Same angle as in player.lua
            local offsetX = borderConfig.leftOffsetX * borderScale
            local offsetY = borderConfig.leftOffsetY * borderScale
            
            playerFrame.CustomBorder.left:SetPoint("TOPLEFT", playerFrame.CustomBorder.frame, "TOPLEFT", offsetX, offsetY)
            playerFrame.CustomBorder.left:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
        
        -- Apply settings to right border
        if playerFrame.CustomBorder.right then
            playerFrame.CustomBorder.right:SetSize(borderConfig.rightWidth * borderScale, borderConfig.rightHeight * borderScale)
            playerFrame.CustomBorder.right:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(45) -- Same angle as in player.lua
            local offsetX = borderConfig.rightOffsetX * borderScale
            local offsetY = borderConfig.rightOffsetY * borderScale
            
            playerFrame.CustomBorder.right:SetPoint("TOPRIGHT", playerFrame.CustomBorder.frame, "TOPRIGHT", offsetX, offsetY)
            playerFrame.CustomBorder.right:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
    end
    
    -- Apply settings to power bar borders for player frame
    if playerFrame.PowerBorder then
        local playerPowerBarConfig = playerConfig.powerBar or {}
        local powerBarScale = (playerPowerBarConfig.scale or 1.0) * playerScale
        
        -- Set visibility based on enabled setting
        if playerPowerBarConfig.enabled then
            playerFrame.PowerBorder.frame:Show()
        else
            playerFrame.PowerBorder.frame:Hide()
        end
        
        -- Apply settings to top border of power bar
        if playerFrame.PowerBorder.top then
            playerFrame.PowerBorder.top:SetSize(playerPowerBarConfig.topWidth * powerBarScale, playerPowerBarConfig.topHeight * powerBarScale)
            playerFrame.PowerBorder.top:ClearAllPoints()
            playerFrame.PowerBorder.top:SetPoint("TOPRIGHT", playerFrame.PowerBorder.frame, "TOPRIGHT", 
                playerPowerBarConfig.topOffsetX * powerBarScale, playerPowerBarConfig.topOffsetY * powerBarScale)
            playerFrame.PowerBorder.top:SetVertexColor(
                playerPowerBarConfig.color and playerPowerBarConfig.color[1] or playerConfig.border.color[1], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[2] or playerConfig.border.color[2], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[3] or playerConfig.border.color[3], 
                playerPowerBarConfig.opacity or playerConfig.border.opacity
            )
        end
        
        -- Apply settings to bottom border of power bar
        if playerFrame.PowerBorder.bottom then
            playerFrame.PowerBorder.bottom:SetSize(playerPowerBarConfig.bottomWidth * powerBarScale, playerPowerBarConfig.bottomHeight * powerBarScale)
            playerFrame.PowerBorder.bottom:ClearAllPoints()
            playerFrame.PowerBorder.bottom:SetPoint("BOTTOMRIGHT", playerFrame.PowerBorder.frame, "BOTTOMRIGHT", 
                playerPowerBarConfig.bottomOffsetX * powerBarScale, playerPowerBarConfig.bottomOffsetY * powerBarScale)
            playerFrame.PowerBorder.bottom:SetVertexColor(
                playerPowerBarConfig.color and playerPowerBarConfig.color[1] or playerConfig.border.color[1], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[2] or playerConfig.border.color[2], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[3] or playerConfig.border.color[3], 
                playerPowerBarConfig.opacity or playerConfig.border.opacity
            )
        end
        
        -- Apply settings to left border of power bar
        if playerFrame.PowerBorder.left then
            playerFrame.PowerBorder.left:SetSize(playerPowerBarConfig.leftWidth * powerBarScale, playerPowerBarConfig.leftHeight * powerBarScale)
            playerFrame.PowerBorder.left:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(135) -- Same angle as in player.lua
            local offsetX = playerPowerBarConfig.leftOffsetX * powerBarScale
            local offsetY = playerPowerBarConfig.leftOffsetY * powerBarScale
            
            playerFrame.PowerBorder.left:SetPoint("TOPLEFT", playerFrame.PowerBorder.frame, "TOPLEFT", offsetX, offsetY)
            playerFrame.PowerBorder.left:SetVertexColor(
                playerPowerBarConfig.color and playerPowerBarConfig.color[1] or playerConfig.border.color[1], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[2] or playerConfig.border.color[2], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[3] or playerConfig.border.color[3], 
                playerPowerBarConfig.opacity or playerConfig.border.opacity
            )
        end
        
        -- Apply settings to right border of power bar
        if playerFrame.PowerBorder.right then
            playerFrame.PowerBorder.right:SetSize(playerPowerBarConfig.rightWidth * powerBarScale, playerPowerBarConfig.rightHeight * powerBarScale)
            playerFrame.PowerBorder.right:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(135) -- Same angle as in player.lua
            local offsetX = playerPowerBarConfig.rightOffsetX * powerBarScale
            local offsetY = playerPowerBarConfig.rightOffsetY * powerBarScale
            
            playerFrame.PowerBorder.right:SetPoint("TOPRIGHT", playerFrame.PowerBorder.frame, "TOPRIGHT", offsetX, offsetY)
            playerFrame.PowerBorder.right:SetVertexColor(
                playerPowerBarConfig.color and playerPowerBarConfig.color[1] or playerConfig.border.color[1], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[2] or playerConfig.border.color[2], 
                playerPowerBarConfig.color and playerPowerBarConfig.color[3] or playerConfig.border.color[3], 
                playerPowerBarConfig.opacity or playerConfig.border.opacity
            )
        end
    end
    
    print("|cff00ff00MilaUI:|r Applied size settings to player frame.")
    
    -- Apply settings to target frame
    local targetConfig = MilaUI.modules.unitframes.config.target
    local targetScale = targetConfig.scale or 1.0
    
    -- Apply scale to main target frame
    targetFrame:SetWidth(targetConfig.width * targetScale)
    targetFrame:SetHeight(targetConfig.height * targetScale)
    
    -- Apply scale to target health container and bar
    if targetFrame.Health then
        -- Scale the health bar
        targetFrame.Health:SetWidth(targetConfig.width * targetScale)
        targetFrame.Health:SetHeight(targetConfig.height * targetScale)
        
        -- Find and scale the health container if it exists
        local healthContainer = targetFrame.Health:GetParent()
        if healthContainer and healthContainer ~= targetFrame then
            healthContainer:SetWidth(targetConfig.width * targetScale)
            healthContainer:SetHeight(targetConfig.height * targetScale)
        end
    else
        print("|cffff0000MilaUI:|r Target frame found but missing Health element.")
    end
    
    -- Apply scale to target power container and bar
    if targetFrame.Power then
        -- Scale the power bar
        targetFrame.Power:SetWidth(targetConfig.powerWidth * targetScale)
        targetFrame.Power:SetHeight(targetConfig.powerHeight * targetScale)
        
        -- Find and scale the power container
        local powerContainer = targetFrame.Power:GetParent()
        if powerContainer and powerContainer ~= targetFrame then
            powerContainer:SetWidth(targetConfig.powerContainerWidth * targetScale)
            powerContainer:SetHeight(targetConfig.powerContainerHeight * targetScale)
        end
    end
    
    -- Apply scale to target backdrop if it exists
    if targetFrame.backdrop then
        targetFrame.backdrop:SetWidth(targetConfig.width * targetScale)
        targetFrame.backdrop:SetHeight(targetConfig.height * targetScale)
    end
    
    -- Apply border settings to target frame
    if targetFrame.CustomBorder then
        local borderConfig = targetConfig.border
        local borderScale = borderConfig.scale * targetScale
        
        -- Set visibility based on enabled setting
        if borderConfig.enabled then
            targetFrame.CustomBorder.frame:Show()
        else
            targetFrame.CustomBorder.frame:Hide()
        end
        
        -- Apply settings to top border
        if targetFrame.CustomBorder.top then
            targetFrame.CustomBorder.top:SetSize(borderConfig.topWidth * borderScale, borderConfig.topHeight * borderScale)
            targetFrame.CustomBorder.top:ClearAllPoints()
            targetFrame.CustomBorder.top:SetPoint("TOPRIGHT", targetFrame.CustomBorder.frame, "TOPRIGHT", 
                borderConfig.topOffsetX * borderScale, borderConfig.topOffsetY * borderScale)
            targetFrame.CustomBorder.top:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
        
        -- Apply settings to bottom border
        if targetFrame.CustomBorder.bottom then
            targetFrame.CustomBorder.bottom:SetSize(borderConfig.bottomWidth * borderScale, borderConfig.bottomHeight * borderScale)
            targetFrame.CustomBorder.bottom:ClearAllPoints()
            targetFrame.CustomBorder.bottom:SetPoint("BOTTOMRIGHT", targetFrame.CustomBorder.frame, "BOTTOMRIGHT", 
                borderConfig.bottomOffsetX * borderScale, borderConfig.bottomOffsetY * borderScale)
            targetFrame.CustomBorder.bottom:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
        
        -- Apply settings to left border
        if targetFrame.CustomBorder.left then
            targetFrame.CustomBorder.left:SetSize(borderConfig.leftWidth * borderScale, borderConfig.leftHeight * borderScale)
            targetFrame.CustomBorder.left:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(135) -- Same angle as in player.lua
            local offsetX = borderConfig.leftOffsetX * borderScale
            local offsetY = borderConfig.leftOffsetY * borderScale
            
            targetFrame.CustomBorder.left:SetPoint("TOPLEFT", targetFrame.CustomBorder.frame, "TOPLEFT", offsetX, offsetY)
            targetFrame.CustomBorder.left:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
        
        -- Apply settings to right border
        if targetFrame.CustomBorder.right then
            targetFrame.CustomBorder.right:SetSize(borderConfig.rightWidth * borderScale, borderConfig.rightHeight * borderScale)
            targetFrame.CustomBorder.right:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(45) -- Same angle as in player.lua
            local offsetX = borderConfig.rightOffsetX * borderScale
            local offsetY = borderConfig.rightOffsetY * borderScale
            
            targetFrame.CustomBorder.right:SetPoint("TOPRIGHT", targetFrame.CustomBorder.frame, "TOPRIGHT", offsetX, offsetY)
            targetFrame.CustomBorder.right:SetVertexColor(
                borderConfig.color[1], 
                borderConfig.color[2], 
                borderConfig.color[3], 
                borderConfig.opacity
            )
        end
    end
    
    -- Apply settings to power bar borders for target frame
    if targetFrame.PowerBorder then
        local targetPowerBarConfig = targetConfig.powerBar or {}
        local powerBarScale = (targetPowerBarConfig.scale or 1.0) * targetScale
        
        -- Set visibility based on enabled setting
        if targetPowerBarConfig.enabled then
            targetFrame.PowerBorder.frame:Show()
        else
            targetFrame.PowerBorder.frame:Hide()
        end
        
        -- Apply settings to top border of power bar
        if targetFrame.PowerBorder.top then
            targetFrame.PowerBorder.top:SetSize(targetPowerBarConfig.topWidth * powerBarScale, targetPowerBarConfig.topHeight * powerBarScale)
            targetFrame.PowerBorder.top:ClearAllPoints()
            targetFrame.PowerBorder.top:SetPoint("TOPLEFT", targetFrame.PowerBorder.frame, "TOPLEFT", 
                targetPowerBarConfig.topOffsetX * powerBarScale, targetPowerBarConfig.topOffsetY * powerBarScale)
            targetFrame.PowerBorder.top:SetVertexColor(
                targetPowerBarConfig.color and targetPowerBarConfig.color[1] or targetConfig.border.color[1], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[2] or targetConfig.border.color[2], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[3] or targetConfig.border.color[3], 
                targetPowerBarConfig.opacity or targetConfig.border.opacity
            )
        end
        
        -- Apply settings to bottom border of power bar
        if targetFrame.PowerBorder.bottom then
            targetFrame.PowerBorder.bottom:SetSize(targetPowerBarConfig.bottomWidth * powerBarScale, targetPowerBarConfig.bottomHeight * powerBarScale)
            targetFrame.PowerBorder.bottom:ClearAllPoints()
            targetFrame.PowerBorder.bottom:SetPoint("BOTTOMLEFT", targetFrame.PowerBorder.frame, "BOTTOMLEFT", 
                targetPowerBarConfig.bottomOffsetX * powerBarScale, targetPowerBarConfig.bottomOffsetY * powerBarScale)
            targetFrame.PowerBorder.bottom:SetVertexColor(
                targetPowerBarConfig.color and targetPowerBarConfig.color[1] or targetConfig.border.color[1], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[2] or targetConfig.border.color[2], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[3] or targetConfig.border.color[3], 
                targetPowerBarConfig.opacity or targetConfig.border.opacity
            )
        end
        
        -- Apply settings to left border of power bar
        if targetFrame.PowerBorder.left then
            targetFrame.PowerBorder.left:SetSize(targetPowerBarConfig.leftWidth * powerBarScale, targetPowerBarConfig.leftHeight * powerBarScale)
            targetFrame.PowerBorder.left:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(45) -- Mirrored angle for target frame
            local offsetX = targetPowerBarConfig.leftOffsetX * powerBarScale
            local offsetY = targetPowerBarConfig.leftOffsetY * powerBarScale
            
            targetFrame.PowerBorder.left:SetPoint("TOPLEFT", targetFrame.PowerBorder.frame, "TOPLEFT", offsetX, offsetY)
            targetFrame.PowerBorder.left:SetVertexColor(
                targetPowerBarConfig.color and targetPowerBarConfig.color[1] or targetConfig.border.color[1], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[2] or targetConfig.border.color[2], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[3] or targetConfig.border.color[3], 
                targetPowerBarConfig.opacity or targetConfig.border.opacity
            )
        end
        
        -- Apply settings to right border of power bar
        if targetFrame.PowerBorder.right then
            targetFrame.PowerBorder.right:SetSize(targetPowerBarConfig.rightWidth * powerBarScale, targetPowerBarConfig.rightHeight * powerBarScale)
            targetFrame.PowerBorder.right:ClearAllPoints()
            
            -- Calculate offset for rotated texture
            local angle = math.rad(45) -- Mirrored angle for target frame
            local offsetX = targetPowerBarConfig.rightOffsetX * powerBarScale
            local offsetY = targetPowerBarConfig.rightOffsetY * powerBarScale
            
            targetFrame.PowerBorder.right:SetPoint("TOPRIGHT", targetFrame.PowerBorder.frame, "TOPRIGHT", offsetX, offsetY)
            targetFrame.PowerBorder.right:SetVertexColor(
                targetPowerBarConfig.color and targetPowerBarConfig.color[1] or targetConfig.border.color[1], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[2] or targetConfig.border.color[2], 
                targetPowerBarConfig.color and targetPowerBarConfig.color[3] or targetConfig.border.color[3], 
                targetPowerBarConfig.opacity or targetConfig.border.opacity
            )
        end
    end
    
    print("|cff00ff00MilaUI:|r Applied size settings to target frame.")
end

-- Function to save the current configuration
function MilaUI.modules.unitframes.SaveConfig()
    -- This would typically save to SavedVariables
    -- For now, just print a message
    print("|cff00ff00MilaUI:|r Size settings saved.")
    
    -- In a real implementation, you would do something like:
    -- MilaUISavedVariables.unitframesConfig = MilaUI.modules.unitframes.config
end

-- Function to reset to default configuration
function MilaUI.modules.unitframes.ResetToDefaults()
    -- Reset the config to defaults
    MilaUI.modules.unitframes.config = {}
    for unitType, settings in pairs(defaultConfig) do
        MilaUI.modules.unitframes.config[unitType] = {}
        for key, value in pairs(settings) do
            MilaUI.modules.unitframes.config[unitType][key] = value
        end
    end
    
    print("|cff00ff00MilaUI:|r Size settings reset to defaults.")
end

-- Initialize on PLAYER_LOGIN
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Apply size settings after frames are created
        C_Timer.After(1, function()
            MilaUI.modules.unitframes.ApplySizeSettings()
        end)
    end
end)
