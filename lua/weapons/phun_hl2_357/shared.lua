SWEP.Base = "phun_base"

SWEP.PrintName = ".357 MAGNUM"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.ViewModelFOV = 60
SWEP.AimViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.HoldType = "revolver"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "revolver"
SWEP.ReloadHoldType = "revolver"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

// weapon specific variables
SWEP.Primary.Ammo = "357"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Automatic = false
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.65
SWEP.Primary.Force = 5
SWEP.Primary.Bullets = 1
SWEP.Primary.Tracer = 0

// Recoil variables
SWEP.Recoil	= 4
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

SWEP.SprintPos = Vector(2.605, -6.665, 0.750)
SWEP.SprintAng = Vector(-13.702, 22.934, -5.764)

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
	fire = "fire",
	fire_last = "fire",
	fire_iron = "fire",
	fire_iron_last = "fire",
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
	reload_shell_start = "reload_start",
	reload_shell_start_empty = "reload_start",
	reload_shell_insert = "reload_loop",
	reload_shell_end = "reload_end",
	reload_shell_end_empty = "reload_end"
}

/*SWEP.Sounds = { // not today
	reload = {
		{time = 1.7, sound = "", callback = function(wep) wep.ShellDelay = 0 for i = 1, 6 do wep.ShellDelay = wep.ShellDelay + i*0.04 wep:MakeShell() end end},
	}
}*/

SWEP.DeployTime = 0.8
SWEP.HolsterTime = 0.25
SWEP.ReloadTime = 3.65
SWEP.DeployTimeAnimOffset = 0.3

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.ShellVelocity = {X = 60, Y = 0, Z = -40}
SWEP.ShellAngularVelocity = {Pitch_Min = -500, Pitch_Max = 200, Yaw_Min = 0, Yaw_Max = 1000, Roll_Min = -200, Roll_Max = 100}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = -90, Up = 0}
SWEP.ShellAttachmentName = "muzzle"
SWEP.ShellDelay = 0
SWEP.ShellScale = 0.8
SWEP.ShellModel = "models/weapons/shell.mdl"
SWEP.ShellEjectVelocity = 0
SWEP.NoShells = true

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol", "smoke_trail"}

SWEP.FireSound = "Weapon_357.Single"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false
