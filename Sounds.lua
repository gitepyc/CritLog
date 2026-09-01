-- Every real in-game sound trigger (crits, auras, deaths, ready check,
-- chat triggers) routes through this one function, so MasterSoundFlag here
-- is a genuine "mute everything" switch rather than something that needs
-- wiring into each trigger separately. The options panel's preview buttons
-- deliberately do NOT go through here - see previewSound() in Options.lua -
-- since a preview needs to be audible even while muted.
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
