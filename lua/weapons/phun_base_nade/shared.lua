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

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true

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

local SP = game.SinglePlayer()

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

// NadeThrowState - 0 = getting ready to throw, 1 = throwing, 2 = redeploying
function SWEP:InitiateThrow()
	local ply = self.Owner
	
	if self:GetIsDeploying() or self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:GetIsWaiting() then return end
	
	self:SetIsWaiting(true)
	
	if IsFirstTimePredicted() then
		self:PlayVMSequence(ply:KeyDown(IN_ATTACK2) and "pullpin_alt" or "pullpin")
	end
	
	self.NadeThrowState = 0
	self.NextNadeAction = CurTime() + self.NadeGetReadyTime
end

function SWEP:AdditionalThink()
	if (SP and SERVER) or IsFirstTimePredicted() then
		local ply = self.Owner
		if self.NadeThrowState == 0 and self.NextNadeAction and CurTime() > self.NextNadeAction then
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
				
				self.NadeThrowState = 1
				self.NextNadeAction = CurTime() + self.NadeThrowWaitTime
			end
		end
		
		if self.NadeThrowState == 1 and self.NextNadeAction and CurTime() > self.NextNadeAction then
			self:CreateNade()
			ply:SetAnimation(PLAYER_ATTACK1)
			
			self.NadeThrowState = 2
			self.NextNadeAction = CurTime() + self.NadeRedeployWaitTime
		end
		
		if self.NadeThrowState == 2 and self.NextNadeAction and CurTime() > self.NextNadeAction then
			if SERVER then
				if !self.SwitchAfterThrow then
					if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
						local wep = ply.PHUNBASE_LastWeapon
						if IsValid(wep) then
							//ply:SelectWeapon(wep:GetClass())
							PHUNBASE.SelectWeapon(self.Owner, wep:GetClass())
						end
						timer.Simple(self.HolsterTime + 0.05, function() if IsValid(ply) and IsValid(self) then ply:StripWeapon(self:GetClass()) end end)
					else
						//self:Deploy()
						PHUNBASE.ForceDeployWeapon(self.Owner, self:GetClass())
					end
				else
					local wep = ply.PHUNBASE_LastWeapon
					if IsValid(wep) then
						//ply:SelectWeapon(wep:GetClass())
						PHUNBASE.SelectWeapon(self.Owner, wep:GetClass())
					end
					if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
						timer.Simple(self.HolsterTime + 0.05, function() if IsValid(ply) and IsValid(self) then ply:StripWeapon(self:GetClass()) end end)
					end
				end
			end
			
			self.NadeThrowState = nil
			self.NextNadeAction = nil
			self:SetIsWaiting(false)
		end
	end
end
