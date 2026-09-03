-- Death Sounds panel, opened via the "Death Sounds..." button on the Sound
-- Settings panel. Split out once Sound Settings had shrunk down to its
-- general toggles plus this 5-row, dropdown-heavy block (the 4 detection-
-- mode dropdowns are taller than a checkbox row, plus a note explaining
-- their four modes) - same reasoning as the Aura Sounds split before it
-- (see CHANGELOG.md).
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

local deathSoundFrame

local function buildDeathSoundFrame()
    -- Tall enough for the heading and all 6 rows (PlayerSoundFlag, the 4
    -- taller dropdown rows, and the note) - not pixel-verified in-game yet,
    -- see docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogDeathSoundFrame", "CritLog Death Sounds", 490, 520)
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
