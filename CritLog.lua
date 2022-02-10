CritLog = { }



--Version
local CRITLOG_VERSION = "0.1.4.2"

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
local MELEE_DEAD_SOMINA = 'somina.mp3'
local MELEE_DEAD_MOON = 'doh.mp3'
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
local DRUM_SOUND = 'dkRapL.mp3'
local INNERVATE1 = 'Inervate1.mp3'
local INNERVATE2 = 'Inervate2.mp3'
local MANATIDESOUND = 'Manatide.mp3'
local BLOODLUS_SOUND = 'Bloodlust.mp3'
local POWERINFUSION1 = 'Surprise.mp3'
local POWERINFUSION2 = 'Surprise2.mp3'
local POWERINFUSION3 = 'Surprise3.mp3'
local PAINSUP_SOUND = 'Painsup.mp3'
local HYMN_OF_HOPE_SOUND = 'HymnOfHope.mp3'
local BUBBLE_BOB = 'Bubble.mp3'
local TABLE_SOUND = 'Table.mp3'
local HEALTH_STONE_SOUND = 'healthstone.mp3'
local DIVINE_INT_SOUND = 'divineInt.mp3'
local DIVINE_INT_SOUND2 = 'divineInt2.mp3'
local SOULSTONE_SOUND = 'soulstone.mp3'
local SOULSTONE_SOUND2 = 'soulstone2.mp3'
local SOULSTONE_SOUND3 = 'soulstone3.mp3'
local EVO_SOUND = 'evo.mp3'


-------------------
-- Roll Sounds:
-------------------
local ROLL_SOUND_100 = 'roll100.mp3'
local ROLL_SOUND_10 = 'roll10.mp3'
local ROLL_SOUND_5 = 'roll5.mp3'
local ROLL_SOUND_1 = 'roll1.mp3'
local ROLL_SOUND_69 = 'roll69.mp3'
local ROLL_SOUND_95 = 'roll95.mp3'

-------------------
-- other sounds:
--------------------
local READY_CHECK_SOUND = 'Ready.mp3'
local LOGIN_SOUND = 'Login.mp3'
local RUBY_SOUND = 'Ruby.mp3'


--SoundLists:
local TANK_DEAD_LIST = {TANK_DEAD, TANK_DEAD2}
local BOSS_DEAD_LIST = {BOSS_DEAD, BOSS_DEAD2}
local ANGEL_LIST = { ANGELS1, ANGELS2 }
local INNERVATE_SOUND_LIST = {INNERVATE1, INNERVATE2}
local POWERINFUSION_LIST = { POWERINFUSION1, POWERINFUSION2, POWERINFUSION3 }
local DIVINE_INT_SOUND_LIST = { DIVINE_INT_SOUND, DIVINE_INT_SOUND2 }
local SOULSTONE_SOUND_LIST = { SOULSTONE_SOUND, SOULSTONE_SOUND2, SOULSTONE_SOUND3 }

-----------
--NAMES
-----------
--FILL OUT THOSE FOR THE FUN :
local BOSS_NAMES = {}
local BOSS_NAMES_GERMAN = {}

local MELEE_NAMES = {"Caliplatexx"; "Schnutz", "Synday", "Kamicaze", "Alcira", "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr", "Truffi", "Gradba", "Zoiy", "Ronnyflex" }
local TANK_NAMES = {"Emanuello", "Warripal", "Caliplatex", "Emanuelloo", "Truby", "Trubÿ", "Ketamartin","Hïnatahÿuuga" ,"Kîtten"}
local HEALPRIEST_NAMES = {"Ilenkov", "Epyç","Pestdoktor"}

