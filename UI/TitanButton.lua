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
        -- Not "CritLog" - kept from an earlier fix attempt at renaming the
        -- id away from a suspected (and, it turned out, wrong) stale-
        -- SavedVariables theory; the real "already loaded" cause was a
        -- genuine double registration, now fixed below (see the comment
        -- above the removed TitanPanelButton_OnLoad(button) call). No
        -- reason to rename it back, "CritLogTitan" works fine. Display
        -- strings (menuText, tooltipTitle, menu labels below) still say
        -- "CritLog" - only the internal registry key differs.
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

    -- No explicit TitanPanelButton_OnLoad(button) call here - verified
    -- against the real Titan Panel 9.3.2 source
    -- (Titan/TitanTemplate.xml): "TitanPanelTextTemplate" inherits
    -- "TitanPanelButtonTemplate", which has its own baked-in
    -- <OnLoad>TitanPanelButton_OnLoad(self)</OnLoad> - it already fires
    -- once, synchronously, as part of the CreateFrame call above. Calling
    -- it again here queued the *same* button frame for registration twice
    -- (TitanUtils_PluginToRegister just appends to a deferred queue
    -- processed later at PLAYER_ENTERING_WORLD - see TitanUtils.lua's
    -- TitanUtils_RegisterPluginList/TitanUtils_RegisterPluginProtected),
    -- so Titan tried to register the same id twice and rejected the
    -- second attempt as "already loaded" - in-game reported, reproduced
    -- even with a brand new id and a confirmed-fresh client restart,
    -- which ruled out stale SavedVariables or a duplicate addon folder.
    -- Setting button.registry above, before Titan actually processes the
    -- queue at PLAYER_ENTERING_WORLD (later than PLAYER_LOGIN, where this
    -- whole function runs), is enough - no second explicit call needed.

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
