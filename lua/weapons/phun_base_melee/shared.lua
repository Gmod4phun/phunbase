AddCSLuaFile()

SWEP.PrintName = "PHUNBASE MELEE"
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

SWEP.HoldType = "melee"
SWEP.SafeHoldType = "normal"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "melee"
SWEP.ReloadHoldType = "melee"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Weight = -1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.FireModes = {"auto"}
SWEP.HUD_NoFiremodes = true

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
SWEP.DisableNearwall = true

SWEP.MeleeAttackWaitTime = 0.15
SWEP.MeleeRedeployWaitTime = 0.5
SWEP.MeleeDamage = 20
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeRange = 50

SWEP.MeleeSoundHitFlesh = ""
SWEP.MeleeSoundHitWorld = ""
SWEP.MeleeSoundSwing = ""

// FX_BLOODSPRAY Enums for BloodEffect SetFlags(), but seems to not do anything
FX_BLOODSPRAY_DROPS = 0x01
FX_BLOODSPRAY_GORE = 0x02
FX_BLOODSPRAY_CLOUD = 0x04
FX_BLOODSPRAY_ALL = 0xFF

local SP = game.SinglePlayer()

function SWEP:PrimaryAttack()
	self:InitiateAttack()
end

function SWEP:SecondaryAttack()
	self:InitiateAttack()
end

function SWEP:OnMeleeHit()
end

function SWEP:DoDamage()
	local ply = self.Owner
	local origin = ply:GetShootPos()
	local dir = ply:EyeAngles():Forward()
	local effect = "Impact"
	local mins, maxs = Vector(-4, -4, -4), Vector(4, 4, 4)
	
	local tr = util.TraceHull({
		start = origin,
		endpos = origin + dir * self.MeleeRange,
		filter = ply,
		mins = mins,
		maxs = maxs
	})

	if tr.Hit then	
		local ent = tr.Entity
		local ed = EffectData()
		
		if IsValid(ent) then
			if SERVER then
				local dmg = DamageInfo()
				dmg:SetAttacker(ply)
				dmg:SetInflictor(self)
				dmg:SetDamageType(self.MeleeDamageType)
				dmg:SetDamage(self.MeleeDamage)
				dmg:SetDamagePosition(tr.HitPos)
				dmg:SetDamageForce(ply:GetAimVector() * self.MeleeDamage * 200)			
				ent:TakeDamageInfo(dmg)
			end
			
			if ent:IsNPC() then
				if SERVER and ent:GetBloodColor() != -1 then
					ed:SetColor(ent:GetBloodColor())
					ed:SetFlags(FX_BLOODSPRAY_ALL)
				end
				effect = "BloodImpact"
			end
			
			if ent:GetClass() == "npc_hunter" then // white blood color does not exist, needs it's own effect
				effect = "pb_impact_effect_hunter"
			end
		end

		local tr2 = util.TraceLine({ // TraeLine needed for proper decal application, TraceHull hitpos does not play nice with decals
			start = tr.StartPos,
			endpos = tr.StartPos + (tr.HitPos - tr.StartPos):GetNormalized() * self.MeleeRange,
			filter = ply
		})
		
		ed:SetOrigin(tr2.HitPos)
		ed:SetStart(tr.StartPos)
		ed:SetSurfaceProp(tr.SurfaceProps)
		ed:SetDamageType(self.MeleeDamageType)
		ed:SetHitBox(tr.HitBox)
		
		if (IsValid(ent) or ent:IsWorld()) then
			ed:SetEntity(ent)
			if SERVER then
				ed:SetEntIndex(ent:EntIndex())
			end
		end
		
		if (!SP and CLIENT) or SERVER then
			util.Effect(effect, ed)
		end
		
		if self.OnMeleeHit then
			self:OnMeleeHit(tr2)
		end
	end
end

// https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/game/shared/shareddefs.h#L627

function SWEP:InitiateAttack()
	local ply = self.Owner
	
	if self:GetIsDeploying() or self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() then return end
	
	if IsFirstTimePredicted() then
		self:PlayVMSequence(ply:KeyDown(IN_ATTACK2) and "attack2" or "attack1")
	end
	
	local t = CurTime() + self.MeleeAttackWaitTime + self.MeleeRedeployWaitTime
	self:SetNextPrimaryFire(t)
	self:SetNextSecondaryFire(t)
	
	self:EmitSound(self.MeleeSoundSwing, 70, 100)
	self.ReadyToAttack = true
	self.NextMeleeAction = CurTime() + self.MeleeAttackWaitTime
end

function SWEP:AdditionalThink()
	if (SP and SERVER) or IsFirstTimePredicted() then
		if self.ReadyToAttack and self.NextMeleeAction and CurTime() > self.NextMeleeAction then
			self.ReadyToAttack = false
			self.NextMeleeAction = nil
			self:DoDamage()
			self.RedeployTime = CurTime() + self.MeleeRedeployWaitTime
			self.Owner:SetAnimation(PLAYER_ATTACK1)
		end
	end
end

function SWEP:Reload()
end
