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
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lotteryFirst",
      hint = "A CrossGambling lottery announcement in raid chat." },
    { field = "RollSoundFlag", label = "Roll Sounds",
      hint = "Master switch for the 6 roll-result sounds - see the button below." },
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the 13 spell sounds - see the button below." },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 9 checkbox rows (hints are
    -- now a hover tooltip, not a line underneath each row - see
    -- UI/Shared.lua), and the two button rows (Aura Sounds/Death Sounds,
    -- then Roll Sounds below) - not pixel-verified in-game yet, see
    -- docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 520)
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

    -- On its own row below the other two rather than squeezed into the
    -- same row - three 140px buttons plus gaps would leave very little
    -- margin either side within this panel's width.
    local rollSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rollSoundsButton:SetSize(140, 24)
    rollSoundsButton:SetText("Roll Sounds...")
    rollSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    rollSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    rollSoundsButton:SetPoint("TOPLEFT", auraSoundsButton, "BOTTOMLEFT", 0, -8)
    rollSoundsButton:SetScript("OnClick", function()
        CritLog:ShowRollSounds()
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
