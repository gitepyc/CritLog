-- Help panel, opened via the main panel's button or `/cl options` ->
-- Help. Lists every slash command, generated from the same
-- CritLog.Constants.help*/helpAbout tables that Commands.lua's `/cl help`
-- prints to chat, so the two descriptions can't drift out of sync with
-- each other.
--
-- Two columns (General/Sounds) rather than one long list, same reasoning
-- and technique as UI/AuraSoundPanel.lua's two-column rework: a single
-- column of every command made this panel nearly as tall as the sound
-- panels used to be. Death Sounds and the About line stay single-column
-- below both, since there's not enough content there to justify a third
-- column.
local helpFrame

-- One command/description pair per row, stacked (command line, then an
-- indented description line below) rather than side by side, since
-- descriptions vary too much in length to share a line without
-- truncating or wrapping unpredictably.
--
-- Takes and returns an x-offset alongside the anchor, same pattern
-- UI/Shared.lua's buildToggleRows uses: descText sits +8 right of its own
-- cmdText, so the next row's cmdText needs a -8 offset to cancel that
-- back out instead of compounding it down the column.
local function buildSection(parent, title, entries, anchor, anchorXOffset)
    local heading = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchorXOffset or 0, -16)
    heading:SetText(title)

    local previous = heading
    local previousXOffset = 0
    for _, entry in ipairs(entries) do
        local cmdText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cmdText:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset, -8)
        cmdText:SetText(entry.cmd)

        local descText = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        descText:SetPoint("TOPLEFT", cmdText, "BOTTOMLEFT", 8, -1)
        descText:SetWidth(280)
        descText:SetJustifyH("LEFT")
        descText:SetText(entry.desc)

        previous = descText
        previousXOffset = -8
    end

    return previous, previousXOffset
end

local function buildHelpFrame()
    local f = CritLog.UI.createPanelFrame("CritLogHelpFrame", "CritLog Help", 640, 640)
    f:SetPoint("CENTER")

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Commands")

    -- Bottom-center via the shared helper, also used by the Highscore
    -- List and Roster Settings popups for consistency.
    CritLog.UI.createCloseButton(f)

    -- Built once at creation, not re-laid-out on refresh: the command
    -- list is static.
    --
    -- Two independent anchor points at the same Y, same technique as
    -- UI/AuraSoundPanel.lua's colLeftAnchor/colRightAnchor - each column
    -- lays out its own rows relative to its own start anchor.
    local colLeftAnchor = CreateFrame("Frame", nil, f)
    colLeftAnchor:SetSize(1, 1)
    colLeftAnchor:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, 0)

    local colRightAnchor = CreateFrame("Frame", nil, f)
    colRightAnchor:SetSize(1, 1)
    colRightAnchor:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 320, 0)

    local leftBottom, leftOffset = buildSection(f, "General", CritLog.Constants.helpGeneral, colLeftAnchor, 0)
    buildSection(f, "Sounds", CritLog.Constants.helpSounds, colRightAnchor, 0)

    -- Continues from the left column specifically (General and Sounds
    -- have the same number of rows, so they end at roughly the same
    -- height either way) - full width again below both columns.
    buildSection(f, "Death Sounds", CritLog.Constants.helpDeathSounds, leftBottom, leftOffset)

    -- Anchored to the panel's own bottom edge instead of chained below
    -- Death Sounds, so this always sits at the same fixed spot above the
    -- Close button regardless of how tall the sections above are.
    --
    -- Two FontStrings, not one, since the subtitle renders one size
    -- smaller than the title and a single FontString can't mix fonts.
    local aboutSubtitle = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aboutSubtitle:SetPoint("BOTTOM", f, "BOTTOM", 0, 44)
    aboutSubtitle:SetText(CritLog.Constants.helpAboutSubtitle)
    local subtitlePath, subtitleSize, subtitleFlags = aboutSubtitle:GetFont()
    aboutSubtitle:SetFont(subtitlePath, subtitleSize - 2, subtitleFlags)

    local aboutTitle = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aboutTitle:SetPoint("BOTTOM", aboutSubtitle, "TOP", 0, 2)
    aboutTitle:SetText(CritLog.Constants.helpAboutTitle)

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
