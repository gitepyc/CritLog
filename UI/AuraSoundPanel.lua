-- Aura Sounds panel, opened via the "Aura Sounds..." button under the
-- AuraSoundFlag row on the Sound Settings panel. Split out once that panel
-- grew to 13 individually-toggleable aura/ritual sounds under one master
-- switch (see CHANGELOG.md) - same reasoning as Sound Settings itself
-- being split out of the main panel originally. AuraSoundFlag stays on
-- Sound Settings (it's the master switch for everything here, not
-- specific to this panel), not duplicated here - see the note row below
-- instead.
--
-- Laid out as two columns rather than one long list (13 rows single-column
-- made this panel nearly as tall as Sound Settings used to be, defeating
-- the point of splitting it out) - split by position, not by theme/
-- category, so it's just "first 7" / "remaining 6" rather than a grouping
-- that would need explaining.
local AURA_CHECKBOXES_LEFT = {
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
    -- Labeled "Applied", not "Resurrection": this fires when the Soulstone
    -- buff itself lands on you (SPELL_AURA_APPLIED), well before it's
    -- actually used to self-resurrect - the buff is literally named
    -- "Soulstone Resurrection" in-game (see Core/Constants.lua's spell
    -- name fallback), which was misleading here as a trigger description.
    { field = "SoulstoneSoundFlag", label = "Soulstone Applied", sound = "soulstone",
      hint = "Received the Soulstone buff (not the resurrection itself)." },
}

local AURA_CHECKBOXES_RIGHT = {
    { field = "DrumsSoundFlag", label = "Drums of Battle", sound = "drums",
      hint = "Received Drums of Battle." },
    { field = "PainSuppressionSoundFlag", label = "Pain Suppression", sound = "painSuppression",
      hint = "Received Pain Suppression." },
    { field = "HymnOfHopeSoundFlag", label = "Hymn of Hope", sound = "hymnOfHope",
      hint = "Received Hymn of Hope." },
    { field = "EvocationSoundFlag", label = "Evocation", sound = "evocation",
      hint = "Received Evocation." },
    { field = "MageTableSoundFlag", label = "Mage Table", sound = "mageTable",
      hint = "A party/raid member casts Ritual of Refreshment (max once per 100s)." },
    { field = "HealthstoneSoundFlag", label = "Warlock Healthstone Ritual", sound = "healthstoneRitual",
      hint = "A party/raid member casts Ritual of Souls (max once per 60s)." },
}

local auraSoundFrame

local function buildAuraSoundFrame()
    -- Wide enough for two columns, each needing the same ~424px a single
    -- column row does (checkbox + label + the Preview button's fixed
    -- 340px-from-checkbox column - see UI/Shared.lua's buildToggleRows).
    -- Tall enough for the heading, the note row, and the longer column (7
    -- rows; hints are now a hover tooltip, not a line underneath each row).
    -- Not pixel-verified in-game yet - see docs/ROADMAP.md, visual polish
    -- is a follow-up.
    local f = CritLog.UI.createPanelFrame("CritLogAuraSoundFrame", "CritLog Aura Sounds", 920, 460)
    -- Offset from center so it doesn't perfectly overlap the main panel or
    -- Sound Settings when several are open at once; a one-time anchor, not
    -- a continuous one, so dragging one doesn't drag the others.
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 60)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Aura Sounds")

    local noteRow = CritLog.UI.buildToggleRows(f, {
        { note = "Requires \"Aura/spell sound\" enabled on the Sound Settings panel." },
    }, heading)

    -- Two independent anchor points at the same Y, one at the panel's left
    -- margin (matching every other panel's row indent) and one far enough
    -- right to clear the left column's Preview buttons (checkbox + 340px +
    -- button width, see the width comment above) - buildToggleRows anchors
    -- each column's own rows relative to its own start anchor, so the two
    -- chains never interact.
    local colLeftAnchor = CreateFrame("Frame", nil, f)
    colLeftAnchor:SetSize(1, 1)
    colLeftAnchor:SetPoint("TOPLEFT", noteRow, "BOTTOMLEFT", 0, -8)

    local colRightAnchor = CreateFrame("Frame", nil, f)
    colRightAnchor:SetSize(1, 1)
    colRightAnchor:SetPoint("TOPLEFT", noteRow, "BOTTOMLEFT", 446, -8)

    CritLog.UI.buildToggleRows(f, AURA_CHECKBOXES_LEFT, colLeftAnchor)
    CritLog.UI.buildToggleRows(f, AURA_CHECKBOXES_RIGHT, colRightAnchor)

    CritLog.UI.createCloseButton(f)

    return f
end

function CritLog:ShowAuraSounds()
    if not auraSoundFrame then
        auraSoundFrame = buildAuraSoundFrame()
    end

    if auraSoundFrame:IsShown() then
        auraSoundFrame:Hide()
    else
        auraSoundFrame:Show()
    end
end
