SWEP.Base = "phun_base"

SWEP.PrintName = "SHOTGUN"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

SWEP.HoldType = "shotgun"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "shotgun"
SWEP.ReloadHoldType = "shotgun"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

// weapon specific variables
SWEP.Primary.Ammo = "buckshot"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Automatic = false
SWEP.Primary.Damage = 22
SWEP.Primary.Delay = 0.75
SWEP.Primary.Force = 5
SWEP.Primary.Bullets = 7
SWEP.Primary.Tracer = 0

// Recoil variables
SWEP.Recoil	= 0.45
SWEP.Spread	= 0.075
SWEP.Spread_Iron = 0.065
SWEP.SpreadVel = 1.2
SWEP.SpreadVel_Iron = 0.9
SWEP.SpreadAdd = 0.3
SWEP.SpreadAdd_Iron	= 0.2

SWEP.Secondary.Delay = 0.9
SWEP.Secondary.Bullets = 12

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(-5.762, -8.65, 2.993)
SWEP.IronsightAng = Vector(0.666, -1.244, 1.871)

SWEP.SprintPos = Vector(-0.817, -8.708, 3.408)
SWEP.SprintAng = Vector(-14.273, 20.116, -7.115)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0, -10, 0)
SWEP.NearWallAng = Vector(0, 0, 0)

SWEP.PistolSprintSway = true

SWEP.DisableIronsights = true

SWEP.Sequences = {
	idle = "idle01",
	idle_empty = "idle01empty",
	idle_iron = "idle01",
	idle_iron_empty = "idle01empty",
	fire = "fire01",
	fire_secondary = "altfire",
	fire_secondary_iron = "altfire",
	fire_last = "fire01",
	fire_iron = "fire01",
	fire_iron_last = "fire01",
	fire_left = "fire",
	fire_left_iron = "fire",
	fire_right = "fire",
	fire_right_iron = "fire",
	reload = "reload",
	deploy = "draw",
	holster = "holster",
	lighton = "idle01",
	lighton_iron = "idle01",
	goto_iron = "idle01",
	goto_hip = "idle01",
	reload_shell_start = "reload1",
	reload_shell_start_empty = "reload1",
	reload_shell_insert = "reload2",
	reload_shell_end = "reload3",
	reload_shell_end_empty = "reload3",
	reload_shell_pump = "pump"
}

SWEP.Sounds = {
	reload2 = {
		{time = 0, sound = "Weapon_Shotgun.Reload"},
	},
	fire01 = {
		{time = 0.3, sound = "Weapon_Shotgun.Special1", callback = function(wep) wep:PlayVMSequence("reload_shell_pump") end},
	},
	altfire = {
		{time = 0.4, sound = "Weapon_Shotgun.Special1", callback = function(wep) wep:PlayVMSequence("reload_shell_pump") end},
	},
}

SWEP.DeployTime = 0.45
SWEP.HolsterTime = 0.25
SWEP.ReloadTime = 1.5

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.ShellVelocity = {X = 60, Y = 0, Z = -40}
SWEP.ShellAngularVelocity = {Pitch_Min = -500, Pitch_Max = 200, Yaw_Min = 0, Yaw_Max = 1000, Roll_Min = -200, Roll_Max = 100}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = -90, Up = 0}
SWEP.ShellAttachmentName = "1"
SWEP.ShellDelay = 0.45
SWEP.ShellScale = 1
SWEP.ShellModel = "models/phunbase/shells/12g_slug_open.mdl"
SWEP.ShellSound = "PB_SHELLIMPACT_SHOTGUN"
SWEP.ShellEjectVelocity = 10

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol", "smoke_trail"}

SWEP.FireSound = "Weapon_Shotgun.Single"
SWEP.FireSoundSecondary = "Weapon_Shotgun.Double"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.ShotgunReload = true
SWEP.ShotgunReloadTime_Start = 0.4
SWEP.ShotgunReloadTime_Start_Empty = 0.4
SWEP.ShotgunReloadTime_Insert = 0.4
SWEP.ShotgunReloadTime_End = 0.4
SWEP.ShotgunReloadTime_End_Empty = 0.4

function SWEP:PrimaryAttack()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() then return end
	
	if self:Clip1() < 1 then
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:SetNextSecondaryFire(CurTime() + 0.25)
		self:EmitSound(self.EmptySoundPrimary)
		return
	end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	
	if IsFirstTimePredicted() then
		self:EmitSound(self.FireSound)
		
		self:_FireBullets() 
		self:StopViewModelParticles()
		
		if self:GetIron() then
			self:PlayVMSequence("fire_iron")
		else
			self:PlayVMSequence("fire")
		end
		
		self:PlayMuzzleFlashEffect()
		self:MakeShell()
		self:MakeRecoil()
		
		if CLIENT then
			self:simulateRecoil()
		end
		
		if SP and SERVER then
			if !self.Owner:IsPlayer() then return end
			SendUserMessage("PHUNBASE_Recoil", ply)
			SendUserMessage("PHUNBASE_PrimaryAttackOverride_CL", ply)
		end
		
		ply:DoAttackEvent()
		
		self:Cheap_WM_ShootEffects()
	end
	
	self:TakePrimaryAmmo(1)
	
end

function SWEP:SecondaryAttack()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() then return end
	
	if self:Clip1() < 1 then
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:SetNextSecondaryFire(CurTime() + 0.25)
		self:EmitSound(self.EmptySoundPrimary)
		return
	end
	
	if self:Clip1() == 1 then
		self:PrimaryAttack()
		return
	end
	
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	
	if IsFirstTimePredicted() then
		self:EmitSound(self.FireSoundSecondary)
		
		self:_FireBullets(self.Secondary.Bullets) 
		self:StopViewModelParticles()
		
		if self:GetIron() then
			self:PlayVMSequence("fire_secondary_iron")
		else
			self:PlayVMSequence("fire_secondary")
		end
		
		self:PlayMuzzleFlashEffect()
		self:MakeShell()
		self:MakeRecoil()
		
		if CLIENT then
			self:simulateRecoil()
		end
		
		if SP and SERVER then
			if !self.Owner:IsPlayer() then return end
			SendUserMessage("PHUNBASE_Recoil", ply)
			SendUserMessage("PHUNBASE_PrimaryAttackOverride_CL", ply)
		end
		
		ply:DoAttackEvent()
		
		self:Cheap_WM_ShootEffects()
	end
	
	self:TakePrimaryAmmo(2)
	
end
