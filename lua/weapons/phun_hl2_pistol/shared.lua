SWEP.Base = "phun_base"

SWEP.PrintName = "9MM PISTOL"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.HoldType = "revolver"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "pistol"
SWEP.ReloadHoldType = "pistol"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.12
SWEP.Primary.Force = 5
SWEP.Primary.Bullets = 1

// Recoil variables
SWEP.Recoil	= 0.45
SWEP.Spread	= 0.02
SWEP.Spread_Iron = 0.01
SWEP.SpreadVel = 1.2
SWEP.SpreadVel_Iron = 0.9
SWEP.SpreadAdd = 0.3
SWEP.SpreadAdd_Iron	= 0.2

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(-5.762, -8.65, 2.993)
SWEP.IronsightAng = Vector(0.666, -1.244, 1.871)

SWEP.SprintPos = Vector(1.257, -11.785, 2.936)
SWEP.SprintAng = Vector(-15.342, 20.095, -6.507)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0, -10, 0)
SWEP.NearWallAng = Vector(0, 0, 0)

SWEP.PistolSprintSway = true

SWEP.DisableIronsights = true
SWEP.Chamberable = false

SWEP.Sequences = {
	idle = "idle01",
	idle_empty = "idle01empty",
	idle_iron = "idle01",
	idle_iron_empty = "idle01empty",
	fire = {"fire1", "fire2", "fire3"},
	fire_last = {"fire1", "fire2", "fire3"},
	fire_iron = {"fire1", "fire2", "fire3"},
	fire_iron_last = {"fire1", "fire2", "fire3"},
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
}

SWEP.Sounds = {
	reload = {
		{time = 0, sound = "Weapon_Pistol.Reload"},
	}
}

SWEP.DeployTime = 0.3
SWEP.HolsterTime = 0.25

SWEP.ReloadTimes = {
	Base = 1.5,
}

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.ShellVelocity = {X = 65, Y = -35, Z = 0}
SWEP.ShellAngularVelocity = {Pitch_Min = -500, Pitch_Max = 200, Yaw_Min = 0, Yaw_Max = 1000, Roll_Min = -200, Roll_Max = 100}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = -90, Up = 0}
SWEP.ShellAttachmentName = "1"
SWEP.ShellDelay = 0.0025
SWEP.ShellScale = 1
SWEP.ShellModel = "models/phunbase/shells/9x19mm.mdl"

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol", "smoke_trail"}

SWEP.FireSound = "Weapon_Pistol.Single"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.CanUseUnderwater = true

SWEP.HL2_IconParams = {dist = 18, mdlOffset = Vector(0,0,0), camOffset = 1.5}
