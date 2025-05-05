-- MyMobHealthColor.lua

-- Create our addon frame to handle events
local MilaUIColor = CreateFrame("Frame")

-- Debug mode flag - disabled by default
local debugMode = false

-- Define the mob ID to color mapping.
local mobColors = {
    [138061] = { r = 1, g = 0, b = 0 },  -- Example: mob ID 12345 -> red
    [67890] = { r = 0, g = 1, b = 0 },  -- Example: mob ID 67890 -> green
    -- Add additional mappings as needed.
    [39] = { r = 1, g = 0, b = 0 },
}

-- Color mapping table for Plater color names
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
        print("|cFF00FFFF[ElvUI Color Debug]|r " .. tostring(message))
    end
end

-- Store original health bar colors for frames we've modified
local modifiedFrames = {}

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

-- Function to completely disable ElvUI's health coloring for a frame
local function DisableElvUIColoring(frame)
    if not frame or not frame.Health then return end
    
    local health = frame.Health
    
    -- Store original values if we haven't already
    if not modifiedFrames[frame] then
        modifiedFrames[frame] = {
            colorTapping = health.colorTapping,
            colorDisconnected = health.colorDisconnected,
            colorClass = health.colorClass,
            colorReaction = health.colorReaction,
            colorHealth = health.colorHealth,
            colorThreat = health.colorThreat,
            colorPower = health.colorPower,
            colorHappiness = health.colorHappiness
        }
        Debug("Stored original coloring settings for frame")
    end
    
    -- Disable all ElvUI coloring
    health.colorTapping = false
    health.colorDisconnected = false
    health.colorClass = false
    health.colorReaction = false
    health.colorHealth = false
    health.colorThreat = false
    health.colorPower = false
    health.colorHappiness = false
    
    Debug("Disabled ElvUI coloring for frame")
end

-- Function to restore ElvUI's health coloring for a frame
local function RestoreElvUIColoring(frame)
    if not frame or not modifiedFrames[frame] then return end
    
    local health = frame.Health
    local original = modifiedFrames[frame]
    
    -- Restore original values
    health.colorTapping = original.colorTapping
    health.colorDisconnected = original.colorDisconnected
    health.colorClass = original.colorClass
    health.colorReaction = original.colorReaction
    health.colorHealth = original.colorHealth
    health.colorThreat = original.colorThreat
    health.colorPower = original.colorPower
    health.colorHappiness = original.colorHappiness
    
    -- Clear cache and modified status
    frameUnitCache[frame] = nil
    modifiedFrames[frame] = nil
    
    Debug("Restored original coloring settings for frame and cleared cache")
end

