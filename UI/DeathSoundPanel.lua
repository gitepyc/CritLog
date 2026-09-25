-- Death Sounds panel, opened via the "Death Sounds..." button on the
-- Sound Settings panel.
local DEATH_CHECKBOXES = {
    { field = "PlayerSoundFlag", label = "Player death sound", sound = "playerDeath",
      hint = "Plays when you yourself die." },
    -- Plain checkbox, not a detection-mode dropdown: the hardcoded boss
    -- name list (Core/Constants.lua's bosses.english/german) is gone - it
    -- was still the original Burning Crusade roster and matched nothing
    -- in Classic Era/SoD, so "Roster"/"Both" on this row never actually
    -- did anything beyond what "Role" already did alone. Live `worldboss`
    -- classification is now the only signal, on or off.
    { field = "BossSoundFlag", label = "Boss death sound", sound = "bossDeath",
      hint = "Plays on a live boss-level-mob classification (raid bosses, outdoor world bosses, and other level-60 raid encounters)." },
    -- These three (unlike PlayerSoundFlag/BossSoundFlag above) can be
    -- driven by the live role detection in Core/CombatLog.lua
    -- (isAssignedDps, isAssignedTank, isAssignedHealer), the hardcoded
    -- name roster, both, or neither - a dropdown instead of a checkbox.
    -- Setting all three to "None" is equivalent to a shared master
    -- switch. Order matches UI/RosterPanel.lua's ROSTER_ORDER.
    --
    -- Labeled "DPS", not "Damage Dealer" (unlike the roster category
    -- label), kept short so it's close to the same length as Healer/Tank
    -- below, keeping all three rows' Preview buttons aligned.
    { field = "DpsDetectionMode", label = "DPS death sound", sound = "dpsDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Role: assigned Damage Dealer role." },
    { field = "TankDetectionMode", label = "Tank death sound", sound = "tankDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Role: assigned Tank role." },
    -- Field renamed HealDetectionMode (was PriestDetectionMode - see
    -- Persistence/Database.lua's migratePriestToHeal) once the live check
    -- stopped being Priest-specific: it now reads the assigned raid
    -- Healer role (isAssignedHealer, same pattern as Tank), not class - a
    -- Holy Paladin/Resto Druid/Resto Shaman death counts the same as a
    -- Priest's.
    { field = "HealDetectionMode", label = "Healer death sound", sound = "healDeath",
      options = CritLog.Constants.detectionModes,
      hint = "Role: assigned Healer role." },
    -- The None/Role/Roster/Both explanation applies to the three
    -- dropdowns above only - a note row after them, not before, same
    -- reasoning as the Sound Settings panel's dropdown note. "Role" in
    -- each row's own hint above ties back to this same word.
    { note = "None = no sound\nRole = assigned role only\nRoster = saved name list only\nBoth = either matches" },
}

local deathSoundFrame

local function buildDeathSoundFrame()
    local f = CritLog.UI.createPanelFrame("CritLogDeathSoundFrame", "CritLog Death Sounds", 420, 420)
    -- Offset from center so it doesn't perfectly overlap the main panel or
    -- Sound Settings when several are open at once.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, -60)
    -- Closes its own child (Roster Settings) when it closes.
    f:HookScript("OnHide", function()
        CritLog.UI.closeChildPanels({ "CritLogRosterFrame" })
    end)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Death Sounds")

    local lastAnchor = CritLog.UI.buildToggleRows(f, DEATH_CHECKBOXES, heading)

    -- The dps/tank/heal name rosters are only ever consulted as a
    -- fallback for the detection-mode dropdowns above (Roster/Both
    -- modes), so this button lives next to them.
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
