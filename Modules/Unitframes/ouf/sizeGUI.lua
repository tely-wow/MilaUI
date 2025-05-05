-- MilaUI Size Adjustment GUI
local addonName, MilaUI = ...

-- Initialize the modules table if it doesn't exist
if not MilaUI.modules then MilaUI.modules = {} end
if not MilaUI.modules.unitframes then MilaUI.modules.unitframes = {} end

-- Create the main frame
local sizeGUI = CreateFrame("Frame", "MilaUISizeGUI", UIParent, "UIPanelDialogTemplate")
sizeGUI:SetSize(600, 500)
sizeGUI:SetPoint("CENTER")
sizeGUI:SetMovable(true)
sizeGUI:EnableMouse(true)
sizeGUI:RegisterForDrag("LeftButton")
sizeGUI:SetScript("OnDragStart", sizeGUI.StartMoving)
sizeGUI:SetScript("OnDragStop", sizeGUI.StopMovingOrSizing)
sizeGUI:Hide()

-- Set the title
local titleText = sizeGUI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", sizeGUI, "TOP", 0, -15)
titleText:SetText("MilaUI Size Adjustment")

-- Create a close button
local closeButton = CreateFrame("Button", nil, sizeGUI, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", sizeGUI, "TOPRIGHT", -4, -4)

-- Create the sidebar frame for unit selection
local sideBar = CreateFrame("Frame", nil, sizeGUI)
sideBar:SetSize(150, 460)
sideBar:SetPoint("TOPLEFT", sizeGUI, "TOPLEFT", 10, -30)

-- Create a background for the sidebar
local sideBarBg = sideBar:CreateTexture(nil, "BACKGROUND")
sideBarBg:SetAllPoints()
sideBarBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

-- Create a header for the sidebar
local sideBarHeader = sideBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
sideBarHeader:SetPoint("TOP", sideBar, "TOP", 0, -10)
sideBarHeader:SetText("Unit Frames")

-- Create the content frame (right side)
local contentFrame = CreateFrame("Frame", nil, sizeGUI)
contentFrame:SetSize(420, 460)
contentFrame:SetPoint("TOPRIGHT", sizeGUI, "TOPRIGHT", -10, -30)

-- Create a background for the content frame
local contentBg = contentFrame:CreateTexture(nil, "BACKGROUND")
contentBg:SetAllPoints()
contentBg:SetColorTexture(0.1, 0.1, 0.1, 0.3)

-- Initialize tabs table
contentFrame.tabs = {}

-- Create tab buttons at the top of the content frame
local tabHeight = 24
local tabWidth = 100
local tabSpacing = 5
local tabStartX = 10

-- Create the tabs container
local tabsFrame = CreateFrame("Frame", nil, contentFrame)
tabsFrame:SetSize(contentFrame:GetWidth(), tabHeight)
tabsFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, 0)

-- Create tab buttons
local function CreateTab(name, index)
    local tab = CreateFrame("Button", nil, tabsFrame)
    tab:SetSize(tabWidth, tabHeight)
    tab:SetPoint("TOPLEFT", tabsFrame, "TOPLEFT", tabStartX + (index-1) * (tabWidth + tabSpacing), 0)
    
    -- Create background texture
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)
    
    -- Create highlight texture
    local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.3, 0.3, 0.3, 0.7)
    
    -- Create selected texture
    local selected = tab:CreateTexture(nil, "BACKGROUND")
    selected:SetAllPoints()
    selected:SetColorTexture(0.4, 0.4, 0.4, 0.7)
    selected:Hide()
    tab.selectedTexture = selected
    
    -- Create text
    local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(name)
    
    -- Function to set selected state
    tab.SetSelectedState = function()
        for _, otherTab in ipairs(contentFrame.tabs) do
            otherTab.selectedTexture:Hide()
        end
        selected:Show()
    end
    
    return tab
end

-- Create content frames for each tab
local function CreateContentFrame(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(parent:GetWidth(), parent:GetHeight() - tabHeight)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -tabHeight)
    frame:Hide()
    
    return frame
end

-- Create unit buttons for the sidebar
local unitButtons = {}
local selectedUnit = nil
local unitFrames = {
    player = { name = "Player", config = MilaUI.modules.unitframes.config.player },
    target = { name = "Target", config = MilaUI.modules.unitframes.config.target },
    focus = { name = "Focus", config = MilaUI.modules.unitframes.config.focus or {} }
}

