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
SWEP.SprintHoldType = "passive"
SWEP.CrouchHoldType = "shotgun"
SWEP.ReloadHoldType = "shotgun"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables
SWEP.Primary.Ammo = "buckshot"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Automatic = false
SWEP.Primary.Damage = 22
SWEP.Primary.Delay = 0.33
SWEP.Primary.Force = 5
SWEP.Primary.Bullets = 7
SWEP.Primary.TakePerShot = 1

SWEP.FireModes = {"pump"}

SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Bullets = 12
SWEP.Secondary.TakePerShot = 2

// Recoil variables
SWEP.Recoil	= 0.45
SWEP.Spread	= 0.075
SWEP.Spread_Iron = 0.065
SWEP.SpreadVel = 1.2
SWEP.SpreadVel_Iron = 0.9
SWEP.SpreadAdd = 0.3
SWEP.SpreadAdd_Iron	= 0.2

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
	fire_iron = "fire01",
	fire_secondary = "altfire",
	fire_iron_secondary = "altfire",
	fire_last = "fire01",
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
	cock = "pump"
}

SWEP.Sounds = {
	reload2 = {
		{time = 0, sound = "Weapon_Shotgun.Reload"},
	},
	pump = {
		{time = 0, sound = "Weapon_Shotgun.Special1"},
	},
	-- fire01 = {
		-- {time = 0.3, sound = "Weapon_Shotgun.Special1", callback = function(wep) wep:PlayVMSequence("cock") end},
	-- },
	-- altfire = {
		-- {time = 0.4, sound = "Weapon_Shotgun.Special1", callback = function(wep) wep:PlayVMSequence("cock") end},
	-- },
}

SWEP.DeployTime = 0.45
SWEP.HolsterTime = 0.25

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.ShellVelocity = {X = 75, Y = -20, Z = 0}
SWEP.ShellAngularVelocity = {Pitch_Min = -500, Pitch_Max = 200, Yaw_Min = 0, Yaw_Max = 1000, Roll_Min = -200, Roll_Max = 100}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = -90, Up = 0}
SWEP.ShellAttachmentName = "1"
SWEP.ShellDelay = 0.15
SWEP.ShellScale = 1
SWEP.ShellModel = "models/phunbase/shells/12g_bird_open.mdl"
SWEP.ShellSound = "PB_SHELLIMPACT_SHOTGUN"

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol", "smoke_trail"}

SWEP.FireSound = "Weapon_Shotgun.Single"
SWEP.FireSoundSecondary = "Weapon_Shotgun.Double"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.HL2_IconParams = {dist = 35, mdlOffset = Vector(0,0,0), camOffset = -1}

SWEP.ShotgunReload = true

SWEP.ShotgunReloadTimes = {
	Start = 0.4,
	Start_Empty = 0.4,
	Insert = 0.4,
	End = 0.4,
	End_Empty = 0.4,
}

SWEP.CockAfterShot = true
SWEP.CockAfterShotTime = 0.55
SWEP.MakeShellOnCock = true

SWEP.AutoCockStart = true
SWEP.AutoCockStartTime = 0.33

SWEP.ReloadAfterShot = false

function SWEP:_setupOrigValues()
	if !self.Primary.Delay_Orig then self.Primary.Delay_Orig = self.Primary.Delay end
	if !self.Primary.Bullets_Orig then self.Primary.Bullets_Orig = self.Primary.Bullets end
	if !self.Primary.TakePerShot_Orig then self.Primary.TakePerShot_Orig = self.Primary.TakePerShot end
	if !self.FireSound_Orig then self.FireSound_Orig = self.FireSound end
	if !self.FireSeq_Orig then self.FireSeq_Orig = self.Sequences.fire end
	if !self.FireSeqIron_Orig then self.FireSeqIron_Orig = self.Sequences.fire_iron end
end

function SWEP:_setupPrimaryValues()
	self.Primary.Delay = self.Primary.Delay_Orig
	self.Primary.Bullets = self.Primary.Bullets_Orig
	self.Primary.TakePerShot = self.Primary.TakePerShot_Orig
	self.FireSound = self.FireSound_Orig
end

function SWEP:_setupSecondaryValues()
	self.Primary.Delay = self.Secondary.Delay
	self.Primary.Bullets = self.Secondary.Bullets
	self.Primary.TakePerShot = self.Secondary.TakePerShot
	self.FireSound = self.FireSoundSecondary
end

function SWEP:PrimaryAttack()
	self:_setupOrigValues()
	self:_setupPrimaryValues()
	
	self:_primaryAttack()
end

function SWEP:SecondaryAttack()
	self:_setupOrigValues()
	if self:Clip1() == 1 then
		self:_setupPrimaryValues()
		self._IsSecondary = false
	else
		self:_setupSecondaryValues()
		self._IsSecondary = true
	end
	
	self:_primaryAttack(self._IsSecondary)
end
