local function toggle(field, enabledMessage, disabledMessage)
    CritLogDB[field] = not CritLogDB[field]
    if CritLogDB[field] then
        print(enabledMessage.." ("..tostring(CritLogDB[field])..")")
    else
        print(disabledMessage.." ("..tostring(CritLogDB[field])..")")
    end
end

-- Melee/tank/priest/boss death sounds are a 4-way mode now (see
-- Core/Constants.lua's detectionModes), not a plain flag - this chat
-- command still only flips between off ("none") and the original default
-- ("both", live check with roster fallback). For "experimental"- or
-- "roster"-only, use `/cl options` -> Sound Settings.
local function toggleDetectionMode(field, label)
    if CritLogDB[field] == "none" then
        CritLogDB[field] = "both"
        print("CritLog "..label.." On (both) - see /cl options for Experimental/Roster only")
    else
        CritLogDB[field] = "none"
        print("CritLog "..label.." Off (none)")
    end
end

local function printHelp()
    print("/cl reset: clears every highscore list")
    print("/cl reset damage|whitehit|heal: clears just that category's highscore list")
    print("/cl options -> Highscore List...: delete a single entry instead of a whole list")
    print("/cl level: changes level requirements for crit logs")
    print("/cl mute: turns ALL sounds on/off, overriding every sound toggle below")
    print("/cl sound: turns BÄM sound on/off (highscore sound)")
    print("/cl allcrits: turns BÄM sound on/off for all crits")
    print("/cl whitehit: turns BÄM sound on/off for all WHITEHIT crits")
    print("/cl xtreme: turns sound for hits over 9000 damage on/off (off by default)")
    print("/cl debug: turns diagnostic chat output on/off (off by default)")
    print("/cl options (or /cl opt): opens/closes the CritLog options panel")
    print("/cl ready: turns ReadyCheck Sound on/off")
    print("/cl aura: turns Aura/Spell Sound on/off")
    print("------------")
    print("/cl priest: toggles Priest Sound between None/Both (see /cl options for Experimental/Roster only)")
    print("/cl melee: toggles Damage Dealer Sound between None/Both (see /cl options for Experimental/Roster only)")
    print("/cl tank: toggles Tank Sound between None/Both (see /cl options for Experimental/Roster only)")
    print("/cl boss: toggles Boss Sound between None/Both (see /cl options for Experimental/Roster only)")
    print("/cl player: turns Player Death Sound on/off")
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
    print("/cl priest: "..CritLogDB.PriestDetectionMode)
    print("/cl melee: "..CritLogDB.MeleeDetectionMode)
    print("/cl tank: "..CritLogDB.TankDetectionMode)
    print("/cl boss: "..CritLogDB.BossDetectionMode)
    print("/cl player: "..tostring(CritLogDB.PlayerSoundFlag))
end

-- Prints only the current best (#1) per category - the same summary the
-- main options panel shows inline. The full top-N list with individual
-- delete buttons is `/cl options` -> "Highscore List...".
local function printHighscores()
    print(CritLog.Records.formatRecordText("damage", 1))
    print(CritLog.Records.formatRecordText("whiteHit", 1))
    print(CritLog.Records.formatRecordText("heal", 1))
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
        toggleDetectionMode("PriestDetectionMode", "PriestSound")
    elseif command == "melee" then
        toggleDetectionMode("MeleeDetectionMode", "Damage Dealer Sound")
    elseif command == "player" then
        toggle(
            "PlayerSoundFlag",
            "CritLog PlayerDeathSound On",
            "CritLog PlayerDeathSound Off"
        )
    elseif command == "tank" then
        toggleDetectionMode("TankDetectionMode", "TankSound")
    elseif command == "boss" then
        toggleDetectionMode("BossDetectionMode", "BossSound")
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
    elseif command == "options" or command == "opt" then
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