-- Function to create a unit button
local function CreateUnitButton(unit, index)
    local button = CreateFrame("Button", nil, sideBar)
    button:SetSize(130, 30)
    button:SetPoint("TOP", sideBar, "TOP", 0, -40 - (index-1) * 35)
    
    -- Create background texture
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.2, 0.7)
    
    -- Create highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.3, 0.3, 0.3, 0.7)
    
    -- Create selected texture
    local selected = button:CreateTexture(nil, "BACKGROUND")
    selected:SetAllPoints()
    selected:SetColorTexture(0.4, 0.4, 0.4, 0.7)
    selected:Hide()
    button.selectedTexture = selected
    
    -- Create text
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(unitFrames[unit].name)
    
    -- Store the unit name
    button.unit = unit
    
    -- Function to set selected state
    button.SetSelectedState = function()
        for _, otherButton in ipairs(unitButtons) do
            otherButton.selectedTexture:Hide()
        end
        selected:Show()
        selectedUnit = unit
    end
    
    -- Set click handler
    button:SetScript("OnClick", function()
        button:SetSelectedState()
        sizeGUI:UpdateUnitDisplay(unit)
    end)
    
    return button
end

-- Create unit buttons
local unitIndex = 1
for unit, _ in pairs(unitFrames) do
    unitButtons[unitIndex] = CreateUnitButton(unit, unitIndex)
    unitIndex = unitIndex + 1
end

-- Create tab content frames for each unit
for unit, unitInfo in pairs(unitFrames) do
    unitInfo.contentFrames = {}
    unitInfo.tabs = {}
    
    -- Create the main content frame for this unit
    unitInfo.frame = CreateFrame("Frame", nil, contentFrame)
    unitInfo.frame:SetSize(contentFrame:GetWidth(), contentFrame:GetHeight())
    unitInfo.frame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT")
    unitInfo.frame:Hide()
    
    -- Create tabs for this unit
    unitInfo.tabs[1] = CreateTab("General", 1)
    unitInfo.tabs[2] = CreateTab("Border", 2)
    unitInfo.tabs[3] = CreateTab("Power Bar", 3)
    
    -- Create content frames for each tab
    unitInfo.contentFrames[1] = CreateContentFrame(unitInfo.frame) -- General tab
    unitInfo.contentFrames[2] = CreateContentFrame(unitInfo.frame) -- Border tab
    unitInfo.contentFrames[3] = CreateContentFrame(unitInfo.frame) -- Power Bar tab
    
    -- Set up tab click handlers
    for i, tab in ipairs(unitInfo.tabs) do
        tab:SetParent(unitInfo.frame)
        tab:SetPoint("TOPLEFT", unitInfo.frame, "TOPLEFT", tabStartX + (i-1) * (tabWidth + tabSpacing), 0)
        tab:SetScript("OnClick", function()
            for j, frame in ipairs(unitInfo.contentFrames) do
                if j == i then
                    frame:Show()
                else
                    frame:Hide()
                end
            end
            tab:SetSelectedState()
        end)
    end
    
    -- Set up scroll frames for tab content
    for i, frame in ipairs(unitInfo.contentFrames) do
        -- Create a scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 5)
        
        -- Create a scroll child
        local scrollChild = CreateFrame("Frame")
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetSize(frame:GetWidth() - 30, 800) -- Make it taller to accommodate all controls
        
        -- Store the scroll child
        unitInfo.contentFrames[i].scrollChild = scrollChild
    end
end

-- Function to create a slider
local function CreateSlider(parent, name, min, max, step, width, height, x, y, text, tooltip, OnValueChanged)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetWidth(width)
    slider:SetHeight(height)
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    -- Set up the slider text
    _G[slider:GetName().."Text"]:SetText(text)
    _G[slider:GetName().."Low"]:SetText(min)
    _G[slider:GetName().."High"]:SetText(max)
    
    -- Create a value text
    slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    slider.valueText:SetPoint("TOP", slider, "BOTTOM", 0, 0)
    
    -- Set the tooltip
    slider.tooltipText = tooltip
    
    -- Set the OnValueChanged handler
    if OnValueChanged then
        slider:SetScript("OnValueChanged", function(self, value, userInput)
            if userInput then
                OnValueChanged(self, value)
            end
            self.valueText:SetText(string.format("%.2f", value))
        end)
    end
    
    return slider
