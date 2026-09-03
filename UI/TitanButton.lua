-- Optional TitanPanel status-bar button (docs/ROADMAP.md item 3). Entirely
-- inert when TitanPanel isn't installed: CritLog:InitTitanPanelButton below
-- is only ever called from Events.lua's PLAYER_LOGIN handler, gated behind
-- IsAddOnLoaded("Titan") there - nothing in this file runs, and no frame is
-- created, if Titan isn't present. `## OptionalDeps: Titan` in CritLog.toc
-- just makes sure Titan's own API exists first at load time if both addons
-- are installed; it doesn't make Titan a hard requirement.
--
-- Not in-game verified - nobody working on this repo has a WoW client
-- available (see README.md's "Known technical issues and risks"). The Titan
-- Panel API surface used here (CreateFrame with "TitanPanelTextTemplate",
-- TitanPanelButton_OnLoad/OnClick, the registry table shape, Titan_Menu.*
-- for the right-click menu) is modeled directly on TitanCritLine, a
-- separate, already-working "track your crits" Titan plugin - not guessed.

-- Compact "D:<dmg> W:<white> H:<heal>" line shown next to the button's icon
-- (the ROADMAP-promised "top score for damage/white-hit/heal"). A category
-- with no record yet shows "-" instead of a number, so the button has a
-- stable shape from the very first login instead of growing/shrinking as
-- categories fill in. Titan re-calls this function by name (see
-- registry.buttonTextFunction below) every time it wants to refresh the
-- button, so it always reflects the live CritLogDB.records state - nothing
-- is cached here.
function CritLogTitan_GetButtonText()
    local function top(kind)
        local entry = CritLogDB.records[kind][1]
        return entry and tostring(entry.amount) or "-"
    end

    return "D:"..top("damage").." W:"..top("whiteHit").." H:"..top("heal")
end

-- Full detail line per category for the hover tooltip, reusing
-- Core/Records.lua's formatRecordText so the wording matches the options
-- panel and /cl chat output exactly instead of a third copy of the format.
function CritLogTitan_GetTooltipText()
    return CritLog.Records.formatRecordText("damage", 1).."\n"
        ..CritLog.Records.formatRecordText("whiteHit", 1).."\n"
        ..CritLog.Records.formatRecordText("heal", 1)
end

-- Right-click context menu. The roadmap only ever said "contents TBD" for
-- this, so it's kept deliberately small: a shortcut to the options panel,
-- and Reset All (reusing the existing CRITLOG_RESET_ALL_HIGHSCORES
-- confirmation popup from UI/MainPanel.lua rather than duplicating that
-- logic here). Titan_Menu.AddContextMenu already adds the plugin title and
-- the standard ShowIcon/ShowLabelText/Hide controls from
-- registry.controlVariables before calling this, so only the CritLog-
-- specific entries are added here - same split TitanCritLine uses.
function CritLogTitan_MenuGenerator(_, rootDescription)
    Titan_Menu.AddCommand(rootDescription, "CritLog", "Options", function()
        CritLog:ShowOptions()
    end)
    Titan_Menu.AddCommand(rootDescription, "CritLog", "Reset All Highscores", function()
        StaticPopup_Show("CRITLOG_RESET_ALL_HIGHSCORES")
    end)
end

-- Called once from Events.lua's PLAYER_LOGIN, only after IsAddOnLoaded("Titan")
-- has already confirmed Titan Panel is present - see Events.lua. Builds the
-- button via a plain runtime CreateFrame call (no XML anywhere in CritLog,
-- see README.md's repository layout) inheriting Titan's own
-- "TitanPanelTextTemplate", the same template/registry shape TitanCritLine's
-- XML-based button ultimately produces.
function CritLog:InitTitanPanelButton()
    -- In-game reported: Titan rejected registration with "Plugin 'CritLog'
    -- already loaded" - this fires if InitTitanPanelButton somehow runs
    -- twice (e.g. two CritLog addon folders both enabled at once, a common
    -- mistake when a new test-build zip gets extracted into a new folder
    -- instead of overwriting the old one - both would independently reach
    -- PLAYER_LOGIN and both try to register the same Titan plugin id).
    -- CreateFrame with an existing global name returns the *same* frame
    -- rather than creating a new one, so this check is enough to make a
    -- second call a no-op regardless of why it happened.
    if _G.CritLogTitanPanelButton then
        return
    end

    local button = CreateFrame("Button", "CritLogTitanPanelButton", UIParent, "TitanPanelTextTemplate")
    button.registry = {
        -- Not "CritLog" - in-game reported: Titan kept rejecting
        -- registration with "Plugin 'CritLog' already loaded" even on a
        -- freshly reloaded client with a single, guarded registration call
        -- (see InitTitanPanelButton's guard above and CHANGELOG.md) -
        -- likely a stale/corrupted entry in Titan's own SavedVariables
        -- left over from the earlier (pre-guard) double-registration bug,
        -- which a code fix alone can't clean up. A different id sidesteps
        -- whatever's stuck under the old one entirely, no need to touch
        -- Titan's SavedVariables by hand. Display strings (menuText,
        -- tooltipTitle, menu labels below) still say "CritLog" - only the
        -- internal registry key changed.
        id = "CritLogTitan",
        category = "Combat",
        version = self.version,
        menuText = "CritLog",
        menuContextFunction = CritLogTitan_MenuGenerator,
        buttonTextFunction = "CritLogTitan_GetButtonText",
        tooltipTitle = "CritLog",
        tooltipTextFunction = "CritLogTitan_GetTooltipText",
        -- Reuses the existing Blizzard-AddOns-list icon (media/icon.png,
        -- wired up via CritLog.toc's ## IconTexture) rather than a second
        -- image asset. It's a 256x256 comic "CRIT LOG" burst; iconWidth
        -- below scales it down to a normal Titan button icon (16px), but
        -- that scaling hasn't been in-game confirmed to still read clearly
        -- at that size - see docs/ROADMAP.md.
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

    TitanPanelButton_OnLoad(button)

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
