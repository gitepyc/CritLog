CritLog = { }



--Version
local CRITLOG_VERSION = "0.2.0"

----------------
--SOUND, SPELL, BOSS AND ROSTER DATA:
----------------
-- Centralized so every trigger's sound file(s) and matched names live in one
-- place instead of being scattered through the event-handling code below.
local SOUNDPATH = 'Interface/AddOns/CritLog/sounds/'

local CritLogData = {
    sounds = {
        crit = 'at_bam_babam.mp3',            -- crit sounds
        xtremeDamage = 'Xtreme.mp3',

        -- on death sounds:
        meleeDeath = 'wilhelm.ogg',
        meleeDeathSchnutz = 'schnutz.mp3',
        playerDeath = 'MarioDeath.mp3',
        bossDeath = { 'FFX.mp3', 'Zelda.mp3' },
        tankDeath = 'Tank.mp3',
        priestDeath = { 'Angels1.mp3', 'Angels2.mp3' },

        -- on Aura sounds:
        innervate = { 'Inervate1.mp3', 'Inervate2.mp3' },
        manaTide = 'Manatide.mp3',
        bloodlust = 'Bloodlust.mp3',
        powerInfusion = 'Surprise.mp3',
        blessingOfProtection = 'Bubble.mp3',
        divineIntervention = 'divineInt.mp3',
        soulstone = { 'soulstone.mp3', 'soulstone2.mp3', 'soulstone3.mp3' },

        -- other sounds:
        readyCheck = 'Ready.mp3',
        raidEndBye = 'bye.mp3',
        raidEndFinal = 'end.mp3',
        wipe = 'wipe.mp3',
    },

    -- FILL OUT THOSE FOR THE FUN :
    bosses = {
        english = {"Lady Vashj", "Kael'thas Sunstrider" , "Hydross the Unstable", "The Lurker Below", "Leotheras the Blind", "Fathom-Lord Karathress", "Morogrim Tidewalker", "Al'ar", "High Astromancer Solarian", "Void Reaver", "Rage Winterchill", "Anetheron", "Kaz'rogal", "Azgalor", "Archimonde", "High Warlord Naj'entus", "Supremus", "Shade of Akama", "Gurtogg Bloodboil", "Reliquary of the Lost", "Teron Gorefiend", "Mother Shahraz", "The Illidari Council", "Illidan Stormrage"},
        german = {"Lady Vashj", "Kael'thas Sonnenwanderer", "Hydross der Unstete", "Das Grauen aus der Tiefe", "Leotheras der Blinde", "Tiefenlord Karathress", "Morogrim Gezeitenwandler", "Al'ar", "Hochastromantin Solarian", "Leerhäscher", "Furor Winterfrost", "Kaz'rogal", "Azgalor", "Archimonde", "Oberster Kriegsfürst Naj'entus", "Supremus", "Akamas Schemen", "Gurtogg Siedeblut", "Reliquiar der Verirrten", "Teron Blutschatten", "Mutter Shahraz", "Der Rat der Illidari", "Illidan Sturmgrimm"},
    },

    playerGroups = {
        melee = { "Schnutz", "Synday", "Kamicaze", "Alcira", "Shocksx", "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr", "Truffi", "Gradba", "Zoiy" },
        tank = {"Truby", "Ketamartin","Hïnatahÿuuga" ,"Kîtten"},
        priest = {"Ilenkov", "Epyç"},
    },

    -- Ability names, English and German:
    spells = {
        bloodlust = {'Bloodlust', 'Heroism', 'Blutrausch', 'Heldentum'},
        innervate = {'Innervate', 'Anregen'},
        powerInfusion = {'Power Infusion', 'Seele der Macht'},
        manaTide = {'Mana Tide Totem', 'Totem der Manaflut'},
        blessingOfProtection = {"Blessing of Protection", "Segen des Schutzes"},
        divineIntervention = {"Göttliches Eingreifen", "Divine Intervention"},
        soulstone = {"Seelenstein Auferstehung", "Soulstone Resurrection"},
    },

    chatTriggers = {
        raidEnd = {"raid ende", "raid end"},
        wipe = {"shit show", "wipe"},
    },
}

