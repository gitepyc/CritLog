-- Roll Sounds panel, opened via the "Roll Sounds..." button under the
-- RollSoundFlag row on the Sound Settings panel. RollSoundFlag stays on
-- Sound Settings (it's the master switch for everything here) - see the
-- note row below instead.
--
-- All 6 roll sounds share that one master switch - `previewOnly` rows
-- (see UI/Shared.lua's buildToggleRows) instead of checkboxes, since
-- there's nothing per-sound to toggle. See Core/Filters.lua's
-- classifyRoll for the exact result/band each one fires on.
local ROLL_CHECKBOXES = {
    { note = "Requires \"Roll Sounds\" enabled on the Sound Settings panel." },
    { label = "Roll 1 (exact)", sound = "roll1", previewOnly = true },
    { label = "Low roll (<8%)", sound = "roll5", previewOnly = true },
    { label = "Low roll (8-12%)", sound = "roll10", previewOnly = true },
    { label = "Roll 69 (exact)", sound = "roll69", previewOnly = true },
    { label = "High roll (>=92%)", sound = "roll95", previewOnly = true },
    { label = "Max roll (exact)", sound = "roll100", previewOnly = true },
}

local rollSoundFrame

local function buildRollSoundFrame()
    local f = CritLog.UI.createPanelFrame("CritLogRollSoundFrame", "CritLog Roll Sounds", 420, 260)
    -- Offset from center so it doesn't perfectly overlap the main panel or
    -- Sound Settings when several are open at once.
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 60)

    local heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    heading:SetText("Roll Sounds")

    CritLog.UI.buildToggleRows(f, ROLL_CHECKBOXES, heading)

    CritLog.UI.createCloseButton(f)

    return f
end

function CritLog:ShowRollSounds()
    if not rollSoundFrame then
        rollSoundFrame = buildRollSoundFrame()
    end

    if rollSoundFrame:IsShown() then
        rollSoundFrame:Hide()
    else
        rollSoundFrame:Show()
    end
end