-- Ability names English and german:
local BLOODLUST_NAMES = {'Bloodlust', 'Heroism', 'Kampfrausch', 'Heldentum'}
local DRUM_NAMES = {'Greater Drums of Battle', 'Drums of Battle', 'Große Trommeln der Schlacht', 'Trommeln der Schlacht'}
local INERVATE_NAMES = {'Innervate', 'Anregen'}
local POWERINFUSION_NAMES = {'Power Infusion', 'Seele der Macht'} 
local PAINSUP_NAMES = {'Pain Suppression', 'Schmerzunterdrückung'}
local HYMN_OF_HOPE_NAMES = {'Hymn of Hope', 'Hymne der Hoffnung'} 
local MANATIDE_NAMES = {'Mana Tide Totem', 'Totem der Manaflut'}
local REFRESHMENT_NAMES = {'Ritual of Refreshment', 'Tischlein deck dich'} 
local HEALTH_STONE_NAMES = {'Ritual of Souls', 'Ritual der Seelen'} 
local SREDEMPTION_NAMES = {"Spirit of Redemption", "Geist der Erlösung"}
local BOB_NAMES = {"Blessing of Protection", "Segen des Schutzes"}
local DIVINE_INT = {"Göttliches Eingreifen", "Divine Intervention"}
local SOULSTONE_NAMES = {"Soulstone Resurrection", "Seelenstein Auferstehung" }
local EVO_NAMES = {"Evocation", "Hervorrufung" }

local ENVIRONMENTAL_TYPE = {"Falling", "Drowning", "Fatique", "Fire", "Fire", "Slime"}

local mageTimer = 0
local hexerTimer = 0
--tmp variables:
--local last_soundboard_trigger = ""

-- Variables for Readycheck functions
local NUMBER_OF_RAIDMEMBER = 0
local TMPNR_RM = 0


local frame = CreateFrame("Frame")


---------------------------------------------------
-- Register Events Here:
---------------------------------------------------
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("READY_CHECK")
--frame:RegisterEvent("PLAYER_REGEN_DISABLED")
--frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")