-- Spirit of Redemption is a disabled test feature (see the commented-out
-- block in COMBAT_LOG_EVENT_UNFILTERED below); its name list is kept
-- separate and untouched until that feature gets a real fix.
local SREDEMPTION_NAMES = {"Spirit of Redemption", "Geist der Erlösung"}


local frame = CreateFrame("Frame")


---------------------------------------------------
-- Register Events Here:
---------------------------------------------------
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")

frame:SetScript("OnEvent", function(_, event, ...)
    CritLog[event](CritLog, ...)
end)

---------------------------------------------------
-- Function is triggert at /reload and every Login
---------------------------------------------------
function CritLog:PLAYER_LOGIN()

    --initalize DB
    self:SetDefaults()

    PrintCritLogs()

end


------------------------------------------------------------------
-- Function is triggert with Chat MSG in a raid (raidleader only)
------------------------------------------------------------------
function CritLog:CHAT_MSG_RAID_LEADER(...)

    local message, _ = ...
    local lowerMessage = string.lower(message)

    --print(message,author)
    if tContains( CritLogData.chatTriggers.raidEnd, lowerMessage ) then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(SOUNDPATH..CritLogData.sounds.raidEndBye, 'Master')
        PlaySoundFile(SOUNDPATH..CritLogData.sounds.raidEndFinal, 'Master')
    end
    if tContains( CritLogData.chatTriggers.wipe, lowerMessage ) then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(SOUNDPATH..CritLogData.sounds.wipe, 'Master')
    end

end

---------------------------------------------------
-- Function is triggert with a Ready Check
---------------------------------------------------
function CritLog:READY_CHECK()

    -- Plays Ready Check Sound
    if CritLogDB.ReadySoundFlag then
        PlaySoundFile(SOUNDPATH..CritLogData.sounds.readyCheck, 'Master')
    end

end


---------------------------------------------------
-- Combat Log Event functions
---------------------------------------------------
function CritLog:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, sv1, sv2, _, sv4, sv5, _, sv7, _, _, sv10 = CombatLogGetCurrentEventInfo()



----------------------------------------------------------------------------
-- Checks if Player got some specific Auras/Buffs and then triggers Sounds
----------------------------------------------------------------------------
    if CritLogDB.AuraSoundFlag then
        --   UnitInRaid
        --   UnitInParty
        if UnitInParty(sourceName) or UnitInRaid(sourceName) then
            --if sourceName == "Epyç" then
            --    print("---------------------------")
            --    print(subevent)
            --    print(sv2)
            --    print(destName)
            --    print("---------------------------")
            --end
            if subevent == "SPELL_SUMMON" then
                --
                -- Mana Tide Totem Sound
                --
                if sv2 ~= nil and tContains( CritLogData.spells.manaTide, sv2 ) then
                    --print("MANA TIDE TOTEM SCRIPT WORKING")
                    --print(subevent)
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.manaTide, 'Master')
                end
            end
        end
        if destGUID == UnitGUID("Player") then -- true if spell targets the player
            --
            -- Gets Trigger if New Aura gets applied ( NOT on refresh of buffs, remove buff with right click to trigger again)
            --
            if subevent == "SPELL_AURA_APPLIED" then
                if tContains( CritLogData.spells.bloodlust, sv2 ) then
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.bloodlust, 'Master')
                end
                --
                -- Inervate Sound
                --
                if tContains( CritLogData.spells.innervate, sv2 ) then
                    local tmpRNDM = math.random(1, 2)
                    --print(SOUNDPATH..CritLogData.sounds.innervate[tmpRNDM])
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.innervate[tmpRNDM], 'Master')
                end
                --
                -- Power Word Infusion Sound
                --
                if tContains( CritLogData.spells.powerInfusion, sv2 ) then
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.powerInfusion, 'Master')
                end
                --
                -- Blessing of Protection Sound
                --
                if tContains( CritLogData.spells.blessingOfProtection, sv2 ) then
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.blessingOfProtection, 'Master')
                end
                --
                -- Divine Intervention Sound
                --
                if tContains( CritLogData.spells.divineIntervention, sv2 ) then
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.divineIntervention, 'Master')
                end
                --
                -- Soulstone Sound
                --
                if tContains( CritLogData.spells.soulstone, sv2 ) then
                    local tmpRNDM = math.random(1, 3)
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.soulstone[tmpRNDM], 'Master')
                end
            end
        end
    end
    --
    --  Plays a sound if a single SPELL_DAMAGE hit exceeds 9000 damage.
    --  Off by default; enable with /cl xtreme.
    --
    if sourceGUID == UnitGUID("Player") and subevent == "SPELL_DAMAGE" then
        if CritLogDB.XtremeSoundFlag and tonumber(sv4) > 9000 then
            PlaySoundFile(SOUNDPATH..CritLogData.sounds.xtremeDamage, 'Master')
        end
    end
    --
    -- Spirit of Redemtption TEST ------not working
    --
    --if Split(sourceGUID, "-")[1] == "Player" then
    --    if subevent == "SPELL_AURA_APPLIED" then
    --        if tContains( SREDEMPTION_NAMES, sv2 ) then
    --            tmpRNDM = math.random(1, 2)
    --            print("SPIRIT OF REDEMPTION SCRIPT WORKING----- TELL ME IF IT DOES Cause i thinks it's not")
    --        end
    --    end
    --end



