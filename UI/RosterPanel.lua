-- Roster Settings panel, opened via the Death Sounds panel's button (moved
-- there from the main panel - see CHANGELOG.md). Editable copy
-- of the melee/tank/heal death-sound name rosters (CritLogDB.playerGroups,
-- migrated once from a code-only seed - see Persistence/Database.lua).
local ROSTER_ORDER = { "melee", "tank", "heal" }

local rosterFrame

-- Same lazy-grown row-widget pool as the highscore list popup: pool slot i
-- for a category always displays that category's list position i when
-- shown, so a Remove button's captured index stays valid across refreshes.
-- Unlike highscores there's no fixed cap here - a roster can have as many
-- entries as someone adds - so the pool just grows as needed instead of
-- being bounded by a MAX_* constant.
--
-- The name itself is an editable box, not static text: renames in place
-- instead of a remove-then-re-add round trip. Deliberately NOT saved on
-- every focus loss (an earlier version did that, but clicking elsewhere on
-- the panel - e.g. a different row's Remove button - counts as focus loss
-- too, so it could commit a half-finished edit by accident) - a rename only
-- takes effect on Enter or the OK button, same as the Add box's explicit
-- Add button. A rejected rename (empty/duplicate) snaps the box back to
-- the stored value instead of leaving the rejected text in place - unlike
-- the Add box, which leaves rejected text so it can be corrected, there's
-- already a known-good value here to fall back to. Reset does the same
-- snap-back but as an explicit action, for discarding an in-progress edit
-- without committing anything first.
local function getOrCreateRosterRow(f, kind, index)
    f.rowPool[kind] = f.rowPool[kind] or {}
    local row = f.rowPool[kind][index]
    if not row then
        local nameBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        nameBox:SetSize(190, 20)
        nameBox:SetAutoFocus(false)
        nameBox:SetMaxLetters(30)

        local function commitRename()
            if not CritLog:RenameRosterName(kind, index, nameBox:GetText()) then
                nameBox:SetText(CritLogDB.playerGroups[kind][index] or "")
            end
            nameBox:ClearFocus()
            CritLog:RefreshOptionsPanel()
        end

        nameBox:SetScript("OnEnterPressed", commitRename)

        -- Plain "OK" rather than a Unicode checkmark glyph: Classic Era's
        -- bundled fonts aren't guaranteed to have that glyph, risking a
        -- tofu box with no way to verify short of testing in-game.
        local confirmButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        confirmButton:SetSize(32, 18)
        confirmButton:SetText("OK")
        confirmButton:SetNormalFontObject("GameFontNormalSmall")
        confirmButton:SetHighlightFontObject("GameFontHighlightSmall")
        confirmButton:SetScript("OnClick", commitRename)

        -- Discards whatever's currently typed and puts the stored value
        -- back, without touching CritLogDB - a pure "undo my edit" action,
        -- distinct from the auto snap-back a rejected OK does.
        local resetButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        resetButton:SetSize(50, 18)
        resetButton:SetText("Reset")
        resetButton:SetNormalFontObject("GameFontNormalSmall")
        resetButton:SetHighlightFontObject("GameFontHighlightSmall")
        resetButton:SetScript("OnClick", function()
            nameBox:SetText(CritLogDB.playerGroups[kind][index] or "")
            nameBox:ClearFocus()
        end)

        local removeButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        removeButton:SetSize(60, 18)
        removeButton:SetText("Remove")
        removeButton:SetNormalFontObject("GameFontNormalSmall")
        removeButton:SetHighlightFontObject("GameFontHighlightSmall")
        removeButton:SetScript("OnClick", function()
            CritLog:RemoveRosterName(kind, index)
            CritLog:RefreshOptionsPanel()
        end)
        row = {
            nameBox = nameBox,
            confirmButton = confirmButton,
            resetButton = resetButton,
            removeButton = removeButton,
        }
        f.rowPool[kind][index] = row
    end
    return row
end

-- Text input + Add button for appending a name to one roster category.
-- Enter in the box and clicking the button both go through the same
-- add-and-clear logic; CritLog:AddRosterName() already rejects empty or
-- duplicate names, so a rejected add just leaves the typed text in place
-- instead of silently clearing it.
local function createRosterAddRow(f, kind)
    local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    editBox:SetSize(190, 20)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(30)

    local function tryAdd()
        if CritLog:AddRosterName(kind, editBox:GetText()) then
            editBox:SetText("")
            CritLog:RefreshOptionsPanel()
        end
        editBox:ClearFocus()
    end

    editBox:SetScript("OnEnterPressed", tryAdd)

    local addButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    addButton:SetSize(50, 20)
    addButton:SetText("Add")
    addButton:SetNormalFontObject("GameFontNormalSmall")
    addButton:SetHighlightFontObject("GameFontHighlightSmall")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 8, 0)
    addButton:SetScript("OnClick", tryAdd)

    return editBox
