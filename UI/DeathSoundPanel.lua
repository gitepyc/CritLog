-- Death Sounds panel, opened via the "Death Sounds..." button on the Sound
-- Settings panel. Split out once Sound Settings had shrunk down to its
-- general toggles plus this dropdown-heavy block (the 4 detection-mode
-- dropdowns are taller than a checkbox row, plus a note explaining their
-- four modes) - same reasoning as the Aura Sounds split before it (see
-- CHANGELOG.md).
local DEATH_CHECKBOXES = {
    { field = "PlayerSoundFlag", label = "Player death sound", sound = "playerDeath",
      hint = "Plays when you yourself die." },
    -- Independent of Healer death below now (used to be folded into it -
    -- see CHANGELOG.md and Core/CombatLog.lua's HandleDeath). Plain
    -- checkbox, not a detection-mode dropdown: the only signal this has
    -- at all is having actually seen the buff applied, there's no roster/
    -- name-list equivalent to fall back to. Placed right after Player
    -- death and before the four detection-mode dropdowns, rather than at
    -- the very end, since it's conceptually closer to those two plain
    -- flags than to the Experimental/Roster/Both system below it.
    { field = "SpiritSoundFlag", label = "Spirit of Redemption", sound = "spiritOfRedemption",
      hint = "A Priest's death delayed ~15s by the talent (own sound file)." },
    -- These four (unlike PlayerSoundFlag/SpiritSoundFlag above) can be
    -- driven by the live class/role/classification detection in
    -- Core/CombatLog.lua (isMeleeClass, isAssignedTank, isAssignedHealer,
    -- isClassifiedBoss), the hardcoded name roster, both, or neither - a
    -- dropdown instead of a checkbox. No shared master switch anymore
    -- (there used to be one, DeadSoundFlag) - setting all four to "None"
    -- is equivalent, and the dropdown is already the one place that
    -- controls all of this. "Experimental" isn't yet in-game verified for
    -- tank/boss/heal specifically (melee's false-positive bug is fixed
    -- and confirmed); "Roster" and "Both" (the original default) aren't
    -- affected by that.
    --
    -- Order matches UI/RosterPanel.lua's ROSTER_ORDER (melee/dmg, tank,
    -- heal) - Boss has no roster category, so it stays last regardless.
    --
    -- Labeled "DPS", not "Damage Dealer", specifically here (unlike the
    -- roster category label, which stays "Damage Dealer") - kept short so
    -- it's close to the same length as Healer/Tank/Boss below, which
    -- keeps all four rows' Preview buttons in one aligned column instead
    -- of each sitting wherever its own label happens to end.
    { field = "MeleeDetectionMode", label = "DPS death sound", sound = "meleeDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Experimental: melee-capable class. Roster: ranged OK too." },
    { field = "TankDetectionMode", label = "Tank death sound", sound = "tankDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Experimental: assigned raid Tank role." },
    -- Field renamed HealDetectionMode (was PriestDetectionMode - see
    -- Persistence/Database.lua's migratePriestToHeal) once the live check
    -- stopped being Priest-specific: it now reads the assigned raid
    -- Healer role (isAssignedHealer, same pattern as Tank), not class - a
    -- Holy Paladin/Resto Druid/Resto Shaman death counts the same as a
    -- Priest's. Doesn't mention excluding a Spirit-of-Redemption-delayed
    -- death in its hint anymore - SpiritSoundFlag sits directly above it
    -- now, no cross-reference needed.
    { field = "HealDetectionMode", label = "Healer death sound", sound = "healDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Experimental: assigned raid Healer role." },
    { field = "BossDetectionMode", label = "Boss death sound", sound = "bossDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Experimental: live classification (worldboss)." },
    -- The None/Experimental/Roster/Both explanation applies to the four
    -- dropdowns above only - a note row after them, not before, same
    -- reasoning as the Sound Settings panel's dropdown note. "Experimental"
    -- in each row's own hint above ties back to this same word, not a
    -- separate "live check" concept.
    { note = "None = nothing\nExperimental = live check only\nRoster = name list only\nBoth = Experimental + Roster" },
}

local deathSoundFrame

local function buildDeathSoundFrame()
    -- Tall enough for the heading, all 7 rows (PlayerSoundFlag,
    -- SpiritSoundFlag, the 4 taller dropdown rows, and the note; hints are
    -- now a hover tooltip, not a line underneath each row), and the Roster
    -- Settings button below them - not pixel-verified in-game yet, see
    -- docs/ROADMAP.md.
    local f = CritLog.UI.createPanelFrame("CritLogDeathSoundFrame", "CritLog Death Sounds", 490, 560)
    -- Offset from center so it doesn't perfectly overlap the main panel or
    -- Sound Settings when several are open at once; a one-time anchor, not
    -- a continuous one, so dragging one doesn't drag the others.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, -60)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Death Sounds")

    local lastAnchor = CritLog.UI.buildToggleRows(f, DEATH_CHECKBOXES, heading)

    -- Moved here from the main panel: the melee/tank/heal name rosters are
    -- only ever consulted as a fallback for the four detection-mode
    -- dropdowns above (Roster/Both modes), so this button is more at home
    -- next to them than on the main panel, where it was otherwise
    -- unrelated to anything else there.
    local rosterButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rosterButton:SetSize(140, 24)
    rosterButton:SetText("Roster Settings...")
    rosterButton:SetNormalFontObject("GameFontNormalSmall")
    rosterButton:SetHighlightFontObject("GameFontHighlightSmall")
    rosterButton:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -16)
    rosterButton:SetScript("OnClick", function()
        CritLog:ShowRoster()
    end)

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
