SWEP.Base = "phun_base"

SWEP.PrintName = "RPG"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.HoldType = "rpg"
SWEP.SprintHoldType = "passive"
SWEP.CrouchHoldType = "rpg"
SWEP.ReloadHoldType = "rpg"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables

SWEP.Primary.Ammo = "rpg_round"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 200
SWEP.Primary.Force = 10
SWEP.Primary.Bullets = 1

SWEP.HUD_NoFiremodes = true

SWEP.BasePos = Vector(0,0,0)
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(-7.995, -11.25, 2.075)
SWEP.IronsightAng = Vector(0, 0, 0)

SWEP.SprintPos = Vector(0, -6.061, 2.937)
SWEP.SprintAng = Vector(-19.701, 29.7, 0)

SWEP.SprintPos = Vector(0, -8.353, 2.631)
SWEP.SprintAng = Vector(-21.3, 21.799, 0)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0, -10, 0)
SWEP.NearWallAng = Vector(0, 0, 0)

SWEP.PistolSprintSway = true
SWEP.Chamberable = false

-- SWEP.VElements = {
	-- ["pb_scope_rt_model"] = { model = "models/phunbase/pb_scope_rt.mdl", bone = "ValveBiped.Crossbow_base", pos = Vector(-0.013, -4.528, -5.45), angle = Angle(90, 0, -90), size = Vector(1.1, 1.1, 1.1), active = true },
	-- ["xbow_model_fix"] = { model = "models/phunbase/attachments/hl2_crossbow_modelfix.mdl", size = Vector(1, 1, 1), bonemerge = true, active = true }
-- }

SWEP.Sequences = {
	idle = "idle1",
	idle_empty = "idle1",
	idle_iron = "idle1",
	idle_iron_empty = "idle1",
	fire = "fire",
	fire_last = "fire",
	fire_iron = "fire",
	fire_iron_last = "fire",
	reload = "reload",
	deploy = "draw",
	holster = "up_to_down",
	lighton = "idle",
	lighton_iron = "idle",
	goto_iron = "idle",
	goto_hip = "idle",
}

SWEP.Sounds = {
	-- reload = {
		-- {time = 0.90, sound = "Weapon_Crossbow.BoltElectrify", callback = function(wep) wep.XBOWGLOW = true end},
	-- },
}

SWEP.DeployTime = 1.1
SWEP.HolsterTime = 0.75

SWEP.ReloadTimes = {
	Base = 1.7,
}

SWEP.ViewModelMovementScale = 0.8

// shell-related stuff
SWEP.NoShells = true

SWEP.MuzzleAttachmentName = "spark"
SWEP.MuzzleEffect = {}

SWEP.FireSound = {"Weapon_RPG.Single"}

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false

SWEP.HL2_IconParams = {dist = 57, mdlOffset = Vector(-20,0,0), camOffset = -3.5}

SWEP.DisableIronsights = true
SWEP.DisableReloadBlur = true
SWEP.ReloadAfterShot = false
SWEP.ReloadAfterShotTime = 0.1
SWEP.NoReloadAnimation = true

SWEP.UsesAmmoCountLogic = false

SWEP.FireMoveMod = 1

function SWEP:TumbleMissile(ent)
	local d = DamageInfo()
	d:SetDamage( 100 )
	d:SetAttacker( self )
	d:SetInflictor( self )
	d:SetDamageType( DMG_AIRBOAT )
	ent:TakeDamageInfo( d )
end

function SWEP:FireMissile()
	local ply = self.Owner
	local dir = ply:EyeAngles():Forward()
	local ent = ents.Create( "rpg_missile" )
	if ( IsValid( ent ) ) then
		ent:SetPos( ply:GetShootPos() + dir * 32 + ply:EyeAngles():Right() * 10 )
		ent:SetAngles( ply:EyeAngles() )
		ent:Spawn()
		ent:Activate()
		ent:SetVelocity( dir * 250 + ply:EyeAngles():Up() * 100 )
		ent:SetOwner(ply)
		ent.Owner = ply
		ent:SetMoveType(MOVETYPE_FLYGRAVITY)
		ent:SetSaveValue("m_flDamage", self.Primary.Damage)
		ent.Weapon = self
		
		self.ActiveMissile = ent
		self:SetIsWaiting(true)
		ent:CallOnRemove("PB_HL2_RPG_Rocket_OnRemove", function(ent) if IsValid(ent.Weapon) then ent.Weapon:SetIsWaiting(false) ent.Weapon:_realReloadStart() self.LaserDot:Remove() self.ActiveMissile = nil end end)
	end
end

function SWEP:Reload()
	if !self:GetIsReloading() and self:Clip1() == 0 and !self.ActiveMissile then
		self:_realReloadStart()
	end
end

function SWEP:PrimaryAttackOverride()
	if SERVER then
		self:FireMissile()
		
		if !IsValid(self.LaserDot) then
			self.LaserDot = ents.Create( "env_laserdot" )
			self.LaserDot:SetSaveValue("m_hOwner", self.Owner)
			self.LaserDot:SetOwner(self.Owner)
		end
	end
end

function SWEP:OnRemove()
	if SERVER then
		if IsValid(self.LaserDot) then
			self.LaserDot:Remove()
		end
	end
end

function SWEP:AdditionalThink()
	if SERVER then
		local ld = self.LaserDot
		local pos = self.Owner:GetEyeTrace().HitPos
		if IsValid(ld) and pos then
			ld:SetPos(pos)
		end
	end
end