---------------------------------------------------
-- Crit Log Functions:
---------------------------------------------------

    if sourceGUID == UnitGUID("Player") then
        if UnitLevel("target") > UnitLevel("player")-9 or UnitClassification("target") == "worldboss" or CritLogDB.AllLevel then
    --
    --  Plays Sound and Logs on Spell and Ability Crits
    --
            if subevent == "SPELL_DAMAGE" then
                if sv10 == true then
                    if CritLogDB.AllCritFlag then
                         self:PlaySoundFile()
                    end
                    if sv4 > CritLogDB.DamageAbilityCrit then
                        CritLogDB.DamageAbilityCrit = sv4
                        CritLogDB.DAC_Name = sv2
                        CritLogDB.DAC_Tar = destName
                        print("DAMAGE Crit "..sv2..": "..sv4.." ("..destName..")")
                        self:PlaySoundFile()
                    end
                end
    --
    --  Plays Sound and Logs on White hit Crits
    --
            elseif (subevent == "SWING_DAMAGE") then
                if sv7 == true then
                    if CritLogDB.AllCritFlag and CritLogDB.WhiteHitFlag then
                         self:PlaySoundFile()
                    end
                    if sv1 > CritLogDB.WhiteHitCrit then
                        CritLogDB.WhiteHitCrit = sv1
                        CritLogDB.WHC_Tar = destName
                        print("DAMAGE Crit WhiteHit: "..sv1.." ("..destName..")")
                        if CritLogDB.WhiteHitFlag then
                            self:PlaySoundFile()
                        end
                    end
                end
    --
    --  Plays Sound and Logs on Range Crits (counts as White hit)
    --
            elseif (subevent == "RANGE_DAMAGE") then
                --print(sv4..tostring(sv6)..tostring(sv7)..tostring(sv8)..tostring(sv9)..tostring(sv10))
                if sv10 == true then
                    if CritLogDB.AllCritFlag then
                         self:PlaySoundFile()
                    end
                    if sv4 > CritLogDB.WhiteHitCrit and CritLogDB.WhiteHitFlag then
                        CritLogDB.WhiteHitCrit = sv4
                        CritLogDB.WHC_Tar = destName
                        print("DAMAGE Crit WhiteHit: "..sv4.." ("..destName..")")
                        if CritLogDB.WhiteHitFlag then
                            self:PlaySoundFile()
                        end
                    end
                end
            end
        end
    --
    --  Plays Sound and Logs on Heal Crits (independent of enemy target level)
    --
        if subevent == "SPELL_HEAL" then
            if sv7 == true then
                if CritLogDB.AllCritFlag then
                     self:PlaySoundFile()
                end
                if sv4 > CritLogDB.HealAbilityCrit then
                    CritLogDB.HealAbilityCrit = sv4
                    CritLogDB.HAC_Name = sv2
                    CritLogDB.HAC_Tar = destName
                    print("HEAL Crit "..sv2..": "..sv4.." ("..destName..")")
                    self:PlaySoundFile()
                end
            end
        end
    end

