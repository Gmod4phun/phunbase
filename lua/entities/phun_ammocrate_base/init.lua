AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

function ENT:Use(ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply:GiveAmmo( self.AmmoCount, self.AmmoType )
		SafeRemoveEntity( self )
	end
end
