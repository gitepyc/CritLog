CritLog.soundPath = "Interface/AddOns/CritLog/sounds/"

CritLog.Constants = {
    -- One entry per highscore record CritLog tracks, so a single false-
    -- positive record (e.g. a buggy value from some other addon reporting
    -- damage) can be cleared without wiping the other two. `name` is nil
    -- for white-hit crits: those aren't tied to a named ability, unlike
    -- damage/heal ability crits.
    records = {
        damage = { value = "DamageAbilityCrit", name = "DAC_Name", target = "DAC_Tar", label = "Damage crit" },
        whiteHit = { value = "WhiteHitCrit", target = "WHC_Tar", label = "White hit crit" },
        heal = { value = "HealAbilityCrit", name = "HAC_Name", target = "HAC_Tar", label = "Heal crit" },
    },
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
        melee = { label = "Melee" },
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
}
