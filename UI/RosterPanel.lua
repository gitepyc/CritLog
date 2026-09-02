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
local function getOrCreateRosterRow(f, kind, index)
    f.rowPool[kind] = f.rowPool[kind] or {}
    local row = f.rowPool[kind][index]
    if not row then
        local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local removeButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        removeButton:SetSize(60, 18)
        removeButton:SetText("Remove")
        removeButton:SetNormalFontObject("GameFontNormalSmall")
        removeButton:SetHighlightFontObject("GameFontHighlightSmall")
        removeButton:SetScript("OnClick", function()
            CritLog:RemoveRosterName(kind, index)
            CritLog:RefreshOptionsPanel()
        end)
        row = { text = text, removeButton = removeButton }
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
                row.text:Hide()
                row.removeButton:Hide()
            else
                row.text:SetText(list[index])
                row.text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
                row.text:Show()
                row.removeButton:SetPoint("TOP", row.text, "TOP", 0, 0)
                row.removeButton:SetPoint("RIGHT", f, "RIGHT", -14, 0)
                row.removeButton:Show()
                previous = row.text
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
