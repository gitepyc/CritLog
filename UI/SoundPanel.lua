-- Sound Settings panel, opened via the main panel's button. Split out from
-- the main panel so the default /cl options view isn't 13 sound rows deep
-- before you even see whether crit tracking itself is configured how you
-- want.
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
    { field = "LoginSoundFlag", label = "Login sound", sound = "login",
      hint = "Plays once on login/reload. Off by default." },
    { field = "RollSoundFlag", label = "Roll sound", sound = "roll100",
      hint = "Specific /roll results on a 1-100 roll (1, 69, 95+, 100, lowest range)." },
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lotteryFirst",
      hint = "A CrossGambling lottery announcement in raid chat." },
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the 13 spell sounds below." },
    -- indent = true: these 7 are a sub-category under AuraSoundFlag above,
    -- not 7 more peers of it - smaller and indented so that reads clearly.
    { field = "BloodlustSoundFlag", label = "Bloodlust/Heroism", sound = "bloodlust", indent = true,
      hint = "Received Bloodlust or Heroism." },
    { field = "InnervateSoundFlag", label = "Innervate", sound = "innervate", indent = true,
      hint = "Received Innervate." },
    { field = "PowerInfusionSoundFlag", label = "Power Infusion", sound = "powerInfusion", indent = true,
      hint = "Received Power Infusion." },
    { field = "BlessingOfProtectionSoundFlag", label = "Blessing of Protection", sound = "blessingOfProtection",
      indent = true, hint = "Received Blessing of Protection." },
    { field = "DivineInterventionSoundFlag", label = "Divine Intervention", sound = "divineIntervention",
      indent = true, hint = "Received Divine Intervention." },
    { field = "ManaTideSoundFlag", label = "Mana Tide Totem", sound = "manaTide", indent = true,
      hint = "A party/raid member summons Mana Tide Totem." },
    -- Labeled "Applied", not "Resurrection": this fires when the Soulstone
    -- buff itself lands on you (SPELL_AURA_APPLIED), well before it's
    -- actually used to self-resurrect - the buff is literally named
    -- "Soulstone Resurrection" in-game (see Core/Constants.lua's spell
    -- name fallback), which was misleading here as a trigger description.
    { field = "SoulstoneSoundFlag", label = "Soulstone Applied", sound = "soulstone", indent = true,
      hint = "Received the Soulstone buff (not the resurrection itself)." },
    { field = "DrumsSoundFlag", label = "Drums of Battle", sound = "drums", indent = true,
      hint = "Received Drums of Battle." },
    { field = "PainSuppressionSoundFlag", label = "Pain Suppression", sound = "painSuppression", indent = true,
      hint = "Received Pain Suppression." },
    { field = "HymnOfHopeSoundFlag", label = "Hymn of Hope", sound = "hymnOfHope", indent = true,
      hint = "Received Hymn of Hope." },
    { field = "EvocationSoundFlag", label = "Evocation", sound = "evocation", indent = true,
      hint = "Received Evocation." },
    { field = "MageTableSoundFlag", label = "Mage Table", sound = "mageTable", indent = true,
      hint = "A party/raid member casts Ritual of Refreshment (max once per 100s)." },
    { field = "HealthstoneSoundFlag", label = "Warlock Healthstone Ritual", sound = "healthstoneRitual", indent = true,
      hint = "A party/raid member casts Ritual of Souls (max once per 60s)." },
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
    -- Tall enough for the toggles heading and all 29 sound toggle rows
    -- (each with its own hint line underneath) - the 13 individual aura/
    -- ritual sounds used to be a compact preview-only button grid under a
    -- single master toggle; now each is a real checkbox row like everything
    -- else, so it needs noticeably more height than before. The 4
    -- detection-mode dropdown rows are taller than a checkbox row too. Not
    -- pixel-verified in-game yet - see docs/ROADMAP.md, visual polish is a
    -- follow-up.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 1400)
    -- Offset from center so it doesn't perfectly overlap the main panel
    -- when both are open at once; a one-time anchor, not a continuous one,
    -- so dragging either panel doesn't drag the other.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    togglesHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    togglesHeading:SetText("Sound Toggles")

    CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES, togglesHeading)

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
