SWEP.Base = "phun_base_nade"

SWEP.PrintName = "BUGBAIT"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 5
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"

SWEP.HoldType = "grenade"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "grenade"
SWEP.ReloadHoldType = "grenade"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

SWEP.BasePos = Vector(0.000, 0.000, 0.000)
SWEP.BaseAng = Vector(0.000, 0.000, 0.000)

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
	pullpin = "drawback",
	throw = "throw",
	squeeze = "squeeze",
	holster = "drawbacklow"
}

SWEP.DeployTime = 1
SWEP.HolsterTime = 0.3
SWEP.ReloadTime = 2.4

SWEP.ViewModelMovementScale = 0.75

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false
SWEP.FlashlightAttachmentName = "1"
SWEP.InstantFlashlight = false

SWEP.HL2_IconParams = {dist = 12, mdlOffset = Vector(0,0,0), camOffset = 0}

SWEP.NadeClass = "npc_grenade_bugbait"
SWEP.NadeModel = "models/weapons/w_bugbait.mdl"
SWEP.NadeFuseTime = 2.5
SWEP.NadeGetReadyTime = 0
SWEP.NadeThrowWaitTime = 0.05
SWEP.NadeRedeployWaitTime = 0.25

SWEP.SwitchAfterThrow = false

function SWEP:InitiateThrow()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:GetIsWaiting() then return end
	
	self:SetIsWaiting(true)
	
	if IsFirstTimePredicted() then
		self:PlayVMSequence("pullpin")
		self.NextNadeAction = CurTime() + self.NadeGetReadyTime
		self.ReadyToThrow = false
	end
end

function SWEP:SecondaryAttack()
	self:Squeeze()
end

function SWEP:Squeeze()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:GetIsWaiting() then return end

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	
	if IsFirstTimePredicted() then
		self:PlayVMSequence("squeeze")
		self:EmitSound("Weapon_Bugbait.Splat", 75, 50, 1, CHAN_WEAPON)
	end
end

function SWEP:TossNade(ent)
	local ply = self.Owner
	local force = 1000
	
	if ply:KeyDown(IN_FORWARD) then
		force = force + ply:GetVelocity():Length()
	end
	
	ent:SetVelocity(ply:EyeAngles():Forward() * force * self.ThrowPower + Vector(0, 0, 100))
	ent:SetLocalAngularVelocity(Angle(450, -550, -420))
end

function SWEP:OnNadeTossed()
	local nade = self.NadeEnt
	local ply = self.Owner
	nade:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	nade:SetSaveValue("m_hOwnerEntity", ply)
	nade:SetSaveValue("m_DmgRadius", 100)
	nade:SetSaveValue("m_hThrower", ply)
end

local IdleAfterSeq = {
	["idle"] = true,
	["deploy"] = true,
	["squeeze"] = true
}

function SWEP:AdditionalThink()
	local ply = self.Owner
	if !self.ReadyToThrow and self.NextNadeAction and CurTime() > self.NextNadeAction then
		if !ply:KeyDown(IN_ATTACK) then
			self:PlayVMSequence("throw")
			self.ThrowPower = 1
			self.WasPrimary = true
			self.ReadyToThrow = true
			self.NextNadeAction = CurTime() + self.NadeThrowWaitTime
		end
	end
	if self.ReadyToThrow and self.NextNadeAction and CurTime() > self.NextNadeAction then
		self.NextNadeAction = nil
		self.ReadyToThrow = false
		self:CreateNade()
		self.RedeployTime = CurTime() + self.NadeRedeployWaitTime
		ply:SetAnimation(PLAYER_ATTACK1)
	end
	if self.RedeployTime and CurTime() > self.RedeployTime then
		self.RedeployTime = nil
		self:SetIsWaiting(false)
		self:Deploy()
	end
	if CLIENT then
		local seq = self:GetActiveSequence()
		if self.Cycle > 0.99 and !self:GetIsDeploying() and IdleAfterSeq[seq] then
			self:PlayVMSequence("idle")
		end
	end
end
