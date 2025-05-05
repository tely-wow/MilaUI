-- MilaUI Config GUI
local addonName, MilaUI = ...
local LSM = LibStub("LibSharedMedia-3.0")

-- Check if ElvUI is loaded
local isElvUILoaded = IsAddOnLoaded("ElvUI")
local E, S
if isElvUILoaded then
    E = unpack(ElvUI)
    if E then
        S = E:GetModule("Skins")
    end
end

-- Create the main GUI frame
local configGUI = CreateFrame("Frame", "MilaUIConfigGUI", UIParent, "BackdropTemplate")
configGUI:SetSize(550, 500)  -- Increased size to accommodate all elements
configGUI:SetPoint("CENTER")
configGUI:SetFrameStrata("HIGH")
configGUI:EnableMouse(true)
configGUI:SetMovable(true)
configGUI:RegisterForDrag("LeftButton")
configGUI:SetScript("OnDragStart", configGUI.StartMoving)
configGUI:SetScript("OnDragStop", configGUI.StopMovingOrSizing)
configGUI:Hide()

-- Set a standard backdrop for non-ElvUI users
configGUI:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})

-- Debug function to help troubleshoot
local function DebugPrint(...)
    print("|cFF00FF00MilaUI Debug:|r", ...)
end

-- Function to get current texture selections from Unitframes.lua
local function GetCurrentTextures()
    local textures = {}
    
    -- Ensure our config table exists
    if not MilaUI.modules then
        DebugPrint("MilaUI.modules is nil")
        return textures
    end
    
    if not MilaUI.modules.unitframes then
        DebugPrint("MilaUI.modules.unitframes is nil")
        return textures
    end
    
    if not MilaUI.modules.unitframes.config then
        DebugPrint("MilaUI.modules.unitframes.config is nil")
        return textures
    end
    
    local config = MilaUI.modules.unitframes.config
    DebugPrint("Config table found, inspecting contents...")
    
    -- Player frame textures
    if config.player then
        DebugPrint("Player config found")
        textures.player = {
            health = config.player.healthTexture,
            power = config.player.powerTexture,
            backdrop = config.player.backdropTexture,
            powerBackdrop = config.player.powerBackdropTexture,
            healthLoss = config.player.healthLossTexture
        }
    else
        DebugPrint("Player config not found")
    end
    
    -- Target frame textures
    if config.target then
        DebugPrint("Target config found")
        textures.target = {
            health = config.target.healthTexture,
            power = config.target.powerTexture,
            backdrop = config.target.backdropTexture,
            powerBackdrop = config.target.powerBackdropTexture,
            healthLoss = config.target.healthLossTexture
        }
    else
        DebugPrint("Target config not found")
    end
    
    return textures
end

-- Function to create ElvUI styled buttons with fallback for non-ElvUI users
local function CreateElvUIStyledButton(parent, name, width, height, point, relativeFrame, relativePoint, xOffset, yOffset, text, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 120, height or 24)
    
    if point then
        if relativeFrame and relativePoint then
            button:SetPoint(point, relativeFrame, relativePoint, xOffset or 0, yOffset or 0)
        else
            button:SetPoint(point, xOffset or 0, yOffset or 0)
        end
    end
    
    button:SetText(text or "Button")
    
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    
    -- Apply ElvUI styling if available
    if isElvUILoaded and S then
        S:HandleButton(button)
    else
        -- Fallback styling for non-ElvUI users
        button:SetNormalFontObject("GameFontNormal")
        button:SetHighlightFontObject("GameFontHighlight")
    end
    
    return button
end

