local units = { player = true, target = true, focus = true }

-- Track modified frames to avoid duplicate processing
local modifiedFrames = {}

-- Configuration for BigDebuffs icons
local config = {
    enabled = true,
    mask = {
        texture = "Interface\\Addons\\MilaUI\\media\\Portrait\\hex_bigdebuffs_mask.tga",
    }
}

-- Create a frame to handle events and updates
local UpdateFrame = CreateFrame("Frame")

local function CustomizeBigDebuffsIcon(frame)
    if not frame or not config.enabled then return end

    if frame.icon then
        frame.icon:ClearAllPoints()
        frame.icon:SetAllPoints(frame)

        frame.icon:SetTexCoord(0, 1, 0, 1)

        -- Apply mask
        if not frame.customMask then
            frame.customMask = frame:CreateMaskTexture()
            frame.customMask:SetAllPoints(frame.icon)
            frame.customMask:SetTexture(config.mask.texture)
            frame.icon:AddMaskTexture(frame.customMask)
        end

        -- Setup cooldown
        if frame.cooldown then
            frame.cooldown:ClearAllPoints()
            frame.cooldown:SetAllPoints(frame.icon)
            frame.cooldown:SetSwipeColor(0, 0, 0, 0.8)
            frame.cooldown:SetSwipeTexture(config.mask.texture)
        end
    end

    return frame
end

-- Function to check if a unit has an elite/rare classification
local function HasSpecialClassification(unit)
    if not unit or not UnitExists(unit) then return false end
    
    local classification = UnitClassification(unit)
    return classification == "elite" or classification == "rare" or classification == "rareelite" or classification == "worldboss"
end

-- Update the EXTRA overlay (Elite/Rare Dragon) - Called only when applying overlays
local function UpdateExtraOverlay(portrait, unit)
    -- Ensure overlay exists
    if not portrait or not portrait.extraOverlay then return end

    -- Hide if unit doesn't exist
    if not UnitExists(unit) then
        portrait.extraOverlay:Hide()
        return
    end

    -- Get original size if possible
    local originalW, originalH = nil, nil
    if portrait.extra then originalW, originalH = portrait.extra:GetSize() end

    -- Check classification and determine texture
    local hasSpecialClass = HasSpecialClassification(unit)
    if hasSpecialClass then
        local extraTexture
        if portrait.extra and portrait.extra:GetTexture() then extraTexture = portrait.extra:GetTexture() end
        if not extraTexture then
             local classification = UnitClassification(unit)
             if classification == "elite" then extraTexture = portrait.eliteFile
             elseif classification == "rare" then extraTexture = portrait.rareFile
             elseif classification == "rareelite" then extraTexture = portrait.rareeliteFile
             elseif classification == "worldboss" then extraTexture = portrait.bossFile end
        end

        -- Hide if no valid texture found for the classification
        if not extraTexture then
            portrait.extraOverlay:Hide()
            return
        end

        -- Apply texture and properties
        local texCoordsToUse = portrait.texCoords or {0, 1, 0, 1}
        local extraBlendMode = portrait.extra and portrait.extra:GetBlendMode() or "BLEND"
        local extraR, extraG, extraB, extraA = 1, 1, 1, 1
        if portrait.extra then extraR, extraG, extraB, extraA = portrait.extra:GetVertexColor() end

        portrait.extraOverlayTexture:SetTexture(extraTexture)
        portrait.extraOverlayTexture:SetVertexColor(extraR, extraG, extraB, extraA)
        portrait.extraOverlayTexture:SetBlendMode(extraBlendMode)

        -- Apply size
        local targetW = originalW or portrait.extraOverlay:GetWidth()
        local targetH = originalH or portrait.extraOverlay:GetHeight()
        portrait.extraOverlayTexture:SetSize(targetW, targetH)
        portrait.extraOverlayTexture:ClearAllPoints()
        portrait.extraOverlayTexture:SetPoint("CENTER", portrait.extraOverlay, "CENTER")
        portrait.extraOverlayTexture:SetTexCoord(unpack(texCoordsToUse))

        -- Mirroring
        if unit == "target" or unit == "focus" then
             portrait.extraOverlayTexture:SetTexCoord(texCoordsToUse[2], texCoordsToUse[1], texCoordsToUse[3], texCoordsToUse[4])
        end
        -- Show the overlay
        portrait.extraOverlay:Show()
    else
        -- Hide if no special classification
        portrait.extraOverlay:Hide()
    end
