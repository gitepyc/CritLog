-- Main options panel (/cl options): crit-tracking behavior that isn't about
-- sound at all, plus buttons into the Sound Settings/Help panels and the
-- Highscore List popup. Label wording is lifted from Commands.lua's
-- printHelp()/printConfig() so the panel doesn't introduce new terminology
-- for the same settings.
-- LevelFilterFlag/LevelDiffThreshold replace the old single AllLevel
-- on/off flag (see Persistence/Database.lua's migrateAllLevelToThreshold
-- and Core/Filters.lua's passesLevelFilter): a checkbox for whether the
-- filter applies at all, plus a slider for how many levels below you a
-- target may be before its crit doesn't count once it does - instead of a
-- fixed hardcoded 9. Two separate controls, not one slider whose minimum
-- doubles as "off" (in-game reported as confusing) - matches AllLevel's
-- old on/off flag behavior more directly, and reads the same way as every
-- other checkbox-gates-a-detail-setting pair in this addon (e.g.
-- MasterSoundFlag above every other sound toggle). One-directional on
-- purpose, unlike TitanCritLine's similar level-adjustment slider (which
-- this is modeled on) - a crit against a tougher-than-you enemy is never
-- filtered out.
local CRIT_CHECKBOXES = {
    { field = "LevelFilterFlag", label = "Enable level filter",
      hint = "Off: counts highscores from enemies of any level." },
    { field = "LevelDiffThreshold", label = "Max levels below you", slider = { min = 1, max = 20, step = 1 },
      hint = "How far below your level a target may be and still count. Worldbosses always count regardless." },
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

-- A "reset everything at once" action (unlike a single category's Reset or
-- a single entry's Delete, both one click, no confirmation) needs a
-- confirmation dialog - it's the one highscore action that can't be
-- undone by re-adding a single entry. Registered once at file scope, the
-- standard StaticPopupDialogs convention.
StaticPopupDialogs["CRITLOG_RESET_ALL_HIGHSCORES"] = {
    text = "Delete ALL highscore entries in every category? This cannot be undone.",
    button1 = "Delete All",
    button2 = "Cancel",
    OnAccept = function()
        CritLog:ResetRecords()
        CritLog:RefreshOptionsPanel()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

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

-- Fixed x-offsets (from the panel's left edge) for the table columns,
-- shared by both the column header row and every data row so values line
-- up underneath their header regardless of text length.
local COLUMN_X = { rank = 14, amount = 50, ability = 110, target = 250 }

local function createColumnHeaderRow(f)
    local labels = {}
    for column, text in pairs({ rank = "#", amount = "Amount", ability = "Ability", target = "Target" }) do
        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetText(text)
        labels[column] = label
    end
    return labels
end

-- Row widgets are pooled and reused rather than created/destroyed on every
-- refresh (WoW frames aren't cheap to churn, and the visible row count
-- changes often as entries are added/deleted) - same pattern as the roster
-- panel's row pool. Pool slot i for a given category always displays that
-- category's list position i when shown - its Delete button's index was
-- fixed at creation time.
--
-- One FontString per column instead of a single pre-formatted line, so
-- values actually line up in a table under the header row created by
-- createColumnHeaderRow above.
local function getOrCreateHighscoreRow(f, kind, index)
    f.rowPool[kind] = f.rowPool[kind] or {}
    local row = f.rowPool[kind][index]
    if not row then
        row = {
            rankText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
            amountText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
            abilityText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
            targetText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
            deleteButton = createDeleteEntryButton(f, kind, index),
        }
        f.rowPool[kind][index] = row
    end
    return row
end

-- Lays out every row fresh on each call (cheap: at most 3 categories *
-- Constants.maxDisplayEntries rows) rather than trying to incrementally
-- patch anchors when the row count changes between refreshes.
--
-- Always lays out all Constants.maxDisplayEntries rows per category,
-- regardless of how many entries actually exist yet - missing ones get a
-- "No record yet" placeholder (see the `not entry` branch below) instead
-- of being skipped. Previously the row count tracked `#list` (floored at
-- 1), so a category with e.g. only 1 real entry reserved just 1 row's
-- worth of space and the next category's heading shifted up to fill the
-- rest - every category "growing into" its final position as entries
-- accumulated, in-game reported as looking wrong. Fixed height per
-- category (even at 0 entries) means the whole popup's layout is stable
-- from the very first time it's opened.
--
-- Only the top Constants.maxDisplayEntries are ever shown, even though up
-- to Constants.maxTrackedEntries can be stored (see Persistence/
-- Database.lua's AddRecord) - deleting one of the visible entries doesn't
-- need a brand new crit to refill it, the next-best already-tracked
-- entry just shifts into view on the next refresh.
local function layoutHighscoreList(f)
    local previous = f.heading

    for _, kind in ipairs(RECORD_ORDER) do
        f.categoryHeadings[kind]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -14)
        previous = f.categoryHeadings[kind]

        local headers = f.columnHeaders[kind]
        for column, x in pairs(COLUMN_X) do
            headers[column]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", x - 14, -6)
        end
        previous = headers.rank

        local list = CritLogDB.records[kind]

        for index = 1, CritLog.Constants.maxDisplayEntries do
            local row = getOrCreateHighscoreRow(f, kind, index)
            local entry = list[index]

            row.rankText:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
            row.rankText:Show()
            previous = row.rankText

            if not entry then
                row.rankText:SetText("No record yet")
                row.amountText:Hide()
                row.abilityText:Hide()
                row.targetText:Hide()
                row.deleteButton:Hide()
            else
                row.rankText:SetText(index..".")

                row.amountText:SetPoint("TOPLEFT", row.rankText, "TOPLEFT", COLUMN_X.amount - COLUMN_X.rank, 0)
                row.amountText:SetText(entry.amount)
                row.amountText:Show()

                row.abilityText:SetPoint("TOPLEFT", row.rankText, "TOPLEFT", COLUMN_X.ability - COLUMN_X.rank, 0)
                row.abilityText:SetText(entry.name or "-")
                row.abilityText:Show()

                row.targetText:SetPoint("TOPLEFT", row.rankText, "TOPLEFT", COLUMN_X.target - COLUMN_X.rank, 0)
                row.targetText:SetText(entry.target)
                row.targetText:Show()

                row.deleteButton:SetPoint("TOP", row.rankText, "TOP", 0, 0)
                row.deleteButton:SetPoint("RIGHT", f, "RIGHT", -14, 0)
                row.deleteButton:Show()
            end
        end
    end
end

-- Sized for the worst case (Constants.maxDisplayEntries rows in every
-- category at once) so it never overflows; looks mostly empty until a
-- character has built up a real history, which is expected for a first
-- draft - see docs/ROADMAP.md. Widened from 420 for the table columns
-- (Ability names in particular need more room than a single combined line
-- did).
local function buildHighscoreListFrame()
    local f = CritLog.UI.createPanelFrame("CritLogHighscoreListFrame", "CritLog Highscore List", 460, 520)
    -- Opens to the left of center, mirroring the sound panel opening to the
    -- right, so both can be open next to the main panel at once.
    f:SetPoint("CENTER", UIParent, "CENTER", -260, 0)

    f.heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    f.heading:SetText("Highscores")

    local resetAllButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetAllButton:SetSize(90, 20)
    resetAllButton:SetText("Reset All")
    resetAllButton:SetNormalFontObject("GameFontNormalSmall")
    resetAllButton:SetHighlightFontObject("GameFontHighlightSmall")
    resetAllButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, -28)
    resetAllButton:SetScript("OnClick", function()
        StaticPopup_Show("CRITLOG_RESET_ALL_HIGHSCORES")
    end)

    CritLog.UI.createCloseButton(f)

    f.categoryHeadings = {}
    f.columnHeaders = {}
    f.rowPool = {}
    for _, kind in ipairs(RECORD_ORDER) do
        local categoryHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        categoryHeading:SetText(CritLog.Constants.recordKinds[kind].label)
        f.categoryHeadings[kind] = categoryHeading

        f.columnHeaders[kind] = createColumnHeaderRow(f)
    end

    layoutHighscoreList(f)

    return f
end

local function buildFrame()
    -- Tall enough for the header block, the Highscore List button, the
    -- level-filter checkbox, the level-filter slider row (taller than a
    -- plain checkbox - Low/High/value labels) and the Debug checkbox row,
    -- and the Sound Settings/Help button row (Roster Settings moved to the
    -- Death Sounds panel, so this is back to a single row - see
    -- CHANGELOG.md). Widened from 420 so a long spell/target name in a
    -- highscore line has room before running into that row's Reset
    -- button. Not pixel-verified in-game yet for the slider specifically
    -- - see docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogOptionsFrame", "CritLog Options", 470, 520)
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
    local dacReset = CritLog.UI.createResetButton(f, "damage", "Reset all")
    dacReset:SetPoint("TOP", f.dacText, "TOP", 0, 0)
    dacReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    f.whcText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    CritLog.UI.anchorBelow(f.whcText, f.dacText)
    local whcReset = CritLog.UI.createResetButton(f, "whiteHit", "Reset all")
    whcReset:SetPoint("TOP", f.whcText, "TOP", 0, 0)
    whcReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    f.hacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    CritLog.UI.anchorBelow(f.hacText, f.whcText)
    local hacReset = CritLog.UI.createResetButton(f, "heal", "Reset all")
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

    -- Roster Settings moved to the Death Sounds panel (it's only relevant
    -- to the melee/tank/heal roster fallback used there, not to anything
    -- else on this main panel) - just Sound Settings and Help remain here,
    -- side by side on one row.
    local helpButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    helpButton:SetSize(140, 24)
    helpButton:SetText("Help...")
    helpButton:SetNormalFontObject("GameFontNormalSmall")
    helpButton:SetHighlightFontObject("GameFontHighlightSmall")
    helpButton:SetPoint("LEFT", soundButton, "RIGHT", 8, 0)
    helpButton:SetScript("OnClick", function()
        CritLog:ShowHelp()
    end)

    CritLog.UI.createCloseButton(f)

    return f
end

CritLog.UI.registerRefresh(function()
    -- Colored variant (Core/Records.lua's formatRecordTextColored) - in-game
    -- requested applying the same spell/target/amount styling used on the
    -- TitanPanel tooltip here too, not just there.
    if frame then
        frame.dacText:SetText(CritLog.Records.formatRecordTextColored("damage", 1))
        frame.whcText:SetText(CritLog.Records.formatRecordTextColored("whiteHit", 1))
        frame.hacText:SetText(CritLog.Records.formatRecordTextColored("heal", 1))
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
