CritLog = { }



--Version
local CRITLOG_VERSION = "0.1.1"

----------------
--SOUNDS:
----------------
local SOUNDPATH = 'Interface/AddOns/CritLog/sounds/' --path of  normal sounds
local ASSISOUND = 'Interface/AddOns/CritLog/sounds/assi/' -- path of assi sounds

local BAM_SOUND = 'at_bam_babam.mp3'        -- crit sounds
local XTREME_DMG = 'Xtreme.mp3'

-------------------
-- on death sounds:
--------------------
local MELEE_DEAD = 'wilhelm.ogg'
local MELEE_DEAD_SCHNUTZ = 'schnutz.mp3'
local YOU_DEAD = 'MarioDeath.mp3'
local BOSS_DEAD = 'FFX.mp3'
local BOSS_DEAD2 = 'Zelda.mp3'
local TANK_DEAD = 'Tank.mp3'
local TANK_DEAD2 = 'Tank2.mp3'
local ANGELS1 = 'Angels1.mp3'
local ANGELS2 = 'Angels2.mp3'

-------------------
-- on Aura sounds:
--------------------
local INNERVATE1 = 'Inervate1.mp3'
local INNERVATE2 = 'Inervate2.mp3'
local MANATIDESOUND = 'Manatide.mp3'
local BLOODLUS_SOUND = 'Bloodlust.mp3'
local POWERINFUSION1 = 'Surprise.mp3'
local POWERINFUSION2 = 'Surprise2.mp3'
local POWERINFUSION3 = 'Surprise3.mp3'
local BUBBLE_BOB = 'Bubble.mp3'
local DIVINE_INT_SOUND = 'divineInt.mp3'
local SOULSTONE_SOUND = 'soulstone.mp3'
local SOULSTONE_SOUND2 = 'soulstone2.mp3'
local SOULSTONE_SOUND3 = 'soulstone3.mp3'

-------------------
-- other sounds:
--------------------
local READY_CHECK_SOUND = 'Ready.mp3'
local LOGIN_SOUND = 'Login.mp3'


--SoundLists:
local TANK_DEAD_LIST = {TANK_DEAD, TANK_DEAD2}
local BOSS_DEAD_LIST = {BOSS_DEAD, BOSS_DEAD2}
local ANGEL_LIST = { ANGELS1, ANGELS2 }
local INNERVATE_SOUND_LIST = {INNERVATE1, INNERVATE2}
local POWERINFUSION_LIST = { POWERINFUSION1, POWERINFUSION2, POWERINFUSION3 }
local SOULSTONE_SOUND_LIST = { SOULSTONE_SOUND, SOULSTONE_SOUND2, SOULSTONE_SOUND3 }

--
-- Sound files that are byte-identical between the default and Toni profile
-- only exist once on disk, under the default folder, to keep the packaged
-- addon smaller. ResolveSound() always loads them from there regardless of
-- the active profile.
--
local SHARED_WITH_DEFAULT = {
    ['Angels1.mp3'] = true,
    ['Angels2.mp3'] = true,
    ['at_bam_babam.mp3'] = true,
    ['divineInt.mp3'] = true,
    ['FFX.mp3'] = true,
    ['Ready.mp3'] = true,
    ['soulstone.mp3'] = true,
    ['soulstone2.mp3'] = true,
    ['soulstone3.mp3'] = true,
    ['wilhelm.ogg'] = true,
    ['wipe.mp3'] = true,
    ['Zelda.mp3'] = true,
}

--
-- Within the Toni profile, Surprise2.mp3/Surprise3.mp3 and Tank2.mp3 were
-- byte-identical to Surprise.mp3/Tank.mp3 respectively, so only one physical
-- copy of each is kept. This redirects the "random" pick to the file that
-- is actually still on disk; the default profile keeps its distinct clips
-- and is unaffected.
--
local TONI_ALIASES = {
    ['Surprise2.mp3'] = 'Surprise.mp3',
    ['Surprise3.mp3'] = 'Surprise.mp3',
    ['Tank2.mp3'] = 'Tank.mp3',
}

local function ResolveSound(filename)
    if SHARED_WITH_DEFAULT[filename] then
        return SOUNDPATH..filename
    end
    if CritLogDB.SoundFile == ASSISOUND and TONI_ALIASES[filename] then
        return ASSISOUND..TONI_ALIASES[filename]
    end
    return CritLogDB.SoundFile..filename
end

