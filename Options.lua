-- First-draft options panel, opened with /cl options. Deliberately plain:
-- only built-in Blizzard templates (BasicFrameTemplateWithInset,
-- UICheckButtonTemplate), no custom textures or third-party UI libs. Visual
-- polish is a follow-up once the layout itself is reviewed - see
-- docs/REFACTORING.md step 5.

-- Label wording is lifted from Commands.lua's printHelp()/printConfig() so
-- the panel doesn't introduce new terminology for the same settings.
local CHECKBOXES = {
    { field = "SoundFlag", label = "Highscore sound (BÄM)" },
    { field = "AllCritFlag", label = "Sound for all crits" },
    { field = "WhiteHitFlag", label = "Sound for white hit crits" },
    { field = "AllLevel", label = "Ignore enemy level requirement" },
    { field = "XtremeSoundFlag", label = "Xtreme damage sound (over 9000)" },
    { field = "DebugFlag", label = "Debug mode (diagnostic chat output)" },
    { field = "ReadySoundFlag", label = "Ready check sound" },
    { field = "AuraSoundFlag", label = "Aura/spell sound" },
    { field = "PriestSoundFlag", label = "Priest death sound" },
    { field = "MeleeSoundFlag", label = "Melee death sound" },
    { field = "TankSoundFlag", label = "Tank death sound" },
    { field = "PlayerSoundFlag", label = "Player death sound" },
    { field = "BossSoundFlag", label = "Boss death sound" },
    { field = "DeadSoundFlag", label = "Death sounds (enables the five above)" },
}

-- Created lazily on first /cl options, not at load time - nothing needs the
-- frame to exist before the player asks for it.
local frame
local checkboxesByField = {}

local function anchorBelow(region, previous, yGap)
    region:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -(yGap or 6))
end

local function buildFrame()
    local f = CreateFrame("Frame", "CritLogOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(380, 600)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.TitleText:SetText("CritLog Options")

    local highscoresHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    highscoresHeading:SetPoint("TOPLEFT", f.Inset, "TOPLEFT", 10, -10)
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
    for _, entry in ipairs(CHECKBOXES) do
        local check = CreateFrame("CheckButton", "CritLogOptions"..entry.field, f, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
        -- Hook rather than replace OnClick, so the template's default click
        -- sound still plays; GetChecked() returns 1/nil on some clients, so
        -- normalize to a real boolean before writing it back to the DB.
        check:HookScript("OnClick", function(self)
            CritLogDB[entry.field] = self:GetChecked() and true or false
        end)
        checkboxesByField[entry.field] = check

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", check, "RIGHT", 2, 1)
        label:SetText(entry.label)

        previous = check
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
