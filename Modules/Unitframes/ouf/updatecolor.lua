-- MilaUI Health Color Module
local addonName, MilaUI = ...

-- Initialize the modules table if it doesn't exist
if not MilaUI.modules then MilaUI.modules = {} end
if not MilaUI.modules.unitframes then MilaUI.modules.unitframes = {} end

-- Create our addon frame to handle events
local MilaUIColor = CreateFrame("Frame")
MilaUI.modules.unitframes.colorModule = MilaUIColor

-- Debug mode flag - set to true to enable debug messages
local debugMode = false

-- Define the mob ID to color mapping.
local mobColors = {
    [138061] = { r = 1, g = 0, b = 0 },  -- Example: mob ID 138061 -> red
    [67890] = { r = 0, g = 1, b = 0 },   -- Example: mob ID 67890 -> green
    [39] = { r = 1, g = 0, b = 0 },      -- Example: mob ID 39 -> red
    -- Add additional mappings as needed.
}

-- Color mapping table for Plater color names (if Plater is installed)
local colorRGB = {
    white = {1.00, 1.00, 1.00},
    black = {0.00, 0.00, 0.00},
    red = {1.00, 0.00, 0.00},
    green = {0.00, 0.67, 0.00},
    blue = {0.00, 0.44, 0.87},
    yellow = {0.12, 1.00, 0.50},
    orange = {1.00, 0.65, 0.00},
    purple = {0.50, 0.00, 0.50},
    cyan = {0.00, 1.00, 1.00},
    magenta = {1.00, 0.00, 1.00},
    gray = {0.50, 0.50, 0.50},
    pink = {1.00, 0.75, 0.80},
    brown = {0.65, 0.16, 0.16},
    gold = {1.00, 0.84, 0.00},
    silver = {0.75, 0.75, 0.75},
    deepskyblue = {0.00, 0.75, 1.00},
    fuchsia = {1.00, 0.00, 1.00},
    peru = {0.80, 0.52, 0.25},
    mediumpurple = {0.58, 0.44, 0.86},
    burlywood = {0.87, 0.72, 0.53},
}

-- Reaction colors for fallback
local reactionColors = {
    [1] = {r = 1.00, g = 0.00, b = 0.00}, -- Hated
    [2] = {r = 1.00, g = 0.00, b = 0.00}, -- Hostile
    [3] = {r = 1.00, g = 0.00, b = 0.00}, -- Unfriendly
    [4] = {r = 1.00, g = 0.79, b = 0.03}, -- Neutral
    [5] = {r = 0.00, g = 0.67, b = 0.00}, -- Friendly
    [6] = {r = 0.00, g = 0.67, b = 0.00}, -- Honored
    [7] = {r = 0.00, g = 0.67, b = 0.00}, -- Revered
    [8] = {r = 0.00, g = 0.67, b = 0.00}, -- Exalted
}

-- Cache to store last known state (GUID, tapped status) for each frame
local frameUnitCache = {}

-- Debug printing function
local function Debug(message)
    if debugMode then
        print("|cFF00FFFF[MilaUI Color Debug]|r " .. tostring(message))
    end
end

-- Utility: Extract mob ID from a unit GUID.
local function ExtractMobID(guid)
    if not guid then
        Debug("No GUID provided to ExtractMobID")
        return nil
    end
    
    Debug("Raw GUID: " .. guid)
    
    -- GUID format in WoW is typically: 
    -- Creature-0-XXXX-XXXX-XXXX-XXXXXXXXXXXX (for NPCs)
    -- Player-XXXX-XXXX-XXXX-XXXXXXXXXXXX (for players)
    local guidType, _, _, _, _, npcID = strsplit("-", guid)
    Debug("GUID Type: " .. (guidType or "nil"))
    
    -- Only process for creatures (NPCs)
    if guidType == "Creature" or guidType == "Vehicle" or guidType == "Pet" or guidType == "Vignette" then
        Debug("Extracted NPC ID: " .. (npcID or "nil"))
        return tonumber(npcID)
    else
        Debug("Not a creature GUID: " .. guidType)
        return nil
    end
end

-- Function to get color from Plater for a specific mob ID (if Plater is installed)
local function GetPlaterColorForMobID(mobID)
    if not Plater or not Plater.db or not Plater.db.profile or not Plater.db.profile.npc_colors then
        Debug("Plater not loaded or npc_colors not available")
        return nil
    end
    
    local npcColorData = Plater.db.profile.npc_colors[mobID]
    if not npcColorData then
        Debug("No Plater color data found for mobID: " .. tostring(mobID))
        return nil
    end
    
    local colorName = npcColorData[3]
    if not colorName then
        Debug("No color name in Plater data for mobID: " .. tostring(mobID))
        return nil
    end
    
    Debug("Found Plater color name: " .. colorName .. " for mobID: " .. tostring(mobID))
    
    local rgb = colorRGB[colorName:lower()]
    if not rgb then
        Debug("Unknown color name from Plater: " .. colorName)
        return nil
    end
    
    return {r = rgb[1], g = rgb[2], b = rgb[3]}
end

