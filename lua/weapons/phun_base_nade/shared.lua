AddCSLuaFile()

SWEP.PrintName = "PHUNBASE NADE"
SWEP.Category = "PHUNBASE"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.IconLetter = "1"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.SwayScale = 1
SWEP.BobScale = 1

SWEP.Base = "phun_base"
SWEP.PHUNBASEWEP = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.AimViewModelFOV = 70
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.HoldType = "grenade"
SWEP.SafeHoldType = "passive"
SWEP.SprintHoldType = "passive"
SWEP.CrouchHoldType = "grenade"
SWEP.ReloadHoldType = "grenade"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Weight = -1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.PB_VMPOS = Vector(0,0,0) // ViewModel position
SWEP.PB_VMANG = Angle(0,0,0) // ViewModel angles

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(0,0,0)
SWEP.IronsightAng = Vector(0,0,0)

SWEP.SprintPos = Vector(0,0,0)
SWEP.SprintAng = Vector(0,0,0)

SWEP.HolsterPos = Vector(0,0,0)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0,0,0)
SWEP.NearWallAng = Vector(0,0,0)

SWEP.InactivePos = Vector(4, 0, 0)
SWEP.InactiveAng = Vector(-45, 45, 0)

SWEP.Sequences = {}
SWEP.Sounds = {}

SWEP.DeployTime = 0.5
SWEP.HolsterTime = 0.5
SWEP.ReloadTime = 0.5

SWEP.UseHands = true

SWEP.IsDual = false
SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleAttachmentName_L = "muzzle_left"
SWEP.MuzzleAttachmentName_R = "muzzle_right"
SWEP.MuzzleEffect = {"smoke_trail"}

SWEP.ShellVelocity = {X = 0, Y = 0, Z = 0}
SWEP.ShellAngularVelocity = {Pitch_Min = 0, Pitch_Max = 0, Yaw_Min = 0, Yaw_Max = 0, Roll_Min = 0, Roll_Max = 0}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = 0, Up = 0}
SWEP.ShellAttachmentName = "shelleject"
SWEP.ShellAttachmentName_L = "shelleject_left"
SWEP.ShellAttachmentName_R = "shelleject_right"
SWEP.ShellDelay = 0.03
SWEP.ShellScale = 0.5
SWEP.ShellModel = "models/weapons/shell.mdl"
SWEP.ShellEjectVelocity = 75

SWEP.FireSound = {} -- can be a string, or a table of sounds

SWEP.DisableIronsights = true
SWEP.DisableReloadBlur = false
SWEP.ReloadAfterShot = false
SWEP.ReloadAfterShotTime = 0.5
SWEP.UseIronTransitionAnims = false

SWEP.EmptySoundPrimary = "PB_WeaponEmpty_Primary"
SWEP.EmptySoundSecondary = "PB_WeaponEmpty_Secondary"

SWEP.InstantFlashlight = false

SWEP.NadeClass = ""
SWEP.NadeFuseTime = 3
SWEP.NadeGetReadyTime = 1
SWEP.NadeThrowWaitTime = 0.15
SWEP.NadeRedeployWaitTime = 0.25

SWEP.ThrowPower = 1
SWEP.SwitchAfterThrow = false

function SWEP:OnNadeTossed() // called after creating the nade, use when needed
end

function SWEP:TossNade(ent)
	local ply = self.Owner
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local force = 1000
		
		if ply:KeyDown(IN_FORWARD) then
			force = force + ply:GetVelocity():Length()
		end
		
		phys:SetVelocity(ply:EyeAngles():Forward() * force * self.ThrowPower + Vector(0, 0, 100))
		phys:AddAngleVelocity(Vector(450, -550, -420))
	end
end

function SWEP:CreateNade()
	if SERVER then
		local ply = self.Owner
		local EA =  ply:EyeAngles()
		local pos = ply:GetShootPos()
		pos = pos + EA:Right() * 5 - EA:Up() * 4 + EA:Forward() * 8
		local ang = Angle(30, 160, 65) 
		
		local nade = ents.Create(self.NadeClass)
		nade:SetPos(pos)
		nade:SetAngles(ang)
		
		nade.Weapon = self
		nade.Owner = ply
		nade.IsPBGrenade = true
		nade:Spawn()
		nade:Activate()
		
		self.NadeEnt = nade
		
		self:TossNade(nade)
		
		if self.OnNadeTossed then
			self:OnNadeTossed()
		end
	end
	
	self:TakePrimaryAmmo(1)
end

function SWEP:PrimaryAttack()
	self:InitiateThrow()
end

function SWEP:SecondaryAttack()
	self:InitiateThrow()
end

function SWEP:InitiateThrow()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:GetIsWaiting() then return end
	
	if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:EmitSound(self.EmptySoundPrimary)
		return
	end
	
	self:SetIsWaiting(true)
	
	if IsFirstTimePredicted() then
		self:PlayVMSequence(ply:KeyDown(IN_ATTACK2) and "pullpin_alt" or "pullpin")
		self.NextNadeAction = CurTime() + self.NadeGetReadyTime
		self.ReadyToThrow = false
	end
end

function SWEP:AdditionalThink()
	local ply = self.Owner
	if !self.ReadyToThrow and self.NextNadeAction and CurTime() > self.NextNadeAction then
		if !ply:KeyDown(IN_ATTACK) and !ply:KeyDown(IN_ATTACK2) then
			if ply:KeyDownLast(IN_ATTACK) then
				self:PlayVMSequence("throw")
				self.ThrowPower = 1
				self.WasPrimary = true
			elseif ply:KeyDownLast(IN_ATTACK2) then
				self.ThrowPower = 0.2
				self:PlayVMSequence("underhand")
				self.WasPrimary = false
			end
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
		if !ply:KeyDown(IN_ATTACK) then
			self.SwitchAfterThrow = true
		else
			self.SwitchAfterThrow = false
		end
		if !self.SwitchAfterThrow then
			if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
				local wep = ply.PHUNBASE_LastWeapon
				if IsValid(wep) then
					ply:SelectWeapon(wep:GetClass())
				end
				timer.Simple(self.HolsterTime + 0.05, function() if IsValid(ply) and IsValid(self) then ply:StripWeapon(self:GetClass()) end end)
			else
				self:Deploy()
			end
		else
			local wep = ply.PHUNBASE_LastWeapon
			if IsValid(wep) then
				ply:SelectWeapon(wep:GetClass())
			end
			if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
				timer.Simple(self.HolsterTime + 0.05, function() if IsValid(ply) and IsValid(self) then ply:StripWeapon(self:GetClass()) end end)
			end
		end
	end
end
