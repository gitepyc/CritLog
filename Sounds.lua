function CritLog:PlaySound(soundFile)
    PlaySoundFile(self.soundPath..soundFile, "Master")
end

function CritLog:PlayCritSound()
    if CritLogDB.SoundFlag then
        self:PlaySound(self.Data.sounds.crit)
    end
end
