local SP = game.SinglePlayer()
local vm

function SWEP:PlayVMSequence(anim, speed, cycle)
	if not anim then
		return
	end
	
	speed = speed or 1
	cycle = cycle or 0
	
	if SERVER then
		self:SetActiveSequence(anim)
	end

	if SP and SERVER then
		if !self.Owner:IsPlayer() then return end
		umsg.Start("PHUNBASE_ANIMATE", self.Owner)
			umsg.String(anim)
			umsg.Float(speed)
			umsg.Float(cycle)
		umsg.End()
		return
	end
	
	self:_playAnim(anim, speed, cycle)
end

function SWEP:_playAnim(anim, speed, cycle, ent)
	ent = ent or self.VM
	cycle = cycle or 0
	speed = speed or 1
	
	local foundAnim = anim
	
	if ent == self.VM then
		foundAnim = self.Sequences[anim]
		
		if not foundAnim then
			return
		end
		
		if type(foundAnim) == "table" then
			foundAnim = table.Random(foundAnim)
		end
		
		if self.Sounds then
			if self.Sounds[foundAnim] then
				self:setCurSoundTable(self.Sounds[foundAnim], speed, cycle, foundAnim)
			else
				self:removeCurSoundTable()
			end
		end
	end

	if SERVER then return end
	
	ent:ResetSequence(foundAnim)
	if cycle > 0 then ent:SetCycle(cycle) else ent:SetCycle(0) end
	ent:SetPlaybackRate(speed)
	self.RealViewModel:SendViewModelMatchingSequence(self.RealViewModel:LookupSequence(foundAnim))
end

function SWEP:PlayMuzzleFlashEffect()
	if SP and SERVER then
		if !self.Owner:IsPlayer() then return end
		SendUserMessage("PHUNBASE_MUZZLE_EFFECTS", self.Owner)
		return
	end
	
	self:_playMuzzleEffect()
end

function SWEP:_playMuzzleEffect()
	if SERVER then return end
	
	if self.Owner:ShouldDrawLocalPlayer() then
		return
	end
	
	vm = self.RealViewModel //attach particles to real VM instead of cmodel vm, fixes positions 
	if !IsValid(vm) then return end
	
	local att = vm:LookupAttachment( self:GetMuzzleAttachmentName() )
	
	if att then
	
		local muz = vm:GetAttachment(att)
		
		if muz then
		
			if type(self.MuzzleEffect) == "table" then
				for _, particle in pairs(self.MuzzleEffect) do
					if type(particle) == "string" then
						ParticleEffectAttach(particle, PATTACH_POINT_FOLLOW, vm, att)
					end
				end
			elseif type(self.MuzzleEffect) == "string" then
				ParticleEffectAttach(self.MuzzleEffect, PATTACH_POINT_FOLLOW, vm, att)
			end
			
			dlight = DynamicLight(self:EntIndex())
			dlight.r = 250
			dlight.g = 250
			dlight.b = 50
			dlight.Brightness = 5
			dlight.Pos = muz.Pos + self.Owner:GetAimVector() * 3
			dlight.Size = 128
			dlight.Decay = 1000
			dlight.DieTime = CurTime() + 1
			
		end
	end
end

function SWEP:StopViewModelParticles()
	if SP and SERVER then
		if !self.Owner:IsPlayer() then return end
		SendUserMessage("PHUNBASE_STOPVMPARTICLES", self.Owner)
		return
	end
	self:_stopViewModelParticles()
end

function SWEP:_stopViewModelParticles()
	if SERVER then return end
	if !self:GetIsDual() then
		self.VM:StopParticleEmission()
		self.RealViewModel:StopParticleEmission()
	else
		if self:GetDualSide() == "left" then
			self.VM:StopParticlesWithNameAndAttachment("smoke_trail", self.VM:LookupAttachment( self.MuzzleAttachmentName_R ) )
			self.RealViewModel:StopParticlesWithNameAndAttachment("smoke_trail", self.VM:LookupAttachment( self.MuzzleAttachmentName_R ) )
		elseif self:GetDualSide() == "right" then
			self.VM:StopParticlesWithNameAndAttachment("smoke_trail", self.VM:LookupAttachment( self.MuzzleAttachmentName_L ) )
			self.RealViewModel:StopParticlesWithNameAndAttachment("smoke_trail", self.VM:LookupAttachment( self.MuzzleAttachmentName_L ) )
		end
	end
end

///////////////// Sounds

function SWEP:setCurSoundTable(animTable, speed, cycle, origAnim)
	local found = 1
	
	if cycle ~= 0 then
		-- get the length of the animation and relative time to animation
		local animLen = self.CW_VM:SequenceDuration()
		local timeRel = animLen * cycle
		local foundInTable = false
		
		-- loop through the table, and find the entry which the cycle has not passed yet
		for k, v in ipairs(animTable) do
			if timeRel < v.time then
				found = k
				foundInTable = true
				break
			end
		end
		
		if not foundInTable then
			found = false
		end
	end
	
	if found then
		self.CurSoundTable = animTable
		self.CurSoundEntry = found
		self.SoundTime = (CLIENT and UnPredictedCurTime() or CurTime())
		self.SoundSpeed = speed
		
		if CLIENT then
			if origAnim == self.Sequences.deploy then
				if self.drawnFirstTime then
					self.SoundTime = self.SoundTime - 0.22
				end
				self.drawnFirstTime = true
			end
		end
	else
		self:removeCurSoundTable()
	end
end

function SWEP:removeCurSoundTable()
	-- wipes all current animation sound table information to turn it off
	self.CurSoundTable = nil
	self.CurSoundEntry = nil
	self.SoundTime = nil
	self.SoundSpeed = nil
end

//////////////// SOUND END

if CLIENT then
	local function PHUNBASE_ANIMATE(um)
		local anim = um:ReadString()
		local speed = um:ReadFloat()
		local cycle = um:ReadFloat()
		
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) then
			return
		end
		
		if wep.PlayVMSequence then
			wep:PlayVMSequence(anim, speed, cycle)
		end
	end
	usermessage.Hook("PHUNBASE_ANIMATE", PHUNBASE_ANIMATE)
	
	local function PHUNBASE_MUZZLE_EFFECTS()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) or not wep.PHUNBASEWEP then
			return
		end
		
		wep:PlayMuzzleFlashEffect()
	end
	usermessage.Hook("PHUNBASE_MUZZLE_EFFECTS", PHUNBASE_MUZZLE_EFFECTS)
	
	local function PHUNBASE_STOPVMPARTICLES()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) or not wep.PHUNBASEWEP then
			return
		end
		
		wep:_stopViewModelParticles()
	end
	usermessage.Hook("PHUNBASE_STOPVMPARTICLES", PHUNBASE_STOPVMPARTICLES)
end
