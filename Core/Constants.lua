CritLog.soundPath = "Interface/AddOns/CritLog/sounds/"

CritLog.Constants = {
    -- Options for the dps/tank/heal/boss death-sound detection mode
    -- dropdowns in the Death Sounds panel: choose whether the live
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
        dpsDeath = "wilhelm.ogg",
        playerDeath = "MarioDeath.mp3",
        bossDeath = "FFX.mp3",
        tankDeath = "Tank.mp3",
        healDeath = "Angels.mp3",
        -- Legacy addon randomly alternated between Angels1.mp3/Angels2.mp3
        -- for the same "priest death" trigger (see CHANGELOG.md); the 0.4.0
        -- cleanup that removed random multi-clip selection kept only one
        -- (as `Angels.mp3`, used by healDeath above) and dropped the other.
        -- Now that Spirit of Redemption is an independently toggleable
        -- trigger rather than just a file choice under the same gate as
        -- healDeath, it gets the previously-dropped clip back as its own
        -- dedicated asset instead of reusing healDeath's file.
        spiritOfRedemption = "Angels2.mp3",
        innervate = "Innervate.mp3",
        manaTide = "Manatide.mp3",
        bloodlust = "Bloodlust.mp3",
        powerInfusion = "Surprise.mp3",
        blessingOfProtection = "Bubble.mp3",
        divineIntervention = "divineInt.mp3",
        soulstone = "soulstone.mp3",
        readyCheck = "Ready.mp3",
        raidEnd = "raidend.mp3",
        wipe = "wipe.mp3",
        lotteryFirst = "lottery2.wav",
        lotterySecond = "lottery3.mp3",
        -- roll1/69/100 hit exact values; roll5/roll10/roll95 are percentage
        -- bands - see Filters.classifyRoll for the exact thresholds.
        roll1 = "roll1.mp3",
        roll5 = "roll5.mp3",
        roll10 = "roll10.mp3",
        roll69 = "roll69.mp3",
        roll95 = "roll95.mp3",
        roll100 = "roll100.mp3",
        drums = "dkRapL.mp3",
        painSuppression = "Painsup.mp3",
        hymnOfHope = "HymnOfHope.mp3",
        evocation = "evo.mp3",
        mageTable = "Table.mp3",
        healthstoneRitual = "healthstone.mp3",
    },
    -- Boss detection is classification-only now - the hardcoded name-list
    -- fallback (english/german) is gone: it was still the original Burning
    -- Crusade roster and matched nothing in Classic Era/SoD, so it was
    -- dead weight requiring manual upkeep for content it would never
    -- actually cover. See CHANGELOG.md.
    bosses = {
        -- Accepted UnitClassification() values. "worldboss" is creature
        -- rank 3 - the "Level ?? (Boss)" tooltip - which in the Classic
        -- database covers the 40-man raid bosses (Lucifron, Ragnaros,
        -- Onyxia, Nefarian, ...), the outdoor world bosses, and SoD's new
        -- level-60 raid encounters. Deliberately nothing else: "elite" and
        -- "rareelite" are ordinary dungeon trash and 5-man end bosses,
        -- "rare" is a leveling rare spawn - accepting those would fire the
        -- boss sound on most pulls. Known gap, accepted rather than
        -- solved: 5-man end bosses and similarly-ranked NPCs aren't
        -- "worldboss" and won't fire the sound at all anymore.
        classifications = { "worldboss" },
    },
    -- Display labels for the three roster categories - Persistence's
    -- migration and UI/RosterPanel.lua both need a consistent name/order
    -- for them.
    rosterKinds = {
        -- Key `dps`, renamed from `melee` (see Persistence/Database.lua's
        -- migrateMeleeToDps) once the live check itself stopped being a
        -- melee-capable-class guess and became the real 3-role system
        -- (Tank/Healer/everyone else, see Core/Filters.lua's
        -- isAssignedDps) - "Melee" in the key/field name was misleading
        -- even before that, since ranged DPS names always belonged in
        -- this free-form roster too.
        dps = { label = "Damage Dealer" },
        tank = { label = "Tank" },
        -- Labeled "Healer" (key `heal`, renamed from `priest` - see
        -- Persistence/Database.lua's migratePriestToHeal), same reasoning
        -- as "Damage Dealer" above: the live check this falls back for
        -- (isAssignedHealer) is role-based, not Priest-specific - a Holy
        -- Paladin/Resto Druid/Resto Shaman belongs here too.
        heal = { label = "Healer" },
    },
    -- Class rule for Spirit of Redemption only now (see Core/Filters.lua's
    -- isPriestClass and Core/CombatLog.lua's HandleDeath) - the talent
    -- itself is Priest-specific, unlike every other death-sound category,
    -- which is role-based (isAssignedDps/isAssignedTank/isAssignedHealer)
    -- and needs no class table at all. Used to also hold meleeCapable/
    -- alwaysMelee for the old class-based DPS guess - removed once that
    -- became a real role check, see CHANGELOG.md.
    deathClasses = {
        -- Priest maps 1:1 onto WoW's class system, so this is a plain
        -- UnitClass check.
        priest = { "PRIEST" },
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
        -- Evocation's ID (12051) is confirmed on Wowhead Classic (a
        -- genuine vanilla/Classic Era Mage spell). Pain Suppression's ID
        -- (402004) is confirmed as the Season of Discovery Priest rune.
        -- Drums of Battle (35476), Ritual of Refreshment/Mage Table
        -- (43987), and Ritual of Souls/Healthstone (29893) are all
        -- confirmed on Wowhead - but confirmed as TBC-introduced spells
        -- (Drums of Battle and Ritual of Refreshment/Souls did not exist
        -- in vanilla WoW at all, added in patches 2.0-2.1), not Classic
        -- Era/SoD ones - whether SoD backports them (e.g. as drops/runes)
        -- is unverified, so having the "right" TBC spell ID doesn't by
        -- itself guarantee these fire on Classic Era/SoD (see
        -- docs/ROADMAP.md). Hymn of Hope did not exist under that name
        -- until WotLK patch 3.0.2 (it replaced the TBC-only, Draenei-only
        -- "Symbol of Hope", spell id 32548 - a different spell with
        -- different mechanics, not used here since the legacy addon's
        -- trigger was always specifically "Hymn of Hope") - no ID exists
        -- for it on Classic Era/SoD at all, so this trigger cannot fire
        -- there under any circumstances until/unless SoD adds an
        -- equivalent rune.
        evocation = {
            ids = { 12051 },
            names = { "Evocation", "Hervorrufung" },
        },
        painSuppression = {
            ids = { 402004 },
            names = { "Pain Suppression", "Schmerzunterdrückung" },
        },
        drums = {
            ids = { 35476 },
            names = {
                "Drums of Battle", "Greater Drums of Battle",
                "Trommeln der Schlacht", "Große Trommeln der Schlacht",
            },
        },
        -- No ids: genuinely does not exist pre-WotLK, see comment above.
        hymnOfHope = {
            ids = {},
            names = { "Hymn of Hope", "Hymne der Hoffnung" },
        },
        mageTable = {
            ids = { 43987 },
            names = { "Ritual of Refreshment", "Tischlein deck dich" },
        },
        healthstoneRitual = {
            ids = { 29893 },
            names = { "Ritual of Souls", "Ritual der Seelen" },
        },
    },
    chatTriggers = {
        raidEnd = { "raid ende", "raid end" },
        wipe = { "shit show", "wipe" },
        gamble = "CrossGambling: A new game has been started! Type 1 to join!",
    },
    -- Every slash command, shared by Commands.lua's `/cl help` (prints to
    -- chat) and UI/HelpPanel.lua's Help panel (two-column layout, General
    -- and Sounds side by side, matching UI/AuraSoundPanel.lua's column
    -- pattern) - a single source of truth so the two can't drift apart.
    -- Split into named lists instead of one flat list specifically so the
    -- panel can lay General/Sounds out as two columns; Death Sounds and
    -- the About line stay single-column below both (see UI/HelpPanel.lua).
    --
    -- `cmd` must not contain a literal "|" - WoW FontStrings/chat treat it
    -- as the start of a color/texture escape sequence and can swallow or
    -- garble the rest of the line (in-game reported: the
    -- "/cl reset damage|whitehit|heal" line went missing). Use "/" instead
    -- wherever a command lists several sub-options, same as
    -- "/cl healer/dps/tank/boss" below already did.
    helpGeneral = {
        { cmd = "/cl", desc = "prints highscores" },
        { cmd = "/cl reset", desc = "clears every highscore list" },
        { cmd = "/cl reset damage/whitehit/heal", desc = "clears one category's list" },
        { cmd = "/cl options -> Highscore List...", desc = "delete a single entry" },
        { cmd = "/cl level", desc = "toggles the level filter (options panel has a threshold slider)" },
        { cmd = "/cl options (or /cl opt)", desc = "opens/closes the options panel" },
        { cmd = "/cl config", desc = "prints current settings" },
        { cmd = "/cl help", desc = "lists this" },
        { cmd = "/cl debug", desc = "diagnostic chat output (off by default)" },
    },
    helpSounds = {
        { cmd = "/cl mute", desc = "master sound switch, overrides everything below" },
        { cmd = "/cl sound", desc = "highscore (BÄM) sound" },
        { cmd = "/cl allcrits", desc = "BÄM sound for every crit" },
        { cmd = "/cl whitehit", desc = "BÄM sound for white-hit crits" },
        { cmd = "/cl xtreme", desc = "sound for hits over 9000 (off by default)" },
        { cmd = "/cl ready", desc = "ready-check sound" },
        { cmd = "/cl aura", desc = "aura/spell sounds" },
        { cmd = "/cl roll", desc = "/roll result sounds (1-100)" },
        { cmd = "/cl gamble", desc = "lottery sound (CrossGambling raid chat trigger)" },
    },
    helpDeathSounds = {
        { cmd = "/cl player", desc = "player death sound" },
        { cmd = "/cl spirit", desc = "Spirit of Redemption sound" },
        { cmd = "/cl healer/dps/tank/boss", desc = "death sound None/Both (options panel for Experimental/Roster only)" },
    },
    helpAbout = "CritLog\nby Epyc, 2026 (original addon by Kîtten aka Chabo)",
}