---------------------------------------
-- Print who got KillingBlow of Bosses
---------------------------------------
    if tContains( CritLogData.bosses.english, destName ) then
        if (ends_with(subevent, '_DAMAGE')) and sv5 and sv5 > 0 then
        print(sourceName.." killed "..destName)
        end
    end


---------------------------------------------------
-- UNIT_DIED FUNKTIONS:
---------------------------------------------------

    --
    --  Plays Sound when Units die
    --
    if subevent == "UNIT_DIED" and CritLogDB.DeadSoundFlag then
        --print(sourceGUID .. "aaa " ..UnitGUID("Player").. " Dest".. destGUID)
        --
        -- Player died
        --
        if destGUID == UnitGUID("Player") then
            if CritLogDB.PlayerSoundFlag then
                PlaySoundFile(SOUNDPATH..CritLogData.sounds.playerDeath, 'Master')
            end
        else
            --
            -- Melee died
            --
            if  CritLogDB.MeleeSoundFlag then
                if tContains( CritLogData.playerGroups.melee, destName ) then
                   if destName == "Schnutz" then
                        PlaySoundFile(SOUNDPATH..CritLogData.sounds.meleeDeathSchnutz, 'Master')
                    else
                        PlaySoundFile(SOUNDPATH..CritLogData.sounds.meleeDeath, 'Master')
                    end
                end
            end
            --
            -- Boss died
            --
            if CritLogDB.BossSoundFlag then
                if tContains( CritLogData.bosses.english, destName ) or tContains( CritLogData.bosses.german, destName ) then
                    local tmpRNDM = math.random(1, 2)
                    PlaySoundFile(SOUNDPATH..CritLogData.sounds.bossDeath[tmpRNDM], 'Master')
                end
            end
            --
            -- Tank died
            --
            if tContains( CritLogData.playerGroups.tank, destName ) and CritLogDB.TankSoundFlag then
                PlaySoundFile(SOUNDPATH..CritLogData.sounds.tankDeath, 'Master')
                --print("wtf2")
            end
            --
            -- Heal Priest died
            --
            if tContains( CritLogData.playerGroups.priest, destName ) and CritLogDB.PriestSoundFlag then
                local tmpRNDM = math.random(1, 2)
                --print(tmpRNDM)
                PlaySoundFile(SOUNDPATH..CritLogData.sounds.priestDeath[tmpRNDM], 'Master')
            end
        end
    end
end

--plays sound file for crits
function CritLog:PlaySoundFile()
    if CritLogDB.SoundFlag then
        PlaySoundFile(SOUNDPATH..CritLogData.sounds.crit, 'Master')
    end
end


---------------------------------------------------
--  Sets Character spec. Variables (DataBase)
---------------------------------------------------
function CritLog:SetDefaults()

    local defaults = {
        DamageAbilityCrit = 0,
        DAC_Name = "",
        DAC_Tar = "",
        WhiteHitCrit = 0,
        WHC_Tar = "",
        HealAbilityCrit = 0,
        HAC_Name = "",
        HAC_Tar ="",
        SoundFlag = true,
        AllLevel = false,
        AllCritFlag = false,
        WhiteHitFlag = true,
        ReadySoundFlag = true,
        AuraSoundFlag = true,
        PriestSoundFlag = true,
        TankSoundFlag = true,
        MeleeSoundFlag = true,
        PlayerSoundFlag = true,
        BossSoundFlag = true,
        DeadSoundFlag = true,
        XtremeSoundFlag = false,
    }

    if not CritLogDB then
        --Character specifc Database:
        CritLogDB = { Version = CRITLOG_VERSION }
        for key, value in pairs(defaults) do
            CritLogDB[key] = value
        end

        print("CritLog Initialized")
        --print("CritLog Sounds Off")
        print("/cl help for list of commands")
        --message('\n Kîtten is DruidLord \n\n Pappi is ShamanKing \n') -- IMPORTANT DO NOT DELETE :D !!!11!1!11

    elseif CritLogDB.Version ~= CRITLOG_VERSION then
        --
        -- Version changed: back-fill any field that doesn't exist yet.
        -- Existing highscores and toggles are kept as-is.
        --
        for key, value in pairs(defaults) do
            if CritLogDB[key] == nil then
                CritLogDB[key] = value
            end
        end
        CritLogDB.Version = CRITLOG_VERSION

        print("CritLog updated to "..CRITLOG_VERSION.." (existing data kept)")
        print("/cl help for list of commands")
    end
