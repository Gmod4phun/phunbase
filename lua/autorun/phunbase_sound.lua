AddCSLuaFile()

-- default settings
PHUNBASE.reloadSoundTable = {
	channel = CHAN_AUTO, 
	volume = 1,
	level = 60, 
	pitchstart = 100,
	pitchend = 100,
	name = "noName",
	sound = "path/to/sound"
	}
	
PHUNBASE.fireSoundTable = {
	channel = CHAN_AUTO, 
	volume = 1,
	level = 97, 
	pitchstart = 92,
	pitchend = 112,
	name = "noName",
	sound = "path/to/sound"
	}
	
PHUNBASE.regularSoundTable = {
	channel = CHAN_AUTO,
	volume = 1,
	level = 65, 
	pitchstart = 92,
	pitchend = 112,
	name = "noName",
	sound = "path/to/sound"
	}

-- "<" makes the sound directional, refer to https://developer.valvesoftware.com/wiki/Soundscripts#Sound_Characters
function PHUNBASE:makeSoundDirectional(snd)
	if type(snd) == "table" then
		for key, sound in ipairs(snd) do
			snd[key] = "<" .. sound
		end
	else
		snd = "<" .. snd
	end
	
	return snd
end
	
function PHUNBASE:addFireSound(name, snd, volume, soundLevel, channel, pitchStart, pitchEnd, noDirection)
	-- use defaults if no args are provided
	volume = volume or 1
	soundLevel = soundLevel or 97
	channel = channel or CHAN_AUTO
	pitchStart = pitchStart or 92
	pitchEnd = pitchEnd or 112
	
	if not noDirection then
		snd = self:makeSoundDirectional(snd)
	end
	
	self.fireSoundTable.name = name
	self.fireSoundTable.sound = snd
	
	self.fireSoundTable.channel = channel
	self.fireSoundTable.volume = volume
	self.fireSoundTable.level = soundLevel
	self.fireSoundTable.pitchstart = pitchStart
	self.fireSoundTable.pitchend = pitchEnd
	
	sound.Add(self.fireSoundTable)
	
	-- precache the registered sounds
	
	if type(self.fireSoundTable.sound) == "table" then
		for k, v in pairs(self.fireSoundTable.sound) do
			util.PrecacheSound(v)
		end
	else
		util.PrecacheSound(snd)
	end
	
end

function PHUNBASE:addReloadSound(name, snd, noDirection)
	if not noDirection then
		snd = self:makeSoundDirectional(snd)
	end
	
	self.reloadSoundTable.name = name
	self.reloadSoundTable.sound = snd

	sound.Add(self.reloadSoundTable)
	
	-- precache the registered sounds
	
	if type(self.reloadSoundTable.sound) == "table" then
		for k, v in pairs(self.reloadSoundTable.sound) do
			util.PrecacheSound(v)
		end
	else
		util.PrecacheSound(snd)
	end
end

function PHUNBASE:addRegularSound(name, snd, level, noDirection)
	if not noDirection then
		snd = self:makeSoundDirectional(snd)
	end
	
	level = level or 65
	self.regularSoundTable.name = name
	self.regularSoundTable.sound = snd
	self.regularSoundTable.level = level

	sound.Add(self.regularSoundTable)
	
	-- precache the registered sounds
	
	if type(self.regularSoundTable.sound) == "table" then
		for k, v in pairs(self.regularSoundTable.sound) do
			util.PrecacheSound(v)
		end
	else
		util.PrecacheSound(snd)
	end
end

PHUNBASE:addRegularSound("PB_WeaponEmpty_Primary", "weapons/pistol/pistol_empty.wav")
PHUNBASE:addRegularSound("PB_WeaponEmpty_Secondary", "weapons/pistol/pistol_empty.wav")