-----------
--NAMES
-----------
--FILL OUT THOSE FOR THE FUN :
local BOSS_NAMES = {"Lady Vashj", "Kael'thas Sunstrider" , "Hydross the Unstable", "The Lurker Below", "Leotheras the Blind", "Fathom-Lord Karathress", "Morogrim Tidewalker", "Al'ar", "High Astromancer Solarian", "Void Reaver", "Rage Winterchill", "Anetheron", "Kaz'rogal", "Azgalor", "Archimonde", "High Warlord Naj'entus", "Supremus", "Shade of Akama", "Gurtogg Bloodboil", "Reliquary of the Lost", "Teron Gorefiend", "Mother Shahraz", "The Illidari Council", "Illidan Stormrage"}
local BOSS_NAMES_GERMAN = {"Lady Vashj", "Kael'thas Sonnenwanderer", "Hydross der Unstete", "Das Grauen aus der Tiefe", "Leotheras der Blinde", "Tiefenlord Karathress", "Morogrim Gezeitenwandler", "Al'ar", "Hochastromantin Solarian", "Leerhäscher", "Furor Winterfrost", "Kaz'rogal", "Azgalor", "Archimonde", "Oberster Kriegsfürst Naj'entus", "Supremus", "Akamas Schemen", "Gurtogg Siedeblut", "Reliquiar der Verirrten", "Teron Blutschatten", "Mutter Shahraz", "Der Rat der Illidari", "Illidan Sturmgrimm"  }
local MELEE_NAMES = { "Schnutz", "Synday", "Kamicaze", "Alcira", "Shocksx", "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr", "Truffi", "Gradba", "Zoiy" }
local TANK_NAMES = {"Truby", "Ketamartin","Hïnatahÿuuga" ,"Kîtten"}
local HEALPRIEST_NAMES = {"Ilenkov", "Epyç"}

-- Ability names English and german:
local BLOODLUST_NAMES = {'Bloodlust', 'Heroism', 'Blutrausch', 'Heldentum'}
local INERVATE_NAMES = {'Innervate', 'Anregen'}
local POWERINFUSION_NAMES = {'Power Infusion', 'Seele der Macht'}
local MANATIDE_NAMES = {'Mana Tide Totem', 'Totem der Manaflut'}
local SREDEMPTION_NAMES = {"Spirit of Redemption", "Geist der Erlösung"}
local BOB_NAMES = {"Blessing of Protection", "Segen des Schutzes"}
local DIVINE_INT = {"Göttliches Eingreifen", "Divine Intervention"}
local SOULSTONE_NAMES = {"Seelenstein Auferstehung", "Soulstone Resurrection"}



local frame = CreateFrame("Frame")


---------------------------------------------------
-- Register Events Here:
---------------------------------------------------
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("READY_CHECK")
--frame:RegisterEvent("ZONE_CHANGED")
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

    -- Plays Login Sound
--    if CritLogDB.LoginSoundFlag then
--        PlaySoundFile(CritLogDB.SoundFile..LOGIN_SOUND, 'Master')
--    end

end

---------------------------------------------------
-- Function is triggert at Zone Change
--
-- Event NOT REGISTERED ATM
---------------------------------------------------
function CritLog:ZONE_CHANGED()

    --possible events:
    --ZONE_CHANGED_NEW_AREA
    --CHAT_MSG_RAID#
    --CHAT_MSG_RAID_LEADER

    print(GetSubZoneText())
    print(GetRealZoneText())


end


------------------------------------------------------------------
-- Function is triggert with Chat MSG in a raid (raidleader only)
------------------------------------------------------------------
function CritLog:CHAT_MSG_RAID_LEADER(...)

    local message, _ = ...

    --string.lower(myString)
    --print(message,author)
    if string.lower(message) =="raid ende" or string.lower(message) =="raid end"  then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(ResolveSound('bye.mp3'), 'Master')
        PlaySoundFile(ResolveSound('end.mp3'), 'Master')
    end
    if string.lower(message) =="shit show" or string.lower(message) =="wipe"  then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(ResolveSound('wipe.mp3'), 'Master')
    end

end

