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
    { field = "MasterSoundFlag", label = "Sound enabled (overrides everything below)",
      hint = "Mutes everything below without changing individual settings." },
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
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lotteryFirst",
      hint = "A CrossGambling lottery announcement in raid chat." },
    { field = "RollSoundFlag", label = "Roll Sounds",
      hint = "Master switch for the 6 roll-result sounds - see the button below." },
}

local SOUND_CHECKBOXES_BOTTOM = {
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the spell sounds - see the button below." },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 9 checkbox rows (hints are
    -- now a hover tooltip, not a line underneath each row - see
    -- UI/Shared.lua), the Roll Sounds button (its own row, right under the
    -- RollSoundFlag checkbox), and the Aura Sounds/Death Sounds button row
    -- below that - not pixel-verified in-game yet, see docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 520)
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
