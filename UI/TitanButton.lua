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
-- Panel API surface used here (CreateFrame with "TitanPanelComboTemplate",
-- TitanPanelButton_OnLoad/OnClick, the registry table shape, Titan_Menu.*
-- for the right-click menu) is modeled directly on TitanCritLine, a
-- separate, already-working "track your crits" Titan plugin - not guessed.

-- "CL: <dmg>/<white>/<heal>" next to the button's icon - matches
-- TitanCritLine's own button text exactly (TITAN_CRITLINE_BUTTON_LABEL
-- "CL: " + TITAN_CRITLINE_BUTTON_TEXT "%s/%s/%s"), in-game requested
-- specifically instead of the longer "D:/W:/H:" first draft. Full detail
-- moved to the hover tooltip below - this is just the at-a-glance number.
-- A category with no record yet shows "-" instead of a number, so the
-- button has a stable shape from the very first login instead of
-- growing/shrinking as categories fill in. Titan re-calls this function by
-- name (see registry.buttonTextFunction below) every time it wants to
-- refresh the button, so it always reflects the live CritLogDB.records
-- state - nothing is cached here.
-- Numbers rendered white (|cffffffff...|r), "/" and "CL: " left in the
-- default inherited font color (GameFontNormalSmall's usual gold) -
-- in-game requested to match TitanCritLine's own look exactly. Verified
-- against their actual code (TitanCritLine.lua): BODY_TEXT_COLOR is
-- literally "|cffffffff", and only the %s values passed through their
-- COLOR() helper get wrapped in it - the "/" separators in their format
-- string are outside that wrapping, same split done here.
function CritLogTitan_GetButtonText()
    local function top(kind)
        local entry = CritLogDB.records[kind][1]
        local value = entry and tostring(entry.amount) or "-"
        return "|cffffffff"..value.."|r"
    end

    return "CL: "..top("damage").."/"..top("whiteHit").."/"..top("heal")
end

-- Second color pass - in-game screenshotted: plain yellow spell + blue
-- target + a white/yellow/orange/red amount all fighting for attention
-- at once "didn't look good", and small amounts landed white-on-white
-- against the label text. Toned down instead of just swapping hues
-- again: WoW's own tooltip-title gold for spell names (softer than pure
-- yellow, a color WoW's UI already uses for "this is important" text),
-- a muted red for target names (WoW's usual "this is an enemy" cue,
-- softer than hot pink), and the amount scale now starts at green
-- instead of white so small values are clearly distinct from the label
-- too - a full green-to-red gradient instead of "invisible, then
-- suddenly colorful".
local WHITE_COLOR = "|cffffffff"
local SPELL_COLOR = "|cffffd200"
local TARGET_COLOR = "|cffff6060"

local function colored(color, text)
    return color..text.."|r"
end

-- Amount colored by a rough "hotter = bigger" heat scale, in-game
-- requested ("color the number by size or something"). Thresholds tuned
-- once already (2026-09-03: orange/red moved from 5000/10000 to
-- 4000/8000) after seeing it in-game - still just a reasonable guess, not
-- measured against real data, easy to retune again.
local function amountColor(amount)
    if amount >= 8000 then
        return "|cffff4040" -- red
    elseif amount >= 4000 then
        return "|cffff8000" -- orange
    elseif amount >= 2000 then
        return "|cffffff00" -- yellow
    end
    return "|cff40ff40" -- green
end

-- Full detail line per category for the hover tooltip. Not
-- Core/Records.lua's formatRecordText anymore (a plain string, no color
-- codes) - in-game requested styling (spell/target in their own colors,
-- amount colored by size) is specific to this one display, so this is a
-- deliberate second copy of the format rather than adding color-code
-- support to the shared formatter and risking it bleeding into the
-- options panel/chat output, which were never asked to look different.
function CritLogTitan_GetTooltipText()
    local function line(kind)
        local fields = CritLog.Constants.recordKinds[kind]
        local entry = CritLogDB.records[kind][1]

        if not entry then
            return colored(WHITE_COLOR, fields.label..": no record yet")
        end

        local amountText = colored(amountColor(entry.amount), tostring(entry.amount))
        local targetText = colored(TARGET_COLOR, entry.target)

        if fields.hasName then
            local spellText = colored(SPELL_COLOR, entry.name)
            return colored(WHITE_COLOR, fields.label.." (")..spellText
                ..colored(WHITE_COLOR, "): ")..amountText
                ..colored(WHITE_COLOR, " (")..targetText..colored(WHITE_COLOR, ")")
        end
        return colored(WHITE_COLOR, fields.label..": ")..amountText
            ..colored(WHITE_COLOR, " (")..targetText..colored(WHITE_COLOR, ")")
    end

    return line("damage").."\n"..line("whiteHit").."\n"..line("heal")
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
-- "TitanPanelComboTemplate", the same template/registry shape TitanCritLine's
-- XML-based button ultimately produces - TitanPanelComboTemplate specifically
-- (not the plain TitanPanelTextTemplate the first draft used), since it's
-- the one that actually has an icon texture region (`$parentIcon`) in
-- addition to the text label - in-game requested: a visible icon next to
-- the button text. Verified against the real Titan Panel 9.3.2 source
-- (Titan/TitanTemplate.xml, Titan/TitanTemplate.lua's
-- TitanPanelButton_SetButtonIcon): it looks up `_G[buttonName.."Icon"]`,
-- which is nil (and silently does nothing) for TitanPanelTextTemplate -
-- that template has no icon region at all, only ComboTemplate does.
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
    if _G.TitanPanelCritLogButton then
        return
    end

    local button = CreateFrame("Button", "TitanPanelCritLogButton", UIParent, "TitanPanelComboTemplate")
    button.registry = {
        -- Plain "CritLog", no "Titan" prefix/suffix on the id itself - see
        -- TitanCritLine's own TITAN_CRITLINE_ID ("CritLine", not
        -- "TitanCritLine"). The frame name above follows the matching
        -- convention instead: "TitanPanel<Name>Button"
        -- (TitanPanelCritLineButton in the reference, TitanPanelCritLogButton
        -- here) - "Titan" is a naming prefix for the frame/addon, not the
        -- registry id. An earlier attempt used "CritLogTitan" here while
        -- chasing a since-debunked stale-SavedVariables theory for the
        -- "already loaded" bug (the real cause, a genuine double
        -- registration, is fixed below - see the comment above the removed
        -- TitanPanelButton_OnLoad(button) call) - safe to use the plain
        -- name again now that the actual bug is gone.
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
    -- (Titan/TitanTemplate.xml): "TitanPanelComboTemplate" (like
    -- "TitanPanelTextTemplate" before it) inherits
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

-- Called from Persistence/Database.lua's AddRecord whenever a crit gets
-- recorded, so the button's own text (CritLogTitan_GetButtonText, the
-- current top score per category) actually refreshes. In-game reported:
-- a new crit updated the hover tooltip (rebuilt fresh every time it's
-- shown) but the button text itself stayed on its initial "-/-/-"
-- placeholder forever - Titan doesn't poll buttonTextFunction on its own,
-- it only re-invokes it when explicitly told to via
-- TitanPanelButton_UpdateButton (verified against the real Titan Panel
-- 9.3.2 source, same as everything else in this file). No-op if the
-- button was never created (Titan not installed), same guard
-- InitTitanPanelButton uses.
function CritLog:RefreshTitanPanelButton()
    if _G.TitanPanelCritLogButton then
        TitanPanelButton_UpdateButton("CritLog")
    end
end
