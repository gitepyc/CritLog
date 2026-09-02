-- First-draft options panel, opened with /cl options. Deliberately plain:
-- only built-in Blizzard templates (BasicFrameTemplateWithInset,
-- UICheckButtonTemplate, UIPanelButtonTemplate), no custom textures or
-- third-party UI libs. Visual polish is a follow-up once the layout itself
-- is reviewed - see docs/ROADMAP.md.

-- Label wording is lifted from Commands.lua's printHelp()/printConfig() so
-- the panel doesn't introduce new terminology for the same settings.
--
-- Split into two panels: the main one (this file's CRIT_CHECKBOXES) covers
-- crit-tracking behavior that isn't about sound at all, while every actual
-- sound toggle lives in a separate "Sound Settings" panel opened via a
-- button, so the default /cl options view isn't 13 sound rows deep before
-- you even see whether crit tracking itself is configured how you want.
--
-- `sound` is a key into CritLog.Data.sounds and gets a "Preview" button on
-- that row; flags with no sound of their own (MasterSoundFlag mutes
-- everything but plays nothing itself, AllCritFlag/WhiteHitFlag only modify
-- *when* the shared crit sound plays, DeadSoundFlag is a master switch
-- already covered by the five death-sound rows below it) get none.
-- AuraSoundFlag is a master switch over seven distinct spell sounds, too
-- many for a single row - see AURA_PREVIEWS below instead.
local CRIT_CHECKBOXES = {
    { field = "AllLevel", label = "Ignore enemy level requirement",
      hint = "Counts highscores from enemies of any level." },
    { field = "DebugFlag", label = "Debug mode (diagnostic chat output)",
      hint = "Prints diagnostic chat messages for troubleshooting." },
}

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
    -- These four (unlike PlayerSoundFlag above) rely on the new class/role/
    -- classification detection added this session (isMeleeClass,
    -- isAssignedTank, isPriestClass, isClassifiedBoss in CombatLog.lua) -
    -- not yet in-game verified, hence "(Experimental)". Untested here
    -- doesn't mean broken: each one falls back to the legacy hardcoded
    -- name roster whenever the live class/role/classification check
    -- doesn't resolve or doesn't match.
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

-- Both created lazily, not at load time - nothing needs either frame to
-- exist before the player asks for it.
local frame
local soundFrame
local checkboxesByField = {}

local function anchorBelow(region, previous, yGap)
    region:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -(yGap or 6))
end

-- Plays a CritLog.Data.sounds entry directly via PlaySoundFile, bypassing
-- CritLogDB flags entirely - including MasterSoundFlag - so a preview
-- works even while sound is muted or the specific toggle is off (the whole
-- point is deciding whether to turn it on) and bypassing the real trigger
-- logic in CombatLog.lua (so no highscore/state is touched). Deliberately
-- not routed through CritLog:PlaySound(): that function is the mute
-- switch's single choke point, which would otherwise make every preview
-- silently do nothing whenever MasterSoundFlag is off - exactly backwards
-- for a button whose purpose is letting you hear a sound before enabling it.
local function previewSound(soundKey)
    PlaySoundFile(CritLog.soundPath..CritLog.Data.sounds[soundKey], "Master")
end

