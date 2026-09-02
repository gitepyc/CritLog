-- Main options panel (/cl options): crit-tracking behavior that isn't about
-- sound at all, plus buttons into the Sound/Roster Settings panels and the
-- Highscore List popup. Label wording is lifted from Commands.lua's
-- printHelp()/printConfig() so the panel doesn't introduce new terminology
-- for the same settings.
local CRIT_CHECKBOXES = {
    { field = "AllLevel", label = "Ignore enemy level requirement",
      hint = "Counts highscores from enemies of any level." },
    { field = "DebugFlag", label = "Debug mode (diagnostic chat output)",
      hint = "Prints diagnostic chat messages for troubleshooting." },
}

-- Fixed display order for the three highscore records - CritLog.Constants.records
-- is keyed by name, not ordered, and both this panel and the highscore list
-- popup need the same consistent order.
local RECORD_ORDER = { "damage", "whiteHit", "heal" }

-- Created lazily, not at load time - nothing needs either frame to exist
-- before the player asks for it.
local frame
local highscoreListFrame

-- Deliberately minimal for now: shows the same 3 current records the main
-- panel already displays inline, just bigger and in their own window. This
-- is the seed for a real multi-entry list (top 5-10 crits per category)
-- once CritLog actually stores more than one value per category - see
-- docs/ROADMAP.md. Not worth building that infrastructure before there's
-- data to put in it.
local function buildHighscoreListFrame()
    local f = CritLog.UI.createPanelFrame("CritLogHighscoreListFrame", "CritLog Highscore List", 420, 190)
    -- Opens to the left of center, mirroring the sound panel opening to the
    -- right, so both can be open next to the main panel at once.
    f:SetPoint("CENTER", UIParent, "CENTER", -260, 0)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Highscores")

    f.recordTexts = {}
    local previous = heading
    for _, kind in ipairs(RECORD_ORDER) do
        local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        CritLog.UI.anchorBelow(text, previous, 12)
        f.recordTexts[kind] = text

        local resetButton = CritLog.UI.createResetButton(f, kind)
        resetButton:SetPoint("TOP", text, "TOP", 0, 0)
        resetButton:SetPoint("RIGHT", f, "RIGHT", -14, 0)

        previous = text
    end

    return f
end

local function buildFrame()
    -- Tall enough for the header block, the Highscore List button, the 2
    -- crit-tracking toggle rows (each with its own hint line underneath),
    -- and the Sound Settings button. Widened from 420 so a long
    -- spell/target name in a highscore line has room before running into
    -- that row's Reset button.
    local f = CritLog.UI.createPanelFrame("CritLogOptionsFrame", "CritLog Options", 470, 470)
    f:SetPoint("CENTER")

    local highscoresHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- Anchored directly to the frame rather than f.Inset: that child region
    -- isn't guaranteed to exist on every BasicFrameTemplateWithInset variant
    -- (SoD's client doesn't expose it), and a nil relativeTo here silently
    -- anchors everything downstream to the screen instead of the panel.
    -- -30 clears the title bar.
    highscoresHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    highscoresHeading:SetText("Highscores")

    f.dacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    CritLog.UI.anchorBelow(f.dacText, highscoresHeading, 8)
    local dacReset = CritLog.UI.createResetButton(f, "damage")
    dacReset:SetPoint("TOP", f.dacText, "TOP", 0, 0)
    dacReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    f.whcText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    CritLog.UI.anchorBelow(f.whcText, f.dacText)
    local whcReset = CritLog.UI.createResetButton(f, "whiteHit")
    whcReset:SetPoint("TOP", f.whcText, "TOP", 0, 0)
    whcReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    f.hacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    CritLog.UI.anchorBelow(f.hacText, f.whcText)
    local hacReset = CritLog.UI.createResetButton(f, "heal")
    hacReset:SetPoint("TOP", f.hacText, "TOP", 0, 0)
    hacReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    local listButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    listButton:SetSize(140, 24)
    listButton:SetText("Highscore List...")
    listButton:SetNormalFontObject("GameFontNormalSmall")
    listButton:SetHighlightFontObject("GameFontHighlightSmall")
    listButton:SetPoint("TOPLEFT", f.hacText, "BOTTOMLEFT", 0, -12)
    listButton:SetScript("OnClick", function()
        CritLog:ShowHighscoreList()
    end)

    local infoHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    CritLog.UI.anchorBelow(infoHeading, listButton, 16)
    infoHeading:SetText("Info")

    f.versionText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    CritLog.UI.anchorBelow(f.versionText, infoHeading, 8)
    f.versionText:SetText("CritLog version: "..CritLog.version)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    CritLog.UI.anchorBelow(togglesHeading, f.versionText, 16)
    togglesHeading:SetText("Options")

    local lastAnchor = CritLog.UI.buildToggleRows(f, CRIT_CHECKBOXES, togglesHeading)

    local soundButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    soundButton:SetSize(140, 24)
    soundButton:SetText("Sound Settings...")
    soundButton:SetNormalFontObject("GameFontNormalSmall")
    soundButton:SetHighlightFontObject("GameFontHighlightSmall")
    soundButton:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -16)
    soundButton:SetScript("OnClick", function()
        CritLog:ShowSoundOptions()
    end)

    local rosterButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rosterButton:SetSize(140, 24)
    rosterButton:SetText("Roster Settings...")
    rosterButton:SetNormalFontObject("GameFontNormalSmall")
    rosterButton:SetHighlightFontObject("GameFontHighlightSmall")
    rosterButton:SetPoint("LEFT", soundButton, "RIGHT", 8, 0)
    rosterButton:SetScript("OnClick", function()
        CritLog:ShowRoster()
    end)

    return f
end

CritLog.UI.registerRefresh(function()
    if frame then
        frame.dacText:SetText(CritLog.Records.formatRecordText("damage"))
        frame.whcText:SetText(CritLog.Records.formatRecordText("whiteHit"))
        frame.hacText:SetText(CritLog.Records.formatRecordText("heal"))
    end

    if highscoreListFrame then
        for _, kind in ipairs(RECORD_ORDER) do
            highscoreListFrame.recordTexts[kind]:SetText(CritLog.Records.formatRecordText(kind))
        end
    end
end)

function CritLog:ShowOptions()
    if not frame then
        frame = buildFrame()
    end

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

function CritLog:ShowHighscoreList()
    if not highscoreListFrame then
        highscoreListFrame = buildHighscoreListFrame()
    end

    if highscoreListFrame:IsShown() then
        highscoreListFrame:Hide()
    else
        highscoreListFrame:Show()
    end
end
