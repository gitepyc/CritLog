-- Help panel, opened via the main panel's button or `/cl options` ->
-- Help. Lists every slash command, generated from the same
-- CritLog.Constants.helpLines that Commands.lua's `/cl help` prints to
-- chat, so the two descriptions can't drift out of sync with each other.
local helpFrame

local function buildHelpFrame()
    local f = CritLog.UI.createPanelFrame("CritLogHelpFrame", "CritLog Help", 480, 560)
    f:SetPoint("CENTER")

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Commands")

    -- In-game reported: no way to close this panel; the button was also
    -- reported as being in the wrong spot (top-right) - moved to
    -- bottom-center via the shared helper (also used by the Highscore
    -- List and Roster Settings popups now, for consistency).
    CritLog.UI.createCloseButton(f)

    -- Built once at creation, not re-laid-out on refresh: the command
    -- list is static, unlike the highscore/roster panels' data.
    local previous = heading
    for _, line in ipairs(CritLog.Constants.helpLines) do
        local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -6)
        text:SetWidth(450)
        text:SetJustifyH("LEFT")
        text:SetText(line)
        previous = text
    end

    return f
end

function CritLog:ShowHelp()
    if not helpFrame then
        helpFrame = buildHelpFrame()
    end

    if helpFrame:IsShown() then
        helpFrame:Hide()
    else
        helpFrame:Show()
    end
end