end


---------------------------------------------------
--  String helper functions
---------------------------------------------------
function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end


-----------------------------------------------------------------
--  Show Logs in Chat
--  and handle "/cl <commands>" where msg is the actual command
-----------------------------------------------------------------
function PrintCritLogs(msg)
    --
    -- reset crits
    --
    if msg == "reset" then
        local tmpSoundFlag = CritLogDB.SoundFlag
        local tmpAllLevel = CritLogDB.AllLevel
        local tmpAllCritFlag = CritLogDB.AllCritFlag
        local tmpWhiteHitFlag = CritLogDB.WhiteHitFlag
        local tmpReadySoundFlag = CritLogDB.ReadySoundFlag
        local tmpAuraSoundFlag = CritLogDB.AuraSoundFlag
        local tmpPriestSoundFlag = CritLogDB.PriestSoundFlag
        local tmpTankSoundFlag = CritLogDB.TankSoundFlag
        local tmpMeleeSoundFlag = CritLogDB.MeleeSoundFlag
        local tmpPlayerSoundFlag = CritLogDB.PlayerSoundFlag
        local tmpBossSoundFlag = CritLogDB.BossSoundFlag
        local tmpDeadSoundFlag = CritLogDB.DeadSoundFlag
        local tmpXtremeSoundFlag = CritLogDB.XtremeSoundFlag

        --Character specifc Database:
        CritLogDB = {
            Version = CRITLOG_VERSION,
            DamageAbilityCrit = 0,
            DAC_Name = "",
            DAC_Tar = "",
            WhiteHitCrit = 0,
            WHC_Tar = "",
            HealAbilityCrit = 0,
            HAC_Name = "",
            HAC_Tar ="",
            SoundFlag = tmpSoundFlag,
            AllLevel = tmpAllLevel,
            AllCritFlag = tmpAllCritFlag,
            WhiteHitFlag = tmpWhiteHitFlag,
            ReadySoundFlag = tmpReadySoundFlag,
            AuraSoundFlag = tmpAuraSoundFlag,
            PriestSoundFlag = tmpPriestSoundFlag,
            TankSoundFlag = tmpTankSoundFlag,
            MeleeSoundFlag = tmpMeleeSoundFlag,
            BossSoundFlag = tmpBossSoundFlag,
            PlayerSoundFlag = tmpPlayerSoundFlag,
            DeadSoundFlag = tmpDeadSoundFlag,
            XtremeSoundFlag = tmpXtremeSoundFlag,
        }
        PrintCritLogs()
    --
    -- Crit Sound config
    --
    elseif msg == "sound" then
        if CritLogDB.SoundFlag then
            CritLogDB.SoundFlag = false
            print("CritLog Sounds Off")
        else
            CritLogDB.SoundFlag = true
            print("CritLog Sounds On")
        end
    --
    -- Config for Sound at ALL critical hits
    --
    elseif msg == "allcrits" then
        if CritLogDB.AllCritFlag then
            CritLogDB.AllCritFlag = false
            print("Sound for all crits Off ("..tostring(CritLogDB.AllCritFlag)..")")
        else
            CritLogDB.AllCritFlag = true
            print("Sound for all crits On("..tostring(CritLogDB.AllCritFlag)..")")
        end
    --
    -- Config for Sound at WHITE HIT critical hits
    --
    elseif msg == "whitehit" then
        if CritLogDB.WhiteHitFlag then
            CritLogDB.WhiteHitFlag = false
            print("Sound for whitehit crits Off ("..tostring(CritLogDB.WhiteHitFlag)..")")
        else
            CritLogDB.WhiteHitFlag = true
            print("Sound for whitehit crits On("..tostring(CritLogDB.WhiteHitFlag)..")")
        end
    --
    -- Config for ReadyCheck Sound
    --
    elseif msg == "ready" then
        if CritLogDB.ReadySoundFlag then
            CritLogDB.ReadySoundFlag = false
            print("CritLog ReadyCheckSound Off ("..tostring(CritLogDB.ReadySoundFlag)..")")
        else
            CritLogDB.ReadySoundFlag = true
            print("CritLog ReadyCheckSound On ("..tostring(CritLogDB.ReadySoundFlag)..")")
        end
    --
    -- Config for Aura/Spell Sound
    --
    elseif msg == "aura" then
        if CritLogDB.AuraSoundFlag then
            CritLogDB.AuraSoundFlag = false
            print("CritLog Aura/Spell Sound Off ("..tostring(CritLogDB.AuraSoundFlag)..")")
        else
            CritLogDB.AuraSoundFlag = true
            print("CritLog Aura/Spell Sound On ("..tostring(CritLogDB.AuraSoundFlag)..")")
        end
    --
    -- Config Priest died Sounds
    --
    elseif msg == "priest" then
        if CritLogDB.PriestSoundFlag then
            CritLogDB.PriestSoundFlag = false
            print("CritLog PriestSound Off ("..tostring(CritLogDB.PriestSoundFlag)..")")
        else
            CritLogDB.PriestSoundFlag = true
            print("CritLog PriestSound On ("..tostring(CritLogDB.PriestSoundFlag)..")")
        end
    --
    -- Config Melee died Sounds
    --
    elseif msg == "melee" then
        if CritLogDB.MeleeSoundFlag then
            CritLogDB.MeleeSoundFlag = false
            print("CritLog MeleeSound Off ("..tostring(CritLogDB.MeleeSoundFlag)..")")
        else
            CritLogDB.MeleeSoundFlag = true
            print("CritLog MeleeSound On ("..tostring(CritLogDB.MeleeSoundFlag)..")")
        end
    --
    -- Config Player died Sounds
    --
    elseif msg == "player" then
        if CritLogDB.PlayerSoundFlag then
            CritLogDB.PlayerSoundFlag = false
            print("CritLog PlayerDeathSound Off ("..tostring(CritLogDB.PlayerSoundFlag)..")")
        else
            CritLogDB.PlayerSoundFlag = true
            print("CritLog PlayerDeathSound On ("..tostring(CritLogDB.PlayerSoundFlag)..")")
        end
    --
    -- Config Tank died Sounds
    --
    elseif msg == "tank" then
        if CritLogDB.TankSoundFlag then
            CritLogDB.TankSoundFlag = false
            print("CritLog TankSound Off ("..tostring(CritLogDB.TankSoundFlag)..")")
        else
            CritLogDB.TankSoundFlag = true
            print("CritLog TankSound On ("..tostring(CritLogDB.TankSoundFlag)..")")
        end
    --
    -- Config Boss died Sounds
    --
    elseif msg == "boss" then
        if CritLogDB.BossSoundFlag then
            CritLogDB.BossSoundFlag = false
            print("CritLog BossSound Off ("..tostring(CritLogDB.BossSoundFlag)..")")
        else
            CritLogDB.BossSoundFlag = true
            print("CritLog BossSound On ("..tostring(CritLogDB.BossSoundFlag)..")")
        end
    --
    -- Config overall on Death sounds (excluding Bosses)
    --
    elseif msg == "dead" then
        if CritLogDB.DeadSoundFlag then
            CritLogDB.DeadSoundFlag = false
            print("CritLog DeathSound Off ("..tostring(CritLogDB.DeadSoundFlag)..")")
        else
            CritLogDB.DeadSoundFlag = true
            print("CritLog DeathSound On ("..tostring(CritLogDB.DeadSoundFlag)..")")
        end
    --
    -- Config for "over 9000 damage" Sound (off by default)
    --
    elseif msg == "xtreme" then
        if CritLogDB.XtremeSoundFlag then
            CritLogDB.XtremeSoundFlag = false
            print("CritLog XtremeSound Off ("..tostring(CritLogDB.XtremeSoundFlag)..")")
        else
            CritLogDB.XtremeSoundFlag = true
            print("CritLog XtremeSound On ("..tostring(CritLogDB.XtremeSoundFlag)..")")
        end
    --
    -- Config for Level-Range on crits
    --
    elseif msg == "level" then
        if CritLogDB.AllLevel then
            CritLogDB.AllLevel = false
            print("CritLog: Enemy Level + 9 < Player Level to log DAMAGE Crits (GREEN Level Units) only")
        else
            CritLogDB.AllLevel = true
            print("CritLog: Enemy Level does not matter now")
        end
    --
    -- Shows list of all commands
    --
    elseif msg == "help" then
        print("/cl reset: sets all Logs to 0")
        print("/cl level: changes level requirements for crit logs")
        print("/cl sound: turns BÄM sound on/off (highscore sound)")
        print("/cl allcrits: turns BÄM sound on/off for all crits")
        print("/cl whitehit: turns BÄM sound on/off for all WHITEHIT crits")
        print("/cl xtreme: turns sound for hits over 9000 damage on/off (off by default)")
        print("/cl ready: turns ReadyCheck Sound on/off")
        print("/cl aura: turns Aura/Spell Sound on/off")
        print("------------")
        print("/cl priest: turns Priest Sound on/off")
        print("/cl melee: turns Melee Sound on/off")
        print("/cl tank: turns Tank Sound on/off")
        print("/cl boss: turns Boss Sound on/off")
        print("/cl player: turns Player Death Sound on/off")
        print("/cl dead: turns  OnDeath Sound on/off (turn on for priest, melee, tank and boss config to work)")
        print("------------")
        print("/cl config: shows actual config/DB-data")
        print("/cl      : prints CritLogs")
    --
    -- Prints actual Config/Data from DB
    --
    elseif msg == "config" then
        print("/cl level: " .. tostring(CritLogDB.AllLevel))
        print("/cl sound: " .. tostring(CritLogDB.SoundFlag))
        print("/cl allcrits: " .. tostring(CritLogDB.AllCritFlag))
        print("/cl whitehit: " .. tostring(CritLogDB.WhiteHitFlag))
        print("/cl xtreme: " .. tostring(CritLogDB.XtremeSoundFlag))
        print("/cl ready: " .. tostring(CritLogDB.ReadySoundFlag))
        print("/cl aura: " .. tostring(CritLogDB.AuraSoundFlag))
        print("------------")
        print("/cl priest: " .. tostring(CritLogDB.PriestSoundFlag))
        print("/cl melee: " .. tostring(CritLogDB.MeleeSoundFlag))
        print("/cl tank: " .. tostring(CritLogDB.TankSoundFlag))
        print("/cl boss: " .. tostring(CritLogDB.BossSoundFlag))
        print("/cl player: " .. tostring(CritLogDB.PlayerSoundFlag))
        print("/cl dead: " .. tostring(CritLogDB.DeadSoundFlag))

    --
    -- Prints Highest Crits
    --
    else
        print("DAMAGE Crit "..CritLogDB.DAC_Name..": "..CritLogDB.DamageAbilityCrit.." ("..CritLogDB.DAC_Tar..")")
        print("DAMAGE Crit WhiteHit: "..CritLogDB.WhiteHitCrit.." ("..CritLogDB.WHC_Tar..")")
        print("HEAL Crit "..CritLogDB.HAC_Name..": "..CritLogDB.HealAbilityCrit.." ("..CritLogDB.HAC_Tar..")")
        print("/cl help for list of commands")
    end
end

---------------------------------------------------
-- Shortcuts: /cl <command> and /critlog <command>
---------------------------------------------------

SLASH_CRITLOG1, SLASH_CRITLOG2 = '/critlog', '/cl'
SlashCmdList["CRITLOG"] = PrintCritLogs
--SlashCmdList["CRITLOG"] = MyAddonCommands
