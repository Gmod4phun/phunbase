AddCSLuaFile()

if !CLIENT then return end

PHUNBASE.shells = PHUNBASE.shells or {}
PHUNBASE.shells._cache = PHUNBASE.shells._cache or {}

function PHUNBASE.shells:_rebuildCache()
	local i = 1

	for _ = 1, #self._cache do
		if !IsValid(self._cache[i]) then
			table.remove(self._cache, i)
		else
			i = i + 1
		end
	end
	
	self.cacheSize = #self._cache
end

PHUNBASE.shells:_rebuildCache()

local CurTime = CurTime
local soundPlay = sound.Play
local mR = math.random

PHUNBASE.shells.shellMeta = {}
local shellMeta = PHUNBASE.shells.shellMeta

function shellMeta:PhysicsCollide()
	if !self._soundPlayed then
		if (self:WaterLevel() == 0) then
			self._soundPlayed = true
			soundPlay(self._sound, self:GetPos())
			ParticleEffectAttach("muzzle_sparks_rifle", PATTACH_ABSORIGIN_FOLLOW, self, 0)
		end
	end
end

function shellMeta:Think()
	self._lastWL = self._lastWL or self:WaterLevel()
	local newWl = self:WaterLevel()
	
	if (newWl == 3) and (newWl != self._lastWL) then
		local pos = self:GetPos()
		soundPlay("CW_KK_INS2_SHELL_SPLASH", pos)
		
		local e = EffectData()
		e:SetOrigin(pos)
		util.Effect("waterripple", e)
	end
	
	self._lastWL = newWl
	
	if self._ttl > CurTime() then return end
	
	SafeRemoveEntity(self)
	
	PHUNBASE.shells:_rebuildCache()
end

function PHUNBASE.shells:make(pos, ang, velocity, shellTable, attPos, attAng)
	pos = pos or EyePos()
	ang = ang or EyeAngles()
	velocity = velocity or Vector()
	
	local wep = shellTable.wep
	wep:_makeParticle("shelleject_spark", wep:GetShellAttachmentName())
	
	local ent = ClientsideModel(shellTable.model, RENDERGROUP_BOTH) 
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModelScale(shellTable.scale)
	
	local mins, maxs = ent:GetModelRenderBounds()
	ent:PhysicsInitBox(mins * shellTable.scale, maxs * shellTable.scale)
	ent:SetMoveType(MOVETYPE_VPHYSICS) 
	ent:SetSolid(SOLID_VPHYSICS) 
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	local phys = ent:GetPhysicsObject()
	phys:SetMaterial("gmod_silent")
	phys:SetMass(10)
	phys:SetVelocity(velocity + attAng:Forward() * mR(shellTable.veladd_X-10, shellTable.veladd_X+10) + attAng:Right() * mR(shellTable.veladd_Y-10, shellTable.veladd_Y+10) + attAng:Up() * mR(shellTable.veladd_Z-10, shellTable.veladd_Z+10) )

	phys:AddAngleVelocity(phys:WorldToLocalVector(
		ent:GetUp() * math.random(shellTable.velmin_P,shellTable.velmax_P) +
		ent:GetForward() * math.random(shellTable.velmin_Y,shellTable.velmax_Y) +
		ent:GetRight() * math.random(shellTable.velmin_R,shellTable.velmax_R)
	))

	ent._sound = shellTable.sound
	ent._soundPlayed = false
	ent:AddCallback("PhysicsCollide", self.shellMeta.PhysicsCollide)

	ent._ttl = CurTime() + 5
	hook.Add("Think", ent, self.shellMeta.Think)
	
	table.insert(self._cache, ent)
	self.cacheSize = #self._cache
	
	return ent
end

function PHUNBASE.shells:cleanUpShells()
	for _,v in pairs(self._cache) do
		SafeRemoveEntity(v)
	end
	
	self:_rebuildCache()
end