end

-- Update the main BP_texture overlay - Called only when applying overlays
local function UpdateBPTextureOverlay(portrait, unit)
    -- Ensure overlay exists
    if not portrait or not portrait.bpTextureOverlay then return end

    -- Hide if unit doesn't exist
    if not UnitExists(unit) then
        portrait.bpTextureOverlay:Hide()
        return
    end

    -- Find original texture
    local originalTexture = portrait.texture or (portrait.GetTexture and portrait)
    if not originalTexture then
        portrait.bpTextureOverlay:Hide()
        return
    end

    -- Get texture path
    local texPath = originalTexture:GetTexture()
    if not texPath then
        portrait.bpTextureOverlay:Hide()
        return
    end

    -- Get properties
    local originalW, originalH = originalTexture:GetSize()
    local texCoordsToUse = portrait.texCoords or {0, 1, 0, 1}
    local blendMode = originalTexture:GetBlendMode() or "BLEND"
    local r, g, b, a = originalTexture:GetVertexColor()

    -- Apply texture and properties
    portrait.bpTextureOverlayTexture:SetTexture(texPath)
    portrait.bpTextureOverlayTexture:SetVertexColor(r, g, b, a)
    portrait.bpTextureOverlayTexture:SetBlendMode(blendMode)
    portrait.bpTextureOverlayTexture:SetTexCoord(unpack(texCoordsToUse))

    -- Apply size
    local targetW = originalW or portrait.bpTextureOverlay:GetWidth()
    local targetH = originalH or portrait.bpTextureOverlay:GetHeight()
    portrait.bpTextureOverlayTexture:SetSize(targetW, targetH)
    portrait.bpTextureOverlayTexture:ClearAllPoints()
    portrait.bpTextureOverlayTexture:SetPoint("CENTER", portrait.bpTextureOverlay, "CENTER")

    -- Mirroring
    if unit == "target" or unit == "focus" then
        portrait.bpTextureOverlayTexture:SetTexCoord(texCoordsToUse[2], texCoordsToUse[1], texCoordsToUse[3], texCoordsToUse[4])
    end

    -- Show the overlay
    portrait.bpTextureOverlay:Show()
end

-- Function to force the BigDebuffs frame strata - Called only when applying overlays
local function ForceHigherStrata(frame, portrait)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(198)
    if frame.parent then
        frame.parent:SetFrameStrata("MEDIUM")
        frame.parent:SetFrameLevel(100)
    end
    if frame.anchor then
        frame.anchor:SetFrameStrata("MEDIUM")
        frame.anchor:SetFrameLevel(100)
    end
end

-- *** NEW *** Function to apply our modifications when BigDebuffs icon shows
local function ApplyMilaUIOverlays(frame, portrait, unit)
    if not frame or not portrait or not UnitExists(unit) then return end

    -- Hide originals
    if portrait.extra then portrait.extra:Hide() end
    local originalTexture = portrait.texture or (portrait.GetTexture and portrait)
    if originalTexture then originalTexture:Hide() end

    -- Update and show our overlays
    UpdateExtraOverlay(portrait, unit)
    UpdateBPTextureOverlay(portrait, unit)

    -- Set strata for BigDebuffs frame
    ForceHigherStrata(frame, portrait)

    -- Customize icon appearance
    CustomizeBigDebuffsIcon(frame)
end

