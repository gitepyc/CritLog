-- Sound Settings panel, opened via the main panel's button. Split out from
-- the main panel so the default /cl options view isn't 13 sound rows deep
-- before you even see whether crit tracking itself is configured how you
-- want.
--
-- Two groups of rows used to live here directly and grew this panel too
-- tall: the 13 individual aura/ritual sounds (now UI/AuraSoundPanel.lua)
-- and the player/priest/DPS/tank/boss death-sound block (now
-- UI/DeathSoundPanel.lua) - see CHANGELOG.md. What's left here is just the
-- general toggles plus the two buttons to reach those panels.
local SOUND_CHECKBOXES = {
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
    { field = "RollSoundFlag", label = "Roll sound", sound = "roll100",
      hint = "Specific /roll results on a 1-100 roll (1, 69, 95+, 100, lowest range)." },
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lotteryFirst",
      hint = "A CrossGambling lottery announcement in raid chat." },
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the 13 spell sounds - see the button below." },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 9 checkbox rows (each with
    -- its own hint line underneath), and the two buttons to the Aura
    -- Sounds/Death Sounds panels - not pixel-verified in-game yet, see
    -- docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 560)
    -- Offset from center so it doesn't perfectly overlap the main panel
    -- when both are open at once; a one-time anchor, not a continuous one,
    -- so dragging either panel doesn't drag the other.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    togglesHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    togglesHeading:SetText("Sound Toggles")

    local lastAnchor, lastOffset = CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES, togglesHeading)

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
