-- Roster Settings panel, opened via the main panel's button. Editable copy
-- of the melee/tank/priest death-sound name rosters (CritLogDB.playerGroups,
-- migrated once from a code-only seed - see Persistence/Database.lua).
local ROSTER_ORDER = { "melee", "tank", "priest" }

local rosterFrame

-- Same lazy-grown row-widget pool as the highscore list popup: pool slot i
-- for a category always displays that category's list position i when
-- shown, so a Remove button's captured index stays valid across refreshes.
-- Unlike highscores there's no fixed cap here - a roster can have as many
-- entries as someone adds - so the pool just grows as needed instead of
-- being bounded by a MAX_* constant.
--
-- The name itself is an editable box, not static text: renames in place on
-- Enter or on losing focus (e.g. clicking elsewhere on the panel), so
-- fixing a typo or a character rename doesn't need a remove-then-re-add
-- round trip. A rejected rename (empty/duplicate) snaps the box back to
-- the stored value instead of leaving the rejected text in place - unlike
-- the Add box below, which leaves rejected text so it can be corrected,
-- there's already a known-good value here to fall back to.
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
        nameBox:SetScript("OnEditFocusLost", commitRename)

        local removeButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        removeButton:SetSize(60, 18)
        removeButton:SetText("Remove")
        removeButton:SetNormalFontObject("GameFontNormalSmall")
        removeButton:SetHighlightFontObject("GameFontHighlightSmall")
        removeButton:SetScript("OnClick", function()
            CritLog:RemoveRosterName(kind, index)
            CritLog:RefreshOptionsPanel()
        end)
        row = { nameBox = nameBox, removeButton = removeButton }
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
    local previous = f.heading

    for _, kind in ipairs(ROSTER_ORDER) do
        f.categoryHeadings[kind]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -14)
        previous = f.categoryHeadings[kind]

        local list = CritLogDB.playerGroups[kind]
        local poolSize = math.max(#list, #(f.rowPool[kind] or {}))

        for index = 1, poolSize do
            local row = getOrCreateRosterRow(f, kind, index)

            if index > #list then
                row.nameBox:Hide()
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
    local f = CritLog.UI.createPanelFrame("CritLogRosterFrame", "CritLog Roster Settings", 440, 750)
    f:SetPoint("CENTER", UIParent, "CENTER", -260, -80)

    f.heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.heading:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
    f.heading:SetText("Rosters")

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
