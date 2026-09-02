-- Shared building blocks for the options panels (MainPanel/SoundPanel/
-- RosterPanel): frame construction, the Escape-key stack, and the checkbox-
-- row layout helper. Deliberately plain: only built-in Blizzard templates
-- (BasicFrameTemplateWithInset, UICheckButtonTemplate, UIPanelButtonTemplate),
-- no custom textures or third-party UI libs. Visual polish is a follow-up
-- once the layout itself is reviewed - see docs/ROADMAP.md.
CritLog.UI = {}

function CritLog.UI.anchorBelow(region, previous, yGap)
    region:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -(yGap or 6))
end

-- Plays a Constants.sounds entry directly via PlaySoundFile, bypassing
-- CritLogDB flags entirely - including MasterSoundFlag - so a preview
-- works even while sound is muted or the specific toggle is off (the whole
-- point is deciding whether to turn it on) and bypassing the real trigger
-- logic in Core/CombatLog.lua (so no highscore/state is touched).
-- Deliberately not routed through CritLog:PlaySound(): that function is the
-- mute switch's single choke point, which would otherwise make every
-- preview silently do nothing whenever MasterSoundFlag is off - exactly
-- backwards for a button whose purpose is letting you hear a sound before
-- enabling it.
function CritLog.UI.previewSound(soundKey)
    PlaySoundFile(CritLog.soundPath..CritLog.Constants.sounds[soundKey], "Master")
end

-- Clears a single highscore record (e.g. a false-positive value from some
-- other addon's damage numbers) without touching the other two, then
-- refreshes the displayed text immediately.
function CritLog.UI.createResetButton(parent, kind)
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

function CritLog.UI.createPreviewButton(parent, soundKey, width)
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
        CritLog.UI.previewSound(soundKey)
    end)
    return button
end

-- AuraSoundFlag gates seven distinct spell sounds individually
-- (Core/CombatLog.lua's HandleAuraSounds); each gets its own small preview
-- button in a compact grid instead of a full checkbox row of its own,
-- since none of them are separately toggleable.
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
            CritLog.UI.previewSound(entry.sound)
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

-- Every checkbox created by buildToggleRows across all panels, keyed by
-- CritLogDB field name - RefreshOptionsPanel below re-syncs all of them on
-- every panel OnShow, regardless of which panel actually owns a given row.
local checkboxesByField = {}

-- Shared row-building loop for every panel: a checkbox, its label, an
-- optional preview button, and a static hint line underneath (used instead
-- of a hover tooltip - GameTooltip on the checkbox didn't reliably show
-- in-game, small hit area, easy to miss). Returns the last anchor region
-- and its x-offset so the caller can keep chaining further content below.
--
-- `sound` on an entry is a key into CritLog.Constants.sounds and gets a
-- "Preview" button on that row; flags with no sound of their own get none.
-- `auraPreviews = true` renders AURA_PREVIEWS as a compact grid instead
-- (too many distinct sounds for a single row).
function CritLog.UI.buildToggleRows(parent, checkboxes, startAnchor)
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
            local previewButton = CritLog.UI.createPreviewButton(parent, entry.sound)
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

-- UISpecialFrames's native Escape behavior hides every registered frame
-- that's currently shown, all at once - fine for a single frame, wrong for
-- us with up to 3 panels open simultaneously (one Escape press would close
-- all of them instead of just the topmost). Only the most-recently-shown
-- panel's name is ever actually present in UISpecialFrames; on hide, the
-- next-most-recent one (if any) is re-registered - so Escape closes them
-- one at a time, in the order they were opened, like a normal window stack.
local escapeFrameStack = {}

local function removeFromTable(t, value)
    for i, existing in ipairs(t) do
        if existing == value then
            table.remove(t, i)
            return
        end
    end
end

local function pushEscapeFrame(name)
    removeFromTable(escapeFrameStack, name)
    if #escapeFrameStack > 0 then
        removeFromTable(UISpecialFrames, escapeFrameStack[#escapeFrameStack])
    end
    table.insert(escapeFrameStack, name)
    tinsert(UISpecialFrames, name)
end

local function popEscapeFrame(name)
    removeFromTable(escapeFrameStack, name)
    removeFromTable(UISpecialFrames, name)
    if #escapeFrameStack > 0 then
        tinsert(UISpecialFrames, escapeFrameStack[#escapeFrameStack])
    end
end

-- Every panel needs to stay above other addon UI (a WeakAuras display was
-- covering the panel before this was added) and share the same drag/close
-- behavior, so this sets up everything but the content.
function CritLog.UI.createPanelFrame(name, title, width, height)
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
        pushEscapeFrame(name)
    end)
    f:SetScript("OnHide", function()
        popEscapeFrame(name)
    end)
    f:Hide()
    return f
end

-- Panels register a refresh callback here instead of RefreshOptionsPanel
-- reaching into each panel file's own frame locals directly - keeps every
-- panel file self-contained (MainPanel.lua doesn't need to know
-- RosterPanel.lua's internals or vice versa).
local refreshCallbacks = {}

function CritLog.UI.registerRefresh(callback)
    table.insert(refreshCallbacks, callback)
end

-- CritLogDB can change while a panel is closed (new highscores, /cl toggles
-- from chat), so re-read everything on every OnShow rather than only when
-- a frame is first built. Every panel's OnShow calls this via
-- createPanelFrame above; a callback only touches what exists (its own
-- frame local may still be nil if that panel was never opened).
function CritLog:RefreshOptionsPanel()
    for _, callback in ipairs(refreshCallbacks) do
        callback()
    end

    for field, check in pairs(checkboxesByField) do
        check:SetChecked(CritLogDB[field])
    end
end
