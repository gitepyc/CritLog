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

-- Fixed display order for the three highscore categories -
-- CritLog.Constants.recordKinds/CritLogDB.records are both keyed by name,
-- not ordered, and both this panel and the highscore list popup need the
-- same consistent order.
local RECORD_ORDER = { "damage", "whiteHit", "heal" }

-- Created lazily, not at load time - nothing needs either frame to exist
-- before the player asks for it.
local frame
local highscoreListFrame

-- Deletes just entry `index` (1 = current best) from a category's list.
-- `index` is captured once at row-creation time in getOrCreateHighscoreRow
-- below, not recomputed per click - valid forever because a given pool
-- slot always displays that same position in the sorted list, whatever
-- entry currently happens to occupy it.
local function createDeleteEntryButton(parent, kind, index)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(50, 18)
    button:SetText("Delete")
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetScript("OnClick", function()
        CritLog:RemoveRecordEntry(kind, index)
        CritLog:RefreshOptionsPanel()
    end)
    return button
end

-- Row widgets are pooled and reused rather than created/destroyed on every
-- refresh (WoW frames aren't cheap to churn, and the visible row count
-- changes often as entries are added/deleted) - same pattern as the roster
-- panel's row pool. Pool slot i for a given category always displays that
-- category's list position i when shown - its Delete button's index was
-- fixed at creation time.
local function getOrCreateHighscoreRow(f, kind, index)
    f.rowPool[kind] = f.rowPool[kind] or {}
    local row = f.rowPool[kind][index]
    if not row then
        row = {
            text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
            deleteButton = createDeleteEntryButton(f, kind, index),
        }
        f.rowPool[kind][index] = row
    end
    return row
end

-- Lays out every row fresh on each call (cheap: at most 3 categories *
-- Constants.maxRecordEntries rows) rather than trying to incrementally
-- patch anchors when the row count changes between refreshes. An empty
-- category still shows one placeholder row (formatRecordText's "no record
-- yet" text) with no Delete button, so the popup never looks broken for a
-- fresh character.
local function layoutHighscoreList(f)
    local previous = f.heading

    for _, kind in ipairs(RECORD_ORDER) do
        local list = CritLogDB.records[kind]
        local visibleRows = math.max(#list, 1)

        for index = 1, CritLog.Constants.maxRecordEntries do
            local row = getOrCreateHighscoreRow(f, kind, index)

            if index > visibleRows then
                row.text:Hide()
                row.deleteButton:Hide()
            else
                row.text:SetText(CritLog.Records.formatRecordText(kind, index))
                row.text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
                row.text:Show()

                if list[index] then
                    row.deleteButton:SetPoint("TOP", row.text, "TOP", 0, 0)
                    row.deleteButton:SetPoint("RIGHT", f, "RIGHT", -14, 0)
                    row.deleteButton:Show()
                else
                    row.deleteButton:Hide()
                end

                previous = row.text
            end
        end
    end
end

-- Sized for the worst case (Constants.maxRecordEntries rows in every
-- category at once) so it never overflows; looks mostly empty until a
-- character has built up a real history, which is expected for a first
-- draft - see docs/ROADMAP.md.
local function buildHighscoreListFrame()
    local f = CritLog.UI.createPanelFrame("CritLogHighscoreListFrame", "CritLog Highscore List", 420, 460)
    -- Opens to the left of center, mirroring the sound panel opening to the
    -- right, so both can be open next to the main panel at once.
    f:SetPoint("CENTER", UIParent, "CENTER", -260, 0)

    f.heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    f.heading:SetText("Highscores")

    f.rowPool = {}
    layoutHighscoreList(f)

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
        frame.dacText:SetText(CritLog.Records.formatRecordText("damage", 1))
        frame.whcText:SetText(CritLog.Records.formatRecordText("whiteHit", 1))
        frame.hacText:SetText(CritLog.Records.formatRecordText("heal", 1))
    end

    if highscoreListFrame then
        layoutHighscoreList(highscoreListFrame)
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
