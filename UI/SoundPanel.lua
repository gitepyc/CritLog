-- Sound Settings panel, opened via the main panel's button. Split out from
-- the main panel so the default /cl options view isn't 13 sound rows deep
-- before you even see whether crit tracking itself is configured how you
-- want.
--
-- Split into two row lists (TOP/BOTTOM) rather than one, with the "Aura
-- Sounds..." button manually placed between them in buildSoundFrame below -
-- the 13 individual aura/ritual sounds used to live here as indented rows
-- under AuraSoundFlag, but got their own panel (UI/AuraSoundPanel.lua) once
-- this one grew too tall (see CHANGELOG.md). AuraSoundFlag (the master
-- switch) stays here, at the end of TOP.
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
    { field = "RollSoundFlag", label = "Roll sound", sound = "roll100",
      hint = "Specific /roll results on a 1-100 roll (1, 69, 95+, 100, lowest range)." },
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lotteryFirst",
      hint = "A CrossGambling lottery announcement in raid chat." },
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the 13 spell sounds - see the button below." },
}

local SOUND_CHECKBOXES_BOTTOM = {
    { field = "PlayerSoundFlag", label = "Player death sound", sound = "playerDeath",
      hint = "Plays when you yourself die." },
    -- These four (unlike PlayerSoundFlag above) can be driven by the live
    -- class/role/classification detection in Core/CombatLog.lua
    -- (isMeleeClass, isAssignedTank, isPriestClass, isClassifiedBoss), the
    -- hardcoded name roster, both, or neither - a dropdown instead of a
    -- checkbox. No shared master switch anymore (there used to be one,
    -- DeadSoundFlag) - setting all four to "None" is equivalent, and the
    -- dropdown is already the one place that controls all of this.
    -- "Experimental" isn't yet in-game verified for tank/boss/priest
    -- specifically (melee's false-positive bug is fixed and confirmed);
    -- "Roster" and "Both" (the original default) aren't affected by that.
    -- Labeled "DPS", not "Damage Dealer", specifically here (unlike the
    -- roster category label, which stays "Damage Dealer") - kept short so
    -- it's close to the same length as Priest/Tank/Boss below, which
    -- keeps all four rows' Preview buttons in one aligned column instead
    -- of each sitting wherever its own label happens to end.
    { field = "PriestDetectionMode", label = "Priest death sound", sound = "priestDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: class = PRIEST." },
    { field = "MeleeDetectionMode", label = "DPS death sound", sound = "meleeDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: melee-capable class. Roster: ranged OK too." },
    { field = "TankDetectionMode", label = "Tank death sound", sound = "tankDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: assigned raid Tank role." },
    { field = "BossDetectionMode", label = "Boss death sound", sound = "bossDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: live classification (worldboss)." },
    -- The None/Experimental/Roster/Both explanation applies to all four
    -- dropdowns above - a note row below them, rather than above (tried
    -- first, but a note explaining rows already past it read backwards).
    { note = "None = nothing\nExperimental = live check only\nRoster = name list only\nBoth = Experimental + Roster" },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 16 checkbox/dropdown/note
    -- rows (each with its own hint line underneath), and the "Aura
    -- Sounds..." button between the two row groups - the 13 individual
    -- aura/ritual sounds that used to live here directly now have their
    -- own panel (UI/AuraSoundPanel.lua). The 4 detection-mode dropdown rows
    -- are taller than a checkbox row too. Not pixel-verified in-game yet -
    -- see docs/ROADMAP.md, visual polish is a follow-up.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 950)
    -- Offset from center so it doesn't perfectly overlap the main panel
    -- when both are open at once; a one-time anchor, not a continuous one,
    -- so dragging either panel doesn't drag the other.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    togglesHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    togglesHeading:SetText("Sound Toggles")

    local lastAnchor, lastOffset = CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES_TOP, togglesHeading)

    local auraSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    auraSoundsButton:SetSize(140, 24)
    auraSoundsButton:SetText("Aura Sounds...")
    auraSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    auraSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    auraSoundsButton:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", lastOffset, -12)
    auraSoundsButton:SetScript("OnClick", function()
        CritLog:ShowAuraSounds()
    end)

    CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES_BOTTOM, auraSoundsButton)

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
