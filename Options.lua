-- First-draft options panel, opened with /cl options. Deliberately plain:
-- only built-in Blizzard templates (BasicFrameTemplateWithInset,
-- UICheckButtonTemplate, UIPanelButtonTemplate), no custom textures or
-- third-party UI libs. Visual polish is a follow-up once the layout itself
-- is reviewed - see docs/REFACTORING.md step 5.

-- Label wording is lifted from Commands.lua's printHelp()/printConfig() so
-- the panel doesn't introduce new terminology for the same settings.
--
-- `sound` is a key into CritLog.Data.sounds and gets a "Preview" button on
-- that row; flags with no sound of their own (MasterSoundFlag mutes
-- everything but plays nothing itself, AllCritFlag/WhiteHitFlag only modify
-- *when* the shared crit sound plays, AllLevel/DebugFlag don't play
-- anything, DeadSoundFlag is a master switch already covered by the five
-- death-sound rows below it) get none. AuraSoundFlag is a master switch
-- over seven distinct spell sounds, too many for a single row - see
-- AURA_PREVIEWS below instead.
local CHECKBOXES = {
    { field = "MasterSoundFlag", label = "Sound enabled (overrides everything below)",
      tooltip = "Mutes every CritLog sound when off, without changing any of the individual settings below - turning it back on restores them exactly as they were." },
    { field = "SoundFlag", label = "Highscore sound (BÄM)", sound = "crit",
      tooltip = "Plays a sound whenever you set a new personal highscore (damage crit, white hit crit, or heal crit)." },
    { field = "AllCritFlag", label = "Sound for all crits",
      tooltip = "Plays the highscore sound on every crit, not just when it's a new highscore." },
    { field = "WhiteHitFlag", label = "Sound for white hit crits",
      tooltip = "Also plays the highscore sound for white hit crits (auto-attacks), not just ability crits." },
    { field = "AllLevel", label = "Ignore enemy level requirement",
      tooltip = "Counts crits toward highscores regardless of the target's level, instead of only ones that pass CritLog's normal enemy level check." },
    { field = "XtremeSoundFlag", label = "Xtreme damage sound (over 9000)", sound = "xtremeDamage",
      tooltip = "Plays an extra sound whenever a single hit deals more than 9000 damage, on top of the normal highscore sound." },
    { field = "DebugFlag", label = "Debug mode (diagnostic chat output)",
      tooltip = "Prints diagnostic chat messages for troubleshooting - spell-ID matching, the level filter, and aura detection." },
    { field = "ReadySoundFlag", label = "Ready check sound", sound = "readyCheck",
      tooltip = "Plays a sound whenever a ready check starts." },
    { field = "AuraSoundFlag", label = "Aura/spell sound", auraPreviews = true,
      tooltip = "Master switch for the 7 tracked spell sounds below - Bloodlust, Innervate, Power Infusion, Blessing of Protection, Divine Intervention, Mana Tide, and Soulstone." },
    -- These four (unlike PlayerSoundFlag) rely on the new class/role/
    -- classification detection added this session (isMeleeClass,
    -- isAssignedTank, isPriestClass, isClassifiedBoss in CombatLog.lua) -
    -- not yet in-game verified, hence "(Experimental)". Untested here
    -- doesn't mean broken: each one falls back to the legacy hardcoded
    -- name roster whenever the live class/role/classification check
    -- doesn't resolve or doesn't match.
    { field = "PriestSoundFlag", label = "Priest death sound (Experimental)", sound = "priestDeath",
      tooltip = "Plays a sound when a Priest dies. Detects Priests by class first, falls back to a hardcoded name list if that check doesn't resolve." },
    { field = "MeleeSoundFlag", label = "Melee death sound (Experimental)", sound = "meleeDeath",
      tooltip = "Plays a sound when a melee-capable class dies. Detects the class directly first, falls back to a hardcoded name list if that check doesn't resolve." },
    { field = "TankSoundFlag", label = "Tank death sound (Experimental)", sound = "tankDeath",
      tooltip = "Plays a sound when the group's assigned tank dies. Detects the tank via assigned raid role first, falls back to a hardcoded name list if that check doesn't resolve." },
    { field = "PlayerSoundFlag", label = "Player death sound", sound = "playerDeath",
      tooltip = "Plays a sound when you yourself die." },
    { field = "BossSoundFlag", label = "Boss death sound (Experimental)", sound = "bossDeath",
      tooltip = "Plays a sound when a boss dies. Detects world bosses via live classification first, falls back to a hardcoded boss name list if that check doesn't resolve." },
    { field = "DeadSoundFlag", label = "Death sounds (enables the five above)",
      tooltip = "Master switch for the five death sounds above (Priest/Melee/Tank/Player/Boss) - they only fire while this is on." },
}