-- Setup the GUI styling and elements
local function SetupGUI()
    -- Add logo to the top left
    -- Create a frame for the logo
    local logoFrame = CreateFrame("Frame", nil, configGUI)
    logoFrame:SetSize(128, 128)
    logoFrame:SetPoint("TOP", 0, -10)
    
    -- Create the texture
    local logo = logoFrame:CreateTexture(nil, "ARTWORK")
    logo:SetAllPoints(logoFrame)
    
    -- Try multiple paths and formats to ensure the logo displays
    local logoDisplayed = false
    
    -- Try SharedMedia first
    if LSM:IsValid("background", "MilaUI-Logo") then
        DebugPrint("Loading logo from SharedMedia...")
        logo:SetTexture(LSM:Fetch("background", "MilaUI-Logo"))
        logoDisplayed = true
    end
    
    -- If SharedMedia didn't work, try direct paths with different formats
    if not logoDisplayed then
        local paths = {
            "Interface\\AddOns\\MilaUI\\Media\\logo.tga",
            "Interface\\AddOns\\MilaUI\\Media\\logo",
            "Interface\\AddOns\\MilaUI\\Media\\logo.blp",
            "Interface\\AddOns\\MilaUI\\Media\\logo.png"
        }
        
        for _, path in ipairs(paths) do
            DebugPrint("Attempting to load logo from: " .. path)
            logo:SetTexture(path)
            
            -- Check if texture loaded successfully (this is a basic check)
            if logo:GetTexture() then
                DebugPrint("Logo loaded successfully from: " .. path)
                logoDisplayed = true
                break
            end
        end
    end
    
    -- If all else fails, create a colored box with text as a fallback
    if not logoDisplayed then
        DebugPrint("Failed to load logo, using fallback...")
        logo:SetColorTexture(0.2, 0.2, 0.2, 1)
        
        local logoText = logoFrame:CreateFontString(nil, "OVERLAY")
        logoText:SetFontObject("GameFontNormalLarge")
        logoText:SetPoint("CENTER", logoFrame, "CENTER")
        logoText:SetText("MilaUI")
        
        if isElvUILoaded and E and E.media and E.media.normFont then
            logoText:SetFont(E.media.normFont, 16, "OUTLINE")
        end
    end
    
    -- Store references
    configGUI.logoFrame = logoFrame
    configGUI.logo = logo
    
    -- Add a title below the logo
    local title = configGUI:CreateFontString(nil, "OVERLAY")
    title:SetFontObject("GameFontNormalLarge")
    title:SetPoint("TOP", logoFrame, "BOTTOM", 0, -5)
    title:SetText("MilaUI ")
    configGUI.title = title
    
    -- Add a close button
    local closeButton = CreateFrame("Button", nil, configGUI, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT")
    configGUI.CloseButton = closeButton
    
    -- Create a scrollable area for texture listings
    local scrollFrame = CreateFrame("ScrollFrame", nil, configGUI, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(500, 300)  -- Increased width and adjusted height
    scrollFrame:SetPoint("TOP", title, "BOTTOM", 0, -15)
    scrollFrame:SetPoint("BOTTOM", configGUI, "BOTTOM", 0, 50)  -- Add bottom anchor with padding for buttons
    configGUI.scrollFrame = scrollFrame
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(480, 800)  -- Adjusted width to prevent horizontal scrolling
    configGUI.scrollChild = scrollChild
    
    -- Create the buttons at the bottom of the main frame using our styled button function
    -- Apply textures button
    local applyButton = CreateElvUIStyledButton(
        configGUI,
        "MilaUIApplyTexturesButton",
        120, 24,
        "BOTTOMLEFT", configGUI, "BOTTOMLEFT", 20, 15,
        "Apply Textures",
        function()
            if MilaUI.modules and MilaUI.modules.unitframes and MilaUI.modules.unitframes.MilaUI_Textures then
                MilaUI.modules.unitframes.MilaUI_Textures:ApplyAllTextures()
                print("|cFF00FF00MilaUI:|r Textures applied successfully!")
            else
                print("|cFFFF0000MilaUI:|r Failed to apply textures - module not loaded")
            end
        end
    )
    configGUI.applyButton = applyButton
    
    -- Reload UI button
    local reloadButton = CreateElvUIStyledButton(
        configGUI,
        "MilaUIReloadButton",
        120, 24,
        "BOTTOM", configGUI, "BOTTOM", 0, 15,
        "Reload UI",
        function() ReloadUI() end
    )
    configGUI.reloadButton = reloadButton
    
    -- Close button
    local closeWindowButton = CreateElvUIStyledButton(
        configGUI,
        "MilaUICloseButton",
        120, 24,
        "BOTTOMRIGHT", configGUI, "BOTTOMRIGHT", -20, 15,
        "Close",
        function() configGUI:Hide() end
    )
    configGUI.closeWindowButton = closeWindowButton
    
    -- Try to style with ElvUI if available
    if isElvUILoaded and E and S then
        -- Style the frame
        configGUI:StripTextures()
        configGUI:SetTemplate("Transparent")
        
        -- Style close button
        S:HandleCloseButton(closeButton)
        
        -- Style scroll frame
        S:HandleScrollBar(scrollFrame.ScrollBar)
        
        -- Use ElvUI font for title
        if E.media and E.media.normFont then
            title:SetFont(E.media.normFont, 16, "OUTLINE")
        end
    end
end

-- Function to update the GUI with current texture data
local function UpdateGUI()
    local scrollChild = configGUI.scrollChild
    
    -- Clear previous entries
    for _, child in pairs({scrollChild:GetChildren()}) do
        child:Hide()
    end
    
    local currentTextures = GetCurrentTextures()
    local yOffset = 10
    
    -- Create header
    local header = scrollChild:CreateFontString(nil, "OVERLAY")
    header:SetFontObject("GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 10, -yOffset)
    header:SetText("Current Texture Configurations")
    
    -- Apply ElvUI font if available
    if isElvUILoaded and E and E.media and E.media.normFont then
        header:SetFont(E.media.normFont, 14, "OUTLINE")
    end
    
    yOffset = yOffset + 25
    
    -- Function to create a texture preview using SharedMedia
    local function CreateTexturePreview(parent, textureName, x, y, width, height)
        local preview = parent:CreateTexture(nil, "ARTWORK")
        preview:SetSize(width or 150, height or 20)
        preview:SetPoint("TOPLEFT", x, y)
        
        -- Try to get texture from SharedMedia
        if textureName and LSM:IsValid("statusbar", textureName) then
            preview:SetTexture(LSM:Fetch("statusbar", textureName))
        else
            -- Fallback for missing textures
            preview:SetColorTexture(0.3, 0.3, 0.3, 0.8)
        end
        
        -- Add a border
        local border = parent:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", preview, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", preview, "BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(0, 0, 0, 1)
        
        return preview
    end
    
    -- Display textures for each frame type
    for frameType, frameTextures in pairs(currentTextures) do
        -- Frame type header
        local frameHeader = scrollChild:CreateFontString(nil, "OVERLAY")
        frameHeader:SetFontObject("GameFontHighlight")
        frameHeader:SetPoint("TOPLEFT", 10, -yOffset)
        frameHeader:SetText(frameType:gsub("^%l", string.upper) .. " Frame")
        
        -- Apply ElvUI font if available
        if isElvUILoaded and E and E.media and E.media.normFont then
            frameHeader:SetFont(E.media.normFont, 12, "OUTLINE")
        end
        
        yOffset = yOffset + 20
        
        -- Check if we have any textures for this frame
        local hasTextures = false
        for _, _ in pairs(frameTextures) do
            hasTextures = true
            break
        end
        
        if hasTextures then
            -- List each texture with preview
            for textureType, textureName in pairs(frameTextures) do
                local textureLabel = scrollChild:CreateFontString(nil, "OVERLAY")
                textureLabel:SetFontObject("GameFontNormal")
                textureLabel:SetPoint("TOPLEFT", 20, -yOffset)
                textureLabel:SetText(textureType:gsub("^%l", string.upper) .. ":")
                
                local textureNameText = scrollChild:CreateFontString(nil, "OVERLAY")
                textureNameText:SetFontObject("GameFontWhite")
                textureNameText:SetPoint("TOPLEFT", 120, -yOffset)
                textureNameText:SetText(textureName or "N/A")
                
                -- Apply ElvUI font if available
                if isElvUILoaded and E and E.media and E.media.normFont then
                    textureLabel:SetFont(E.media.normFont, 11, "OUTLINE")
                    textureNameText:SetFont(E.media.normFont, 11, "NONE")
                end
                
                -- Create texture preview
                CreateTexturePreview(scrollChild, textureName, 300, -yOffset + 8)
                
                yOffset = yOffset + 25
            end
        else
            local noTexturesText = scrollChild:CreateFontString(nil, "OVERLAY")
            noTexturesText:SetFontObject("GameFontRed")
            noTexturesText:SetPoint("TOPLEFT", 20, -yOffset)
            noTexturesText:SetText("No textures configured")
            
            -- Apply ElvUI font if available
            if isElvUILoaded and E and E.media and E.media.normFont then
                noTexturesText:SetFont(E.media.normFont, 11, "OUTLINE")
            end
            
            yOffset = yOffset + 25
        end
        
        yOffset = yOffset + 15 -- Add space between frame types
    end
    
    -- Adjust scrollChild height based on content
    scrollChild:SetHeight(math.max(400, yOffset + 50))
end

-- Register slash command
SLASH_MILAUI1 = "/mui"
SlashCmdList["MILAUI"] = function(msg)
    -- Make sure module is loaded
    if not MilaUI.modules or not MilaUI.modules.unitframes or not MilaUI.modules.unitframes.config then
        print("|cFFFF0000MilaUI:|r Configuration not fully loaded. Please report this issue.")
    end
    
    configGUI:Show()
    UpdateGUI()
end

-- Initialize frame (wait for addon to fully load)
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" then
        if addon == "ElvUI" then
            print("|cFF00FF00MilaUI:|r ElvUI detected, applying styling")
            
            -- Update ElvUI references
            isElvUILoaded = true
            E = unpack(ElvUI)
            if E then
                S = E:GetModule("Skins")
            end
            
            -- Update styling if GUI already exists
            if configGUI and configGUI:IsShown() then
                -- Refresh the GUI to apply ElvUI styling
                UpdateGUI()
                
                -- Re-style buttons if they exist
                if configGUI.applyButton then S:HandleButton(configGUI.applyButton) end
                if configGUI.reloadButton then S:HandleButton(configGUI.reloadButton) end
                if configGUI.closeWindowButton then S:HandleButton(configGUI.closeWindowButton) end
                if configGUI.CloseButton then S:HandleCloseButton(configGUI.CloseButton) end
                
                -- Re-style the frame
                configGUI:StripTextures()
                configGUI:SetTemplate("Transparent")
                
                -- Re-style scroll frame if it exists
                if configGUI.scrollFrame and configGUI.scrollFrame.ScrollBar then
                    S:HandleScrollBar(configGUI.scrollFrame.ScrollBar)
                end
            end
        end
    end
    
    -- Initialize the GUI data when the player logs in
    -- This ensures all addon data is loaded
    if event == "PLAYER_LOGIN" then
        -- Set up MilaUI table if needed
        if not MilaUI.modules then MilaUI.modules = {} end
        if not MilaUI.gui then MilaUI.gui = {} end
        
        -- Create the GUI structure
        SetupGUI()
        
        -- Store GUI references
        MilaUI.gui.configGUI = configGUI
        MilaUI.gui.UpdateGUI = UpdateGUI
        
        -- Make the CreateElvUIStyledButton function available to other modules
        MilaUI.gui.CreateElvUIStyledButton = CreateElvUIStyledButton
        
        -- Wait a bit to ensure all modules are loaded
        C_Timer.After(1, function()
            if not MilaUI.modules.unitframes or not MilaUI.modules.unitframes.config then
                print("|cFFFF0000MilaUI:|r Error loading texture configuration. Please report this issue.")
            end
        end)
    end
end)