-- *** NEW *** Function to revert our modifications when BigDebuffs icon hides
local function RevertMilaUIOverlays(frame, portrait, unit)
     if not frame or not portrait then return end -- Don't need UnitExists here

    -- Hide our overlays
    if portrait.extraOverlay then portrait.extraOverlay:Hide() end
    if portrait.bpTextureOverlay then portrait.bpTextureOverlay:Hide() end

    -- Show originals (if they exist)
    if portrait.extra then portrait.extra:Show() end
    local originalTexture = portrait.texture or (portrait.GetTexture and portrait)
    if originalTexture then originalTexture:Show() end

    -- Optional: Reset BigDebuffs frame strata if desired when hidden
    -- frame:SetFrameStrata("MEDIUM") -- Or whatever its default is
    -- frame:SetFrameLevel(1)
end

-- Initialize Slash Commands (Keep as is)
local function InitializeSlashCommands()
    SLASH_SABIGDEBUFFS1 = '/sabigdebuffs'
    SlashCmdList['SABIGDEBUFFS'] = function(msg)
        if msg == "toggle" then
            config.enabled = not config.enabled
            -- Update all frames
            if BigDebuffs then
                for unit in pairs(units) do
                    if BigDebuffs.UnitFrames and BigDebuffs.UnitFrames[unit] then
                        local frame = BigDebuffs.UnitFrames[unit]
                        if frame and frame.icon then
                            if config.enabled then
                                CustomizeBigDebuffsIcon(frame)
                            else
                                if frame.customMask then
                                    frame.icon:RemoveMaskTexture(frame.customMask)
                                    frame.customMask = nil
                                end
                                if frame.cooldown then
                                    frame.cooldown:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Register for target and focus change events to update the overlay
UpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
UpdateFrame:RegisterEvent("ADDON_LOADED")
UpdateFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
UpdateFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
UpdateFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
UpdateFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE") -- Important for texture changes

-- Event Handler
UpdateFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "MilaUI" then -- Changed from Strongauras
        InitializeSlashCommands()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Delay initialization slightly to ensure other addons are loaded
        C_Timer.After(0.5, function()
            if BigDebuffs then
                for unit in pairs(units) do
                    if BigDebuffs.UnitFrames and BigDebuffs.UnitFrames[unit] then
                        local frame = BigDebuffs.UnitFrames[unit]
                        local portrait = BLINKIISPORTRAITS and BLINKIISPORTRAITS.Portraits and BLINKIISPORTRAITS.Portraits[unit]
                        if portrait then
                            -- Center BigDebuffs frame over portrait
                            frame:ClearAllPoints()
                            frame:SetPoint("CENTER", portrait, "CENTER", 0, 0)
                            -- Force the frame to a higher strata
                            --ForceHigherStrata(frame, portrait) -- Set initial strata
                            --if portrait.extra then portrait.extra:Hide() end -- Hide original extra
                            --if portrait.texture then portrait.texture:Hide() end -- Hide original BP texture
                            --UpdateExtraOverlay(portrait, unit) -- Initial update
                            --UpdateBPTextureOverlay(portrait, unit) -- Initial update
                            --CustomizeBigDebuffsIcon(frame)
                            --modifiedFrames[frame] = true
                        end
                    end
                end
            end
        end)
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Update the extra overlay for target
        local portrait = BLINKIISPORTRAITS and BLINKIISPORTRAITS.Portraits and BLINKIISPORTRAITS.Portraits["target"]
        if portrait then
            -- *** ADDED CHECK: Explicitly hide if unit doesn't exist ***
            if not UnitExists("target") then
                if portrait.extraOverlay then portrait.extraOverlay:Hide() end
                if portrait.bpTextureOverlay then portrait.bpTextureOverlay:Hide() end
            else
                C_Timer.After(0.1, function() -- Short delay
                    if portrait.extra then portrait.extra:Hide() end
                    if portrait.texture and portrait.texture.IsVisible then portrait.texture:Hide() end -- Hide original BP texture
                    UpdateExtraOverlay(portrait, "target")
                    UpdateBPTextureOverlay(portrait, "target") -- Update BP overlay
                end)
            end
        end
    elseif event == "PLAYER_FOCUS_CHANGED" then
        -- Update the extra overlay for focus
        local portrait = BLINKIISPORTRAITS and BLINKIISPORTRAITS.Portraits and BLINKIISPORTRAITS.Portraits["focus"]
        if portrait then
            -- *** ADDED CHECK: Explicitly hide if unit doesn't exist ***
            if not UnitExists("focus") then
                if portrait.extraOverlay then portrait.extraOverlay:Hide() end
                if portrait.bpTextureOverlay then portrait.bpTextureOverlay:Hide() end
            else
                C_Timer.After(0.1, function() -- Short delay
                    if portrait.extra then portrait.extra:Hide() end
                    if portrait.texture and portrait.texture.IsVisible then portrait.texture:Hide() end -- Hide original BP texture
                    UpdateExtraOverlay(portrait, "focus")
                    UpdateBPTextureOverlay(portrait, "focus") -- Update BP overlay
                end)
            end
        end
    elseif event == "UNIT_CLASSIFICATION_CHANGED" then
        -- Update the extra overlay for the unit whose classification changed
        local unit = ...
        if units[unit] then
            local portrait = BLINKIISPORTRAITS and BLINKIISPORTRAITS.Portraits and BLINKIISPORTRAITS.Portraits[unit]
            if portrait then
                -- Add a short delay to allow Blinkiis to update first
                C_Timer.After(0.1, function()
                    -- Always hide the original extra texture
                    if portrait.extra then portrait.extra:Hide() end
                    if portrait.texture and portrait.texture.IsVisible then portrait.texture:Hide() end -- Hide original BP texture
                    UpdateExtraOverlay(portrait, unit)
                    UpdateBPTextureOverlay(portrait, unit) -- Update BP overlay
                end)
            end
        end
    end
