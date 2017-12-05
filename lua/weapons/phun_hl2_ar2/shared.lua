SWEP.Base = "base_gmod4phun"

SWEP.PrintName = "PULSE-RIFLE"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 2
SWEP.SlotPos = 1

include("sounds.lua")

SWEP.ViewModelFOV = 55
SWEP.AimViewModelFOV = 55
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.HoldType = "ar2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

// weapon specific variables

SWEP.Primary.Ammo = "ar2"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 20
SWEP.Primary.Force = 10
SWEP.Primary.Bullets = 1
SWEP.Primary.Tracer = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Cone = 0.01

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(-7.995, -11.25, 2.075)
SWEP.IronsightAng = Vector(0, 0, 0)

SWEP.SprintPos = Vector(0, -6.061, 2.937)
SWEP.SprintAng = Vector(-19.701, 29.7, 0)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0, -10, 0)
SWEP.NearWallAng = Vector(0, 0, 0)

SWEP.PistolSprintSway = true

SWEP.Sequences = {
	idle = "ir_idle",
	idle_empty = "ir_idle",
	idle_iron = "ir_idle",
	idle_iron_empty = "ir_idle",
	fire = "fire3",
	fire_last = "ir_fire",
	fire_iron = "ir_fire",
	fire_iron_last = "ir_fire",
	reload = "ir_reload",
	deploy = "ir_draw",
	holster = "ir_holster",
	lighton = "ir_idle",
	lighton_iron = "ir_idle",
	goto_iron = "ir_idle",
	goto_hip = "ir_idle",
	shake = "shake",
	fire_ball = "ir_fire2",
}

SWEP.Sounds = {
	shake = {
		{time = 0.01, sound = "Weapon_CombineGuard.Special1"},
		{time = 0.49, sound = "Weapon_Irifle.Single"},
		{time = 0.5, sound = "PB_HL2_AR2_Launch"},
	},
}

SWEP.DeployTime = 0.3
SWEP.HolsterTime = 0.25
SWEP.ReloadTime = 1.9

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
SWEP.MuzzleEffect = {"weapon_muzzle_flash_smoke_small2", "PistolGlow", "muzzle_lee_simple_pistol", "muzzle_fire_pistol", "muzzle_sparks_pistol"}

SWEP.FireSound = "Weapon_AR2.Single"

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.DisableIronsights = true

SWEP.Secondary.Ammo = "AR2AltFire"
SWEP.Secondary.Delay = 1.6
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 6
SWEP.Secondary.Automatic = true

function SWEP:FireCombineBall()
	if CLIENT then return end
	
	local ply = self.Owner
	local dir = ply:EyeAngles():Forward()
	local ent = ents.Create( "point_combine_ball_launcher" )
	local pos = ply:GetShootPos() + dir
	local ball = NULL
	
	if ( IsValid( ent ) ) then
		ent:SetPos( pos )
		ent:SetAngles( ply:EyeAngles() )
		ent:Spawn()
		ent:Activate()
		ent:SetOwner( ply )
		ent.Owner = self:GetOwner()
		ent:SetKeyValue("speed", 1000)
		ent:SetKeyValue("minspeed", 1000)
		ent:SetKeyValue("maxspeed", 1000)
		ent:SetKeyValue("maxballbounces", 0)
		ent:Fire("LaunchBall")
		
		timer.Simple(0.01, function()
			for _, v in pairs(ents.FindInSphere(pos, 32)) do
				if v:GetClass() == "prop_combine_ball" then
					ball = v
					ball:SetOwner(ply)
					self.AR2Ball = ball
					ball.FiredFrom = self
				end
			end
			ent:Remove()
		end)
		
		timer.Simple(4, function()
			if IsValid(ball) then ball:Fire("explode") end
		end)
	end
	
	if ply:GetAmmoCount(self:GetSecondaryAmmoType()) > 0 then // takesecondaryammo is broken
		ply:RemoveAmmo( 1, self:GetSecondaryAmmoType() )
	end
	
	ply:ViewPunch(Angle(-8, 0, 0))
	PHUNBASE.PlayerScreenFlash(ply, 0.1, Color(200,200,200,100))
end

function SWEP:SecondaryAttackOverride()
	if self.Owner:GetAmmoCount(self:GetSecondaryAmmoType()) < 1 then
		self:SetNextSecondaryFire(CurTime()+0.25)
		self:EmitSound(self.EmptySoundSecondary)
		return
	end
	self:SetNextPrimaryFire(CurTime() + 1.2)
	self:PlayVMSequence("shake", 1, 0)
	timer.Simple(0.5, function()
		if !IsValid(self) then return end
		self:PlayVMSequence("fire_ball", 1, 0)
		self:FireCombineBall()
	end)
end
