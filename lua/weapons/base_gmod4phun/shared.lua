local SP, TimeScale
SP = game.SinglePlayer()

AddCSLuaFile()

PHUNBASE.LoadLua("cl_blur.lua")
PHUNBASE.LoadLua("cl_crosshair.lua")
PHUNBASE.LoadLua("cl_flashlight.lua")
PHUNBASE.LoadLua("cl_hooks.lua")
PHUNBASE.LoadLua("cl_model.lua")
PHUNBASE.LoadLua("cl_shells.lua")
PHUNBASE.LoadLua("sh_firebullets.lua")
PHUNBASE.LoadLua("sh_networkfuncs.lua")
PHUNBASE.LoadLua("sh_reloading.lua")
PHUNBASE.LoadLua("sh_sequences.lua")
PHUNBASE.LoadLua("sh_thinkfuncs.lua")
PHUNBASE.LoadLua("sv_flashlight.lua")

SWEP.PrintName = "PHUN BASE"
SWEP.Category = "PHUN BASE"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.IconLetter = "1"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.SwayScale = 1
SWEP.BobScale = 1

SWEP.Base = "weapon_base"
SWEP.PHUNBASEWEP = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.AimViewModelFOV = 70
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.HoldType = "pistol"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 20
SWEP.Primary.Force = 10
SWEP.Primary.Bullets = 0
SWEP.Primary.Tracer = 0
SWEP.Primary.Spread = 0.02
SWEP.Primary.Cone = 0.02

//
//

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

//
//

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

SWEP.FireSound = ""

function SWEP:FireAnimationEvent(pos,ang,event,name)
	return true
end

function SWEP:Initialize()
	self:InitRealViewModel()
	
	self:SetHoldType(self.HoldType)
	PHUNBASE.cmodel:LoopCheck()
	
	self.AimPos = self.IronsightPos
	self.AimAng = self.IronsightAng
	
	self.ViewModelFOV_Orig = self.ViewModelFOV
	self.CurVMFOV = self.ViewModelFOV
	
	self:SetIron(false)
	self:SetIsDual(self.IsDual)
	self:SetDualSide("right")
	self:SetIsReloading(false)
	self:SetIsSprinting(false)
	self:SetIsDeploying(false)
	self:SetIsHolstering(false)
	self:SetIsNearWall(false)
	self:SetIsUnderwater(false)
	self:SetIsOnLadder(false)
	self:SetHolsterDelay(0)
	self:SetMuzzleAttachmentName(self.MuzzleAttachmentName)
	self:SetShellAttachmentName(self.ShellAttachmentName)
	self:SetFlashlightState(false)
	self:SetFlashlightStateOld(false)
	
	self._deployedShells = {}
	
	if CLIENT then
		self:_CreateVM()
		self:_CreateHands()
	end
	
	self.IronRollOffset = 0
	self.RealIronRoll = 0
end

function SWEP:Deploy()
	self:InitRealViewModel() // needed both in Init and Deploy, so that picked up weapons dont error
	self:_UpdateHands()
	
	if SERVER then
		self:CreateFlashlight()
		self:SetFlashlightState(false)
		self:SetFlashlightStateOld(true)
		if !self.NormalFlashlight then
			if self.Owner:FlashlightIsOn() then
				self.Owner:Flashlight(false)
			end
		end
	end
	
	if IsFirstTimePredicted() then
		if CLIENT then
			self.CurSoundTable = nil
			self.CurSoundEntry = nil
			self.SoundTime = nil
			self.SoundSpeed = 1
		end
	end
	
	self:SetHolsterDelay(0)
	self.FinishDeployTime = CurTime() + self.DeployTime
	self:SetIsDeploying(true)
	self:PlayVMSequence("deploy")
	self.SwitchWep = nil
	return true
end

function SWEP:Holster(wep)
	if not IsValid(wep) and not IsValid(self.SwitchWep) then
		self.SwitchWep = nil
		return false
	end

	if self:GetIsDeploying() or self:GetIsReloading() or ( self:GetHolsterDelay() ~= 0 and CurTime() < self:GetHolsterDelay() ) then
		return false
	end
	
	if !self:GetIsHolstering() then
		self:SetHolsterDelay(CurTime() + self.HolsterTime)
	end
	
	self:SetIsHolstering(true)
	self:SetFlashlightState(false)

	if self.SwitchWep and self:GetIsHolstering() and CurTime() > self:GetHolsterDelay() then
		self:SetIsHolstering(false)
		self:SetHolsterDelay(0)
		if SERVER then
			self:DestroyFlashlight()
		end
		return true
	end

	if IsFirstTimePredicted() then
		if self:GetActiveSequence() != "holster" then
			self:PlayVMSequence("holster")
		end
	end
	
	self.SwitchWep = wep
end

function SWEP:_CalcIronRoll()
	if CLIENT then
		TimeScale = game.GetTimeScale()
		if self:GetIron() then
			self.IronRollOffset = PHUNBASE_Lerp(FrameTime() * 20/TimeScale, self.IronRollOffset, 179)
		else
			self.IronRollOffset = PHUNBASE_Lerp(FrameTime() * 20/TimeScale, self.IronRollOffset, 1)
		end
		if !self:GetIsDual() then
			self.RealIronRoll = math.Clamp( math.sin(math.rad(self.IronRollOffset)) , 0, 0.5 )
		else
			self.RealIronRoll = 0
		end
	end
end

