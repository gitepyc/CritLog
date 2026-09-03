-- Death Sounds panel, opened via the "Death Sounds..." button on the Sound
-- Settings panel. Split out once Sound Settings had shrunk down to its
-- general toggles plus this dropdown-heavy block (the 4 detection-mode
-- dropdowns are taller than a checkbox row, plus a note explaining their
-- four modes) - same reasoning as the Aura Sounds split before it (see
-- CHANGELOG.md).
local DEATH_CHECKBOXES = {
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
    -- it's close to the same length as Healer/Tank/Boss below, which
    -- keeps all four rows' Preview buttons in one aligned column instead
    -- of each sitting wherever its own label happens to end.
    --
    -- Labeled "Healer", not "Priest" (same rename reasoning as DPS above)
    -- - the field name (PriestDetectionMode) is unchanged. Also not
    -- priest-specific anymore: the live check reads the assigned raid
    -- Healer role (isAssignedHealer, same pattern as Tank), not class - a
    -- Holy Paladin/Resto Druid/Resto Shaman death counts the same as a
    -- Priest's. This no longer covers a Spirit-of-Redemption-delayed
    -- death - that's the separate, Priest-specific SpiritSoundFlag
    -- checkbox further down, previously folded into this same toggle (see
    -- CHANGELOG.md).
    { field = "PriestDetectionMode", label = "Healer death sound", sound = "priestDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: assigned raid Healer role. Excludes Spirit of Redemption deaths - see below." },
    { field = "MeleeDetectionMode", label = "DPS death sound", sound = "meleeDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: melee-capable class. Roster: ranged OK too." },
    { field = "TankDetectionMode", label = "Tank death sound", sound = "tankDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: assigned raid Tank role." },
    { field = "BossDetectionMode", label = "Boss death sound", sound = "bossDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Live check: live classification (worldboss)." },
    -- The None/Experimental/Roster/Both explanation applies to the four
    -- dropdowns above only - SpiritSoundFlag below is a plain on/off flag,
    -- not one of these four modes, so the note sits between them rather
    -- than after everything.
    { note = "None = nothing\nExperimental = live check only\nRoster = name list only\nBoth = Experimental + Roster" },
    -- Independent of Healer death above now (used to be folded into it -
    -- see CHANGELOG.md and Core/CombatLog.lua's HandleDeath). Plain
    -- checkbox, not a detection-mode dropdown: the only signal this has
    -- at all is having actually seen the buff applied, there's no roster/
    -- name-list equivalent to fall back to.
    { field = "SpiritSoundFlag", label = "Spirit of Redemption", sound = "spiritOfRedemption",
      hint = "A Priest's death was delayed ~15s by the talent (Priest-only, unlike Healer death above)." },
}

local deathSoundFrame

local function buildDeathSoundFrame()
    -- Tall enough for the heading and all 7 rows (PlayerSoundFlag, the 4
    -- taller dropdown rows, the note, and the Spirit of Redemption
    -- checkbox) - not pixel-verified in-game yet, see docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogDeathSoundFrame", "CritLog Death Sounds", 490, 580)
    -- Offset from center so it doesn't perfectly overlap the main panel or
    -- Sound Settings when several are open at once; a one-time anchor, not
    -- a continuous one, so dragging one doesn't drag the others.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, -60)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Death Sounds")

    CritLog.UI.buildToggleRows(f, DEATH_CHECKBOXES, heading)

    CritLog.UI.createCloseButton(f)

    return f
end

function CritLog:ShowDeathSounds()
    if not deathSoundFrame then
        deathSoundFrame = buildDeathSoundFrame()
    end

    if deathSoundFrame:IsShown() then
        deathSoundFrame:Hide()
    else
        deathSoundFrame:Show()
    end
end
