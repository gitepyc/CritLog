-- Optional TitanPanel status-bar button. Entirely inert when TitanPanel
-- isn't installed: CritLog:InitTitanPanelButton below is only ever called
-- from Events.lua's PLAYER_LOGIN handler, gated behind
-- IsAddOnLoaded("Titan") there. The Titan Panel API surface used here
-- (CreateFrame with "TitanPanelComboTemplate", TitanPanelButton_OnLoad/
-- OnClick, the registry table shape, Titan_Menu.* for the right-click
-- menu) is modeled directly on TitanCritLine, a separate, already-working
-- "track your crits" Titan plugin.

-- "CL: <dmg>/<white>/<heal>" next to the button's icon, matching
-- TitanCritLine's own button text format. Full detail moved to the hover
-- tooltip below. A category with no record yet shows "-" instead of a
-- number, so the button has a stable shape from the very first login.
-- Titan re-calls this function by name (see registry.buttonTextFunction
-- below) every time it wants to refresh the button, so it always
-- reflects the live CritLogDB.records state - nothing is cached here.
-- Numbers rendered white (|cffffffff...|r), "/" and "CL: " left in the
-- default inherited font color, matching TitanCritLine's own look
-- (verified against their actual code: BODY_TEXT_COLOR is literally
-- "|cffffffff", and only the %s values get wrapped in it).
function CritLogTitan_GetButtonText()
    local function top(kind)
        local entry = CritLogDB.records[kind][1]
        local value = entry and tostring(entry.amount) or "-"
        return "|cffffffff"..value.."|r"
    end

    return "CL: "..top("damage").."/"..top("whiteHit").."/"..top("heal")
end

-- Full detail line per category for the hover tooltip, sharing
-- Core/Records.lua's formatRecordTextColored with the main options panel
-- (UI/MainPanel.lua) instead of a separate color scheme kept only here.
function CritLogTitan_GetTooltipText()
    return CritLog.Records.formatRecordTextColored("damage", 1).."\n"
        ..CritLog.Records.formatRecordTextColored("whiteHit", 1).."\n"
        ..CritLog.Records.formatRecordTextColored("heal", 1)
end

-- Right-click context menu: a shortcut to the options panel, and Reset
-- All (reusing the existing CRITLOG_RESET_ALL_HIGHSCORES confirmation
-- popup from UI/MainPanel.lua rather than duplicating that logic here).
-- Titan_Menu.AddContextMenu already adds the plugin title and the
-- standard ShowIcon/ShowLabelText/Hide controls from
-- registry.controlVariables before calling this, so only the CritLog-
-- specific entries are added here.
function CritLogTitan_MenuGenerator(_, rootDescription)
    Titan_Menu.AddCommand(rootDescription, "CritLog", "Options", function()
        CritLog:ShowOptions()
    end)
    Titan_Menu.AddCommand(rootDescription, "CritLog", "Reset All Highscores", function()
        CritLog.UI.showConfirmation("CRITLOG_RESET_ALL_HIGHSCORES")
    end)
end

-- Called once from Events.lua's PLAYER_LOGIN, only after
-- IsAddOnLoaded("Titan") has already confirmed Titan Panel is present.
-- Builds the button via a plain runtime CreateFrame call inheriting
-- Titan's own "TitanPanelComboTemplate" - specifically that one, not the
-- plain TitanPanelTextTemplate, since ComboTemplate is the one with an
-- icon texture region (`$parentIcon`) in addition to the text label
-- (verified against the real Titan Panel 9.3.2 source: TitanTemplate.lua's
-- TitanPanelButton_SetButtonIcon looks up `_G[buttonName.."Icon"]`, which
-- is nil for TitanPanelTextTemplate).
function CritLog:InitTitanPanelButton()
    -- CreateFrame with an existing global name returns the *same* frame
    -- rather than creating a new one, so this guards against
    -- InitTitanPanelButton somehow running twice (e.g. two CritLog addon
    -- folders both enabled at once) triggering Titan's "already loaded"
    -- rejection.
    if _G.TitanPanelCritLogButton then
        return
    end

    local button = CreateFrame("Button", "TitanPanelCritLogButton", UIParent, "TitanPanelComboTemplate")
    button.registry = {
        -- Plain "CritLog", no "Titan" prefix/suffix on the id itself -
        -- see TitanCritLine's own TITAN_CRITLINE_ID ("CritLine", not
        -- "TitanCritLine"). The frame name above follows the matching
        -- convention instead: "TitanPanel<Name>Button".
        id = "CritLog",
        category = "Combat",
        version = self.version,
        menuText = "CritLog",
        menuContextFunction = CritLogTitan_MenuGenerator,
        buttonTextFunction = "CritLogTitan_GetButtonText",
        tooltipTitle = "CritLog Summary",
        tooltipTextFunction = "CritLogTitan_GetTooltipText",
        -- Reuses the existing Blizzard-AddOns-list icon (media/icon.png,
        -- wired up via CritLog.toc's ## IconTexture) rather than a second
        -- image asset. It's a 256x256 comic "CRIT LOG" burst; iconWidth
        -- below scales it down to a normal Titan button icon (16px).
        icon = "Interface\\AddOns\\CritLog\\media\\icon.png",
        iconWidth = 16,
        controlVariables = {
            ShowIcon = true,
            ShowLabelText = true,
        },
        savedVariables = {
            ShowIcon = true,
            ShowLabelText = true,
        },
    }

    -- No explicit TitanPanelButton_OnLoad(button) call here - verified
    -- against the real Titan Panel 9.3.2 source: "TitanPanelComboTemplate"
    -- inherits "TitanPanelButtonTemplate", which has its own baked-in
    -- <OnLoad>TitanPanelButton_OnLoad(self)</OnLoad> that already fires
    -- once, synchronously, as part of the CreateFrame call above. Calling
    -- it again queues the *same* button frame for registration twice
    -- (TitanUtils_PluginToRegister appends to a deferred queue processed
    -- later at PLAYER_ENTERING_WORLD), so Titan rejects the second attempt
    -- as "already loaded". Setting button.registry above, before Titan
    -- processes that queue, is enough - no second explicit call needed.

    -- Only the left-click "open options" shortcut is handled here; right-
    -- click is left entirely to Titan's own default OnClick handling, which
    -- reads registry.menuContextFunction above - deliberately not
    -- reimplemented here to avoid the two menus potentially firing at once.
    button:SetScript("OnClick", function(clickedButton, mouseButton)
        if mouseButton == "LeftButton" then
            CritLog:ShowOptions()
        end
        TitanPanelButton_OnClick(clickedButton, mouseButton)
    end)
end

-- Called from Persistence/Database.lua's AddRecord whenever a crit gets
-- recorded, so the button's own text (CritLogTitan_GetButtonText)
-- actually refreshes - Titan doesn't poll buttonTextFunction on its own,
-- it only re-invokes it when explicitly told to via
-- TitanPanelButton_UpdateButton. No-op if the button was never created
-- (Titan not installed), same guard InitTitanPanelButton uses.
function CritLog:RefreshTitanPanelButton()
    if _G.TitanPanelCritLogButton then
        TitanPanelButton_UpdateButton("CritLog")
    end
end