frame:SetScript("OnEvent", function(this, event, ...)
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
    if CritLogDB.LoginSoundFlag then
        PlaySoundFile(CritLogDB.SoundFile..LOGIN_SOUND, 'Master')
    end
    
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
    
    local message, author = ...
     
    --string.lower(myString)
    --print(message,author)
    if string.lower(message) =="raid ende" or string.lower(message) =="raid end"  then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(CritLogDB.SoundFile..'bye.mp3', 'Master')
        PlaySoundFile(CritLogDB.SoundFile..'end.mp3', 'Master')
    end
    if string.lower(message) =="shit show" or string.lower(message) =="wipe"  then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(CritLogDB.SoundFile..'wipe.mp3', 'Master')
    end
    
end

------------------------------------------------------------------
-- Function is triggert with Chat MSG in a raid
------------------------------------------------------------------
function CritLog:CHAT_MSG_RAID(...)
    
    local message, author = ...
     
    --string.lower(myString)
    --print(message,author)
    if string.find(message, "CrossGambling: A new game has been started! Type 1 to join!") then -- and Split(author, "-")[1] == "Kîtten" then
        PlaySoundFile(CritLogDB.SoundFile..'lottery2.wav', 'Master')
        PlaySoundFile(CritLogDB.SoundFile..'lottery3.mp3', 'Master')
    end
    
end

---------------------------------------------------
-- Function is triggert with a Ready Check
---------------------------------------------------
function CritLog:READY_CHECK(...)
    
    -- Plays Ready Check Sound
    if CritLogDB.ReadySoundFlag then
        PlaySoundFile(CritLogDB.SoundFile..READY_CHECK_SOUND, 'Master')
    end
    
end

--function CritLog:PLAYER_REGEN_DISABLED(...)
--    xx = ...
--    print("combat entaaaaaaaa  "..xx)
--end

---------------------------------------------------
-- Function is triggert with a /roll /random etc
---------------------------------------------------
function CritLog:CHAT_MSG_SYSTEM(...)
    if CritLogDB.RollSoundFlag then
        local message = ...
        local author, rollResult, rollMin, rollMax = string.match(message, "(.+) rolls (%d+) %((%d+)-(%d+)%)")
        
        if message:find('würfelt', 1, true) then
            author, rollResult, rollMin, rollMax = string.match(message, "(.+) würfelt%. Ergebnis%: (%d+) %((%d+)-(%d+)%)")
            --print(author, rollResult)
        end
        if author then
            --print(rollMin, rollMax, rollResult)
            
            --play sound only if roll is 1-100
            if tonumber(rollMin) == 1 and tonumber(rollMax) >= 100 then ---
                if tonumber(rollResult) == tonumber(rollMax) then
                    PlaySoundFile(CritLogDB.SoundFile..ROLL_SOUND_100, 'Master')
                elseif tonumber(rollResult) == 1*rollMax/100 then
                    PlaySoundFile(CritLogDB.SoundFile..ROLL_SOUND_1, 'Master')
                elseif tonumber(rollResult) == 69 then
                    PlaySoundFile(CritLogDB.SoundFile..ROLL_SOUND_69, 'Master')
                elseif tonumber(rollResult) >= 92*rollMax/100 then
                    PlaySoundFile(CritLogDB.SoundFile..ROLL_SOUND_95, 'Master')
                elseif tonumber(rollResult) < 8*rollMax/100 then
                    PlaySoundFile(CritLogDB.SoundFile..ROLL_SOUND_5, 'Master')
                elseif tonumber(rollResult) <= 10*rollMax/100 then
                    PlaySoundFile(CritLogDB.SoundFile..ROLL_SOUND_10, 'Master')
                end
            end      
        end
    end
end

---------------------------------------------------
-- Combat Log Event functions
---------------------------------------------------
function CritLog:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, sv1, sv2, sv3, sv4, sv5, sv6, sv7, sv8, sv9, sv10 = CombatLogGetCurrentEventInfo()
 

 
----------------------------------------------------------------------------
-- Checks if Player got some specific Auras/Buffs and then triggers Sounds
----------------------------------------------------------------------------  
    if CritLogDB.AuraSoundFlag then
        --   UnitInRaid
        --   UnitInParty
        if sourceName == "Yukimî" then 
            --print(difftime (time(), mageTimer))
            --print(subevent)
            --print(sv2)
            --PlaySoundFile(CritLogDB.SoundFile..MELEE_DEAD_SOMINA, 'Master')
        end
        if UnitInParty(sourceName) or UnitInRaid(sourceName) then
            if subevent == "SPELL_SUMMON" then
                --
                -- Mana Tide Totem Sound
                --
                if sv2 ~= nil and tContains( MANATIDE_NAMES, sv2 ) then
                    --print("MANA TIDE TOTEM SCRIPT WORKING")
                    --print(subevent)
                    PlaySoundFile(CritLogDB.SoundFile..MANATIDESOUND, 'Master')
                end
            end
            if subevent == "SPELL_CAST_SUCCESS" and CritLogDB.TableFlag then
                --
                -- Table Sound
                --
                if sv2 ~= nil and tContains( REFRESHMENT_NAMES, sv2 ) then
                    if(difftime (time(), mageTimer)> 100) then
                        mageTimer = time() 
                        PlaySoundFile(CritLogDB.SoundFile..TABLE_SOUND, 'Master')               
                    end                    
                end
                --
                -- HealthStone Sound
                --
                if sv2 ~= nil and tContains( HEALTH_STONE_NAMES, sv2 ) then
                    if(difftime (time(), hexerTimer)> 60) then
                        hexerTimer = time() 
                        PlaySoundFile(CritLogDB.SoundFile..HEALTH_STONE_SOUND, 'Master')               
                    end                    
                end
            end
            --local ICL = InCombatLockdown()
            --print(ICL)
            if sourceName == "Trubÿ" and CritLogDB.TrubyFlag then
                aCD = UnitAffectingCombat(sourceName)
                --print(aCD)
                if subevent == "SPELL_CAST_SUCCESS" and not aCD then
                    if sv2 == "Schild des Rächers" or sv2 == "Avenger's Shield" then
                        PlaySoundFile(CritLogDB.SoundFile..RUBY_SOUND, 'Master')
                    end
                end
            end
        end
        if destGUID == UnitGUID("Player") then -- true if spell targets the player
            --
            -- Gets Trigger if New Aura gets applied ( NOT on refresh of buffs, remove buff with right click to trigger again)
            --
            if subevent == "SPELL_AURA_APPLIED" then
                if tContains( BLOODLUST_NAMES, sv2 ) then
                    PlaySoundFile(CritLogDB.SoundFile..BLOODLUS_SOUND, 'Master')
                end
                --
                -- Drums Sound
                --
                if tContains( DRUM_NAMES, sv2 ) then
                    --print(CritLogDB.SoundFile..INNERVATE_SOUND_LIST[tmpRNDM])
                    PlaySoundFile(CritLogDB.SoundFile..DRUM_SOUND, 'Master')                
                end
                --
                -- Inervate Sound
                --
                if tContains( INERVATE_NAMES, sv2 ) then
                    tmpRNDM = math.random(1, 2)
                    --print(CritLogDB.SoundFile..INNERVATE_SOUND_LIST[tmpRNDM])
                    PlaySoundFile(CritLogDB.SoundFile..INNERVATE_SOUND_LIST[tmpRNDM], 'Master')                
                end
                --
                -- Power Word Infusion Sound
                --
                if tContains( POWERINFUSION_NAMES, sv2 ) then
                    tmpRNDM = math.random(1, 3)
                    PlaySoundFile(CritLogDB.SoundFile..POWERINFUSION_LIST[tmpRNDM], 'Master')
                end
                --
                -- PainSup Sound
                --
                if tContains( PAINSUP_NAMES, sv2 ) then
                    PlaySoundFile(CritLogDB.SoundFile..PAINSUP_SOUND, 'Master')
                end
                --
                -- Hymn of Hope Sound
                --
                if tContains( HYMN_OF_HOPE_NAMES, sv2 ) then
                    PlaySoundFile(CritLogDB.SoundFile..HYMN_OF_HOPE_SOUND, 'Master')
                end
                --
                -- Blessing of Protection Sound
                --
                if tContains( BOB_NAMES, sv2 ) then
                    PlaySoundFile(CritLogDB.SoundFile..BUBBLE_BOB, 'Master')
                end
                --
                -- Evocation Sound
                --
                if tContains( EVO_NAMES, sv2 ) then
                    PlaySoundFile(CritLogDB.SoundFile..EVO_SOUND, 'Master')
                end
                --
                -- Divine Intervention Sound
                -- not sure if its working
                --
                if tContains( DIVINE_INT, sv2 ) then
                    tmpRNDM = math.random(1, 2)
                    PlaySoundFile(CritLogDB.SoundFile..DIVINE_INT_SOUND_LIST[tmpRNDM], 'Master')
                end
                --
                -- Soulstone Sound
                --
                if tContains( SOULSTONE_NAMES, sv2 ) then
                    tmpRNDM = math.random(1, 3)
                    PlaySoundFile(CritLogDB.SoundFile..SOULSTONE_SOUND_LIST[tmpRNDM], 'Master')
                end
            end
        end
    end    
    --
    --  Plays Sound if someone does OVER 9k DMG :D
    -- 
    if CritLogDB.NineK_SoundFlag and Split(sourceGUID, "-")[1] == "Player" then
        if subevent == "SPELL_DAMAGE" then
            --print("shit: "..sv4)
            if tonumber(sv4) > 9000 then
                --print(sv4)
                PlaySoundFile(CritLogDB.SoundFile..XTREME_DMG, 'Master')
                --print("working")
            end    
        end
    end


    
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
    --
    --  Plays Sound and Logs on Heal Crits
    --
        elseif subevent == "SPELL_HEAL" then
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
    
--
-- Heal Priest died
-- might be buggy
--
    if tContains( HEALPRIEST_NAMES, destName ) and CritLogDB.PriestSoundFlag then
        if (ends_with(subevent, '_DAMAGE')) and not tContains( ENVIRONMENTAL_TYPE, sv1 ) and sv2 and tonumber(sv2) and sv2 > 0 then
        tmpRNDM = math.random(1, 2)
        PlaySoundFile(CritLogDB.SoundFile..ANGEL_LIST[tmpRNDM], 'Master')
        print(destName.." died!")
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
                PlaySoundFile(CritLogDB.SoundFile..YOU_DEAD, 'Master')
            end    
        else
            --
            -- Melee died/Moon died
            --
            if  CritLogDB.MeleeSoundFlag then 
                if tContains( MELEE_NAMES, destName ) then
                   if destName == "Schnutz" then
                        PlaySoundFile(CritLogDB.SoundFile..MELEE_DEAD_SCHNUTZ, 'Master')
                    elseif destName == "Feniara" then
                        PlaySoundFile(CritLogDB.SoundFile..MELEE_DEAD_SOMINA, 'Master')
                    elseif destName == "Pappalapap" then
                        PlaySoundFile(CritLogDB.SoundFile..MELEE_DEAD_MOON, 'Master')
                    else
                        PlaySoundFile(CritLogDB.SoundFile..MELEE_DEAD, 'Master')
                    end
                end
            end
            --
            -- Boss died
            -- 
            if CritLogDB.BossSoundFlag then
                if tContains( BOSS_NAMES, destName ) or tContains( BOSS_NAMES_GERMAN, destName ) then
                    tmpRNDM = math.random(1, 2)
                    PlaySoundFile(CritLogDB.SoundFile..BOSS_DEAD_LIST[tmpRNDM], 'Master')
                end
            end
            --
            -- Tank died
            --
            if tContains( TANK_NAMES, destName ) and CritLogDB.TankSoundFlag then
                tmpRNDM = math.random(1, 2)
                PlaySoundFile(CritLogDB.SoundFile..TANK_DEAD_LIST[tmpRNDM], 'Master')
                --print("wtf2")
            end
            --
            -- Heal Priest died
            -- does not work as intendet cause Spirit of Redemption does not count as aura in COMBAT_LOG_EVENT_UNFILTERED
            --
            if tContains( HEALPRIEST_NAMES, destName ) and CritLogDB.PriestSoundFlag then
                tmpRNDM = math.random(1, 2)
                --print(tmpRNDM) 
                PlaySoundFile(CritLogDB.SoundFile..ANGEL_LIST[tmpRNDM], 'Master')
            end
        end
    end    
end

--plays sound file for crits
function CritLog:PlaySoundFile()
    if CritLogDB.SoundFlag then
        PlaySoundFile(CritLogDB.SoundFile..BAM_SOUND, 'Master')
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
            LoginSoundFlag = false,
            ReadySoundFlag = true,
            RollSoundFlag = true,
            AuraSoundFlag = true,
            TableFlag = true,
            TrubyFlag = true,
            NineK_SoundFlag = false,
            PriestSoundFlag = true,
            TankSoundFlag = true,
            MeleeSoundFlag = true,
            PlayerSoundFlag = true,
            BossSoundFlag = true,
            DeadSoundFlag = true,
            GambleFlag = true,
            ToniFlag = false,
            SoundFile = SOUNDPATH
        }

        print("CritLog Initialized")
        --print("CritLog Sounds Off")
        print("/cl help for list of commands")
        message('\n Kîtten is DruidGod \n\n Pappi is ShamanKing \n') -- IMPORTANT DO NOT DELETE :D !!!11!1!11

    end
