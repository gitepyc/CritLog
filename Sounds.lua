-- Every real in-game sound trigger routes through this one function, so
-- MasterSoundFlag is a genuine "mute everything" switch. The options
-- panel's preview buttons deliberately do NOT go through here - see
-- UI/Shared.lua's previewSound() - since a preview needs to be audible
-- even while muted.
function CritLog:PlaySound(soundFile)
    if not CritLogDB.MasterSoundFlag then
        return
    end
    PlaySoundFile(self.soundPath..soundFile, "Master")
end

function CritLog:PlayCritSound()
    if CritLogDB.SoundFlag then
        self:PlaySound(self.Constants.sounds.crit)
    end
end
