CritLog.soundPath = "Interface/AddOns/CritLog/sounds/"

CritLog.Data = {
    sounds = {
        crit = "at_bam_babam.mp3",
        xtremeDamage = "Xtreme.mp3",
        meleeDeath = "wilhelm.ogg",
        meleeDeathSchnutz = "schnutz.mp3",
        playerDeath = "MarioDeath.mp3",
        bossDeath = { "FFX.mp3", "Zelda.mp3" },
        tankDeath = "Tank.mp3",
        priestDeath = { "Angels1.mp3", "Angels2.mp3" },
        innervate = { "Inervate1.mp3", "Inervate2.mp3" },
        manaTide = "Manatide.mp3",
        bloodlust = "Bloodlust.mp3",
        powerInfusion = "Surprise.mp3",
        blessingOfProtection = "Bubble.mp3",
        divineIntervention = "divineInt.mp3",
        soulstone = { "soulstone.mp3", "soulstone2.mp3", "soulstone3.mp3" },
        readyCheck = "Ready.mp3",
        raidEndBye = "bye.mp3",
        raidEndFinal = "end.mp3",
        wipe = "wipe.mp3",
    },
    bosses = {
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
    -- Legacy name-based death rosters, tied to one specific historical raid
    -- group. As of the class/role-based matching added in CombatLog.lua
    -- (see deathClasses below), these are no longer the primary check —
    -- they're kept as a fallback, same ID-first-then-name-fallback pattern
    -- already used for spells above: class/role detection needs a live
    -- unit token and (for tank) an explicitly assigned raid role, neither
    -- of which is guaranteed available, so a name still in this list keeps
    -- firing even when the live check can't. See CHANGELOG.md for the
    -- decision to keep rather than delete these.
    playerGroups = {
        melee = {
            "Schnutz", "Synday", "Kamicaze", "Alcira", "Shocksx",
            "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr",
            "Truffi", "Gradba", "Zoiy",
        },
        tank = { "Truby", "Ketamartin", "Hïnatahÿuuga", "Kîtten" },
        priest = { "Ilenkov", "Epyç" },
    },
    -- Class/role rules for death-sound matching, used as the primary check
    -- (see CombatLog.lua's isMeleeClass/isAssignedTank/isPriestClass and
    -- HandleDeath) before falling back to playerGroups above. See
    -- CHANGELOG.md for the reasoning and known trade-offs behind each rule.
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
    },
    chatTriggers = {
        raidEnd = { "raid ende", "raid end" },
        wipe = { "shit show", "wipe" },
    },
}