-- Function to get color from Plater for a specific mob ID
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
    
    -- Get the frame from the health element (ensure __owner is valid or find alternative)
    local frame = health.__owner 
    if not frame then
        Debug("Could not get frame from health element")
        return
    end

    if unit == "target" or unit == "focus" then
        local guid = UnitGUID(unit)
        local isTapped = UnitIsTapDenied(unit)
        Debug("GUID for " .. unit .. ": " .. (guid or "nil") .. ", Tapped: " .. tostring(isTapped))
        
        -- Check cache
        local cached = frameUnitCache[frame]
        if cached and cached.guid == guid and cached.tapped == isTapped then
            Debug("Cache hit for frame " .. (frame:GetName() or "unnamed") .. ". GUID and tapped status unchanged.")
            return -- No change, skip update
        end
        
        -- Update cache before proceeding
        frameUnitCache[frame] = { guid = guid, tapped = isTapped }
        Debug("Cache miss or state changed for frame " .. (frame:GetName() or "unnamed") .. ". Proceeding with update.")

        if not guid then
            Debug("No GUID found for " .. unit .. ", attempting to restore default colors.")
            RestoreElvUIColoring(frame) -- Restore if we lose GUID
            -- Explicitly set default reaction color if needed after restore
            local reaction = UnitReaction(unit, "player")
            local fallbackColor = reactionColors[reaction] or {r=0.5, g=0.5, b=0.5} -- Default gray
            health:SetStatusBarColor(fallbackColor.r, fallbackColor.g, fallbackColor.b)
            return
        end
        
        -- Check if unit is tapped/tagged by another player
        if isTapped then
            Debug("Unit is tapped/tagged by another player, using gray color")
            DisableElvUIColoring(frame) 
            health:SetStatusBarColor(0.5, 0.5, 0.5) -- Set to gray
            return
        end
        
        -- Handle player units with class colors
        if UnitIsPlayer(unit) then
            Debug("Unit is a player, using class color")
            local _, class = UnitClass(unit)
            if class then
                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    Debug("Applying class color for " .. class)
                    
                    if frame then
                        -- Disable ElvUI's coloring system
                        DisableElvUIColoring(frame)
                        
                        -- Apply class color directly
                        health:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
                        Debug("Class color set successfully")
                    else
                        Debug("Could not get frame from health element")
                        health:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
                    end
                    return
                end
            end
        end
        
        local mobID = ExtractMobID(guid)
        Debug("MobID for " .. unit .. ": " .. (mobID or "nil"))
        
        if mobID then
            -- First check our local mobColors table
            local color = mobColors[mobID]
            
            -- If not found in our local table, try to get from Plater
            if not color and Plater then
                color = GetPlaterColorForMobID(mobID)
                Debug("Got color from Plater: " .. (color and "yes" or "no"))
            end
            
            if color then
                Debug("Found color for mobID " .. mobID .. ": r=" .. color.r .. ", g=" .. color.g .. ", b=" .. color.b)
                
                if frame then
                    -- Disable ElvUI's coloring system
                    DisableElvUIColoring(frame)
                    
                    -- Apply our color directly
                    health:SetStatusBarColor(color.r, color.g, color.b)
                    Debug("Color set successfully with ElvUI coloring disabled")
                    
                    -- Prevent ElvUI from changing it back
                    if health.UpdateColor then
                        health.UpdateColor = function() end
                        Debug("Overrode UpdateColor function to prevent recoloring")
                    end
                else
                    Debug("Could not get frame from health element")
                    health:SetStatusBarColor(color.r, color.g, color.b)
                end
                return
            end
            
            -- If no specific color found, try using reaction color
            local reaction = UnitReaction(unit, "player")
            if reaction and reactionColors[reaction] then
                Debug("Using reaction color for reaction level: " .. reaction)
                local color = reactionColors[reaction]
                
                if frame then
                    DisableElvUIColoring(frame)
                    health:SetStatusBarColor(color.r, color.g, color.b)
                else
                    health:SetStatusBarColor(color.r, color.g, color.b)
                end
                return
            end
            
            -- Finally, check if unit is enemy and use red color
            if UnitIsEnemy("player", unit) then
                Debug("Unit is enemy, using red color")
                if frame then
                    DisableElvUIColoring(frame)
                    health:SetStatusBarColor(1.0, 0.0, 0.0) -- Red for enemies
                else
                    health:SetStatusBarColor(1.0, 0.0, 0.0)
                end
                return
            end
            
            Debug("No color mapping found, reverting to default")
            -- Don't change color if no mapping exists
            -- Restore original coloring if we previously modified this frame
            if frame then
                RestoreElvUIColoring(frame)
            end
        else
            Debug("No valid mobID extracted, cannot update color")
            -- Restore original coloring if we previously modified this frame
            if frame then
                RestoreElvUIColoring(frame)
            end
        end
    else
        Debug("Unit is not target or focus: " .. (unit or "nil"))
    end
end

-- Function to hook into the health bar's PostUpdate so that it updates automatically.
local function HookHealthBar(frame)
    Debug("Attempting to hook health bar for frame: " .. (frame and frame:GetName() or "unnamed frame"))
    
    if frame and frame.Health then
        Debug("Frame has Health element, hooking PostUpdate")
        
        -- Override the SetStatusBarColor method to ensure our colors stick
        local oldSetStatusBarColor = frame.Health.SetStatusBarColor
        frame.Health.SetStatusBarColor = function(self, r, g, b, a)
            -- Check if this is our custom color
            local unit = frame.unit
            if unit and (unit == "target" or unit == "focus") then
                local guid = UnitGUID(unit)
                if guid then
                    local mobID = ExtractMobID(guid)
                    if mobID and mobColors[mobID] then
                        local color = mobColors[mobID]
                        Debug("Intercepted SetStatusBarColor, applying our color instead")
                        return oldSetStatusBarColor(self, color.r, color.g, color.b, a or 1)
                    end
                end
            end
            
            -- Otherwise, let the original function handle it
            return oldSetStatusBarColor(self, r, g, b, a)
        end
        
        -- Hook PostUpdate
        local oldPostUpdate = frame.Health.PostUpdate
        frame.Health.PostUpdate = function(self, unit, ...)
            Debug("Health PostUpdate called for unit: " .. (unit or "nil"))
            
            -- First, let ElvUI's PostUpdate run (if it exists)
            if oldPostUpdate then
                oldPostUpdate(self, unit, ...)
            end
            
            -- Now apply our custom coloring
            UpdateHealthBarColor(self, unit)
        end
        
        Debug("Successfully hooked health bar PostUpdate")
    else
        Debug("Frame has no Health element, cannot hook")
    end
end

