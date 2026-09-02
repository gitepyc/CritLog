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
    { field = "BloodlustSoundFlag", label = "Bloodlust/Heroism", sound = "bloodlust",
      hint = "Received Bloodlust or Heroism." },
    { field = "InnervateSoundFlag", label = "Innervate", sound = "innervate",
      hint = "Received Innervate." },
    { field = "PowerInfusionSoundFlag", label = "Power Infusion", sound = "powerInfusion",
      hint = "Received Power Infusion." },
    { field = "BlessingOfProtectionSoundFlag", label = "Blessing of Protection", sound = "blessingOfProtection",
      hint = "Received Blessing of Protection." },
    { field = "DivineInterventionSoundFlag", label = "Divine Intervention", sound = "divineIntervention",
      hint = "Received Divine Intervention." },
    { field = "ManaTideSoundFlag", label = "Mana Tide Totem", sound = "manaTide",
      hint = "A party/raid member summons Mana Tide Totem." },
    { field = "SoulstoneSoundFlag", label = "Soulstone Resurrection", sound = "soulstone",
      hint = "Received Soulstone Resurrection." },
    { field = "PlayerSoundFlag", label = "Player death sound", sound = "playerDeath",
      hint = "Plays when you yourself die." },
    -- These four (unlike PlayerSoundFlag above) can be driven by the live
    -- class/role/classification detection in Core/CombatLog.lua
    -- (isMeleeClass, isAssignedTank, isPriestClass, isClassifiedBoss), the
    -- hardcoded name roster, both, or neither - a dropdown instead of a
    -- checkbox. "Experimental" isn't yet in-game verified for tank/boss/
    -- priest specifically (melee's false-positive bug is fixed and
    -- confirmed); "Roster" and "Both" (the original default) aren't
    -- affected by that.
    { field = "PriestDetectionMode", label = "Priest death sound", sound = "priestDeath",
      options = CritLog.Constants.detectionModes,
      hint = "None / Experimental (live class check) / Roster (name list) / Both." },
    { field = "MeleeDetectionMode", label = "Melee death sound", sound = "meleeDeath",
      options = CritLog.Constants.detectionModes,
      hint = "None / Experimental (live class check) / Roster (name list) / Both." },
    { field = "TankDetectionMode", label = "Tank death sound", sound = "tankDeath",
      options = CritLog.Constants.detectionModes,
      hint = "None / Experimental (live role check) / Roster (name list) / Both." },
    { field = "BossDetectionMode", label = "Boss death sound", sound = "bossDeath",
      options = CritLog.Constants.detectionModes,
      hint = "None / Experimental (live classification) / Roster (name list) / Both." },
    { field = "DeadSoundFlag", label = "Death sounds (enables the five above)",
      hint = "Master switch for the five death sounds above." },
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
