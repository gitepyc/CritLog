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
    { field = "AuraSoundFlag", label = "Aura/spell sound", auraPreviews = true,
      hint = "Master switch for the 7 spell sounds below." },
    { field = "PlayerSoundFlag", label = "Player death sound", sound = "playerDeath",
      hint = "Plays when you yourself die." },
    -- These four (unlike PlayerSoundFlag above) rely on the class/role/
    -- classification detection in Core/CombatLog.lua (isMeleeClass,
    -- isAssignedTank, isPriestClass, isClassifiedBoss) - not yet in-game
    -- verified, hence "(Experimental)". Untested here doesn't mean broken:
    -- each one falls back to the legacy hardcoded name roster whenever the
    -- live class/role/classification check doesn't resolve or doesn't
    -- match.
    { field = "PriestSoundFlag", label = "Priest death sound (Experimental)", sound = "priestDeath",
      hint = "By class first, name list fallback." },
    { field = "MeleeSoundFlag", label = "Melee death sound (Experimental)", sound = "meleeDeath",
      hint = "By class first, name list fallback." },
    { field = "TankSoundFlag", label = "Tank death sound (Experimental)", sound = "tankDeath",
      hint = "By assigned raid role first, name list fallback." },
    { field = "BossSoundFlag", label = "Boss death sound (Experimental)", sound = "bossDeath",
      hint = "By live classification first, name list fallback." },
    { field = "DeadSoundFlag", label = "Death sounds (enables the five above)",
      hint = "Master switch for the five death sounds above." },
}

local soundFrame

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 13 sound toggle rows (each
    -- with its own hint line underneath), and the aura preview grid.
    -- Widened from 440: the "(Experimental)" suffix on four labels needs
    -- more room before the preview button column.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 820)
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