---------------------------------------------------
-- Function is triggert with a Ready Check
---------------------------------------------------
function CritLog:READY_CHECK()

    -- Plays Ready Check Sound
    if CritLogDB.ReadySoundFlag then
        PlaySoundFile(ResolveSound(READY_CHECK_SOUND), 'Master')
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
                if sv2 ~= nil and tContains( MANATIDE_NAMES, sv2 ) then
                    --print("MANA TIDE TOTEM SCRIPT WORKING")
                    --print(subevent)
                    PlaySoundFile(ResolveSound(MANATIDESOUND), 'Master')
                end
            end
        end
        if destGUID == UnitGUID("Player") then -- true if spell targets the player
            --
            -- Gets Trigger if New Aura gets applied ( NOT on refresh of buffs, remove buff with right click to trigger again)
            --
            if subevent == "SPELL_AURA_APPLIED" then
                if tContains( BLOODLUST_NAMES, sv2 ) then
                    PlaySoundFile(ResolveSound(BLOODLUS_SOUND), 'Master')
                end
                --
                -- Inervate Sound
                --
                if tContains( INERVATE_NAMES, sv2 ) then
                    local tmpRNDM = math.random(1, 2)
                    --print(CritLogDB.SoundFile..INNERVATE_SOUND_LIST[tmpRNDM])
                    PlaySoundFile(ResolveSound(INNERVATE_SOUND_LIST[tmpRNDM]), 'Master')
                end
                --
                -- Power Word Infusion Sound
                --
                if tContains( POWERINFUSION_NAMES, sv2 ) then
                    local tmpRNDM = math.random(1, 3)
                    PlaySoundFile(ResolveSound(POWERINFUSION_LIST[tmpRNDM]), 'Master')
                end
                --
                -- Blessing of Protection Sound
                --
                if tContains( BOB_NAMES, sv2 ) then
                    PlaySoundFile(ResolveSound(BUBBLE_BOB), 'Master')
                end
                --
                -- Divine Intervention Sound
                --
                if tContains( DIVINE_INT, sv2 ) then
                    PlaySoundFile(ResolveSound(DIVINE_INT_SOUND), 'Master')
                end
                --
                -- Soulstone Sound
                --
                if tContains( SOULSTONE_NAMES, sv2 ) then
                    local tmpRNDM = math.random(1, 3)
                    PlaySoundFile(ResolveSound(SOULSTONE_SOUND_LIST[tmpRNDM]), 'Master')
                end
            end
        end
    end
    --
    --  Plays Sound if OVER 9k DMG :D
    --    testphase should be working
    --
    --if Split(sourceGUID, "-")[1] == "Player" then
    --    if subevent == "SPELL_DAMAGE" then
            --print("shit: "..sv4)
    --        if tonumber(sv4) > 9000 then
                --print(sv4)
     --           PlaySoundFile(CritLogDB.SoundFile..XTREME_DMG, 'Master')
                --print("working")
     --       end
    --    end
        --
        -- Spirit of Redemtption TEST ------not working
        --
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
    if tContains( BOSS_NAMES, destName ) then
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
                PlaySoundFile(ResolveSound(YOU_DEAD), 'Master')
            end
        else
            --
            -- Melee died
            --
            if  CritLogDB.MeleeSoundFlag then
                if tContains( MELEE_NAMES, destName ) then
                   if destName == "Schnutz" then
                        PlaySoundFile(ResolveSound(MELEE_DEAD_SCHNUTZ), 'Master')
                    else
                        PlaySoundFile(ResolveSound(MELEE_DEAD), 'Master')
                    end
                end
            end
            --
            -- Boss died
            --
            if CritLogDB.BossSoundFlag then
                if tContains( BOSS_NAMES, destName ) or tContains( BOSS_NAMES_GERMAN, destName ) then
                    local tmpRNDM = math.random(1, 2)
                    PlaySoundFile(ResolveSound(BOSS_DEAD_LIST[tmpRNDM]), 'Master')
                end
            end
            --
            -- Tank died
            --
            if tContains( TANK_NAMES, destName ) and CritLogDB.TankSoundFlag then
                local tmpRNDM = math.random(1, 2)
                PlaySoundFile(ResolveSound(TANK_DEAD_LIST[tmpRNDM]), 'Master')
                --print("wtf2")
            end
            --
            -- Heal Priest died
            --
            if tContains( HEALPRIEST_NAMES, destName ) and CritLogDB.PriestSoundFlag then
                local tmpRNDM = math.random(1, 2)
                --print(tmpRNDM)
                PlaySoundFile(ResolveSound(ANGEL_LIST[tmpRNDM]), 'Master')
            end
        end
    end
end

--plays sound file for crits
function CritLog:PlaySoundFile()
    if CritLogDB.SoundFlag then
        PlaySoundFile(ResolveSound(BAM_SOUND), 'Master')
    end
end