end)

-- Hook BigDebuffs AttachUnitFrame
hooksecurefunc(BigDebuffs, "AttachUnitFrame", function(self, unit)
    --print("[MilaUI:Debug] AttachUnitFrame triggered for unit:", unit)

    if not units[unit] then
        return
    end

    local portrait = BLINKIISPORTRAITS and BLINKIISPORTRAITS.Portraits and BLINKIISPORTRAITS.Portraits[unit]
    if not portrait then
        return
    end

    local frame = BigDebuffs.UnitFrames and BigDebuffs.UnitFrames[unit]
    if not frame then
        return
    end

    -- Center BigDebuff frame over portrait
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", portrait, "CENTER", 0, 0)
    
    -- Force the frame to a higher strata
    --ForceHigherStrata(frame, portrait)
    
    -- Create a new frame for the extra texture that will be on top if it doesn't exist
    if not portrait.extraOverlay then
        -- Set an even higher strata for the extra overlay
        portrait.extraOverlay = CreateFrame("Frame", nil, UIParent)
        portrait.extraOverlay:SetAllPoints(portrait)
        portrait.extraOverlay:SetFrameStrata("FULLSCREEN")
        portrait.extraOverlay:SetFrameLevel(200)
        
        -- Create the texture inside this frame
        portrait.extraOverlayTexture = portrait.extraOverlay:CreateTexture(nil, "ARTWORK")
        portrait.extraOverlayTexture:SetAllPoints(portrait.extraOverlay)
        
        -- If there was a mask on the original, recreate it
        if portrait.extraMask then
            local extraOverlayMask = portrait.extraOverlay:CreateMaskTexture()
            extraOverlayMask:SetAllPoints(portrait.extraOverlay)
            extraOverlayMask:SetTexture(portrait.extraMask:GetTexture())
            portrait.extraOverlayTexture:AddMaskTexture(extraOverlayMask)
        end
    end
    
    -- *** NEW *** Create BP Texture overlay if it doesn't exist
    if not portrait.bpTextureOverlay then
        portrait.bpTextureOverlay = CreateFrame("Frame", nil, UIParent)
        portrait.bpTextureOverlay:SetAllPoints(portrait)
        portrait.bpTextureOverlay:SetFrameStrata("FULLSCREEN")
        portrait.bpTextureOverlay:SetFrameLevel(199) -- Middle level
        portrait.bpTextureOverlayTexture = portrait.bpTextureOverlay:CreateTexture(nil, "ARTWORK")
        portrait.bpTextureOverlayTexture:SetAllPoints(portrait.bpTextureOverlay)
         -- No mask needed usually for the base portrait texture
    end
    
    -- Hide originals immediately
    if portrait.extra then portrait.extra:Hide() end
    if portrait.texture and portrait.texture.IsVisible then -- Check visibility method
         portrait.texture:Hide()
    elseif portrait.IsVisible then -- Maybe portrait itself is the texture
         portrait:Hide()
    end

    -- Update overlays after a short delay
    C_Timer.After(0.1, function()
        UpdateExtraOverlay(portrait, unit)
        UpdateBPTextureOverlay(portrait, unit) -- Update BP overlay
    end)
    
    -- Customize BigDebuff icon
    CustomizeBigDebuffsIcon(frame)

    -- Mark frame as modified
    modifiedFrames[frame] = true
    
    -- Schedule another strata update after a short delay
    -- This helps in case something else is modifying the strata after our hook
    C_Timer.After(0.1, function()
        --ForceHigherStrata(frame, portrait)
    end)
end)

