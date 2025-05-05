local frame = CreateFrame("Frame")

frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function()
    -- Hide Micro Menu if it exists
    --if MicroMenu then
        --MicroMenu:Hide()
    --end
    -- Hide Status Tracking Bar if it exists
    if StatusTrackingBarManager then
        StatusTrackingBarManager:Hide()
    end
end)

-- Chat command to toggle visibility
SLASH_HIDEMENU1 = "/hidemenu"
SlashCmdList["HIDEMENU"] = function()
    if MicroMenu and StatusTrackingBarManager then
        if MicroMenu:IsShown() or StatusTrackingBarManager:IsShown() then
            StatusTrackingBarManager:Hide()
            print("Micro Menu and Status Bar Hidden")
        else
            MicroMenu:Show()
            StatusTrackingBarManager:Show()
            print("Micro Menu and Status Bar Shown")
        end
    end
end
