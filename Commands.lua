local function toggle(field, enabledMessage, disabledMessage)
    CritLogDB[field] = not CritLogDB[field]
    if CritLogDB[field] then
        print(enabledMessage.." ("..tostring(CritLogDB[field])..")")
    else
        print(disabledMessage.." ("..tostring(CritLogDB[field])..")")
    end
end

local function printHelp()
    print("/cl reset: sets all Logs to 0")
    print("/cl reset damage|whitehit|heal: clears a single highscore record (e.g. a false positive)")
    print("/cl level: changes level requirements for crit logs")
    print("/cl mute: turns ALL sounds on/off, overriding every sound toggle below")
    print("/cl sound: turns BÄM sound on/off (highscore sound)")
    print("/cl allcrits: turns BÄM sound on/off for all crits")
    print("/cl whitehit: turns BÄM sound on/off for all WHITEHIT crits")
    print("/cl xtreme: turns sound for hits over 9000 damage on/off (off by default)")
    print("/cl debug: turns diagnostic chat output on/off (off by default)")
    print("/cl options: opens/closes the CritLog options panel")
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
end

local function printConfig()
    print("/cl level: "..tostring(CritLogDB.AllLevel))
    print("/cl mute: "..tostring(CritLogDB.MasterSoundFlag))
    print("/cl sound: "..tostring(CritLogDB.SoundFlag))
    print("/cl allcrits: "..tostring(CritLogDB.AllCritFlag))
    print("/cl whitehit: "..tostring(CritLogDB.WhiteHitFlag))
    print("/cl xtreme: "..tostring(CritLogDB.XtremeSoundFlag))
    print("/cl debug: "..tostring(CritLogDB.DebugFlag))
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
    elseif command == "reset damage" then
        self:ResetRecord("damage")
        printHighscores()
    elseif command == "reset whitehit" then
        self:ResetRecord("whiteHit")
        printHighscores()
    elseif command == "reset heal" then
        self:ResetRecord("heal")
        printHighscores()
    elseif command == "mute" then
        toggle(
            "MasterSoundFlag",
            "CritLog: all sounds enabled",
            "CritLog: all sounds muted"
        )
    elseif command == "sound" then
        CritLogDB.SoundFlag = not CritLogDB.SoundFlag
        if CritLogDB.SoundFlag then
            print("CritLog Sounds On")
        else
            print("CritLog Sounds Off")
        end
    elseif command == "allcrits" then
        CritLogDB.AllCritFlag = not CritLogDB.AllCritFlag
        if CritLogDB.AllCritFlag then
            print("Sound for all crits On("..tostring(CritLogDB.AllCritFlag)..")")
        else
            print("Sound for all crits Off ("..tostring(CritLogDB.AllCritFlag)..")")
        end
    elseif command == "whitehit" then
        CritLogDB.WhiteHitFlag = not CritLogDB.WhiteHitFlag
        if CritLogDB.WhiteHitFlag then
            print("Sound for whitehit crits On("..tostring(CritLogDB.WhiteHitFlag)..")")
        else
            print("Sound for whitehit crits Off ("..tostring(CritLogDB.WhiteHitFlag)..")")
        end
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
    elseif command == "debug" then
        toggle(
            "DebugFlag",
            "CritLog Debug Mode On",
            "CritLog Debug Mode Off"
        )
    elseif command == "level" then
        CritLogDB.AllLevel = not CritLogDB.AllLevel
        if CritLogDB.AllLevel then
            print("CritLog: Enemy Level does not matter now")
        else
            print("CritLog: Enemy Level + 9 < Player Level to log DAMAGE Crits (GREEN Level Units) only")
        end
    elseif command == "options" then
        self:ShowOptions()
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
