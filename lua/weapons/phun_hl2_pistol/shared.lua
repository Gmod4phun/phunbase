SWEP.Base = "base_gmod4phun"

SWEP.PrintName = "9MM PISTOL"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 60
SWEP.AimViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "pistol"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

// weapon specific variables

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 20
SWEP.Primary.Force = 10
SWEP.Primary.Bullets = 1
SWEP.Primary.Tracer = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Cone = 0.01

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(-5.762, -8.65, 2.993)
SWEP.IronsightAng = Vector(0.666, -1.244, 1.871)

SWEP.SprintPos = Vector(-0.44, -25, -8.7)
SWEP.SprintAng = Vector(70, 0, 0)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(1.6, -11.5, -10.301)
SWEP.NearWallAng = Vector(64.8, 0, 0)

SWEP.PistolSprintSway = true

SWEP.DisableIronsights = true

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
SWEP.ReloadTime = 1.5

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.ShellVelocity = {X = 60, Y = 0, Z = -40}
SWEP.ShellAngularVelocity = {Pitch_Min = -500, Pitch_Max = 200, Yaw_Min = 0, Yaw_Max = 1000, Roll_Min = -200, Roll_Max = 100}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = -90, Up = 0}
SWEP.ShellAttachmentName = "1"
SWEP.ShellDelay = 0.001
SWEP.ShellScale = 0.5
SWEP.ShellModel = "models/weapons/shell.mdl"
SWEP.ShellEjectVelocity = 0

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol", "smoke_trail"}

SWEP.FireSound = "Weapon_Pistol.Single"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false