---------------------------------------------------
--  Sets Character spec. Variables (DataBase)
---------------------------------------------------
function CritLog:SetDefaults()

    --
    -- Checks for last CritLog-Version and builds initiale DataBase ( New Version resets config )
    --
    if not CritLogDB or CritLogDB.Version ~= CRITLOG_VERSION then


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
            SoundFlag = true,
            AllLevel = false,
            AllCritFlag = false,
            WhiteHitFlag = true,
            LoginSoundFlag = true,
            ReadySoundFlag = true,
            AuraSoundFlag = true,
            PriestSoundFlag = true,
            TankSoundFlag = true,
            MeleeSoundFlag = true,
            PlayerSoundFlag = true,
            BossSoundFlag = true,
            DeadSoundFlag = true,
            ToniFlag = false,
            SoundFile = SOUNDPATH
        }

        print("CritLog Initialized")
        --print("CritLog Sounds Off")
        print("/cl help for list of commands")
        --message('\n Kîtten is DruidLord \n\n Pappi is ShamanKing \n') -- IMPORTANT DO NOT DELETE :D !!!11!1!11

    end
end


---------------------------------------------------
--  Split String Functions
---------------------------------------------------
function Split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

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
        local tmpLoginSoundFlag = CritLogDB.LoginSoundFlag
        local tmpReadySoundFlag = CritLogDB.ReadySoundFlag
        local tmpAuraSoundFlag = CritLogDB.AuraSoundFlag
        local tmpPriestSoundFlag = CritLogDB.PriestSoundFlag
        local tmpTankSoundFlag = CritLogDB.TankSoundFlag
        local tmpMeleeSoundFlag = CritLogDB.MeleeSoundFlag
        local tmpPlayerSoundFlag = CritLogDB.PlayerSoundFlag
        local tmpBossSoundFlag = CritLogDB.BossSoundFlag
        local tmpDeadSoundFlag = CritLogDB.DeadSoundFlag
        local tmpToniFlag = CritLogDB.ToniFlag
        local tmpSoundFile = CritLogDB.SoundFile

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
            LoginSoundFlag = tmpLoginSoundFlag,
            ReadySoundFlag = tmpReadySoundFlag,
            AuraSoundFlag = tmpAuraSoundFlag,
            PriestSoundFlag = tmpPriestSoundFlag,
            TankSoundFlag = tmpTankSoundFlag,
            MeleeSoundFlag = tmpMeleeSoundFlag,
            BossSoundFlag = tmpBossSoundFlag,
            PlayerSoundFlag = tmpPlayerSoundFlag,
            DeadSoundFlag = tmpDeadSoundFlag,
            ToniFlag = tmpToniFlag,
            SoundFile = tmpSoundFile
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
    -- Config for Login Sound
    --
    elseif msg == "login" then
        if CritLogDB.LoginSoundFlag then
            CritLogDB.LoginSoundFlag = false
            print("CritLog LoginSound Off ("..tostring(CritLogDB.LoginSoundFlag)..")")
        else
            CritLogDB.LoginSoundFlag = true
            print("CritLog LoginSound On ("..tostring(CritLogDB.LoginSoundFlag)..")")
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
    -- Config TONI Sounds
    --
    elseif msg == "toni" then
        if CritLogDB.ToniFlag then
            CritLogDB.ToniFlag = false
            CritLogDB.SoundFile = SOUNDPATH
            print("CritLog special Toni Sounds Off ("..tostring(CritLogDB.ToniFlag)..")")
        else
            CritLogDB.ToniFlag = true
            CritLogDB.SoundFile = ASSISOUND
            print("CritLog special Toni Sounds On ("..tostring(CritLogDB.ToniFlag)..")")
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
        print("/cl login: turns Login Sound on/off")
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
        print("/cl toni: turns special Toni Sounds on/off (vulgar)")
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
        print("/cl login: " .. tostring(CritLogDB.LoginSoundFlag))
        print("/cl ready: " .. tostring(CritLogDB.ReadySoundFlag))
        print("/cl aura: " .. tostring(CritLogDB.AuraSoundFlag))
        print("------------")
        print("/cl priest: " .. tostring(CritLogDB.PriestSoundFlag))
        print("/cl melee: " .. tostring(CritLogDB.MeleeSoundFlag))
        print("/cl tank: " .. tostring(CritLogDB.TankSoundFlag))
        print("/cl boss: " .. tostring(CritLogDB.BossSoundFlag))
        print("/cl player: " .. tostring(CritLogDB.PlayerSoundFlag))
        print("/cl dead: " .. tostring(CritLogDB.DeadSoundFlag))
        print("------------")
        print("/cl toni: " .. tostring(CritLogDB.ToniFlag))

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
