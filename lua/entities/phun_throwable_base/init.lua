AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ExplodeRadius = 384
ENT.ExplodeDamage = 100
ENT.NadeModel = "models/weapons/w_eq_fraggrenade_thrown.mdl"
ENT.NadeBounceSound = "weapons/hegrenade/he_bounce-1.wav"
ENT.IsBouncy = false

function ENT:Initialize()
	self:SetModel(self.NadeModel) 
	//self:PhysicsInitBox(self:OBBMins(), self:OBBMaxs())
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.NextImpact = 0
	self.Bounces = 0
	self:SetUseType(SIMPLE_USE)

	self:SetOwner(self.Owner) // disable collisions with thrower on creation
	self.RemoveOwnerTime = CurTime() + 0.75
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMaterial(self.IsBouncy and "gmod_bouncy" or "weapon")
		phys:Wake()
		phys:SetBuoyancyRatio(0)
		phys:SetMass(5)
	end

end

function ENT:Use(ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply.PB_IsPickingUpObject = true
		ply:PickupObject(self)
	end
end

function ENT:PhysicsCollide(data, physobj)
	local vel = physobj:GetVelocity()
	local len = vel:Length()
	
	if len > 500 then -- let it roll
		physobj:SetVelocity(vel * 0.6) -- cheap as fuck, but it works
	end
	
	if len > 50 then
		local CT = CurTime()
		
		if CT > self.NextImpact then
			self:EmitSound(self.NadeBounceSound, 75, 100)
			self.NextImpact = CT + 0.05
			self.Bounces = self.Bounces + 1
			
			-- if data.HitEntity then // for now disable this, as its killing player standing on the grenade
				-- data.HitEntity:TakeDamage(2, self.Owner, self)
			-- end
		end
	end
	
	if self.Bounces == 2 then
		physobj:SetMaterial("weapon")
	end
end

function ENT:Detonate() // this gets called when the fuse runs out, so override this to do what your ent needs to do
	SafeRemoveEntity(self)
end

function ENT:Think()
	if SERVER then
		if self.FuseTime and CurTime() > self.FuseTime then
			self:Detonate()
		end
		if self.RemoveOwnerTime and CurTime() > self.RemoveOwnerTime then
			self.RemoveOwnerTime = nil
			self:SetOwner(NULL) // enable collisions with thrower again
		end
	end
end

function ENT:OnRemove()
end