-- Add a repeating timer to ensure our frames stay at the right strata
-- and to update the extra overlay for units that need it
C_Timer.NewTicker(0.2, function()
    for unit in pairs(units) do
        if BigDebuffs and BigDebuffs.UnitFrames and BigDebuffs.UnitFrames[unit] then
            local frame = BigDebuffs.UnitFrames[unit]
            local portrait = BLINKIISPORTRAITS and BLINKIISPORTRAITS.Portraits and BLINKIISPORTRAITS.Portraits[unit]
            
            if frame and portrait then
                -- *** ADDED CHECK: Hide overlays if unit doesn't exist ***
                if not UnitExists(unit) then
                    if portrait.extraOverlay and portrait.extraOverlay:IsShown() then portrait.extraOverlay:Hide() end
                    if portrait.bpTextureOverlay and portrait.bpTextureOverlay:IsShown() then portrait.bpTextureOverlay:Hide() end
                else
                    -- Ensure BigDebuffs frame strata is correct
                    if frame:GetFrameStrata() ~= "FULLSCREEN" or frame:GetFrameLevel() ~= 198 then
                        --print("[MilaUI:Debug Ticker] Forcing strata for BD frame:", unit)
                        --ForceHigherStrata(frame, portrait)
                    end
                    
                    -- Ensure Extra Overlay is updated correctly
                    local needsExtraUpdate = false
                    if HasSpecialClassification(unit) and portrait.extraOverlay and not portrait.extraOverlay:IsVisible() then
                        needsExtraUpdate = true
                    elseif not HasSpecialClassification(unit) and portrait.extraOverlay and portrait.extraOverlay:IsVisible() then
                         needsExtraUpdate = true
                    end
                    if needsExtraUpdate then
                        --print("[MilaUI:Debug Ticker] Updating Extra Overlay for:", unit)
                        if portrait.extra then portrait.extra:Hide() end -- Ensure original hidden
                        UpdateExtraOverlay(portrait, unit)
                    elseif portrait.extra and portrait.extra:IsVisible() then -- Hide original if it reappears
                         portrait.extra:Hide()
                    end
    
                    -- Ensure BP Texture Overlay is updated correctly (check if original is visible or our overlay isn't)
                    local originalTexture = portrait.texture or (portrait.GetTexture and portrait)
                    if originalTexture and originalTexture:IsVisible() then
                        --print("[MilaUI:Debug Ticker] Updating BP Texture Overlay for:", unit)
                        UpdateBPTextureOverlay(portrait, unit) -- This will hide the original again
                    elseif originalTexture and (not portrait.bpTextureOverlay or not portrait.bpTextureOverlay:IsShown()) then
                        -- If our overlay isn't showing but should be (assuming original texture exists)
                        --print("[MilaUI:Debug Ticker] Forcing BP Texture Overlay update for:", unit)
                        UpdateBPTextureOverlay(portrait, unit)
                    elseif not originalTexture and portrait.bpTextureOverlay and portrait.bpTextureOverlay:IsShown() then
                        -- Hide our overlay if original texture doesn't exist anymore
                         portrait.bpTextureOverlay:Hide()
                    end
                end
            end
        end
    end
end)