end


---------------------------------------------------
--  Split String Functions
---------------------------------------------------
function Split(s, delimiter)
    result = {};
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
        
        --Character specifc Database:
            CritLogDB.DamageAbilityCrit = 0
            CritLogDB.DAC_Name = ""
            CritLogDB.DAC_Tar = ""
            CritLogDB.WhiteHitCrit = 0
            CritLogDB.WHC_Tar = ""
            CritLogDB.HealAbilityCrit = 0
            CritLogDB.HAC_Name = ""
            CritLogDB.HAC_Tar =""

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
    -- Config for Roll Sound
    --
    elseif msg == "roll" then
        if CritLogDB.RollSoundFlag then
            CritLogDB.RollSoundFlag = false
            print("CritLog RollSound Off ("..tostring(CritLogDB.RollSoundFlag)..")")
        else
            CritLogDB.RollSoundFlag = true
            print("CritLog RollSound On ("..tostring(CritLogDB.RollSoundFlag)..")")
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
    -- Config for Truby Sound
    --
    elseif msg == "truby" then
        if CritLogDB.TrubyFlag then
            CritLogDB.TrubyFlag = false
            print("CritLog Truby Sound Off ("..tostring(CritLogDB.TrubyFlag)..")")
        else
            CritLogDB.TrubyFlag = true
            print("CritLog Truby Sound On ("..tostring(CritLogDB.TrubyFlag)..")")
        end
    --
    -- Config for MageTable Sound
    --
    elseif msg == "table" then
        if CritLogDB.TableFlag then
            CritLogDB.TableFlag = false
            print("CritLog Mage Table Sound Off ("..tostring(CritLogDB.TableFlag)..")")
        else
            CritLogDB.TableFlag = true
            print("CritLog Mage Table Sound On ("..tostring(CritLogDB.TableFlag)..")")
        end
    --
    -- Config for 9k Damage Sound
    --
    elseif msg == "9k" then
        if CritLogDB.NineK_SoundFlag then
            CritLogDB.NineK_SoundFlag = false
            print("CritLog over 9k Damage Sound Off ("..tostring(CritLogDB.NineK_SoundFlag)..")")
        else
            CritLogDB.NineK_SoundFlag = true
            print("CritLog over 9k Damage Sound On ("..tostring(CritLogDB.NineK_SoundFlag)..")")
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
    -- Config Lottery sounds
    --
    elseif msg == "gamble" then
        if CritLogDB.GambleFlag then
            CritLogDB.GambleFlag = false
            print("CritLog GambleSound Off ("..tostring(CritLogDB.GambleFlag)..")")
        else
            CritLogDB.GambleFlag = true
            print("CritLog GambleSound On ("..tostring(CritLogDB.GambleFlag)..")")
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
        print("/cl roll: turns Roll Sound on/off")
        print("/cl aura: turns Aura/Spell Sound on/off")
        print("/cl truby: turns Truby Sound on/off (req. AuraSounds)")
        print("/cl table: turns Mage Table/ Hexer Ritual Sound on/off (req. AuraSounds)")
        print("/cl 9k: turns 9k on/off")
        print("------------")
        print("/cl priest: turns Priest Sound on/off")
        print("/cl melee: turns Melee Sound on/off")
        print("/cl tank: turns Tank Sound on/off")
        print("/cl boss: turns Boss Sound on/off")
        print("/cl player: turns Player Death Sound on/off")
        print("/cl dead: turns  OnDeath Sound on/off (turn on for priest, melee, tank and boss config to work)")
        print("------------")
        print("/cl gamble: turns lottery Sounds on/off")
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
        print("/cl roll: " .. tostring(CritLogDB.RollSoundFlag))
        print("/cl aura: " .. tostring(CritLogDB.AuraSoundFlag))
        print("/cl truby: " .. tostring(CritLogDB.TrubyFlag))
        print("/cl table: " .. tostring(CritLogDB.TableFlag))
        print("/cl 9k: " .. tostring(CritLogDB.TableFlag))
        print("------------")
        print("/cl priest: " .. tostring(CritLogDB.PriestSoundFlag))
        print("/cl melee: " .. tostring(CritLogDB.MeleeSoundFlag))
        print("/cl tank: " .. tostring(CritLogDB.TankSoundFlag))
        print("/cl boss: " .. tostring(CritLogDB.BossSoundFlag))
        print("/cl player: " .. tostring(CritLogDB.PlayerSoundFlag))
        print("/cl dead: " .. tostring(CritLogDB.DeadSoundFlag))
        print("------------")
        print("/cl gamble: " .. tostring(CritLogDB.GambleFlag))
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