end

-- Lays out every row fresh on each call, same reasoning as the highscore
-- list: cheap (a roster this addon realistically deals with is a couple
-- dozen names at most), and avoids incrementally patching anchors when a
-- category's entry count changes between refreshes.
local function layoutRosterList(f)
    local previous = f.behaviorNote

    for _, kind in ipairs(ROSTER_ORDER) do
        f.categoryHeadings[kind]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -14)
        previous = f.categoryHeadings[kind]

        local list = CritLogDB.playerGroups[kind]
        local poolSize = math.max(#list, #(f.rowPool[kind] or {}))

        for index = 1, poolSize do
            local row = getOrCreateRosterRow(f, kind, index)

            if index > #list then
                row.nameBox:Hide()
                row.confirmButton:Hide()
                row.resetButton:Hide()
                row.removeButton:Hide()
            else
                -- Skip overwriting the text if this box is mid-edit: a
                -- refresh can happen while it still has focus (e.g. a
                -- different row's Remove button was just clicked), and
                -- clobbering the in-progress text here would silently
                -- discard whatever the user was typing.
                if not row.nameBox:HasFocus() then
                    row.nameBox:SetText(list[index])
                end
                row.nameBox:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
                row.nameBox:Show()
                -- OK and Reset sit directly beside the input box (the
                -- actions that act on what's currently typed); Remove stays
                -- pinned to the panel's right edge, same as every other
                -- Remove button in this panel.
                row.confirmButton:SetPoint("TOPLEFT", row.nameBox, "TOPRIGHT", 6, 0)
                row.confirmButton:Show()
                row.resetButton:SetPoint("TOPLEFT", row.confirmButton, "TOPRIGHT", 6, 0)
                row.resetButton:Show()
                row.removeButton:SetPoint("TOP", row.nameBox, "TOP", 0, 0)
                row.removeButton:SetPoint("RIGHT", f, "RIGHT", -14, 0)
                row.removeButton:Show()
                previous = row.nameBox
            end
        end

        f.addEditBoxes[kind]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
        previous = f.addEditBoxes[kind]
    end
end

-- Sized generously tall since a roster has no fixed entry cap, unlike the
-- highscore list popup.
local function buildRosterFrame()
    local f = CritLog.UI.createPanelFrame("CritLogRosterFrame", "CritLog Roster Settings", 440, 775)
    f:SetPoint("CENTER", UIParent, "CENTER", -260, -80)

    f.heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    f.heading:SetText("Rosters")

    -- In-game requested: explain the save behavior somewhere on this
    -- panel, since it's not the same for every action here. Add/Remove
    -- write to CritLogDB.playerGroups immediately, no confirmation - see
    -- CritLog:AddRosterName/RemoveRosterName in Persistence/Database.lua.
    -- A rename is the one exception: typing (or clicking away, which just
    -- loses focus) does not save by itself - only Enter or OK commits it,
    -- and Reset explicitly discards it - see commitRename above. A
    -- separate field, not reusing f.heading for the anchor chain below -
    -- f.heading is the panel title, keep it that way for anyone reading
    -- this later.
    f.behaviorNote = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.behaviorNote:SetPoint("TOPLEFT", f.heading, "BOTTOMLEFT", 0, -6)
    f.behaviorNote:SetWidth(400)
    f.behaviorNote:SetJustifyH("LEFT")
    f.behaviorNote:SetText(
        "Add and Remove take effect immediately, no confirmation. "..
        "Renaming only saves on Enter or OK - Reset discards an "..
        "in-progress edit instead."
    )

    f.categoryHeadings = {}
    f.rowPool = {}
    f.addEditBoxes = {}

    for _, kind in ipairs(ROSTER_ORDER) do
        local categoryHeading = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        categoryHeading:SetText(CritLog.Constants.rosterKinds[kind].label)
        f.categoryHeadings[kind] = categoryHeading

        f.addEditBoxes[kind] = createRosterAddRow(f, kind)
    end

    layoutRosterList(f)

    CritLog.UI.createCloseButton(f)

    return f
end

CritLog.UI.registerRefresh(function()
    if rosterFrame then
        layoutRosterList(rosterFrame)
    end
end)

function CritLog:ShowRoster()
    if not rosterFrame then
        rosterFrame = buildRosterFrame()
    end

    if rosterFrame:IsShown() then
        rosterFrame:Hide()
    else
        rosterFrame:Show()
    end
end
