SWEP.Base = "phun_base_melee"

SWEP.PrintName = "CROWBAR"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.HoldType = "melee"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "melee"
SWEP.ReloadHoldType = "melee"

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

SWEP.SprintPos = Vector(0.000, 0.000, 0.000)
SWEP.SprintAng = Vector(-10, 0.000, 0.000)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(1.510, -4.800, 1.030)
SWEP.NearWallAng = Vector(-13.560, 20.560, -11.080)

SWEP.PistolSprintSway = true
SWEP.UseIronTransitionAnims = false

SWEP.Sequences = {
	idle = "idle01",
	deploy = "draw",
	attack1 = {"hitcenter1", "hitcenter2", "hitcenter3"},
	attack2 = {"hitcenter1", "hitcenter2", "hitcenter3"},
	miss = {"misscenter1", "misscenter2"},
	holster = "holster"
}

SWEP.DeployTime = 0.75
SWEP.HolsterTime = 0.25
SWEP.ReloadTime = 0

SWEP.ViewModelMovementScale = 0.75

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false
SWEP.FlashlightAttachmentName = "1"
SWEP.InstantFlashlight = false

SWEP.HL2_IconParams = {dist = 40, mdlOffset = Vector(0,0,0), camOffset = -2}

SWEP.MeleeAttackWaitTime = 0.025
SWEP.MeleeRedeployWaitTime = 0.4
SWEP.MeleeDamage = 25
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeRange = 70

SWEP.MeleeSoundHitFlesh = "Weapon_Crowbar.Melee_Hit"
SWEP.MeleeSoundHitWorld = "physics/concrete/concrete_impact_bullet1.wav"
SWEP.MeleeSoundSwing = "Weapon_Crowbar.Single"

SWEP.CanUseUnderwater = true
SWEP.CanUseOnLadder = true

function SWEP:OnMeleeHit()
	self:EmitSound("Flesh.BulletImpact")
end

function SWEP:SecondaryAttack()
	return
end
