SWEP.Base = "phun_base_nade"

SWEP.PrintName = "GRENADE"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 4
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.HoldType = "grenade"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "grenade"
SWEP.ReloadHoldType = "grenade"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables

SWEP.Primary.Ammo = "grenade"

SWEP.BasePos = Vector(0.000, 0.000, 0.000)
SWEP.BaseAng = Vector(0.000, 0.000, 0.000)

SWEP.BasePos = Vector(1.078, -6.682, 3.931)
SWEP.BaseAng = Vector(-8.339, -0.660, 19.983)

SWEP.IronsightPos = Vector(0.000, 0.000, 0.000)
SWEP.IronsightAng = Vector(0.000, 0.000, 0.000)

SWEP.SprintPos = Vector(1.078, -6.682, 3.931)
SWEP.SprintAng = Vector(-8.339, -0.660, 19.983)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(1.510, -4.800, 1.030)
SWEP.NearWallAng = Vector(-13.560, 20.560, -11.080)

SWEP.PistolSprintSway = true
SWEP.UseIronTransitionAnims = false

SWEP.Sequences = {
	idle = "idle01",
	deploy = "draw",
	pullpin = "drawbackhigh",
	pullpin_alt = "drawbacklow",
	throw = "throw",
	underhand = "lob",
	holster = "drawbacklow"
}

SWEP.DeployTime = 1.1
SWEP.HolsterTime = 0.25
SWEP.ReloadTime = 2.4

SWEP.ViewModelMovementScale = 0.75

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false
SWEP.FlashlightAttachmentName = "1"
SWEP.InstantFlashlight = false

SWEP.HL2_IconParams = {dist = 16, mdlOffset = Vector(0,0,0), camOffset = -4}

SWEP.NadeClass = "npc_grenade_frag"
SWEP.NadeModel = "models/weapons/w_npcnade.mdl"
SWEP.NadeFuseTime = 2.5
SWEP.NadeGetReadyTime = 0
SWEP.NadeThrowWaitTime = 0.17
SWEP.NadeRedeployWaitTime = 0.25

SWEP.SwitchAfterThrow = false

function SWEP:TossNade(ent)
	local ply = self.Owner
	local EA =  ply:EyeAngles()
	local dummy = self.NadeEnt

	local phys = dummy:GetPhysicsObject()
	if IsValid(phys) then
		local force = 1000
		
		if ply:KeyDown(IN_FORWARD) then
			force = force + ply:GetVelocity():Length()
		end
		
		if ply:Crouching() and ply:OnGround() and !self.WasPrimary then
			local ea = EA
			ea.p = 0
			local grenang = ea
			grenang:RotateAroundAxis(grenang:Forward(), 90)
			
			local b, t = ply:GetHullDuck()
			local diff = t.z - b.z
			
			dummy:SetPos(ply:GetShootPos() - Vector(0,0,diff - 12))
			dummy:SetAngles(grenang)
			phys:SetVelocity(ea:Forward() * force * 0.75)
			phys:AddAngleVelocity(Vector(0, 0, 0))
		else
			phys:SetVelocity(EA:Forward() * force * self.ThrowPower + Vector(0, 0, 100))
			phys:AddAngleVelocity(Vector(450, -550, -420))
		end
	end
end

function SWEP:OnNadeTossed()
	local nade = self.NadeEnt
	local ply = self.Owner
	nade:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	nade:SetSaveValue("m_hOwnerEntity", ply)
	nade:SetSaveValue("m_DmgRadius", 250)
	nade:SetSaveValue("m_hThrower", ply)
	nade:SetSaveValue("m_flDamage", 125)
	nade:SetSaveValue("m_takedamage", 1) // does not get blown up by other nades, bounces away
	nade:Fire("SetTimer", self.NadeFuseTime)
end

if SERVER then
	hook.Add("AllowPlayerPickup", "PB_HL2Nade_AllowPlayerPickup", function(ply, ent)
		if IsValid(ent) and ply:GetActiveWeapon().PHUNBASEWEP then
			ply.PB_IsPickingUpObject = true
			return true
		end
	end)

	hook.Add("Think", "PB_HL2Nade_Think", function()
		for _, ent in pairs(ents.FindByClass("npc_grenade_frag")) do
			if ent:IsPlayerHolding() and !ent.WasHeld then
				ent.WasHeld = true
			end
			if !ent:IsPlayerHolding() and ent.WasHeld then
				ent.WasHeld = false
				ent.NextPickupTime = CurTime() + 0.2
			end
		end
	end)

	hook.Add("FindUseEntity", "PB_HL2Nade_FindUseEntity", function(ply, ent)
		if IsValid(ent) and ent:GetClass() == "npc_grenade_frag" and !ent.WasHeld and (!ent.NextPickupTime or ent.NextPickupTime < CurTime()) then
			ply.PB_IsPickingUpObject = true
			ent.RealTimeLeft = ent:GetSaveTable().m_flDetonateTime // after picking up, reset timer to how it was before pickup
			ply:PickupObject(ent)
			ent:Fire("SetTimer", ent.RealTimeLeft)
			return ent
		end
	end)
end
