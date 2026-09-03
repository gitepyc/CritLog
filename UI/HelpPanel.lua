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
-- indented description line below) rather than side by side on one line -
-- descriptions vary a lot in length (a few words to a full sentence), and
-- fitting both on one line within a column's width would mean either
-- truncating or wrapping unpredictably.
--
-- Takes and returns an x-offset alongside the anchor, same pattern
-- UI/Shared.lua's buildToggleRows uses. In-game reported: every row in
-- this panel drifted one level further right than the last (a growing
-- staircase). Root cause: descText sits +8 right of its own cmdText, and
-- the *next* cmdText anchored to that descText with a hardcoded 0 offset
-- - inheriting the +8 drift instead of cancelling it back out, so it
-- compounded every single row. Tracking the offset explicitly like
-- buildToggleRows already does fixes it, and lets a caller chain more
-- content after this section without inheriting a stray +8/-8 either.
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
        descText:SetWidth(390)
        descText:SetJustifyH("LEFT")
        descText:SetText(entry.desc)

        previous = descText
        previousXOffset = -8
    end

    return previous, previousXOffset
end

local function buildHelpFrame()
    -- Widened to 920 (matching UI/AuraSoundPanel.lua's two-column width)
    -- so each column has room for a full sentence without wrapping.
    -- Height is a first guess for General (the taller of the two columns)
    -- plus Death Sounds and About below it - not pixel-verified in-game
    -- yet, see docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogHelpFrame", "CritLog Help", 920, 660)
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
    --
    -- Two independent anchor points at the same Y, same technique as
    -- UI/AuraSoundPanel.lua's colLeftAnchor/colRightAnchor - each column
    -- lays out its own rows relative to its own start anchor, so the two
    -- chains never interact.
    local colLeftAnchor = CreateFrame("Frame", nil, f)
    colLeftAnchor:SetSize(1, 1)
    colLeftAnchor:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, 0)

    local colRightAnchor = CreateFrame("Frame", nil, f)
    colRightAnchor:SetSize(1, 1)
    colRightAnchor:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 446, 0)

    local leftBottom, leftOffset = buildSection(f, "General", CritLog.Constants.helpGeneral, colLeftAnchor, 0)
    buildSection(f, "Sounds", CritLog.Constants.helpSounds, colRightAnchor, 0)

    -- Continues from the left column specifically (General and Sounds
    -- have the same number of rows, so they end at roughly the same
    -- height either way) - full width again below both columns, same
    -- pattern UI/AuraSoundPanel.lua's note row uses ahead of its own two
    -- columns, just reversed (here it's after).
    buildSection(f, "Death Sounds", CritLog.Constants.helpDeathSounds, leftBottom, leftOffset)

    -- Anchored to the panel's own bottom edge instead of chained below
    -- Death Sounds - in-game requested "all the way down, but still above
    -- the Close button" (which sits at y=14 from the bottom, 22 tall, so
    -- its top edge is at y=36 - 44 leaves it a small gap above that).
    -- Centered rather than left-aligned like the rest of the panel, which
    -- also reads as a distinct footer rather than another content row.
    -- Anchoring to the panel directly (not the content above) means this
    -- always sits at the same fixed spot regardless of how tall the
    -- sections above happen to be.
    local aboutText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    aboutText:SetPoint("BOTTOM", f, "BOTTOM", 0, 44)
    aboutText:SetText(CritLog.Constants.helpAbout)

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
