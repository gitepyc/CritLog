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

-- Every checkbox created by buildToggleRows across all panels, keyed by
-- CritLogDB field name - RefreshOptionsPanel below re-syncs all of them on
-- every panel OnShow, regardless of which panel actually owns a given row.
local checkboxesByField = {}

-- Same idea as checkboxesByField, for buildToggleRows' dropdown rows
-- (entries with `options` instead of a plain boolean flag).
local dropdownsByField = {}

local function createDropdownRow(parent, entry, previous, previousXOffset)
    -- UIDropDownMenuTemplate's clickable texture extends ~16px left of the
    -- frame's own left edge, so this is nudged left to keep the control
    -- itself visually lined up with the checkboxes in the rows above/below
    -- it - approximate, not pixel-verified in-game yet.
    local dropdown = CreateFrame("Frame", "CritLogOptions"..entry.field, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset - 16, -4)
    UIDropDownMenu_SetWidth(dropdown, 110)

    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, option in ipairs(entry.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = option.value
            info.checked = (CritLogDB[entry.field] == option.value)
            info.func = function()
                CritLogDB[entry.field] = option.value
                UIDropDownMenu_SetText(dropdown, option.label)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    dropdownsByField[entry.field] = dropdown

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", dropdown, "RIGHT", -8, 2)
    label:SetText(entry.label)

    if entry.sound then
        local previewButton = CritLog.UI.createPreviewButton(parent, entry.sound)
        previewButton:SetPoint("LEFT", dropdown, "LEFT", 340 - 16, 0)
    end

    local hint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 20, -2)
    hint:SetText(entry.hint)

    return hint
end

-- Shared row-building loop for every panel: a checkbox (or, for an entry
-- with `options`, a dropdown - see createDropdownRow above), its label, an
-- optional preview button, and a static hint line underneath (used instead
-- of a hover tooltip - GameTooltip on the checkbox didn't reliably show
-- in-game, small hit area, easy to miss). Returns the last anchor region
-- and its x-offset so the caller can keep chaining further content below.
--
-- `sound` on an entry is a key into CritLog.Constants.sounds and gets a
-- "Preview" button on that row; flags with no sound of their own get none.
function CritLog.UI.buildToggleRows(parent, checkboxes, startAnchor)
    local previous = startAnchor
    -- 0 for the first row: startAnchor (a section heading) has no x-indent
    -- quirk to cancel. Every row after that anchors to the PREVIOUS row's
    -- hint line, which sits +4px right of its own checkbox - so from the
    -- second row on this needs to be -4, or each row would drift 4px
    -- further right than the last (a growing staircase, not a one-time
    -- shift).
    local previousXOffset = 0

    for _, entry in ipairs(checkboxes) do
        if entry.options then
            previous = createDropdownRow(parent, entry, previous, previousXOffset)
            previousXOffset = -4
        else
            local check = CreateFrame("CheckButton", "CritLogOptions"..entry.field, parent, "UICheckButtonTemplate")
            check:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset, -4)
            -- Hook rather than replace OnClick, so the template's default
            -- click sound still plays; GetChecked() returns 1/nil on some
            -- clients, so normalize to a real boolean before writing it
            -- back to the DB.
            check:HookScript("OnClick", function(self)
                CritLogDB[entry.field] = self:GetChecked() and true or false
            end)
            checkboxesByField[entry.field] = check

            local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", check, "RIGHT", 2, 1)
            label:SetText(entry.label)

            if entry.sound then
                -- Anchored to a fixed offset from the checkbox itself
                -- rather than to the label, so button position doesn't
                -- depend on how long a given label happens to be.
                local previewButton = CritLog.UI.createPreviewButton(parent, entry.sound)
                previewButton:SetPoint("LEFT", check, "LEFT", 340, 0)
            end

            local hint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            hint:SetPoint("TOPLEFT", check, "BOTTOMLEFT", 4, -2)
            hint:SetText(entry.hint)

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

-- The one name we've actually put in UISpecialFrames right now, or nil.
-- Tracked explicitly instead of inferred from the stack: an earlier version
-- assumed "whatever I just popped was the one occupying UISpecialFrames",
-- which is only true if panels are always closed in reverse-open order.
-- Closing a non-topmost panel (e.g. panel A opened, then B, then A is
-- closed directly via its own close button while B is still open) broke
-- that assumption - the pop re-added the new stack top on top of an entry
-- that was never actually removed, leaving a duplicate. Over a few
-- out-of-order closes those duplicates piled up until every panel's name
-- was permanently stuck in UISpecialFrames regardless of what was actually
-- open - exactly the in-game report ("always all entries, even with just
-- one window open"). Explicitly removing whatever `registeredFrame`
-- currently is - not whatever was just popped - fixes that regardless of
-- close order.
local registeredFrame

local function removeFromTable(t, value)
    for i, existing in ipairs(t) do
        if existing == value then
            table.remove(t, i)
            return
        end
    end
end

local function setRegisteredFrame(name)
    if registeredFrame then
        removeFromTable(UISpecialFrames, registeredFrame)
    end
    registeredFrame = name
    if registeredFrame then
        tinsert(UISpecialFrames, registeredFrame)
    end
end

local function pushEscapeFrame(name)
    removeFromTable(escapeFrameStack, name)
    table.insert(escapeFrameStack, name)
    setRegisteredFrame(name)
end

local function popEscapeFrame(name)
    removeFromTable(escapeFrameStack, name)
    setRegisteredFrame(escapeFrameStack[#escapeFrameStack])
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

    -- All current dropdown rows share the same detectionModes option set
    -- (see Core/Constants.lua) - fine to assume here since it's the only
    -- one in use; would need a per-field option list if that changes.
    for field, dropdown in pairs(dropdownsByField) do
        for _, option in ipairs(CritLog.Constants.detectionModes) do
            if option.value == CritLogDB[field] then
                UIDropDownMenu_SetText(dropdown, option.label)
                break
            end
        end
    end
end