end

-- Function to create a checkbox
local function CreateCheckbox(parent, name, text, x, y, tooltip, onClick)
    local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    _G[checkbox:GetName().."Text"]:SetText(text)
    
    checkbox.tooltipText = tooltip
    
    if onClick then
        checkbox:SetScript("OnClick", function(self)
            onClick(self, self:GetChecked())
        end)
    end
    
    return checkbox
end

-- Function to create a section header
local function CreateHeader(parent, text, x, y)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", x, y)
    header:SetText(text)
    return header
end

-- Function to create controls for a unit's general tab
local function CreateGeneralControls(unit, scrollChild)
    local config = unitFrames[unit].config
    
    -- Create headers
    local scaleHeader = CreateHeader(scrollChild, "Scale (Proportional Sizing)", 10, -10)
    local individualHeader = CreateHeader(scrollChild, "Individual Element Sizing", 10, -80)
    
    -- Create scale slider
    local scaleSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."ScaleSlider", 
        0.5, 2.0, 0.05, 300, 20, 10, -40, 
        "Frame Scale", 
        "Adjusts the overall scale of the "..unitFrames[unit].name.." frame while maintaining proportions",
        function(self, value)
            config.scale = value
            MilaUI.modules.unitframes.ApplyScale(unit, value)
        end
    )
    
    -- Create individual element sliders
    -- Main frame width slider
    local widthSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."WidthSlider", 
        200, 500, 1, 300, 20, 10, -110, 
        "Frame Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." frame",
        function(self, value)
            config.width = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Main frame height slider
    local heightSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."HeightSlider", 
        20, 50, 1, 300, 20, 10, -160, 
        "Frame Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." frame",
        function(self, value)
            config.height = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Power container width slider
    local powerContainerWidthSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."PowerContainerWidthSlider", 
        200, 500, 1, 300, 20, 10, -210, 
        "Power Container Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." power container",
        function(self, value)
            config.powerContainerWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Power container height slider
    local powerContainerHeightSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."PowerContainerHeightSlider", 
        20, 50, 1, 300, 20, 10, -260, 
        "Power Container Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." power container",
        function(self, value)
            config.powerContainerHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Power bar width slider
    local powerWidthSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."PowerWidthSlider", 
        200, 500, 1, 300, 20, 10, -310, 
        "Power Bar Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." power bar",
        function(self, value)
            config.powerWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Power bar height slider
    local powerHeightSlider = CreateSlider(
        scrollChild, "MilaUI"..unit.."PowerHeightSlider", 
        10, 30, 1, 300, 20, 10, -360, 
        "Power Bar Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." power bar",
        function(self, value)
            config.powerHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Store references to the sliders for updating
    unitFrames[unit].sliders = {
        scale = scaleSlider,
        width = widthSlider,
        height = heightSlider,
        powerContainerWidth = powerContainerWidthSlider,
        powerContainerHeight = powerContainerHeightSlider,
        powerWidth = powerWidthSlider,
        powerHeight = powerHeightSlider
    }
    
    return {
        scaleHeader = scaleHeader,
        individualHeader = individualHeader,
        scaleSlider = scaleSlider,
        widthSlider = widthSlider,
        heightSlider = heightSlider,
        powerContainerWidthSlider = powerContainerWidthSlider,
        powerContainerHeightSlider = powerContainerHeightSlider,
        powerWidthSlider = powerWidthSlider,
        powerHeightSlider = powerHeightSlider
    }
end

-- Function to create controls for a unit's border tab
local function CreateBorderControls(unit, scrollChild)
    local config = unitFrames[unit].config.border or {}
    
    -- Create header
    local borderHeader = CreateHeader(scrollChild, unitFrames[unit].name.." Frame Border", 10, -10)
    
    -- Create enable checkbox
    local enabledCheckbox = CreateCheckbox(
        scrollChild, 
        "MilaUI"..unit.."BorderEnabledCheckbox", 
        "Enable Border", 
        10, -40, 
        "Enable or disable the "..unitFrames[unit].name.." frame border",
        function(self, checked)
            config.enabled = checked
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create scale slider
    local scaleSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."BorderScaleSlider", 
        0.5, 2.0, 0.05, 300, 20, 10, -70, 
        "Border Scale", 
        "Adjusts the scale of the "..unitFrames[unit].name.." frame border elements",
        function(self, value)
            config.scale = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create opacity slider
    local opacitySlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."BorderOpacitySlider", 
        0, 1.0, 0.05, 300, 20, 10, -120, 
        "Border Opacity", 
        "Adjusts the opacity of the "..unitFrames[unit].name.." frame border elements",
        function(self, value)
            config.opacity = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create top border section header
    local topBorderHeader = CreateHeader(scrollChild, "Top Border", 10, -170)
    
    -- Create top border width/height sliders
    local topWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."TopBorderWidthSlider", 
        100, 500, 1, 300, 20, 10, -200, 
        "Top Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." frame top border",
        function(self, value)
            config.topWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local topHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."TopBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -250, 
        "Top Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." frame top border",
        function(self, value)
            config.topHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create top border X/Y position sliders
    local topXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."TopBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -300, 
        "Top Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." frame top border",
        function(self, value)
            config.topOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local topYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."TopBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -350, 
        "Top Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." frame top border",
        function(self, value)
            config.topOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create bottom border section header
    local bottomBorderHeader = CreateHeader(scrollChild, "Bottom Border", 10, -400)
    
    -- Create bottom border width/height sliders
    local bottomWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."BottomBorderWidthSlider", 
        100, 500, 1, 300, 20, 10, -430, 
        "Bottom Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." frame bottom border",
        function(self, value)
            config.bottomWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local bottomHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."BottomBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -480, 
        "Bottom Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." frame bottom border",
        function(self, value)
            config.bottomHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create bottom border X/Y position sliders
    local bottomXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."BottomBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -530, 
        "Bottom Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." frame bottom border",
        function(self, value)
            config.bottomOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local bottomYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."BottomBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -580, 
        "Bottom Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." frame bottom border",
        function(self, value)
            config.bottomOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create left border section header
    local leftBorderHeader = CreateHeader(scrollChild, "Left Border", 10, -630)
    
    -- Create left border width/height sliders
    local leftWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."LeftBorderWidthSlider", 
        20, 100, 1, 300, 20, 10, -660, 
        "Left Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." frame left border",
        function(self, value)
            config.leftWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local leftHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."LeftBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -710, 
        "Left Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." frame left border",
        function(self, value)
            config.leftHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create left border X/Y position sliders
    local leftXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."LeftBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -760, 
        "Left Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." frame left border",
        function(self, value)
            config.leftOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local leftYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."LeftBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -810, 
        "Left Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." frame left border",
        function(self, value)
            config.leftOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create right border section header
    local rightBorderHeader = CreateHeader(scrollChild, "Right Border", 10, -860)
    
    -- Create right border width/height sliders
    local rightWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."RightBorderWidthSlider", 
        20, 100, 1, 300, 20, 10, -890, 
        "Right Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." frame right border",
        function(self, value)
            config.rightWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local rightHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."RightBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -940, 
        "Right Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." frame right border",
        function(self, value)
            config.rightHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create right border X/Y position sliders
    local rightXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."RightBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -990, 
        "Right Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." frame right border",
        function(self, value)
            config.rightOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local rightYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."RightBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -1040, 
        "Right Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." frame right border",
        function(self, value)
            config.rightOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Store references to the border controls for updating
    unitFrames[unit].borderControls = {
        enabledCheckbox = enabledCheckbox,
        scaleSlider = scaleSlider,
        opacitySlider = opacitySlider,
        topWidthSlider = topWidthSlider,
        topHeightSlider = topHeightSlider,
        topXSlider = topXSlider,
        topYSlider = topYSlider,
        bottomWidthSlider = bottomWidthSlider,
        bottomHeightSlider = bottomHeightSlider,
        bottomXSlider = bottomXSlider,
        bottomYSlider = bottomYSlider,
        leftWidthSlider = leftWidthSlider,
        leftHeightSlider = leftHeightSlider,
        leftXSlider = leftXSlider,
        leftYSlider = leftYSlider,
        rightWidthSlider = rightWidthSlider,
        rightHeightSlider = rightHeightSlider,
        rightXSlider = rightXSlider,
        rightYSlider = rightYSlider
    }
    
    return unitFrames[unit].borderControls
end

-- Function to create controls for a unit's power bar tab
local function CreatePowerBarControls(unit, scrollChild)
    local config = unitFrames[unit].config.powerBar or {}
    
    -- Create header
    local powerBarHeader = CreateHeader(scrollChild, unitFrames[unit].name.." Power Bar", 10, -10)
    
    -- Create enable checkbox
    local enabledCheckbox = CreateCheckbox(
        scrollChild, 
        "MilaUI"..unit.."PowerBarEnabledCheckbox", 
        "Enable Power Bar", 
        10, -40, 
        "Enable or disable the "..unitFrames[unit].name.." power bar",
        function(self, checked)
            config.enabled = checked
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create scale slider
    local scaleSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarScaleSlider", 
        0.5, 2.0, 0.05, 300, 20, 10, -70, 
        "Power Bar Scale", 
        "Adjusts the scale of the "..unitFrames[unit].name.." power bar elements",
        function(self, value)
            config.scale = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create opacity slider
    local opacitySlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarOpacitySlider", 
        0, 1.0, 0.05, 300, 20, 10, -120, 
        "Power Bar Opacity", 
        "Adjusts the opacity of the "..unitFrames[unit].name.." power bar elements",
        function(self, value)
            config.opacity = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create top border section header
    local topBorderHeader = CreateHeader(scrollChild, "Top Border", 10, -170)
    
    -- Create top border width/height sliders
    local topWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarTopBorderWidthSlider", 
        100, 500, 1, 300, 20, 10, -200, 
        "Top Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." power bar top border",
        function(self, value)
            config.topWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local topHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarTopBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -250, 
        "Top Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." power bar top border",
        function(self, value)
            config.topHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create top border X/Y position sliders
    local topXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarTopBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -300, 
        "Top Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." power bar top border",
        function(self, value)
            config.topOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local topYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarTopBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -350, 
        "Top Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." power bar top border",
        function(self, value)
            config.topOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create bottom border section header
    local bottomBorderHeader = CreateHeader(scrollChild, "Bottom Border", 10, -400)
    
    -- Create bottom border width/height sliders
    local bottomWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarBottomBorderWidthSlider", 
        100, 500, 1, 300, 20, 10, -430, 
        "Bottom Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." power bar bottom border",
        function(self, value)
            config.bottomWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local bottomHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarBottomBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -480, 
        "Bottom Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." power bar bottom border",
        function(self, value)
            config.bottomHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create bottom border X/Y position sliders
    local bottomXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarBottomBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -530, 
        "Bottom Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." power bar bottom border",
        function(self, value)
            config.bottomOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local bottomYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarBottomBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -580, 
        "Bottom Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." power bar bottom border",
        function(self, value)
            config.bottomOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create left border section header
    local leftBorderHeader = CreateHeader(scrollChild, "Left Border", 10, -630)
    
    -- Create left border width/height sliders
    local leftWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarLeftBorderWidthSlider", 
        20, 100, 1, 300, 20, 10, -660, 
        "Left Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." power bar left border",
        function(self, value)
            config.leftWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local leftHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarLeftBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -710, 
        "Left Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." power bar left border",
        function(self, value)
            config.leftHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create left border X/Y position sliders
    local leftXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarLeftBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -760, 
        "Left Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." power bar left border",
        function(self, value)
            config.leftOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local leftYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarLeftBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -810, 
        "Left Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." power bar left border",
        function(self, value)
            config.leftOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create right border section header
    local rightBorderHeader = CreateHeader(scrollChild, "Right Border", 10, -860)
    
    -- Create right border width/height sliders
    local rightWidthSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarRightBorderWidthSlider", 
        20, 100, 1, 300, 20, 10, -890, 
        "Right Border Width", 
        "Adjusts the width of the "..unitFrames[unit].name.." power bar right border",
        function(self, value)
            config.rightWidth = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local rightHeightSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarRightBorderHeightSlider", 
        1, 20, 1, 300, 20, 10, -940, 
        "Right Border Height", 
        "Adjusts the height of the "..unitFrames[unit].name.." power bar right border",
        function(self, value)
            config.rightHeight = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Create right border X/Y position sliders
    local rightXSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarRightBorderXSlider", 
        -50, 50, 1, 300, 20, 10, -990, 
        "Right Border X Offset", 
        "Adjusts the horizontal position of the "..unitFrames[unit].name.." power bar right border",
        function(self, value)
            config.rightOffsetX = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    local rightYSlider = CreateSlider(
        scrollChild, 
        "MilaUI"..unit.."PowerBarRightBorderYSlider", 
        -50, 50, 1, 300, 20, 10, -1040, 
        "Right Border Y Offset", 
        "Adjusts the vertical position of the "..unitFrames[unit].name.." power bar right border",
        function(self, value)
            config.rightOffsetY = value
            MilaUI.modules.unitframes.ApplySizeSettings()
        end
    )
    
    -- Store references to the power bar controls for updating
    unitFrames[unit].powerBarControls = {
        enabledCheckbox = enabledCheckbox,
        scaleSlider = scaleSlider,
        opacitySlider = opacitySlider,
        topWidthSlider = topWidthSlider,
        topHeightSlider = topHeightSlider,
        topXSlider = topXSlider,
        topYSlider = topYSlider,
        bottomWidthSlider = bottomWidthSlider,
        bottomHeightSlider = bottomHeightSlider,
        bottomXSlider = bottomXSlider,
        bottomYSlider = bottomYSlider,
        leftWidthSlider = leftWidthSlider,
        leftHeightSlider = leftHeightSlider,
        leftXSlider = leftXSlider,
        leftYSlider = leftYSlider,
        rightWidthSlider = rightWidthSlider,
        rightHeightSlider = rightHeightSlider,
        rightXSlider = rightXSlider,
        rightYSlider = rightYSlider
    }
    
    return unitFrames[unit].powerBarControls
end

-- Create controls for each unit
for unit, unitInfo in pairs(unitFrames) do
    -- Create general controls
    CreateGeneralControls(unit, unitInfo.contentFrames[1].scrollChild)
    
    -- Create border controls
    CreateBorderControls(unit, unitInfo.contentFrames[2].scrollChild)
    
    -- Create power bar controls
    CreatePowerBarControls(unit, unitInfo.contentFrames[3].scrollChild)
    
    -- Set the first tab as selected by default
    unitInfo.tabs[1]:SetSelectedState()
    unitInfo.contentFrames[1]:Show()
end

-- Function to update the unit display
function sizeGUI:UpdateUnitDisplay(unit)
    -- Hide all unit frames
    for u, info in pairs(unitFrames) do
        info.frame:Hide()
    end
    
    -- Show the selected unit frame
    unitFrames[unit].frame:Show()
    
    -- Update the values
    self:UpdateValues(unit)
end

-- Function to update slider values from config
function sizeGUI:UpdateValues(unit)
    if not unit then return end
    
    local config = unitFrames[unit].config
    local sliders = unitFrames[unit].sliders
    local borderControls = unitFrames[unit].borderControls
    local powerBarControls = unitFrames[unit].powerBarControls
    
    -- Update general sliders
    if sliders then
        sliders.scale:SetValue(config.scale or 1.0)
        sliders.scale.valueText:SetText(string.format("%.2f", config.scale or 1.0))
        
        sliders.width:SetValue(config.width or 295)
        sliders.height:SetValue(config.height or 34)
        sliders.powerContainerWidth:SetValue(config.powerContainerWidth or 295)
        sliders.powerContainerHeight:SetValue(config.powerContainerHeight or 34)
        sliders.powerWidth:SetValue(config.powerWidth or 278)
        sliders.powerHeight:SetValue(config.powerHeight or 17)
    end
    
    -- Update border controls
    if borderControls and config.border then
        borderControls.enabledCheckbox:SetChecked(config.border.enabled)
        borderControls.scaleSlider:SetValue(config.border.scale or 1.0)
        borderControls.scaleSlider.valueText:SetText(string.format("%.2f", config.border.scale or 1.0))
        borderControls.opacitySlider:SetValue(config.border.opacity or 0.8)
        borderControls.topWidthSlider:SetValue(config.border.topWidth or 264)
        borderControls.topHeightSlider:SetValue(config.border.topHeight or 6)
        borderControls.bottomWidthSlider:SetValue(config.border.bottomWidth or 264)
        borderControls.bottomHeightSlider:SetValue(config.border.bottomHeight or 6)
        borderControls.leftWidthSlider:SetValue(config.border.leftWidth or 45)
        borderControls.leftHeightSlider:SetValue(config.border.leftHeight or 6)
        borderControls.rightWidthSlider:SetValue(config.border.rightWidth or 45)
        borderControls.rightHeightSlider:SetValue(config.border.rightHeight or 6)
        borderControls.topXSlider:SetValue(config.border.topOffsetX or 0)
        borderControls.topYSlider:SetValue(config.border.topOffsetY or 0)
        borderControls.bottomXSlider:SetValue(config.border.bottomOffsetX or 0)
        borderControls.bottomYSlider:SetValue(config.border.bottomOffsetY or 0)
        borderControls.leftXSlider:SetValue(config.border.leftOffsetX or 0)
        borderControls.leftYSlider:SetValue(config.border.leftOffsetY or 0)
        borderControls.rightXSlider:SetValue(config.border.rightOffsetX or 0)
        borderControls.rightYSlider:SetValue(config.border.rightOffsetY or 0)
    end
    
    -- Update power bar controls
    if powerBarControls and config.powerBar then
        powerBarControls.enabledCheckbox:SetChecked(config.powerBar.enabled)
        powerBarControls.scaleSlider:SetValue(config.powerBar.scale or 1.0)
        powerBarControls.scaleSlider.valueText:SetText(string.format("%.2f", config.powerBar.scale or 1.0))
        powerBarControls.opacitySlider:SetValue(config.powerBar.opacity or 0.8)
        powerBarControls.topWidthSlider:SetValue(config.powerBar.topWidth or 264)
        powerBarControls.topHeightSlider:SetValue(config.powerBar.topHeight or 6)
        powerBarControls.bottomWidthSlider:SetValue(config.powerBar.bottomWidth or 264)
        powerBarControls.bottomHeightSlider:SetValue(config.powerBar.bottomHeight or 6)
        powerBarControls.leftWidthSlider:SetValue(config.powerBar.leftWidth or 45)
        powerBarControls.leftHeightSlider:SetValue(config.powerBar.leftHeight or 6)
        powerBarControls.rightWidthSlider:SetValue(config.powerBar.rightWidth or 45)
        powerBarControls.rightHeightSlider:SetValue(config.powerBar.rightHeight or 6)
        powerBarControls.topXSlider:SetValue(config.powerBar.topOffsetX or 0)
        powerBarControls.topYSlider:SetValue(config.powerBar.topOffsetY or 0)
        powerBarControls.bottomXSlider:SetValue(config.powerBar.bottomOffsetX or 0)
        powerBarControls.bottomYSlider:SetValue(config.powerBar.bottomOffsetY or 0)
        powerBarControls.leftXSlider:SetValue(config.powerBar.leftOffsetX or 0)
        powerBarControls.leftYSlider:SetValue(config.powerBar.leftOffsetY or 0)
        powerBarControls.rightXSlider:SetValue(config.powerBar.rightOffsetX or 0)
        powerBarControls.rightYSlider:SetValue(config.powerBar.rightOffsetY or 0)
    end
end

-- Function to create a button
local function CreateButton(parent, name, width, height, point, relativeFrame, relativePoint, xOffset, yOffset, text, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
    button:SetText(text)
    
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    
    return button
end

-- Create Save and Reset buttons
local saveButton = CreateButton(
    sizeGUI, "MilaUISaveButton", 100, 25, "BOTTOMRIGHT", sizeGUI, "BOTTOMRIGHT", -10, 10, "Save",
    function()
        MilaUI.modules.unitframes.SaveConfig()
    end
)

local resetButton = CreateButton(
    sizeGUI, "MilaUIResetButton", 100, 25, "BOTTOMRIGHT", saveButton, "BOTTOMLEFT", -10, 0, "Reset to Default",
    function()
        MilaUI.modules.unitframes.ResetToDefaults()
        sizeGUI:UpdateValues(selectedUnit)
    end
)

-- Select the first unit by default
if #unitButtons > 0 then
    unitButtons[1]:SetSelectedState()
    sizeGUI:UpdateUnitDisplay(unitButtons[1].unit)
end

-- Register slash command
SLASH_MILASIZE1 = "/muisize"
SlashCmdList["MILASIZE"] = function()
    sizeGUI:Show()
end

-- Make the GUI accessible through the addon table
MilaUI.sizeGUI = sizeGUI
