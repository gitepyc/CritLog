local function toggle(field, enabledMessage, disabledMessage)
    CritLogDB[field] = not CritLogDB[field]
    if CritLogDB[field] then
        print(enabledMessage.." ("..tostring(CritLogDB[field])..")")
    else
        print(disabledMessage.." ("..tostring(CritLogDB[field])..")")
    end
end

local function printHelp()
    print("/cl reset: sets all logs to 0")
    print("/cl level: changes level requirements for crit logs")
    print("/cl sound: turns BÄM sound on/off (highscore sound)")
    print("/cl allcrits: turns BÄM sound on/off for all crits")
    print("/cl whitehit: turns BÄM sound on/off for all white-hit crits")
    print("/cl xtreme: turns sound for hits over 9000 damage on/off (off by default)")
    print("/cl ready: turns ReadyCheck sound on/off")
    print("/cl aura: turns aura/spell sound on/off")
    print("------------")
    print("/cl priest: turns priest sound on/off")
    print("/cl melee: turns melee sound on/off")
    print("/cl tank: turns tank sound on/off")
    print("/cl boss: turns boss sound on/off")
    print("/cl player: turns player death sound on/off")
    print("/cl dead: turns death sounds on/off")
    print("------------")
    print("/cl config: shows the current configuration")
    print("/cl: prints CritLog highscores")
end

local function printConfig()
    print("/cl level: "..tostring(CritLogDB.AllLevel))
    print("/cl sound: "..tostring(CritLogDB.SoundFlag))
    print("/cl allcrits: "..tostring(CritLogDB.AllCritFlag))
    print("/cl whitehit: "..tostring(CritLogDB.WhiteHitFlag))
    print("/cl xtreme: "..tostring(CritLogDB.XtremeSoundFlag))
    print("/cl ready: "..tostring(CritLogDB.ReadySoundFlag))
    print("/cl aura: "..tostring(CritLogDB.AuraSoundFlag))
    print("------------")
    print("/cl priest: "..tostring(CritLogDB.PriestSoundFlag))
    print("/cl melee: "..tostring(CritLogDB.MeleeSoundFlag))
    print("/cl tank: "..tostring(CritLogDB.TankSoundFlag))
    print("/cl boss: "..tostring(CritLogDB.BossSoundFlag))
    print("/cl player: "..tostring(CritLogDB.PlayerSoundFlag))
    print("/cl dead: "..tostring(CritLogDB.DeadSoundFlag))
end

local function printHighscores()
    print(
        "DAMAGE Crit "..CritLogDB.DAC_Name..": "
        ..CritLogDB.DamageAbilityCrit.." ("..CritLogDB.DAC_Tar..")"
    )
    print(
        "DAMAGE Crit WhiteHit: "..CritLogDB.WhiteHitCrit
        .." ("..CritLogDB.WHC_Tar..")"
    )
    print(
        "HEAL Crit "..CritLogDB.HAC_Name..": "
        ..CritLogDB.HealAbilityCrit.." ("..CritLogDB.HAC_Tar..")"
    )
    print("/cl help for list of commands")
end

function CritLog:PrintCritLogs(message)
    local command = message or ""

    if command == "reset" then
        self:ResetRecords()
        printHighscores()
    elseif command == "sound" then
        CritLogDB.SoundFlag = not CritLogDB.SoundFlag
        if CritLogDB.SoundFlag then
            print("CritLog Sounds On")
        else
            print("CritLog Sounds Off")
        end
    elseif command == "allcrits" then
        toggle(
            "AllCritFlag",
            "Sound for all crits On",
            "Sound for all crits Off"
        )
    elseif command == "whitehit" then
        toggle(
            "WhiteHitFlag",
            "Sound for white-hit crits On",
            "Sound for white-hit crits Off"
        )
    elseif command == "ready" then
        toggle(
            "ReadySoundFlag",
            "CritLog ReadyCheckSound On",
            "CritLog ReadyCheckSound Off"
        )
    elseif command == "aura" then
        toggle(
            "AuraSoundFlag",
            "CritLog Aura/Spell Sound On",
            "CritLog Aura/Spell Sound Off"
        )
    elseif command == "priest" then
        toggle(
            "PriestSoundFlag",
            "CritLog PriestSound On",
            "CritLog PriestSound Off"
        )
    elseif command == "melee" then
        toggle(
            "MeleeSoundFlag",
            "CritLog MeleeSound On",
            "CritLog MeleeSound Off"
        )
    elseif command == "player" then
        toggle(
            "PlayerSoundFlag",
            "CritLog PlayerDeathSound On",
            "CritLog PlayerDeathSound Off"
        )
    elseif command == "tank" then
        toggle(
            "TankSoundFlag",
            "CritLog TankSound On",
            "CritLog TankSound Off"
        )
    elseif command == "boss" then
        toggle(
            "BossSoundFlag",
            "CritLog BossSound On",
            "CritLog BossSound Off"
        )
    elseif command == "dead" then
        toggle(
            "DeadSoundFlag",
            "CritLog DeathSound On",
            "CritLog DeathSound Off"
        )
    elseif command == "xtreme" then
        toggle(
            "XtremeSoundFlag",
            "CritLog XtremeSound On",
            "CritLog XtremeSound Off"
        )
    elseif command == "level" then
        CritLogDB.AllLevel = not CritLogDB.AllLevel
        if CritLogDB.AllLevel then
            print("CritLog: enemy level no longer affects damage crit logging")
        else
            print("CritLog: damage crits require a relevant-level target")
        end
    elseif command == "help" then
        printHelp()
    elseif command == "config" then
        printConfig()
    else
        printHighscores()
    end
end

SLASH_CRITLOG1, SLASH_CRITLOG2 = "/critlog", "/cl"
SlashCmdList["CRITLOG"] = function(message)
    CritLog:PrintCritLogs(message)
end
