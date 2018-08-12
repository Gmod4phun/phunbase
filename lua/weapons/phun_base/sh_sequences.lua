local SP = game.SinglePlayer()
local vm

function SWEP:PlayVMSequence(anim, speed, cycle, noSound)
	if not anim then
		return
	end
	
	speed = speed or 1
	cycle = cycle or 0
	noSound = noSound or false
	
	if SERVER then
		self:SetActiveSequence(anim)
	end

	if SERVER then
		if !self.Owner:IsPlayer() then return end
		umsg.Start("PHUNBASE_ANIMATE", self.Owner)
			umsg.String(anim)
			umsg.Float(speed)
			umsg.Float(cycle)
			umsg.Bool(noSound)
		umsg.End()
		return
	end
	
	self:_playAnim(anim, speed, cycle, noSound)
end

function SWEP:_playAnim(anim, speed, cycle, noSound)
	if SERVER then return end

	local ent = self.VM
	cycle = cycle or 0
	speed = speed or 1
	noSound = noSound or false
	
	local foundAnim = self.Sequences[anim]
	
	if not foundAnim then
		return
	end
	
	if type(foundAnim) == "table" then
		foundAnim = table.Random(foundAnim)
	end
	
	if !noSound and self.Sounds then
		if self.Sounds[foundAnim] then
			self:setCurSoundTable(self.Sounds[foundAnim], speed, cycle, foundAnim)
		else
			self:removeCurSoundTable()
		end
	else
		self:removeCurSoundTable()
	end
	
	ent:ResetSequence(foundAnim)
	if cycle > 0 then ent:SetCycle(cycle) else ent:SetCycle(0) end
	ent:SetPlaybackRate(speed)
	self.RealViewModel:SendViewModelMatchingSequence(self.RealViewModel:LookupSequence(foundAnim))
	self.RealSequence = anim
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
	
	vm = self.CustomEjectionSourceEnt or self.RealViewModel //attach particles to real VM instead of cmodel vm, fixes positions 
	if !IsValid(vm) then return end
	
	local att = vm:LookupAttachment( self:GetMuzzleAttachmentName() )
    
    local isSup = self.IsSuppressed
    local muzTab = isSup and self.MuzzleEffectSuppressed or self.MuzzleEffect
	
	if att or (self.CustomEjectionSourceEnt) then
	
		local muz = vm:GetAttachment(att)
		
		if muz or (self.CustomEjectionSourceEnt) then

			if type(muzTab) == "table" then
				for _, particle in pairs(muzTab) do
					if type(particle) == "string" then
						ParticleEffectAttach(particle, self.CustomEjectionSourceEnt and PATTACH_ABSORIGIN_FOLLOW or PATTACH_POINT_FOLLOW, vm, att)
					end
				end
			elseif type(muzTab) == "string" then
				ParticleEffectAttach(muzTab, self.CustomEjectionSourceEnt and PATTACH_ABSORIGIN_FOLLOW or PATTACH_POINT_FOLLOW, vm, att)
			end
			
            
            if !isSup then
                local dlight = DynamicLight(self:EntIndex())
                dlight.r = 250
                dlight.g = 250
                dlight.b = 50
                dlight.Brightness = 5
                dlight.Pos = (self.CustomEjectionSourceEnt) and vm:GetPos() or muz.Pos + self.Owner:GetAimVector() * 3
                dlight.Size = 128
                dlight.Decay = 1000
                dlight.DieTime = CurTime() + 1
            end
			
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
		local animLen = self.VM:SequenceDuration()
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
		local noSound = um:ReadBool()
		
		local ply = LocalPlayer()
        if !IsValid(ply) then return end // this prevents MP bullshit happening in MP on user loading into the map
        
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) then
			return
		end
		
		if wep.PlayVMSequence then
			wep:PlayVMSequence(anim, speed, cycle, noSound)
		end
	end
	usermessage.Hook("PHUNBASE_ANIMATE", PHUNBASE_ANIMATE)
	
	local function PHUNBASE_MUZZLE_EFFECTS()
		local ply = LocalPlayer()
        if !IsValid(ply) then return end
        
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) or not wep.PHUNBASEWEP then
			return
		end
		
		wep:PlayMuzzleFlashEffect()
	end
	usermessage.Hook("PHUNBASE_MUZZLE_EFFECTS", PHUNBASE_MUZZLE_EFFECTS)
	
	local function PHUNBASE_STOPVMPARTICLES()
		local ply = LocalPlayer()
        if !IsValid(ply) then return end
        
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) or not wep.PHUNBASEWEP then
			return
		end
		
		wep:_stopViewModelParticles()
	end
	usermessage.Hook("PHUNBASE_STOPVMPARTICLES", PHUNBASE_STOPVMPARTICLES)
end
