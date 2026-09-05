-- Sound Settings panel, opened via the main panel's button. Split out from
-- the main panel so the default /cl options view isn't 13 sound rows deep
-- before you even see whether crit tracking itself is configured how you
-- want.
--
-- Three groups of rows used to live here directly and grew this panel too
-- tall: the 13 individual aura/ritual sounds (now UI/AuraSoundPanel.lua),
-- the player/heal/DPS/tank/boss death-sound block (now
-- UI/DeathSoundPanel.lua), and the 6 roll-result sounds (now
-- UI/RollSoundPanel.lua) - see CHANGELOG.md. What's left here is just the
-- general toggles plus the buttons to reach those panels.
-- Split in two so the Roll Sounds button can sit directly under the
-- RollSoundFlag row instead of grouped with the Aura/Death Sounds buttons
-- at the very end - in-game requested. AuraSoundFlag stays in its own
-- list for the same reason: its button belongs right after it, then
-- Death Sounds' button alongside it as before.
local SOUND_CHECKBOXES_TOP = {
    -- MasterSoundFlag itself moved to the main panel (UI/MainPanel.lua) -
    -- in-game requested, muting everything shouldn't need a submenu.
    { field = "SoundFlag", label = "Highscore sound (BÄM)", sound = "crit",
      hint = "Plays on a new personal highscore." },
    { field = "AllCritFlag", label = "Sound for all crits",
      hint = "Plays on every crit, not just new highscores." },
    { field = "WhiteHitFlag", label = "Sound for white hit crits",
      hint = "White-hit highscores need this; ability crits don't." },
    { field = "XtremeSoundFlag", label = "Xtreme damage sound (over 9000)", sound = "xtremeDamage",
      hint = "Extra sound when a hit deals over 9000 damage." },
    { field = "ReadySoundFlag", label = "Ready check sound", sound = "readyCheck",
      hint = "Plays when a ready check starts." },
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lottery",
      hint = "A CrossGambling lottery announcement in raid chat." },
    -- No exact count in the hint (matches the AuraSoundFlag hint below -
    -- in-game requested the same treatment here), and "on the side" not
    -- "below" - the Roll Sounds button sits on this same row now (see
    -- buildSoundFrame), unlike the Aura/Death Sounds buttons.
    { field = "RollSoundFlag", label = "Roll Sounds",
      hint = "Master switch for the roll-result sounds - see the button on the side." },
}

local SOUND_CHECKBOXES_BOTTOM = {
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the spell sounds - see the button below." },
}

-- Raid-leader/raid-chat phrase sounds (ChatTriggers.lua's
-- CHAT_MSG_RAID_LEADER handler) had no preview anywhere - in-game
-- requested. Unlike every other sound group here, these have no
-- CritLogDB flag at all (they always fire, gated only by MasterSoundFlag
-- like every CritLog:PlaySound call), so previewOnly rows with no
-- checkbox, same mechanism as the roll/aura sub-panels' shared-master
-- rows. Raid end plays both clips back to back (bye, then end) - two
-- rows, matching the lottery second-clip fix above.
local CHAT_PHRASE_PREVIEWS = {
    { note = "Fires when the raid leader says \"raid end\"/\"raid ende\" or \"wipe\"/\"shit show\" in raid chat." },
    { label = "Raid end (part 1)", sound = "raidEndBye", previewOnly = true },
    { label = "Raid end (part 2)", sound = "raidEndFinal", previewOnly = true },
    { label = "Wipe", sound = "wipe", previewOnly = true },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 8 checkbox rows plus the
    -- lottery second-clip preview row (hints are now a hover tooltip, not
    -- a line underneath each row - see UI/Shared.lua; MasterSoundFlag
    -- moved to the main panel, one row fewer than before), the Roll
    -- Sounds button (its own row, right under the RollSoundFlag
    -- checkbox), the Aura Sounds/Death Sounds button row below that, and
    -- the new Raid Chat Phrases heading + its trigger-phrase note and 3
    -- preview-only rows at the
    -- bottom - not pixel-verified in-game yet, see docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 700)
    -- Offset from center so it doesn't perfectly overlap the main panel
    -- when both are open at once; a one-time anchor, not a continuous one,
    -- so dragging either panel doesn't drag the other.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    togglesHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    togglesHeading:SetText("Sound Toggles")

    local lastAnchor, lastOffset = CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES_TOP, togglesHeading)

    -- In-game screenshotted: a 140px button at the Preview column
    -- overflowed past the panel's right edge, and sitting on its own row
    -- below RollSoundFlag (rather than beside it) looked like it
    -- belonged to the wrong row. Sized and positioned like a Preview
    -- button instead - same row as the checkbox, same column, close to
    -- the same size (Preview buttons are 70x20) - "Roll Sounds..." needs
    -- a bit more width than "Preview" to stay readable, 110px comfortably
    -- fits within this panel's right margin at this column.
    local rollSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rollSoundsButton:SetSize(110, 20)
    rollSoundsButton:SetText("Roll Sounds...")
    rollSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    rollSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    rollSoundsButton:SetPoint("LEFT", lastAnchor, "LEFT", 340 + lastOffset, 0)
    rollSoundsButton:SetScript("OnClick", function()
        CritLog:ShowRollSounds()
    end)

    lastAnchor, lastOffset = CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES_BOTTOM, lastAnchor)

    local auraSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    auraSoundsButton:SetSize(140, 24)
    auraSoundsButton:SetText("Aura Sounds...")
    auraSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    auraSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    auraSoundsButton:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", lastOffset, -12)
    auraSoundsButton:SetScript("OnClick", function()
        CritLog:ShowAuraSounds()
    end)

    local deathSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    deathSoundsButton:SetSize(140, 24)
    deathSoundsButton:SetText("Death Sounds...")
    deathSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    deathSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    deathSoundsButton:SetPoint("LEFT", auraSoundsButton, "RIGHT", 8, 0)
    deathSoundsButton:SetScript("OnClick", function()
        CritLog:ShowDeathSounds()
    end)

    local chatPhraseHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- Two separate anchor points, not a single TOPLEFT relative to
    -- deathSoundsButton: that button sits well right of the panel's left
    -- margin (it's anchored off auraSoundsButton's RIGHT edge, not the
    -- panel itself), so chaining straight off it pushed this heading - and
    -- every previewOnly row's Preview button under it, 340px further right
    -- again - past the panel's right edge. TOP for vertical chaining, LEFT
    -- pinned to the panel's own standard column instead.
    chatPhraseHeading:SetPoint("TOP", deathSoundsButton, "BOTTOM", 0, -16)
    chatPhraseHeading:SetPoint("LEFT", f, "LEFT", 14, 0)
    chatPhraseHeading:SetText("Raid Chat Phrases")

    CritLog.UI.buildToggleRows(f, CHAT_PHRASE_PREVIEWS, chatPhraseHeading)

    CritLog.UI.createCloseButton(f)

    return f
end

function CritLog:ShowSoundOptions()
    if not soundFrame then
        soundFrame = buildSoundFrame()
    end

    if soundFrame:IsShown() then
        soundFrame:Hide()
    else
        soundFrame:Show()
    end
end
