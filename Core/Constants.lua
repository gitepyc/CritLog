CritLog.soundPath = "Interface/AddOns/CritLog/sounds/"

CritLog.Constants = {
    -- Options for the melee/tank/priest/boss death-sound detection mode
    -- dropdowns in the Sound Settings panel: choose whether the live
    -- class/role/classification check, the roster/name-list fallback,
    -- both (the original, still-default behavior), or neither decides
    -- whether the sound plays. See Core/Filters.lua's
    -- matchesDetectionMode.
    detectionModes = {
        { value = "none", label = "None" },
        { value = "experimental", label = "Experimental" },
        { value = "roster", label = "Roster" },
        { value = "both", label = "Both" },
    },
    -- One entry per highscore category CritLog tracks (see
    -- CritLogDB.records in Persistence/Database.lua for the actual
    -- per-character lists, same split as rosterKinds/playerGroups below).
    -- `hasName` is false for white-hit crits: those aren't tied to a named
    -- ability, unlike damage/heal ability crits.
    recordKinds = {
        damage = { label = "Damage crit", hasName = true },
        whiteHit = { label = "White hit crit", hasName = false },
        heal = { label = "Heal crit", hasName = true },
    },
    -- Top-N per highscore category instead of a single value, so
    -- highscores are a real list (each entry individually deletable in the
    -- options panel) rather than just the current best. Tracked and
    -- displayed counts are deliberately different: tracking more than is
    -- shown means deleting a couple of bad entries (e.g. false positives)
    -- doesn't need brand new crits to refill the visible list - the
    -- next-best already-tracked entries just shift into view immediately.
    maxTrackedEntries = 10,
    maxDisplayEntries = 5,
    sounds = {
        crit = "at_bam_babam.mp3",
        xtremeDamage = "Xtreme.mp3",
        meleeDeath = "wilhelm.ogg",
        playerDeath = "MarioDeath.mp3",
        bossDeath = "FFX.mp3",
        tankDeath = "Tank.mp3",
        priestDeath = "Angels.mp3",
        -- Reuses priestDeath's file - no dedicated asset yet, same precedent
        -- as the shared `crit` sound above. Kept as its own catalog key
        -- since it's a logically distinct trigger (see HandleDeath in
        -- Core/CombatLog.lua), just sharing a file for now.
        spiritOfRedemption = "Angels.mp3",
        innervate = "Innervate.mp3",
        manaTide = "Manatide.mp3",
        bloodlust = "Bloodlust.mp3",
        powerInfusion = "Surprise.mp3",
        blessingOfProtection = "Bubble.mp3",
        divineIntervention = "divineInt.mp3",
        soulstone = "soulstone.mp3",
        readyCheck = "Ready.mp3",
        raidEndBye = "bye.mp3",
        raidEndFinal = "end.mp3",
        wipe = "wipe.mp3",
    },
    -- Boss detection is classification-first with the name lists as a
    -- fallback, mirroring the spells table below: the primary signal is the
    -- game's own data, the hardcoded names catch what that signal misses.
    bosses = {
        -- Accepted UnitClassification() values. "worldboss" is creature
        -- rank 3 - the "Level ?? (Boss)" tooltip - which in the Classic
        -- database covers the 40-man raid bosses (Lucifron, Ragnaros,
        -- Onyxia, Nefarian, ...), the outdoor world bosses, and SoD's new
        -- level-60 raid encounters. Deliberately nothing else: "elite" and
        -- "rareelite" are ordinary dungeon trash and 5-man end bosses,
        -- "rare" is a leveling rare spawn - accepting those would fire the
        -- boss sound on most pulls. The known gap this leaves is documented
        -- in CHANGELOG.md and is exactly why the name lists below stay.
        classifications = { "worldboss" },
        -- Fallback allowlist for bosses the classification check can't see.
        -- This is still the original Burning Crusade roster and therefore
        -- matches nothing in Classic Era/SoD; it is kept as the mechanism
        -- for "boss NPCs that aren't flagged worldboss" (5-man end bosses,
        -- SoD's Blackfathom Deeps/Gnomeregan raid bosses) rather than for
        -- its current contents, which are due for replacement.
        english = {
            "Lady Vashj", "Kael'thas Sunstrider", "Hydross the Unstable",
            "The Lurker Below", "Leotheras the Blind",
            "Fathom-Lord Karathress", "Morogrim Tidewalker", "Al'ar",
            "High Astromancer Solarian", "Void Reaver", "Rage Winterchill",
            "Anetheron", "Kaz'rogal", "Azgalor", "Archimonde",
            "High Warlord Naj'entus", "Supremus", "Shade of Akama",
            "Gurtogg Bloodboil", "Reliquary of the Lost", "Teron Gorefiend",
            "Mother Shahraz", "The Illidari Council", "Illidan Stormrage",
        },
        german = {
            "Lady Vashj", "Kael'thas Sonnenwanderer", "Hydross der Unstete",
            "Das Grauen aus der Tiefe", "Leotheras der Blinde",
            "Tiefenlord Karathress", "Morogrim Gezeitenwandler", "Al'ar",
            "Hochastromantin Solarian", "Leerhäscher", "Furor Winterfrost",
            "Kaz'rogal", "Azgalor", "Archimonde",
            "Oberster Kriegsfürst Naj'entus", "Supremus", "Akamas Schemen",
            "Gurtogg Siedeblut", "Reliquiar der Verirrten",
            "Teron Blutschatten", "Mutter Shahraz", "Der Rat der Illidari",
            "Illidan Sturmgrimm",
        },
    },
    -- Display labels for the three roster categories - Persistence's
    -- migration and UI/RosterPanel.lua both need a consistent name/order
    -- for them.
    rosterKinds = {
        -- Labeled "Damage Dealer" rather than "Melee" so it's clear ranged
        -- DPS names belong here too - the roster is a free-form name list,
        -- unrelated to the live "melee-capable class" check in deathClasses
        -- below (that stays melee-specific; the roster/name-list fallback
        -- was never actually restricted to melee, just mislabeled).
        melee = { label = "Damage Dealer" },
        tank = { label = "Tank" },
        priest = { label = "Priest" },
    },
    -- Class/role rules for death-sound matching, used as the primary check
    -- (see Core/Filters.lua's isMeleeClass/isAssignedTank/isPriestClass and
    -- Core/CombatLog.lua's HandleDeath) before falling back to
    -- CritLogDB.playerGroups. See CHANGELOG.md for the reasoning and known
    -- trade-offs behind each rule.
    deathClasses = {
        -- Priest maps 1:1 onto WoW's class system, so this is a plain
        -- UnitClass check — no ambiguity like melee/tank below.
        priest = { "PRIEST" },
        -- Classes with at least one melee-capable spec in Season of
        -- Discovery. Hunter is deliberately excluded (functionally a
        -- ranged class even though it can equip melee weapons); Mage and
        -- Warlock are never melee. Paladin, Shaman, and Druid are hybrids —
        -- narrowed further by assigned role in isMeleeClass().
        meleeCapable = { "WARRIOR", "ROGUE", "PALADIN", "SHAMAN", "DRUID" },
        -- Subset of meleeCapable with no ranged/caster spec at all, so
        -- assigned role doesn't need to be checked for these two.
        alwaysMelee = { "WARRIOR", "ROGUE" },
    },
    -- Matched by spell ID first (Season of Discovery, cross-checked against
    -- Wowhead's current Classic database - see CHANGELOG.md), with the
    -- English/German display name kept as a fallback in case an ID turns
    -- out to be wrong: a wrong ID fails silently, a wrong name doesn't cost
    -- anything extra to keep around.
    spells = {
        bloodlust = {
            ids = { 27689, 23682 }, -- Bloodlust (Horde), Heroism (Alliance)
            names = { "Bloodlust", "Heroism", "Blutrausch", "Heldentum" },
        },
        innervate = {
            ids = { 29166 },
            names = { "Innervate", "Anregen" },
        },
        powerInfusion = {
            ids = { 10060 },
            names = { "Power Infusion", "Seele der Macht" },
        },
        manaTide = {
            ids = { 16190 },
            names = { "Mana Tide Totem", "Totem der Manaflut" },
        },
        blessingOfProtection = {
            ids = { 1022 },
            names = { "Blessing of Protection", "Segen des Schutzes" },
        },
        divineIntervention = {
            ids = { 19752 },
            names = { "Göttliches Eingreifen", "Divine Intervention" },
        },
        soulstone = {
            ids = { 20707 },
            names = { "Seelenstein Auferstehung", "Soulstone Resurrection" },
        },
        spiritOfRedemption = {
            ids = { 27827 },
            names = { "Spirit of Redemption", "Geist der Erlösung" },
        },
    },
    chatTriggers = {
        raidEnd = { "raid ende", "raid end" },
        wipe = { "shit show", "wipe" },
    },
    -- One line per slash command, shared by Commands.lua's `/cl help`
    -- (prints each line to chat) and UI/HelpPanel.lua's Help button (shows
    -- each line in a panel) - a single source of truth so the two can't
    -- drift apart. "------------" entries are section dividers, rendered
    -- as-is in both places.
    helpLines = {
        "/cl reset: clears every highscore list",
        "/cl reset damage|whitehit|heal: clears just that category's highscore list",
        "/cl options -> Highscore List...: delete a single entry instead of a whole list",
        "/cl level: changes level requirements for crit logs",
        "/cl mute: turns ALL sounds on/off, overriding every sound toggle below",
        "/cl sound: turns BÄM sound on/off (highscore sound)",
        "/cl allcrits: turns BÄM sound on/off for all crits",
        "/cl whitehit: turns BÄM sound on/off for all WHITEHIT crits",
        "/cl xtreme: turns sound for hits over 9000 damage on/off (off by default)",
        "/cl debug: turns diagnostic chat output on/off (off by default)",
        "/cl options (or /cl opt): opens/closes the CritLog options panel",
        "/cl ready: turns ReadyCheck Sound on/off",
        "/cl aura: turns Aura/Spell Sound on/off",
        "------------",
        "/cl priest: toggles Priest Sound between None/Both (see /cl options for Experimental/Roster only)",
        "/cl dps: toggles Damage Dealer Sound between None/Both (see /cl options for Experimental/Roster only)",
        "/cl tank: toggles Tank Sound between None/Both (see /cl options for Experimental/Roster only)",
        "/cl boss: toggles Boss Sound between None/Both (see /cl options for Experimental/Roster only)",
        "/cl player: turns Player Death Sound on/off",
        "------------",
        "/cl config: shows actual config/DB-data",
        "/cl help (or /cl options -> Help): lists this",
        "/cl      : prints CritLogs",
    },
}
