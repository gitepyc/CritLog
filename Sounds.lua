-- Every sound in the addon (crits, auras, deaths, ready check, chat
-- triggers, GUI previews) routes through this one function, so
-- MasterSoundFlag here is a genuine "mute everything" switch rather than
-- something that needs wiring into each trigger separately.
function CritLog:PlaySound(soundFile)
    if not CritLogDB.MasterSoundFlag then
        return
    end
    PlaySoundFile(self.soundPath..soundFile, "Master")
end

function CritLog:PlayCritSound()
    if CritLogDB.SoundFlag then
        self:PlaySound(self.Data.sounds.crit)
    end
end
