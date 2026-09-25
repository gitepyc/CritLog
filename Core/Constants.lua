CritLog.soundPath = "Interface/AddOns/CritLog/sounds/"

CritLog.Constants = {
    -- Options for the dps/tank/heal death-sound detection mode dropdowns
    -- in the Death Sounds panel: choose whether the live assigned-role
    -- check, the roster/name-list fallback, both, or neither decides
    -- whether the sound plays. See Core/Filters.lua's matchesDetectionMode.
    detectionModes = {
        { value = "none", label = "None" },
        { value = "experimental", label = "Role" },
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
    -- Highscore List popup's "Post" dropdown (see UI/MainPanel.lua's
    -- postHighscores) - `value` doubles as the literal SendChatMessage
    -- channel argument for every entry except FOR_ME (a local print, not
    -- a real chat channel) and WHISPER (needs the extra target-name box).
    postChannels = {
        { label = "For me", value = "FOR_ME" },
        { label = "Guild", value = "GUILD" },
        { label = "Party", value = "PARTY" },
        { label = "Raid", value = "RAID" },
        { label = "Whisper", value = "WHISPER" },
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
        playerDeath = "Toni.mp3",
        bossDeath = "FFX.mp3",
        tankDeath = "Tank.mp3",
        healDeath = "Angels.mp3",
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
        lottery = "lottery.mp3",
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
    bosses = {
        -- Accepted UnitClassification() values. "worldboss" is creature
        -- rank 3 - the "Level ?? (Boss)" tooltip - covering 40-man raid
        -- bosses, outdoor world bosses, and SoD's level-60 raid
        -- encounters. Deliberately nothing else: "elite"/"rareelite" are
        -- dungeon trash and 5-man end bosses, "rare" is a leveling rare
        -- spawn - accepting those would fire the boss sound on most
        -- pulls.
        classifications = { "worldboss" },
    },
    -- Display labels for the three roster categories - Persistence's
    -- migration and UI/RosterPanel.lua both need a consistent name/order
    -- for them.
    -- Key `dps` (Persistence/Database.lua's migrateMeleeToDps renames an
    -- existing character's `melee`) and `heal` (migratePriestToHeal
    -- renames `priest`) reflect the real role-based live check
    -- (isAssignedDps/isAssignedHealer), not a class guess.
    rosterKinds = {
        dps = { label = "Damage Dealer" },
        tank = { label = "Tank" },
        heal = { label = "Healer" },
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
        -- Feign Death fires a real UNIT_DIED for the feigning hunter (a
        -- known WoW quirk) - see Core/CombatLog.lua's HandleDeath.
        feignDeath = {
            ids = { 5384 },
            names = { "Feign Death", "Totstellen" },
        },
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
    -- Every slash command, shared by Commands.lua's `/cl help` and
    -- UI/HelpPanel.lua's Help panel - a single source of truth so the two
    -- can't drift apart. Split into named lists so the panel can lay
    -- General/Sounds out as two columns.
    --
    -- `cmd` must not contain a literal "|" - WoW FontStrings/chat treat it
    -- as the start of a color/texture escape sequence and can garble the
    -- rest of the line. Use "/" instead when a command lists sub-options.
    helpGeneral = {
        { cmd = "/cl", desc = "prints highscores" },
        { cmd = "/cl reset", desc = "clears every highscore list" },
        { cmd = "/cl reset damage/whitehit/heal", desc = "clears one category's list" },
        { cmd = "/cl options -> Highscore List...", desc = "delete a single entry" },
        { cmd = "/cl level", desc = "toggles the level filter (on by default, 9 levels below you still counts - options panel has a slider to change the threshold)" },
        { cmd = "/cl options (or /cl opt)", desc = "opens/closes the options panel" },
        { cmd = "/cl config", desc = "prints current settings" },
        { cmd = "/cl help", desc = "lists this" },
        { cmd = "/cl debug", desc = "diagnostic chat output for troubleshooting (off by default)" },
    },
    -- Order matches UI/SoundPanel.lua's row order. /cl mute stays first:
    -- it's the master switch for everything below, even though its own
    -- checkbox lives on the main options panel, not here.
    helpSounds = {
        { cmd = "/cl mute", desc = "master sound switch, overrides everything below (on by default)" },
        { cmd = "/cl sound", desc = "sound on a new personal highscore (the \"BÄM\" sound) (on by default)" },
        { cmd = "/cl allcrits", desc = "plays the BÄM sound on every crit, not just new highscores (off by default)" },
        { cmd = "/cl whitehit", desc = "includes white-hit (auto-attack/ranged) crits in the sounds above - ability crits count either way (on by default)" },
        { cmd = "/cl xtreme", desc = "extra sound when a hit deals over 9000 damage (off by default)" },
        { cmd = "/cl ready", desc = "sound when a ready check starts (on by default)" },
        { cmd = "/cl gamble", desc = "lottery sound (CrossGambling raid/party/guild chat trigger) (on by default)" },
        { cmd = "/cl roll", desc = "master switch for the 6 roll-result sounds (1, 69, 100, and three percentage bands) - see the Roll Sounds panel for each one individually (on by default)" },
        { cmd = "/cl aura", desc = "master switch for 13 individually-toggleable aura/ritual sounds - see the Aura Sounds panel (on by default, all 13 individually on too)" },
    },
    -- Order matches UI/DeathSoundPanel.lua's actual row order (player,
    -- boss, then dps/tank/healer).
    helpDeathSounds = {
        { cmd = "/cl player", desc = "player death sound (on by default)" },
        { cmd = "/cl boss", desc = "boss death sound - plain on/off, live worldboss classification is the only signal (on by default)" },
        { cmd = "/cl bosskill", desc = "chat message naming who landed the killing blow on a live worldboss - also on the main options panel (on by default)" },
        { cmd = "/cl dps/tank/healer", desc = "toggles that role's death sound off/on (\"None\"/\"Both\"); the options panel dropdown adds Role-only (live assigned role) or Roster-only (saved name list) - see the Death Sounds panel (Both by default)" },
    },
    -- Split into a title and a smaller two-line subtitle - UI/HelpPanel.lua
    -- renders these as two separate FontStrings so the subtitle can use a
    -- smaller font; Commands.lua's `/cl help` just joins them with a
    -- blank line.
    helpAboutTitle = "CritLog",
    helpAboutSubtitle = "© by Epyc, 2026\n(original addon by Kîtten aka Chabo)",
}
