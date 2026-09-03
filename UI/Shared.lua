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
-- refreshes the displayed text immediately. `label` defaults to "Reset";
-- the main panel's three rows all use "Reset all" instead - wording only,
-- each one still just clears its own `kind`, not the other two.
function CritLog.UI.createResetButton(parent, kind, label)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(60, 18)
    button:SetText(label or "Reset")
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetScript("OnClick", function()
        CritLog:ResetRecord(kind)
        CritLog:RefreshOptionsPanel()
    end)
    return button
end

-- Bottom-center "Close" button - the built-in corner X and Escape (via
-- createPanelFrame's escape-stack registration) already close every
-- panel, but a corner X alone wasn't obvious enough (in-game reported for
-- the Help panel); added here as a shared helper so the Highscore List
-- and Roster Settings popups get the same, not just Help.
function CritLog.UI.createCloseButton(parent)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(90, 22)
    button:SetText("Close")
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetPoint("BOTTOM", parent, "BOTTOM", 0, 14)
    button:SetScript("OnClick", function()
        parent:Hide()
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

-- Shows `text` in GameTooltip while the mouse is over `control` - shared by
-- checkbox and dropdown rows below, replacing the static hint line that
-- used to sit underneath every row (see CHANGELOG.md,
-- feature/toggle-row-tooltips). An earlier attempt at this apparently
-- didn't show reliably in-game because the checkbox's own hit area is tiny
-- and easy to miss with the mouse - see the SetHitRectInsets calls at each
-- call site, which grow the hit area out to cover the row's label too so
-- hovering the text works, not just the control itself.
--
-- In-game reported: the tooltip never appeared at all (not just hard to
-- trigger). Root cause: every options panel deliberately sits on
-- "TOOLTIP" frame strata (see createPanelFrame below, added so panels
-- stay above other addons like WeakAuras) - the same strata GameTooltip
-- itself defaults to. Our own panel is `SetToplevel(true)` and gets
-- raised by normal interaction (dragging, clicking buttons), so within
-- that shared strata it can end up with a higher frame level than
-- GameTooltip's own default one and render on top of it, hiding the
-- tooltip completely behind the panel's opaque background. Explicitly
-- bumping GameTooltip's strata/level above the hovered control every time
-- it's shown fixes that regardless of whatever level the panel happens to
-- be at.
local function attachTooltip(control, text)
    if not text then
        return
    end

    control:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:SetFrameLevel(self:GetFrameLevel() + 10)
        GameTooltip:SetText(text, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    control:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function createDropdownRow(parent, entry, previous, previousXOffset)
    -- UIDropDownMenuTemplate's clickable texture extends ~16px left of the
    -- frame's own left edge, so this is nudged left to keep the control
    -- itself visually lined up with the checkboxes in the rows above/below
    -- it - approximate, not pixel-verified in-game yet.
    local dropdown = CreateFrame("Frame", "CritLogOptions"..entry.field, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset - 16, -8)
    UIDropDownMenu_SetWidth(dropdown, 110)

    -- Reported in-game: clicking the dropdown showed no menu at all. The
    -- options panels use "TOOLTIP" strata (the highest there is - see
    -- createPanelFrame below) so they stay above other addons' windows,
    -- but Blizzard's shared dropdown-list frames (DropDownList1/2) are
    -- created at a lower fixed strata - the menu was very likely opening
    -- behind our own panel, not failing to open at all. Bumping the list
    -- frames to match right when this dropdown's button is clicked fixes
    -- that without affecting anything else that uses dropdowns.
    local dropdownButton = _G[dropdown:GetName().."Button"]
    if dropdownButton then
        dropdownButton:HookScript("OnClick", function()
            if DropDownList1 then
                DropDownList1:SetFrameStrata("TOOLTIP")
            end
            if DropDownList2 then
                DropDownList2:SetFrameStrata("TOOLTIP")
            end
        end)
    end

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
        -- 340 relative to the checkbox rows' own baseline, same column as
        -- their Preview buttons - but this dropdown sits 16px left of that
        -- baseline (see the -16 nudge above), so +16 on top of 340 lands
        -- back in the same column instead of 16px short of it. Labels here
        -- are kept close in length to each other (see the DPS/"Damage
        -- Dealer" comment in UI/SoundPanel.lua) specifically so this fixed
        -- column doesn't run into any of them - it did once, when one
        -- label was much longer than the rest (in-game
        -- reported/screenshotted, fixed by shortening the label instead of
        -- abandoning the shared column).
        local previewButton = CritLog.UI.createPreviewButton(parent, entry.sound)
        previewButton:SetPoint("LEFT", dropdown, "LEFT", 340 + 16, 0)
    end

    attachTooltip(dropdown, entry.hint)
    -- SetHitRectInsets(left, right, top, bottom) - a negative value grows
    -- the hit area outward instead of shrinking it, so this extends the
    -- dropdown's hit rect rightward to cover its own label too. A fixed
    -- value, not label:GetStringWidth() - these rows are built while the
    -- panel is still hidden (see "Created lazily" comments on each panel),
    -- and a FontString that's never been drawn yet reliably reports a
    -- width of 0, which silently shrank this back down to a few px past
    -- the dropdown itself (in-game reported: tooltip never appeared at
    -- all). 340 matches the fixed Preview-button column used everywhere
    -- else in this file, comfortably past every label in use. Same fix
    -- TitanCritLine's settings panel uses (a flat XML HitRectInsets, not
    -- a computed one).
    dropdown:SetHitRectInsets(0, -340, 0, 0)

    return dropdown
end

-- Shared row-building loop for every panel: a checkbox (or, for an entry
-- with `options`, a dropdown - see createDropdownRow above), its label, an
-- optional preview button, and a `entry.hint` shown as a hover tooltip via
-- attachTooltip above instead of a static line underneath the row (see
-- CHANGELOG.md, feature/toggle-row-tooltips). Returns the last anchor
-- region and its x-offset so the caller can keep chaining further content
-- below.
--
-- `sound` on an entry is a key into CritLog.Constants.sounds and gets a
-- "Preview" button on that row; flags with no sound of their own get none.
-- `indent = true` renders a smaller, indented sub-row instead of a
-- full-size one - for a set of toggles that belong under one master
-- switch (e.g. the 7 aura sounds under AuraSoundFlag) and should visually
-- read as a subordinate category, not as 7 more peers of the master row.
-- `note` renders a plain text row instead of a checkbox/dropdown - see
-- createDropdownRow's sibling branch below.
function CritLog.UI.buildToggleRows(parent, checkboxes, startAnchor)
    local previous = startAnchor
    -- 0 for the first row: startAnchor (a section heading) has no x-indent
    -- quirk to cancel. Every row after that anchors directly to the
    -- PREVIOUS row's own control (checkbox/dropdown), not to a hint line
    -- underneath it anymore - so there's no fixed per-row drift to cancel
    -- out here. `indent` rows add a further, one-time +20 on top of that
    -- for themselves, then subtract the same +20 back out of what they
    -- hand to the next row - so indentation doesn't compound across
    -- consecutive indented rows, and a normal row right after an indented
    -- block lands back at the same column as if the indent never happened.
    local previousXOffset = 0

    for _, entry in ipairs(checkboxes) do
        if entry.note then
            -- A plain text row, no checkbox/dropdown control - for
            -- explaining something that applies to several rows below it
            -- (e.g. the detection-mode meanings, which apply to all four
            -- mode dropdowns, not just the first one) without tying it to
            -- one specific toggle's hint line.
            local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            note:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset, -8)
            note:SetJustifyH("LEFT")
            note:SetText(entry.note)
            previous = note
            previousXOffset = 0
        elseif entry.options then
            previous = createDropdownRow(parent, entry, previous, previousXOffset)
            -- Cancels the -16 nudge createDropdownRow applies to the
            -- dropdown itself, so a row anchored below it lands back in the
            -- normal checkbox column instead of drifting 16px left.
            previousXOffset = 16
        else
            local indent = entry.indent and 20 or 0
            local checkSize = entry.indent and 20 or 26
            local labelFont = entry.indent and "GameFontHighlightSmall" or "GameFontHighlight"

            local check = CreateFrame("CheckButton", "CritLogOptions"..entry.field, parent, "UICheckButtonTemplate")
            check:SetSize(checkSize, checkSize)
            check:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", previousXOffset + indent, -10)
            -- Hook rather than replace OnClick, so the template's default
            -- click sound still plays; GetChecked() returns 1/nil on some
            -- clients, so normalize to a real boolean before writing it
            -- back to the DB.
            check:HookScript("OnClick", function(self)
                CritLogDB[entry.field] = self:GetChecked() and true or false
            end)
            checkboxesByField[entry.field] = check

            local label = parent:CreateFontString(nil, "OVERLAY", labelFont)
            label:SetPoint("LEFT", check, "RIGHT", 2, 1)
            label:SetText(entry.label)

            if entry.sound then
                -- Anchored to a fixed offset from the checkbox itself
                -- rather than to the label, so button position doesn't
                -- depend on how long a given label happens to be.
                local previewButton = CritLog.UI.createPreviewButton(parent, entry.sound)
                previewButton:SetPoint("LEFT", check, "LEFT", 340 - indent, 0)
            end

            attachTooltip(check, entry.hint)
            -- SetHitRectInsets(left, right, top, bottom) - a negative value
            -- grows the hit area outward instead of shrinking it, so this
            -- extends the checkbox's hit rect rightward to cover its own
            -- label too (fixes the "small hit area, easy to miss" problem
            -- an earlier tooltip attempt apparently ran into - see
            -- attachTooltip's comment above). A fixed value, not
            -- label:GetStringWidth() - see createDropdownRow's identical
            -- comment above for why a computed width silently broke this
            -- entirely (checkboxes are built while the panel is still
            -- hidden, so the label's width reads as 0 at this point).
            check:SetHitRectInsets(0, -340, 0, 0)

            previous = check
            previousXOffset = -indent
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