-- AuraSoundFlag gates all seven of these individually (CombatLog.lua's
-- HandleAuraSounds); each gets its own small preview button in a compact
-- grid instead of a full checkbox row of its own, since none of them are
-- separately toggleable.
local AURA_PREVIEWS = {
    { sound = "bloodlust", label = "Bloodlust" },
    { sound = "innervate", label = "Innervate" },
    { sound = "powerInfusion", label = "Power Infusion" },
    { sound = "blessingOfProtection", label = "Bless. of Prot." },
    { sound = "divineIntervention", label = "Divine Int." },
    { sound = "manaTide", label = "Mana Tide" },
    { sound = "soulstone", label = "Soulstone" },
}

local AURA_BUTTONS_PER_ROW = 3

-- Created lazily on first /cl options, not at load time - nothing needs the
-- frame to exist before the player asks for it.
local frame
local checkboxesByField = {}

local function anchorBelow(region, previous, yGap)
    region:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -(yGap or 6))
end

-- Plays a CritLog.Data.sounds entry directly through the addon's own
-- CritLog:PlaySound(), bypassing CritLogDB flags entirely (so a preview
-- works even while the toggle is off - the whole point is deciding whether
-- to turn it on) and bypassing the real trigger logic in CombatLog.lua
-- (so no highscore/state is touched). For multi-variant entries this picks
-- one at random each click, the same way CombatLog.lua's local
-- randomEntry() does for the real in-game trigger - a preview should sound
-- like what you'd actually hear, including the randomness. Cycling through
-- variants instead would need extra per-sound state for no real benefit in
-- a first draft.
local function previewSound(soundKey)
    local sound = CritLog.Data.sounds[soundKey]
    if type(sound) == "table" then
        CritLog:PlaySound(sound[math.random(1, #sound)])
    else
        CritLog:PlaySound(sound)
    end
end

local function createPreviewButton(parent, soundKey, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 70, 20)
    button:SetText("Preview")
    button:GetFontString():SetFontObject("GameFontHighlightSmall")
    button:SetScript("OnClick", function()
        previewSound(soundKey)
    end)
    return button
end

-- Lays out AURA_PREVIEWS as a compact button grid under the AuraSoundFlag
-- row and returns the last button, so the caller can keep chaining the
-- next checkbox row below it.
local function buildAuraPreviewGrid(parent, anchorTo)
    local rowStart, previousButton

    for i, entry in ipairs(AURA_PREVIEWS) do
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        button:SetSize(112, 20)
        button:SetText(entry.label)
        button:GetFontString():SetFontObject("GameFontHighlightSmall")
        button:SetScript("OnClick", function()
            previewSound(entry.sound)
        end)

        if (i - 1) % AURA_BUTTONS_PER_ROW == 0 then
            if rowStart then
                button:SetPoint("TOPLEFT", rowStart, "BOTTOMLEFT", 0, -4)
            else
                button:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 20, -4)
            end
            rowStart = button
        else
            button:SetPoint("LEFT", previousButton, "RIGHT", 4, 0)
        end

        previousButton = button
    end

    return rowStart
end

local function buildFrame()
    local f = CreateFrame("Frame", "CritLogOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
    -- Tall enough for the header block plus all 15 toggle rows plus the
    -- aura preview grid; 660 was too short and let the bottom rows render
    -- past the frame's own border.
    -- Widened from 440: the "(Experimental)" suffix on four labels needs
    -- more room before the preview button column.
    f:SetSize(490, 860)
    f:SetPoint("CENTER")
    -- TOOLTIP is the highest frame strata WoW exposes; other addons
    -- (WeakAuras displays included) commonly sit at MEDIUM/HIGH/DIALOG,
    -- so this keeps the options panel on top of them without needing to
    -- know what strata any specific one uses. SetToplevel raises it above
    -- same-strata siblings whenever it's clicked, same as other dialogs.
    f:SetFrameStrata("TOOLTIP")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.TitleText:SetText("CritLog Options")

    local highscoresHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- Anchored directly to the frame rather than f.Inset: that child region
    -- isn't guaranteed to exist on every BasicFrameTemplateWithInset variant
    -- (SoD's client doesn't expose it), and a nil relativeTo here silently
    -- anchors everything downstream - the whole checkbox chain included -
    -- to the screen instead of the panel. -30 clears the title bar.
    highscoresHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    highscoresHeading:SetText("Highscores")

    f.dacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.dacText, highscoresHeading, 8)

    f.whcText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.whcText, f.dacText)

    f.hacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.hacText, f.whcText)

    local infoHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    anchorBelow(infoHeading, f.hacText, 16)
    infoHeading:SetText("Info")

    f.versionText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.versionText, infoHeading, 8)
    f.versionText:SetText("CritLog version: "..CritLog.version)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    anchorBelow(togglesHeading, f.versionText, 16)
    togglesHeading:SetText("Toggles")

    local previous = togglesHeading
    -- buildAuraPreviewGrid's returned anchor sits 20px right of the checkbox
    -- column (to line the grid up under its label); this offset cancels
    -- that back out so the next real checkbox stays in the same column
    -- instead of drifting right for the rest of the list.
    local previousXOffset = 0
    for _, entry in ipairs(CHECKBOXES) do
        local check = CreateFrame("CheckButton", "CritLogOptions"..entry.field, f, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset, -4)
        -- Hook rather than replace OnClick, so the template's default click
        -- sound still plays; GetChecked() returns 1/nil on some clients, so
        -- normalize to a real boolean before writing it back to the DB.
        check:HookScript("OnClick", function(self)
            CritLogDB[entry.field] = self:GetChecked() and true or false
        end)
        checkboxesByField[entry.field] = check

        if entry.tooltip then
            check:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(entry.label, 1, 1, 1)
                GameTooltip:AddLine(entry.tooltip, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            check:SetScript("OnLeave", GameTooltip_Hide)
        end

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", check, "RIGHT", 2, 1)
        label:SetText(entry.label)

        if entry.sound then
            -- Anchored to a fixed offset from the checkbox itself rather
            -- than to the label, so button position doesn't depend on how
            -- long a given label happens to be.
            local previewButton = createPreviewButton(f, entry.sound)
            previewButton:SetPoint("LEFT", check, "LEFT", 340, 0)
            previous = check
            previousXOffset = 0
        elseif entry.auraPreviews then
            previous = buildAuraPreviewGrid(f, check)
            previousXOffset = -20
        else
            previous = check
            previousXOffset = 0
        end
    end

    f:SetScript("OnShow", function()
        CritLog:RefreshOptionsPanel()
    end)

    f:Hide()
    return f
end

-- CritLogDB can change while the panel is closed (new highscores, /cl
-- toggles from chat), so re-read everything on every OnShow rather than
-- only when the frame is first built.
function CritLog:RefreshOptionsPanel()
    if not frame then
        return
    end

    frame.dacText:SetText(
        "Damage crit ("..CritLogDB.DAC_Name.."): "
        ..CritLogDB.DamageAbilityCrit.." ("..CritLogDB.DAC_Tar..")"
    )
    frame.whcText:SetText(
        "Damage crit (white hit): "..CritLogDB.WhiteHitCrit
        .." ("..CritLogDB.WHC_Tar..")"
    )
    frame.hacText:SetText(
        "Heal crit ("..CritLogDB.HAC_Name.."): "
        ..CritLogDB.HealAbilityCrit.." ("..CritLogDB.HAC_Tar..")"
    )

    for field, check in pairs(checkboxesByField) do
        check:SetChecked(CritLogDB[field])
    end
end

function CritLog:ShowOptions()
    if not frame then
        frame = buildFrame()
    end

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
