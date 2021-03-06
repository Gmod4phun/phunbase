SWEP.Base = "phun_base"

SWEP.PrintName = "SMG"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.HoldType = "smg"
SWEP.SprintHoldType = "passive"
SWEP.CrouchHoldType = "smg"
SWEP.ReloadHoldType = "smg"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Damage = 23
SWEP.Primary.Delay = 0.075
SWEP.Primary.Force = 5
SWEP.Primary.Bullets = 1

SWEP.FireModes = {"auto"}

// Recoil variables
SWEP.Recoil	= 0.2
SWEP.Spread	= 0.02
SWEP.Spread_Iron = 0.01
SWEP.SpreadVel = 1.2
SWEP.SpreadVel_Iron = 0.9
SWEP.SpreadAdd = 0.3
SWEP.SpreadAdd_Iron	= 0.2

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(-6.393, -6.674, 1.024)
SWEP.IronsightAng = Vector(0, 0, 0)

SWEP.SprintPos = Vector(0.481, -6.25, 0.351)
SWEP.SprintAng = Vector(-15.301, 28, -8.811)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0, -10, 0)
SWEP.NearWallAng = Vector(0, 0, 0)

SWEP.PistolSprintSway = true

SWEP.DisableIronsights = true
SWEP.Chamberable = false

SWEP.Sequences = {
	idle = "idle01",
	idle_empty = "idle01",
	idle_iron = "idle01",
	idle_iron_empty = "idle01",
	fire = "fire02",
	fire_last = "fire01",
	fire_iron = "fire02",
	fire_iron_last = "fire01",
	reload = "reload",
	deploy = "draw",
	holster = "draw",
	goto_iron = "idle01",
	goto_hip = "idle01",
	alt = "altfire",
}

SWEP.Sounds = {
	reload = {
		{time = 0, sound = "Weapon_SMG1.Reload"},
	},
	altfire = {
		{time = 0, sound = "Weapon_SMG1.Double"},
	}
}

SWEP.DeployTime = 0.3
SWEP.HolsterTime = 0.3

SWEP.ReloadTimes = {
	Base = 1.6,
}

SWEP.HolsterAnimSpeed = -2
SWEP.HolsterAnimStartCyc = 1

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.ShellVelocity = {X = 60, Y = -20, Z = 0}
SWEP.ShellAngularVelocity = {Pitch_Min = -500, Pitch_Max = 200, Yaw_Min = 0, Yaw_Max = 1000, Roll_Min = -200, Roll_Max = 100}
SWEP.ShellViewAngleAlign = {Forward = 0, Right = -90, Up = 0}
SWEP.ShellAttachmentName = "1"
SWEP.ShellDelay = 0.01
SWEP.ShellScale = 1
SWEP.ShellModel = "models/phunbase/shells/4_6x30mm.mdl"

SWEP.MuzzleAttachmentName = "muzzle"
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol", "smoke_trail"}

SWEP.FireSound = "Weapon_SMG1.Single"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.HL2_IconParams = {dist = 24, mdlOffset = Vector(0,0,0), camOffset = 0.5}

SWEP.Secondary.Ammo = "SMG1_Grenade"
SWEP.Secondary.Delay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 3
SWEP.Secondary.Automatic = true

function SWEP:FireSMGGrenade()
	if CLIENT then return end
	
	local ply = self.Owner
	local dir = ply:EyeAngles():Forward()
	local ent = ents.Create( "grenade_ar2" )
	local pos = ply:GetShootPos() + dir
	
	if ( IsValid( ent ) ) then
		ent:SetPos( pos )
		ent:SetAngles( ply:EyeAngles() )
		ent:Spawn()
		ent:Activate()
		ent:SetOwner( ply )
		ent.Owner = self:GetOwner()
		ent:SetSaveValue("m_flDamage", 100)
		ent:SetSaveValue("m_flDangerRadius", 100)
		ent:SetVelocity( dir * 1000 )
		ent:SetLocalAngularVelocity( Angle(math.random(-400, 400), math.random(-400, 400), math.random(-400, 400) ) )
	end
	
	if ply:GetAmmoCount(self:GetSecondaryAmmoType()) > 0 then
		ply:RemoveAmmo( 1, self:GetSecondaryAmmoType() )
	end
	
	ply:ViewPunch(Angle(-2, 0, 0))
end

function SWEP:SecondaryAttackOverride()
	if self.Owner:GetAmmoCount(self:GetSecondaryAmmoType()) < 1 then
		self:SetNextSecondaryFire(CurTime()+0.25)
		self:EmitSound(self.EmptySoundSecondary)
		return
	end
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 1)
	self:PlayVMSequence("alt", 1, 0)
	self:FireSMGGrenade()
end
