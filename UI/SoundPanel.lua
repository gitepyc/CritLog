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
-- CHAT_MSG_RAID_LEADER handler) - deliberately an Easter egg, in-game
-- requested: no CritLogDB flag at all (they always fire, gated only by
-- MasterSoundFlag like every CritLog:PlaySound call) and no toggle, so
-- previewOnly rows with no checkbox. The whole section is hidden unless
-- `/cl debug` is on - see buildSoundFrame's chatPhraseFrame below - so
-- it's not discoverable through the normal options UI either.
local CHAT_PHRASE_PREVIEWS = {
    { note = "Fires when the raid leader says \"raid end\"/\"raid ende\" or \"wipe\"/\"shit show\" in raid chat." },
    { label = "Raid end", sound = "raidEnd", previewOnly = true },
    { label = "Wipe", sound = "wipe", previewOnly = true },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 8 checkbox rows (hints are
    -- now a hover tooltip, not a line underneath each row - see
    -- UI/Shared.lua; MasterSoundFlag moved to the main panel, one row
    -- fewer than before), the Roll Sounds button (its own row, right
    -- under the RollSoundFlag checkbox), the Aura Sounds/Death Sounds
    -- button row below that, and (debug mode only - see chatPhraseFrame
    -- below) the Raid Chat Phrases heading + its trigger-phrase note and
    -- 2 preview-only rows at the bottom - not pixel-verified in-game yet,
    -- see docs/ROADMAP.md.
    -- Kept wider than the other single-column panels (420) after the
    -- general size-reduction pass: the Roll Sounds button above needs
    -- PREVIEW_COLUMN_X(300) + its own 110px width + margin, more room than
    -- the standard 70px Preview button the other panels only ever use.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 460, 620)
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
    -- fits within this panel's right margin at this column. This button's
    -- extra width (110 vs. the standard 70) is the reason this panel keeps
    -- a bit more width than the other single-column panels after the
    -- general size-reduction pass - see buildSoundFrame's width comment.
    local rollSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rollSoundsButton:SetSize(110, 20)
    rollSoundsButton:SetText("Roll Sounds...")
    rollSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    rollSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    rollSoundsButton:SetPoint("LEFT", lastAnchor, "LEFT", CritLog.UI.PREVIEW_COLUMN_X + lastOffset, 0)
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

    -- Easter egg: these sounds always fire (no CritLogDB flag, no toggle -
    -- see CHAT_PHRASE_PREVIEWS' own comment above), and the whole point is
    -- that they're not meant to be discoverable through the normal options
    -- UI. The section lives in its own child frame (not directly on `f`
    -- like every other row) purely so it can be shown/hidden as one unit -
    -- CritLog.UI.registerRefresh below toggles it based on DebugFlag every
    -- time any options panel opens.
    local chatPhraseFrame = CreateFrame("Frame", nil, f)
    chatPhraseFrame:SetSize(1, 1)
    chatPhraseFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    local chatPhraseHeading = chatPhraseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
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

    CritLog.UI.buildToggleRows(chatPhraseFrame, CHAT_PHRASE_PREVIEWS, chatPhraseHeading)

    CritLog.UI.registerRefresh(function()
        chatPhraseFrame:SetShown(CritLogDB.DebugFlag)
    end)

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