-- Function to update the health bar's color based on the unit's mob ID.
local function UpdateHealthBarColor(health, unit)
    Debug("UpdateHealthBarColor called for unit: " .. (unit or "nil"))
    
    if not health then
        Debug("Health frame is nil, cannot update color")
        return
    end
    
    -- Get the frame from the health element
    local frame = health:GetParent()
    if not frame then
        Debug("Could not get frame from health element")
        return
    end

    if unit == "target" or unit == "focus" then
        local guid = UnitGUID(unit)
        local isTapped = UnitIsTapDenied(unit)
        Debug("GUID for " .. unit .. ": " .. (guid or "nil") .. ", Tapped: " .. tostring(isTapped))
        
        -- Check cache to avoid unnecessary updates
        local cached = frameUnitCache[frame]
        if cached and cached.guid == guid and cached.tapped == isTapped then
            Debug("No change in unit or tapped status, skipping update")
            return
        end
        
        -- Update cache
        frameUnitCache[frame] = {
            guid = guid,
            tapped = isTapped
        }
        
        -- Handle tapped units
        if isTapped then
            Debug("Unit is tapped, setting tapped color")
            health:SetStatusBarColor(0.6, 0.6, 0.6) -- Gray for tapped units
            return
        end
        
        -- Extract mob ID from GUID
        local mobID = ExtractMobID(guid)
        Debug("Extracted mobID: " .. (mobID or "nil"))
        
        if mobID then
            -- First check our local mobColors table
            local color = mobColors[mobID]
            
            -- If not found in our local table, try to get from Plater
            if not color and Plater then
                color = GetPlaterColorForMobID(mobID)
                Debug("Got color from Plater: " .. (color and "yes" or "no"))
            end
            
            -- If we have a color, apply it
            if color then
                Debug("Setting color for mobID " .. mobID .. ": r=" .. color.r .. ", g=" .. color.g .. ", b=" .. color.b)
                health:SetStatusBarColor(color.r, color.g, color.b)
                return
            else
                Debug("No specific color found for mobID: " .. mobID)
            end
        end
        
        -- If we get here, no specific color was found, use reaction color
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local reactionColor = reactionColors[reaction]
            if reactionColor then
                Debug("Using reaction color for reaction " .. reaction)
                health:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)
                return
            end
        end
        
        -- If all else fails, use class color for players or default color for NPCs
        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            if class then
                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    Debug("Using class color for " .. class)
                    health:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
                    return
                end
            end
        else
            -- Default color for NPCs when no other color is found
            Debug("Using default color for NPC")
            health:SetStatusBarColor(0.8, 0.0, 0.0) -- Default red for NPCs
        end
    else
        Debug("Unit is not target or focus: " .. (unit or "nil"))
    end
end

-- Function to hook into oUF health updates
local function HookHealthUpdate(self, unit, min, max)
    if unit == "target" or unit == "focus" then
        UpdateHealthBarColor(self, unit)
    end
end

-- Function to initialize the color module
function MilaUIColor:Initialize()
    Debug("MilaUI color module loaded")
    
    -- Register for events
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self:RegisterEvent("UNIT_HEALTH")
    
    -- Set up event handler
    self:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_TARGET_CHANGED" then
            Debug("Target changed event")
            local targetFrame = _G["MilaUITargetFrame"]
            if targetFrame and targetFrame.Health then
                UpdateHealthBarColor(targetFrame.Health, "target")
            else
                Debug("Target frame or health element not found")
            end
        elseif event == "PLAYER_FOCUS_CHANGED" then
            Debug("Focus changed event")
            local focusFrame = _G["MilaUIFocusFrame"]
            if focusFrame and focusFrame.Health then
                UpdateHealthBarColor(focusFrame.Health, "focus")
            else
                Debug("Focus frame or health element not found")
            end
        elseif event == "UNIT_HEALTH" then
            local unit = ...
            if unit == "target" then
                local targetFrame = _G["MilaUITargetFrame"]
                if targetFrame and targetFrame.Health then
                    UpdateHealthBarColor(targetFrame.Health, "target")
                end
            elseif unit == "focus" then
                local focusFrame = _G["MilaUIFocusFrame"]
                if focusFrame and focusFrame.Health then
                    UpdateHealthBarColor(focusFrame.Health, "focus")
                end
            end
        end
    end)
    
    -- Hook into oUF frames
    local function HookFrames()
        Debug("Attempting to hook MilaUI frames")
        
        -- Hook target frame
        local targetFrame = _G["MilaUITargetFrame"]
        if targetFrame and targetFrame.Health then
            Debug("Hooking target frame health")
            hooksecurefunc(targetFrame.Health, "SetValue", function(self)
                UpdateHealthBarColor(self, "target")
            end)
        else
            Debug("Target frame or health element not found for hooking")
        end
        
        -- Hook focus frame if it exists
        local focusFrame = _G["MilaUIFocusFrame"]
        if focusFrame and focusFrame.Health then
            Debug("Hooking focus frame health")
            hooksecurefunc(focusFrame.Health, "SetValue", function(self)
                UpdateHealthBarColor(self, "focus")
            end)
        else
            Debug("Focus frame or health element not found for hooking")
        end
    end
    
    -- Wait for frames to be created
    C_Timer.After(1, HookFrames)
    
    -- Add a slash command to toggle debug mode
    SLASH_MILAUICOLOR1 = "/muicolor"
    SlashCmdList["MILAUICOLOR"] = function(msg)
        if msg == "debug" then
            debugMode = not debugMode
            print("|cff00ff00MilaUI Color:|r Debug mode " .. (debugMode and "enabled" or "disabled"))
        elseif msg == "test" then
            print("|cff00ff00MilaUI Color:|r Testing color module...")
            local targetFrame = _G["MilaUITargetFrame"]
            if targetFrame and targetFrame.Health then
                UpdateHealthBarColor(targetFrame.Health, "target")
                print("|cff00ff00MilaUI Color:|r Test complete for target frame")
            else
                print("|cffff0000MilaUI Color:|r Target frame not found for testing")
            end
        else
            print("|cff00ff00MilaUI Color:|r Commands:")
            print("  /muicolor debug - Toggle debug mode")
            print("  /muicolor test - Test color module on current target")
        end
    end
    
    print("|cff00ff00MilaUI Color Module Loaded|r")
end

-- Initialize the module
MilaUIColor:Initialize()
