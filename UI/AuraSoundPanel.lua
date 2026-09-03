-- Aura Sounds panel, opened via the "Aura Sounds..." button under the
-- AuraSoundFlag row on the Sound Settings panel. Split out once that panel
-- grew to 13 individually-toggleable aura/ritual sounds under one master
-- switch (see CHANGELOG.md) - same reasoning as Sound Settings itself
-- being split out of the main panel originally. AuraSoundFlag stays on
-- Sound Settings (it's the master switch for everything here, not
-- specific to this panel), not duplicated here - see the note row below
-- instead.
local AURA_CHECKBOXES = {
    { note = "Requires \"Aura/spell sound\" enabled on the Sound Settings panel." },
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
    -- Tall enough for the heading, the note row, and all 13 checkbox rows
    -- (each with its own hint line underneath). Not pixel-verified in-game
    -- yet - see docs/ROADMAP.md, visual polish is a follow-up.
    local f = CritLog.UI.createPanelFrame("CritLogAuraSoundFrame", "CritLog Aura Sounds", 490, 760)
    -- Offset from center so it doesn't perfectly overlap the main panel or
    -- Sound Settings when several are open at once; a one-time anchor, not
    -- a continuous one, so dragging one doesn't drag the others.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 60)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Aura Sounds")

    CritLog.UI.buildToggleRows(f, AURA_CHECKBOXES, heading)

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