-- Function to hook into ElvUI's handling of unit frames
local function HookElvUI()
    Debug("Attempting to hook ElvUI unit frames")
    
    if not ElvUI then
        Debug("ElvUI is not loaded, cannot hook")
        return
    end
    
    local E = unpack(ElvUI)
    local UF = E:GetModule('UnitFrames')
    
    if not UF then
        Debug("ElvUI UnitFrames module not found, cannot hook")
        return
    end
    
    Debug("Found ElvUI UnitFrames module, attempting to hook")
    
    -- Hook ElvUI's CreateAndUpdateUF function to catch when frames are created/updated
    if UF.CreateAndUpdateUF then
        local oldCreateAndUpdateUF = UF.CreateAndUpdateUF
        UF.CreateAndUpdateUF = function(self, unit)
            -- Let the original function run first
            oldCreateAndUpdateUF(self, unit)
            
            -- Only hook our targeted unit frames
            if unit == "target" or unit == "focus" then
                local frame = UF[unit]
                if frame then
                    Debug("Hooking " .. unit .. " frame")
                    HookHealthBar(frame)
                end
            end
            
            -- For boss and arena frames, we need to hook all of them
            if unit == "boss" or unit == "arena" then
                for i = 1, 5 do
                    local frame = UF[unit .. i]
                    if frame then
                        Debug("Hooking " .. unit .. i .. " frame")
                        HookHealthBar(frame)
                    end
                end
            end
        end
        
        Debug("Successfully hooked ElvUI's CreateAndUpdateUF function")
    else
        Debug("ElvUI's CreateAndUpdateUF function not found, trying alternative hook")
        
        -- Alternative: Hook into specific frame construction functions
        if UF.Target then
            Debug("Target frame exists, hooking directly")
            HookHealthBar(UF.Target)
        end
        
        if UF.Focus then
            Debug("Focus frame exists, hooking directly")
            HookHealthBar(UF.Focus)
        end
    end
    
    -- Hook UF:UpdateAllFrames to catch updates
    if UF.UpdateAllFrames then
        local oldUpdateAllFrames = UF.UpdateAllFrames
        UF.UpdateAllFrames = function(self)
            -- Let the original update happen
            oldUpdateAllFrames(self)
            
            -- Re-hook our target frames
            if UF.Target then
                HookHealthBar(UF.Target)
            end
            
            if UF.Focus then
                HookHealthBar(UF.Focus)
            end
            
            Debug("Re-hooked frames after UpdateAllFrames")
        end
        
        Debug("Successfully hooked ElvUI's UpdateAllFrames function")
    end
end

-- Initialize the addon when it's loaded
function MilaUIColor:Initialize()
    Debug("ElvUI color module loaded")
    
    -- Check if ElvUI is loaded
    if not ElvUI then
        Debug("ElvUI is not loaded, waiting for it to load")
        self:RegisterEvent("ADDON_LOADED")
        return
    end
    
    -- Register events for target changes
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    
    -- Hook into ElvUI
    HookElvUI()
    
    -- Create a slash command for testing
    SLASH_ELVUICOLOR1 = "/elvuicolor"
    SlashCmdList["ELVUICOLOR"] = function(msg)
        Debug("Test command received: " .. msg)
        
        -- Find the target frame
        local E = unpack(ElvUI)
        local UF = E:GetModule('UnitFrames')
        
        if UF and UF.Target and UF.Target.Health then
            Debug("Setting test color on target frame")
            UF.Target.Health:SetStatusBarColor(1, 0, 0)
        else
            Debug("Could not find target frame health bar")
        end
    end
    
    -- Create debug toggle command
    SLASH_SADEBUG1 = "/sadebug"
    SlashCmdList["SADEBUG"] = function(msg)
        debugMode = not debugMode
        if debugMode then
            print("|cFF00FFFF[MilaUIColor]|r Debug mode |cFF00FF00enabled|r")
        else
            print("|cFF00FFFF[MilaUIColor]|r Debug mode |cFFFF0000disabled|r")
        end
    end
    
    print("|cFF00FFFF[MilaUIColor]|r Loaded. Type '/sadebug' to toggle debug mode.")
    Debug("Initialization complete")
end

-- Register for ADDON_LOADED to initialize after ElvUI loads
MilaUIColor:SetScript("OnEvent", function(self, event, arg1)
    Debug("Event fired: " .. event .. (arg1 and (", arg1: " .. arg1) or ""))
    
    if event == "ADDON_LOADED" then
        if arg1 == "ElvUI" or arg1 == "ElvUI_OptionsUI" then
            Debug("ElvUI loaded, initializing")
            self:Initialize()
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        Debug("Target changed, updating color")
        
        -- Find the target frame
        if ElvUI then
            local E = unpack(ElvUI)
            local UF = E:GetModule('UnitFrames')
            
            if UF and UF.Target and UF.Target.Health then
                -- If we have a previous target that's going away, restore its colors
                if modifiedFrames[UF.Target] then
                    RestoreElvUIColoring(UF.Target)
                end
                
                -- Now update for the new target
                UpdateHealthBarColor(UF.Target.Health, "target")
            end
        end
    elseif event == "PLAYER_FOCUS_CHANGED" then
        Debug("Focus changed, updating color")
        
        -- Find the focus frame
        if ElvUI then
            local E = unpack(ElvUI)
            local UF = E:GetModule('UnitFrames')
            
            if UF and UF.Focus and UF.Focus.Health then
                -- If we have a previous focus that's going away, restore its colors
                if modifiedFrames[UF.Focus] then
                    RestoreElvUIColoring(UF.Focus)
                end
                
                -- Now update for the new focus
                UpdateHealthBarColor(UF.Focus.Health, "focus")
            end
        end
    end
end)

-- Initialize on load
MilaUIColor:Initialize()
