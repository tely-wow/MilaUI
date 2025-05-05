local Name, Private = ...

-- Define textures
Private.AbsorbOverlay = "Interface\\RaidFrame\\Shield-Overlay"
Private.AbsorbGlow = "Interface\\RaidFrame\\Shield-Overshield"
Private.AbsorbTexture = "Interface\\RaidFrame\\Shield-Overshield"

-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)
local OS = E:NewModule('MilaUI_Overshield', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local UF = E:GetModule("UnitFrames")

local absorbOverlays = {}

if not E.Retail then return end

-- Update absorb visuals
local function updateAbsorbOverlayFrame(self, _, _, _, absorb, _, hasOverAbsorb, _, health, maxHealth)
    if not absorb or not health or not maxHealth then return end

    local frame = self.frame
    if not frame or not absorbOverlays[frame] then return end

    local absorbOverlay, overAbsorbGlow = unpack(absorbOverlays[frame])

    local cappedAbsorbSize = math.min(absorb, maxHealth)
    if cappedAbsorbSize > 0 and hasOverAbsorb then
        local totalWidth, totalHeight = frame:GetSize()
        local barSize = (cappedAbsorbSize - (maxHealth - health)) / maxHealth * totalWidth

        absorbOverlay:SetPoint("TOPRIGHT", frame.Health, "TOPRIGHT", 0, 0)
        absorbOverlay:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", 0, 0)
        absorbOverlay:SetWidth(barSize)
        absorbOverlay:SetVertexColor(0.80, 1.00, 0.95, 0.52)
        absorbOverlay:SetTexCoord(0, barSize / 32, 0, totalHeight / 32)
        absorbOverlay:Show()

        -- Dynamically position glow at end of absorb bar
        overAbsorbGlow:ClearAllPoints()
        overAbsorbGlow:SetPoint("TOPLEFT", frame.Health, "TOPRIGHT", -barSize, 0)
        overAbsorbGlow:SetPoint("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", -barSize, 0)
        overAbsorbGlow:SetWidth(8)
        overAbsorbGlow:SetTexCoord(0, 10 / 32, 0, 1)
        overAbsorbGlow:Show()
    else
        absorbOverlay:Hide()
        overAbsorbGlow:Hide()
    end
end

-- Create overlay and glow
local function createAbsorbOverlayFrame(self, frame)
    local parentFrame = frame.Health
    if not parentFrame then return end

    local unit = frame.unit or "unknown"
    local isPlayer = unit == "player" or (frame:GetName() and frame:GetName():find("Player"))
    local isTarget = unit == "target" or (frame:GetName() and frame:GetName():find("Target"))

    local maskTexture
    if isPlayer then
        maskTexture = "Interface\\AddOns\\MilaUI\\Media\\Statusbars\\Mila_health01.tga"
    elseif isTarget then
        maskTexture = "Interface\\AddOns\\MilaUI\\Media\\Statusbars\\Mila_health_target01.tga"
    else
        maskTexture = "Interface\\AddOns\\MilaUI\\Media\\Statusbars\\Mila_health01.tga"
    end

    -- Create absorb overlay
    local absorbOverlay = parentFrame:CreateTexture(nil, "OVERLAY")
    absorbOverlay:SetTexture(Private.AbsorbOverlay, true, true)
    absorbOverlay:SetVertexColor(0.80, 1.00, 0.95, 0.521)
    absorbOverlay:SetSize(180, 21)

    -- Create glow line
    local overAbsorbGlow = parentFrame:CreateTexture(nil, "OVERLAY")
    overAbsorbGlow:SetTexture(Private.AbsorbGlow)
    overAbsorbGlow:SetVertexColor(0.80, 1.00, 0.95, 0.392) -- ✅ cyan with 100 alpha

    overAbsorbGlow:SetBlendMode("ADD")
    overAbsorbGlow:SetDrawLayer("OVERLAY", 7)
    overAbsorbGlow:SetTexCoord(10 / 32, 0, 0, 1)
    overAbsorbGlow:SetSize(10, 21)

    -- Create mask and apply to both absorbOverlay and glow (safely)
    local mask = parentFrame:CreateMaskTexture()
    if mask then
        mask:SetTexture(maskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(parentFrame)
        absorbOverlay:AddMaskTexture(mask)
        overAbsorbGlow:AddMaskTexture(mask)
    end

    -- Optional: apply to HealCommBar
    if frame.HealCommBar then
        frame.HealCommBar:AddMaskTexture(mask)
        frame.HealCommBar:ClearAllPoints()
        frame.HealCommBar:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, 0)
        frame.HealCommBar:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", 0, 0)
        frame.HealCommBar:SetSize(180, 21)
    end

    absorbOverlays[frame] = {
        absorbOverlay,
        overAbsorbGlow,
        mask
    }
end

-- Replace HealComm texture
function OS:SetTexture_HealComm(module, obj, texture)
    texture = Private.AbsorbTexture
    return self.hooks[module].SetTexture_HealComm(module, obj, texture)
end

-- Test command for absorb + glow
local function testAbsorbs()
    local playerFrame = _G["ElvUF_Player"]
    if not playerFrame or not playerFrame.Health then return end

    local maxHealth = select(2, playerFrame.Health:GetMinMaxValues()) or 0
    local testAbsorb = maxHealth * 0.7

    local originalGetAbsorb = UnitGetTotalAbsorbs
    local originalHasOverAbsorb = UnitHasOverAbsorb

    UnitGetTotalAbsorbs = function(unit)
        if unit == "player" then return testAbsorb end
        return originalGetAbsorb(unit)
    end

    UnitHasOverAbsorb = function(unit)
        if unit == "player" then return true end
        return originalHasOverAbsorb and originalHasOverAbsorb(unit)
    end

    if playerFrame.Health.PostUpdate then
        playerFrame.Health:PostUpdate(playerFrame.unit)
    end

    C_Timer.After(5, function()
        UnitGetTotalAbsorbs = originalGetAbsorb
        UnitHasOverAbsorb = originalHasOverAbsorb
        if playerFrame.Health.PostUpdate then
            playerFrame.Health:PostUpdate(playerFrame.unit)
        end
    end)
end

-- Initialization
function OS:Initialize()
    UF:SecureHook(UF, "Construct_HealComm", createAbsorbOverlayFrame)
    UF:SecureHook(UF, "UpdateHealComm", updateAbsorbOverlayFrame)
    self:RawHook(UF, "SetTexture_HealComm")

    -- Slash command
    SLASH_SAABSORB1 = '/saabsorb'
    SlashCmdList['SAABSORB'] = function(msg)
        if msg == "test" then
            testAbsorbs()
        end
    end

    -- Pre-existing frames
    self:ScheduleTimer(function()
        local frames = {
            _G["ElvUF_Player"],
            _G["ElvUF_Target"],
            _G["ElvUF_Focus"]
        }
        for _, frame in ipairs(frames) do
            if frame and frame.Health then
                createAbsorbOverlayFrame(UF, frame)
            end
        end
    end, 1)

    self:RegisterEvent("PLAYER_LOGIN", function()
        self.hooks = self.hooks or {}
        self.hooks[UF] = self.hooks[UF] or {}
        self:SecureHook(UF, "SetTexture_HealComm", "SetTexture_HealComm")
    end)
end

E:RegisterModule(OS:GetName())
