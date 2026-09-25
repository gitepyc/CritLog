-- Sound Settings panel, opened via the main panel's button. What lives
-- here directly is just the general toggles plus buttons into
-- UI/AuraSoundPanel.lua, UI/DeathSoundPanel.lua, and
-- UI/RollSoundPanel.lua.
--
-- Split in two so the Roll Sounds button can sit directly under the
-- RollSoundFlag row instead of grouped with the Aura/Death Sounds
-- buttons at the very end.
local SOUND_CHECKBOXES_TOP = {
    { field = "SoundFlag", label = "Highscore sound (BÄM)", sound = "crit",
      hint = "Plays on a new personal highscore." },
    { field = "AllCritFlag", label = "Sound for all crits",
      hint = "Plays on every crit, not just new highscores." },
    { field = "WhiteHitFlag", label = "Sound for white hit crits",
      hint = "White-hit highscores need this; ability crits don't." },
    { field = "XtremeSoundFlag", label = "Xtreme damage sound", sound = "xtremeDamage",
      hint = "Extra sound when a hit deals over 9000 damage." },
    { field = "ReadySoundFlag", label = "Ready check sound", sound = "readyCheck",
      hint = "Plays when a ready check starts." },
    { field = "GambleSoundFlag", label = "Lottery sound", sound = "lottery",
      hint = "A CrossGambling lottery announcement in raid, party, or guild chat." },
    { field = "RollSoundFlag", label = "Roll Sounds",
      hint = "Master switch for the roll-result sounds - see the button on the side." },
}

local SOUND_CHECKBOXES_BOTTOM = {
    { field = "AuraSoundFlag", label = "Aura/spell sounds",
      hint = "Master switch for the spell sounds - see the button below." },
}

-- Raid-leader/raid-chat phrase sounds (ChatTriggers.lua's
-- CHAT_MSG_RAID_LEADER handler) - deliberately an Easter egg: no
-- CritLogDB flag at all (they always fire, gated only by
-- MasterSoundFlag) and no toggle, so previewOnly rows with no checkbox.
-- The whole section is hidden unless `/cl debug` is on - see
-- buildSoundFrame's chatPhraseFrame below.
local CHAT_PHRASE_PREVIEWS = {
    { note = "Fires when the raid leader says \"raid end\"/\"raid ende\"\nor \"wipe\"/\"shit show\" in raid chat." },
    { label = "Raid end", sound = "raidEnd", previewOnly = true },
    { label = "Wipe", sound = "wipe", previewOnly = true },
}

local soundFrame

-- The Raid Chat Phrases section (chatPhraseFrame below) only shows in
-- debug mode - the panel's own height follows that instead of always
-- reserving room for it. Fixed sizes instead of measuring real content
-- height/width at runtime: GetHeight()/GetWidth() on freshly-created
-- FontStrings/rows unreliably report 0 before the panel has ever been
-- shown.
local SOUND_FRAME_WIDTH = 460
local SOUND_FRAME_HEIGHT = 460
local SOUND_FRAME_HEIGHT_DEBUG = 550

local function buildSoundFrame()
    -- Kept wider than the other single-column panels: the Roll Sounds
    -- button below needs PREVIEW_COLUMN_X + its own 110px width + margin,
    -- more room than the standard 70px Preview button.
    local f = CritLog.UI.createPanelFrame("CritLogSoundOptionsFrame", "CritLog Sound Settings", SOUND_FRAME_WIDTH, SOUND_FRAME_HEIGHT)
    -- Offset from center so it doesn't perfectly overlap the main panel
    -- when both are open at once.
    f:SetPoint("CENTER", UIParent, "CENTER", 260, 0)
    -- Closes its own children (Aura/Death/Roll Sounds) when it closes.
    -- Death Sounds closes its own child (Roster Settings) the same way,
    -- so that closes transitively from here too.
    f:HookScript("OnHide", function()
        CritLog.UI.closeChildPanels({
            "CritLogAuraSoundFrame",
            "CritLogDeathSoundFrame",
            "CritLogRollSoundFrame",
        })
    end)

    local togglesHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    togglesHeading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    togglesHeading:SetText("Sound Toggles")

    local lastAnchor, lastOffset = CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES_TOP, togglesHeading)

    -- Sized and positioned like a Preview button - same row as the
    -- checkbox, same column - just a bit wider (110 vs. 70) since "Roll
    -- Sounds..." needs more room than "Preview" to stay readable.
    local rollSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    rollSoundsButton:SetSize(110, 20)
    rollSoundsButton:SetText("Roll Sounds...")
    rollSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    rollSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    rollSoundsButton:SetPoint("LEFT", lastAnchor, "LEFT", CritLog.UI.PREVIEW_COLUMN_X + lastOffset, 0)
    rollSoundsButton:SetScript("OnClick", function()
        CritLog:ShowRollSounds()
    end)

    lastAnchor, lastOffset = CritLog.UI.buildToggleRows(f, SOUND_CHECKBOXES_BOTTOM, lastAnchor)

    local auraSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    auraSoundsButton:SetSize(140, 24)
    auraSoundsButton:SetText("Aura Sounds...")
    auraSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    auraSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    auraSoundsButton:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", lastOffset, -12)
    auraSoundsButton:SetScript("OnClick", function()
        CritLog:ShowAuraSounds()
    end)

    local deathSoundsButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    deathSoundsButton:SetSize(140, 24)
    deathSoundsButton:SetText("Death Sounds...")
    deathSoundsButton:SetNormalFontObject("GameFontNormalSmall")
    deathSoundsButton:SetHighlightFontObject("GameFontHighlightSmall")
    deathSoundsButton:SetPoint("LEFT", auraSoundsButton, "RIGHT", 8, 0)
    deathSoundsButton:SetScript("OnClick", function()
        CritLog:ShowDeathSounds()
    end)

    -- The section lives in its own child frame (not directly on `f` like
    -- every other row) so it can be shown/hidden as one unit -
    -- CritLog.UI.registerRefresh below toggles it based on DebugFlag
    -- every time any options panel opens.
    local chatPhraseFrame = CreateFrame("Frame", nil, f)
    chatPhraseFrame:SetSize(1, 1)
    chatPhraseFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    local chatPhraseHeading = chatPhraseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- Two separate anchor points, not a single TOPLEFT relative to
    -- deathSoundsButton: that button sits well right of the panel's left
    -- margin (it's anchored off auraSoundsButton's RIGHT edge, not the
    -- panel itself), so chaining straight off it pushed this heading - and
    -- every previewOnly row's Preview button under it, 340px further right
    -- again - past the panel's right edge. TOP for vertical chaining, LEFT
    -- pinned to the panel's own standard column instead.
    chatPhraseHeading:SetPoint("TOP", deathSoundsButton, "BOTTOM", 0, -16)
    chatPhraseHeading:SetPoint("LEFT", f, "LEFT", 14, 0)
    chatPhraseHeading:SetText("Raid Chat Phrases")

    CritLog.UI.buildToggleRows(chatPhraseFrame, CHAT_PHRASE_PREVIEWS, chatPhraseHeading)

    CritLog.UI.registerRefresh(function()
        chatPhraseFrame:SetShown(CritLogDB.DebugFlag)
        f:SetHeight(CritLogDB.DebugFlag and SOUND_FRAME_HEIGHT_DEBUG or SOUND_FRAME_HEIGHT)
    end)

    CritLog.UI.createCloseButton(f)

    return f
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
