function CritLog:CHAT_MSG_RAID_LEADER(message)
    local lowerMessage = string.lower(message)

    if tContains(self.Constants.chatTriggers.raidEnd, lowerMessage) then
        self:PlaySound(self.Constants.sounds.raidEnd)
    end

    if tContains(self.Constants.chatTriggers.wipe, lowerMessage) then
        self:PlaySound(self.Constants.sounds.wipe)
    end
end

-- Matches a third-party lottery addon's raid-chat announcement (e.g.
-- CrossGambling) - not anything CritLog itself understands or runs, just a
-- fixed phrase to react to, same as raid end/wipe above. In-game reported:
-- only fired in a raid, not a party - CrossGambling (and similar addons)
-- announce to whichever group chat you're actually in, which is party
-- chat outside a raid. Shared by both CHAT_MSG_RAID and CHAT_MSG_PARTY
-- below instead of duplicating the check.
local function handleGambleMessage(message)
    if not CritLogDB.GambleSoundFlag then
        return
    end

    if string.find(message, CritLog.Constants.chatTriggers.gamble, 1, true) then
        CritLog:PlaySound(CritLog.Constants.sounds.lottery)
    end
end

function CritLog:CHAT_MSG_RAID(message)
    handleGambleMessage(message)
end

function CritLog:CHAT_MSG_PARTY(message)
    handleGambleMessage(message)
end

-- /roll results arrive as a system message, not a real chat channel. Not
-- just an English/German wording split: the client also phrases your own
-- roll differently from someone else's ("You roll 47 (1-100)" vs
-- "PlayerName rolls 47 (1-100)", presumably a similar self-vs-other split
-- in German) - in-game reported: the sound only ever fired off someone
-- else's roll, never the player's own, which only stood out once solo
-- (nobody else around to roll and mask it). Rather than pin down every
-- exact self/other/locale verb form, this only requires the message to
-- mention rolling at all ("roll"/"ürfel" substring, case-insensitive -
-- matches "roll"/"rolls"/"rolled" and any würfeln conjugation) and reads
-- the trailing "N (min-max)" numbers, which every phrasing shares.
-- Actual classification is CritLog.Filters.classifyRoll (pure, no WoW
-- API) - this just parses the message and hands the numbers off.
function CritLog:CHAT_MSG_SYSTEM(message)
    if not CritLogDB.RollSoundFlag then
        return
    end

    local lowerMessage = string.lower(message)
    if not string.find(lowerMessage, "roll") and not string.find(lowerMessage, "ürfel") then
        return
    end

    local rollResult, rollMin, rollMax = string.match(message, "(%d+) %((%d+)%-(%d+)%)$")
    if not rollResult then
        return
    end

    local soundKey = CritLog.Filters.classifyRoll(tonumber(rollResult), tonumber(rollMin), tonumber(rollMax))
    if soundKey then
        self:PlaySound(self.Constants.sounds[soundKey])
    end
end