-- Clears a single highscore record (e.g. a false-positive value from some
-- other addon's damage numbers) without touching the other two, then
-- refreshes the displayed text immediately.
local function createResetButton(parent, kind)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(50, 18)
    button:SetText("Reset")
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetScript("OnClick", function()
        CritLog:ResetRecord(kind)
        CritLog:RefreshOptionsPanel()
    end)
    return button
end

local function createPreviewButton(parent, soundKey, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 70, 20)
    button:SetText("Preview")
    -- SetNormalFontObject/SetHighlightFontObject (not a direct
    -- GetFontString():SetFontObject() call) so the button's own built-in
    -- mouseover handling still switches between them correctly. Calling
    -- SetFontObject() directly on the shared FontString bypassed that
    -- state machine and left the text stuck yellow (the hover color)
    -- after the mouse left the button.
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
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
        -- See createPreviewButton's comment: SetNormalFontObject/
        -- SetHighlightFontObject, not a direct SetFontObject() call.
        button:SetNormalFontObject("GameFontNormalSmall")
        button:SetHighlightFontObject("GameFontHighlightSmall")
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

-- Shared row-building loop for both panels: a checkbox, its label, an
-- optional preview button, and a static hint line underneath (used instead
-- of a hover tooltip - GameTooltip on the checkbox didn't reliably show
-- in-game, small hit area, easy to miss). Returns the last anchor region
-- and its x-offset so the caller can keep chaining further content below.
local function buildToggleRows(parent, checkboxes, startAnchor)
    local previous = startAnchor
    -- 0 for the first row: startAnchor (a section heading) has no x-indent
    -- quirk to cancel. Every row after that anchors to the PREVIOUS row's
    -- hint line, which sits +4px right of its own checkbox - so from the
    -- second row on this needs to be -4, or each row would drift 4px
    -- further right than the last (a growing staircase, not a one-time
    -- shift). buildAuraPreviewGrid's returned anchor is an extra 20px
    -- right on top of that (hint's +4, then the grid's own +20 to line up
    -- under it), so that branch below cancels -24 instead.
    local previousXOffset = 0

    for _, entry in ipairs(checkboxes) do
        local check = CreateFrame("CheckButton", "CritLogOptions"..entry.field, parent, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset, -4)
        -- Hook rather than replace OnClick, so the template's default click
        -- sound still plays; GetChecked() returns 1/nil on some clients, so
        -- normalize to a real boolean before writing it back to the DB.
        check:HookScript("OnClick", function(self)
            CritLogDB[entry.field] = self:GetChecked() and true or false
        end)
        checkboxesByField[entry.field] = check

        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", check, "RIGHT", 2, 1)
        label:SetText(entry.label)

        if entry.sound then
            -- Anchored to a fixed offset from the checkbox itself rather
            -- than to the label, so button position doesn't depend on how
            -- long a given label happens to be.
            local previewButton = createPreviewButton(parent, entry.sound)
            previewButton:SetPoint("LEFT", check, "LEFT", 340, 0)
        end

        local hint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("TOPLEFT", check, "BOTTOMLEFT", 4, -2)
        hint:SetText(entry.hint)

        if entry.auraPreviews then
            previous = buildAuraPreviewGrid(parent, hint)
            previousXOffset = -24
        else
            previous = hint
            previousXOffset = -4
        end
    end

    return previous, previousXOffset
end

-- Both panels need to stay above other addon UI (a WeakAuras display was
-- covering the panel before this was added) and share the same drag/close
-- behavior, so this sets up everything but the content.
local function createPanelFrame(name, title, width, height)
    local f = CreateFrame("Frame", name, UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(width, height)
    -- TOOLTIP is the highest frame strata WoW exposes; other addons
    -- (WeakAuras displays included) commonly sit at MEDIUM/HIGH/DIALOG,
    -- so this keeps the options panels on top of them without needing to
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
    f.TitleText:SetText(title)
    f:SetScript("OnShow", function()
        CritLog:RefreshOptionsPanel()
    end)
    f:Hide()
    return f
end

local function buildSoundFrame()
    -- Tall enough for the toggles heading, all 13 sound toggle rows (each
    -- with its own hint line underneath), and the aura preview grid.
    -- Widened from 440: the "(Experimental)" suffix on four labels needs
    -- more room before the preview button column.
    local f = createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", 490, 820)
    -- Offset from center so it doesn't perfectly overlap the main panel
    -- when both are open at once; a one-time anchor, not a continuous one,
    -- so dragging either panel doesn't drag the other.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    togglesHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    togglesHeading:SetText("Sound Toggles")

    buildToggleRows(f, SOUND_CHECKBOXES, togglesHeading)

    return f
end

local function buildFrame()
    -- Tall enough for the header block, the 2 crit-tracking toggle rows
    -- (each with its own hint line underneath), and the Sound Settings
    -- button. Widened from 420 so a long spell/target name in a highscore
    -- line has room before running into that row's Reset button.
    local f = createPanelFrame("CritLogOptionsFrame", "CritLog Options", 470, 420)
    f:SetPoint("CENTER")

    local highscoresHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- Anchored directly to the frame rather than f.Inset: that child region
    -- isn't guaranteed to exist on every BasicFrameTemplateWithInset variant
    -- (SoD's client doesn't expose it), and a nil relativeTo here silently
    -- anchors everything downstream to the screen instead of the panel.
    -- -30 clears the title bar.
    highscoresHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    highscoresHeading:SetText("Highscores")

    f.dacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.dacText, highscoresHeading, 8)
    local dacReset = createResetButton(f, "damage")
    dacReset:SetPoint("TOP", f.dacText, "TOP", 0, 0)
    dacReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    f.whcText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.whcText, f.dacText)
    local whcReset = createResetButton(f, "whiteHit")
    whcReset:SetPoint("TOP", f.whcText, "TOP", 0, 0)
    whcReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    f.hacText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.hacText, f.whcText)
    local hacReset = createResetButton(f, "heal")
    hacReset:SetPoint("TOP", f.hacText, "TOP", 0, 0)
    hacReset:SetPoint("RIGHT", f, "RIGHT", -14, 0)

    local infoHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    anchorBelow(infoHeading, f.hacText, 16)
    infoHeading:SetText("Info")

    f.versionText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchorBelow(f.versionText, infoHeading, 8)
    f.versionText:SetText("CritLog version: "..CritLog.version)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    anchorBelow(togglesHeading, f.versionText, 16)
    togglesHeading:SetText("Options")

    local lastAnchor = buildToggleRows(f, CRIT_CHECKBOXES, togglesHeading)

    local soundButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    soundButton:SetSize(140, 24)
    soundButton:SetText("Sound Settings...")
    soundButton:SetNormalFontObject("GameFontNormalSmall")
    soundButton:SetHighlightFontObject("GameFontHighlightSmall")
    soundButton:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -16)
    soundButton:SetScript("OnClick", function()
        CritLog:ShowSoundOptions()
    end)

    return f
end

-- CritLogDB can change while a panel is closed (new highscores, /cl toggles
-- from chat), so re-read everything on every OnShow rather than only when
-- a frame is first built. Both panels call this; it only touches what
-- exists (checkboxesByField spans both panels, harmless to refresh a
-- checkbox that isn't currently visible).
function CritLog:RefreshOptionsPanel()
    if frame then
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
    end

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
