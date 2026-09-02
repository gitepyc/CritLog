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
    { field = "AuraSoundFlag", label = "Aura/spell sound",
      hint = "Master switch for the 7 spell sounds below." },
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
    -- The None/Experimental/Roster/Both explanation applies to all four
    -- dropdowns below, so it's its own note row above them instead of
    -- being tied to (and only shown on) one specific row's hint.
    { note = "None = nothing\nExperimental = live check only\nRoster = name list only\nBoth = Experimental + Roster" },
    { field = "PriestDetectionMode", label = "Priest death sound", sound = "priestDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: class = PRIEST." },
    { field = "MeleeDetectionMode", label = "Damage Dealer death sound", sound = "meleeDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: melee-capable class. Roster: ranged OK too." },
    { field = "TankDetectionMode", label = "Tank death sound", sound = "tankDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: assigned raid Tank role." },
    { field = "BossDetectionMode", label = "Boss death sound", sound = "bossDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: live classification (worldboss)." },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading and all 20 sound toggle rows
    -- (each with its own hint line underneath) - the 7 individual aura
    -- sounds used to be a compact preview-only button grid under a single
    -- master toggle; now each is a real checkbox row like everything else,
    -- so it needs noticeably more height than before. The 4 detection-mode
    -- dropdown rows are taller than a checkbox row too. Not pixel-verified
    -- in-game yet - see docs/ROADMAP.md, visual polish is a follow-up.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 1010)
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