function SWEP:Think()
	self.lastOwner = self.Owner
	self:_IdleAnimThink()
	self:_IronThink()
	self:_SprintThink()
	self:_HideBGHands()
	self:_DeployThink()
	self:_CalcIronRoll()
	self:_NearWallThink()
	self:_WaterLadderThink()
	self:_ReloadThink()
	self:_SoundTableThink()
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:Clip1() < 1 then return end
	
	if IsFirstTimePredicted() then
		self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)	
		self:SetClip1(self:Clip1()-1)
		self:EmitSound(self.FireSound)
		
		self:_FireBullets()
		self:StopViewModelParticles()
		self:FireAnimLogic()
		self:PlayMuzzleFlashEffect()
		self:MakeShell()
		self:MakeRecoil()
		
		if CLIENT then
			self:simulateRecoil()
		end
		
		if SP and SERVER then
			if !self.Owner:IsPlayer() then return end
			SendUserMessage("PHUNBASE_Recoil", ply)
		end
	end
end

function SWEP:FireAnimLogic()
	local last = self:Clip1() == 0
	if !self:GetIsDual() then
		if self:GetIron() then
			self:PlayVMSequence(last and "fire_iron_last" or "fire_iron")
		else
			self:PlayVMSequence(last and "fire_last" or "fire")
		end
	else
		if self:GetDualSide() == "left" then
			if self:GetIron() then
				self:PlayVMSequence("fire_left_iron")
			else
				self:PlayVMSequence("fire_left")
			end
			self:SetMuzzleAttachmentName(self.MuzzleAttachmentName_L)
			self:SetShellAttachmentName(self.ShellAttachmentName_L)
			self:SetDualSide("right")
		elseif self:GetDualSide() == "right" then
			if self:GetIron() then
				self:PlayVMSequence("fire_right_iron")
			else
				self:PlayVMSequence("fire_right")
			end
			self:SetMuzzleAttachmentName(self.MuzzleAttachmentName_R)
			self:SetShellAttachmentName(self.ShellAttachmentName_R)
			self:SetDualSide("left")
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:OnRemove()
end

function SWEP:OnDrop()
	self:SetFlashlightState(false)
	self:DestroyFlashlight()
end

function SWEP:GetViewModelPosition(pos,ang)
	return self.PB_VMPOS, self.PB_VMANG
end

/*
function SWEP:PreDrawViewModel()
	render.SetBlend(1) // dont render the default viewmodel, but we use it for particle positions later
end

function SWEP:PostDrawViewModel()
	render.SetBlend(1) //back to normal rendering
end
*/

// RECOIL

SWEP.Recoil = 0.5
SWEP.FireMoveMod = 10
SWEP.LuaViewmodelRecoil = true
SWEP.FullAimViewmodelRecoil = true
SWEP.LuaVMRecoilIntensity = 1
SWEP.LuaVMRecoilLowerSpeed = 1
SWEP.LuaVMRecoilMod = 1 -- modifier of overall intensity for the code based recoil
SWEP.LuaVMRecoilAxisMod = {vert = 0, hor = 0, roll = 0, forward = 2, pitch = -1} -- modifier for intensity of the recoil on varying axes

function SWEP:simulateRecoil()
	if self:GetIron() then
		self.FireMove = math.Clamp(self.Recoil * self.FireMoveMod, 1, 3)
	else
		self.FireMove = 0.4
	end
	
	/*if !self:GetIron() then
		self.FOVHoldTime = UnPredictedCurTime() + self.FireDelay * 2
		
		if self.HipFireFOVIncrease then
			self.FOVTarget = math.Clamp(self.FOVTarget + 8 / (self.Primary.ClipSize_Orig * 0.75) * self.FOVPerShot, 0, 7)
		end
	end*/
	
	if self.freeAimOn and not self.dt.BipodDeployed then -- we only want to add the 'roll' view shake when we're not using a bipod in free-aim mode
		self.lastViewRoll = math.Clamp(self.lastViewRoll + self.Recoil * 0.5, 0, 15)
		self.lastViewRollTime = UnPredictedCurTime() + FrameTime() * 3
	end
	
	//self.lastShotTime = CurTime() + math.Clamp(self.FireDelay * 3, 0, 0.3) -- save the last time we shot
	
	if self.BoltBone then
		self:offsetBoltBone()
	end
	
	if self.LuaViewmodelRecoil then
		if (!self:GetIron() and not self.FullAimViewmodelRecoil) or self.FullAimViewmodelRecoil then
			-- increase intensity of the viewmodel recoil with each shot
			self.LuaVMRecoilIntensity = math.Approach(self.LuaVMRecoilIntensity, 1, self.Recoil * 0.15)
			self.LuaVMRecoilLowerSpeed = 0
			self:makeVMRecoil()
		end
	end
end

function SWEP:MakeRecoil(mod)
	local mod = 1 //self:GetRecoilModifier(mod)
	
	if !self.Owner:IsPlayer() then return end
	
	if (SP and SERVER) or (not SP and CLIENT) then
		ang = self.Owner:EyeAngles()
		ang.p = ang.p - self.Recoil * 0.5 * mod
		ang.y = ang.y + math.Rand(-1, 1) * self.Recoil * 0.5 * mod
	
		self.Owner:SetEyeAngles(ang)
	end

	self.Owner:ViewPunch(Angle(-self.Recoil * 1.25 * mod, 0, 0))
end

if CLIENT then
	local ply, wep, CT
	
	local function GetRecoil()
		ply = LocalPlayer()
		
		if not ply:Alive() then
			return
		end
		
		wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and wep.PHUNBASEWEP then
			//CT = CurTime()
			//wep.SpreadWait = CT + wep.SpreadCooldown
			
			wep:MakeRecoil()
			wep:simulateRecoil()
			//wep:addFireSpread(CT)
		end
	end
	
	usermessage.Hook("PHUNBASE_Recoil", GetRecoil)
end