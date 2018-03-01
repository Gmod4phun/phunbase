/*
PHUNBASE BASE CODE
*/

AddCSLuaFile()

PHUNBASE.LoadLua("cl_blur.lua")
PHUNBASE.LoadLua("cl_crosshair.lua")
PHUNBASE.LoadLua("cl_flashlight.lua")
PHUNBASE.LoadLua("cl_halo.lua")
PHUNBASE.LoadLua("cl_hooks.lua")
PHUNBASE.LoadLua("cl_model.lua")
PHUNBASE.LoadLua("cl_model_movement.lua")
PHUNBASE.LoadLua("cl_rtscope.lua")
PHUNBASE.LoadLua("cl_shells.lua")
PHUNBASE.LoadLua("cl_velements.lua")
PHUNBASE.LoadLua("sh_crossbow.lua")
PHUNBASE.LoadLua("sh_firebullets.lua")
PHUNBASE.LoadLua("sh_networkfuncs.lua")
PHUNBASE.LoadLua("sh_reloading.lua")
PHUNBASE.LoadLua("sh_sequences.lua")
PHUNBASE.LoadLua("sh_thinkfuncs.lua")
PHUNBASE.LoadLua("sv_flashlight.lua")

SWEP.PrintName = "PHUNBASE"
SWEP.Category = "PHUNBASE"
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

SWEP.SprintHoldType = "passive"
SWEP.SafeHoldType = "passive"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Weight = -1
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

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0.1

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

SWEP.BipodPos = Vector(0,0,0)
SWEP.BipodAng = Vector(0,0,0)

SWEP.Sequences = {}
SWEP.Sounds = {}

SWEP.DeployTime = 0.5
SWEP.HolsterTime = 0.5
SWEP.ReloadTime = 0.5
SWEP.DeployTimeAnimOffset = 0

SWEP.ShotgunReload = false
SWEP.ShotgunReloadTime_Start = 1
SWEP.ShotgunReloadTime_Start_Empty = 1
SWEP.ShotgunReloadTime_Insert = 0.5
SWEP.ShotgunReloadTime_End = 1
SWEP.ShotgunReloadTime_End_Empty = 1

SWEP.UseHands = true

SWEP.IsDual = false
SWEP.DefaultDualSide = "left"

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

SWEP.DisableIronsights = false
SWEP.DisableReloadBlur = false
SWEP.ReloadAfterShot = false
SWEP.ReloadAfterShotTime = 0.5
SWEP.UseIronTransitionAnims = true

SWEP.EmptySoundPrimary = "PB_WeaponEmpty_Primary"
SWEP.EmptySoundSecondary = "PB_WeaponEmpty_Secondary"

SWEP.InstantFlashlight = false

SWEP.MouseSensitivityHip = 1
SWEP.MouseSensitivityIron = 1

// Recoil variables
SWEP.Recoil	= 0.5
SWEP.Spread	= 0.02
SWEP.Spread_Iron = 0.01
SWEP.SpreadVel = 1.2
SWEP.SpreadVel_Iron = 0.9
SWEP.SpreadAdd = 0.3
SWEP.SpreadAdd_Iron	= 0.2

SWEP.MoveType = 1
SWEP.SprintShakeMod = 0.5

SWEP.HL2IconLetters = {
	["phun_hl2_ar2"] = "l",
	["phun_hl2_crossbow"] = "g",
	["phun_hl2_pistol"] = "d",
	["phun_hl2_smg"] = "a",
	["phun_hl2_357"] = "e",
	["phun_hl2_shotgun"] = "b",
	["phun_hl2_rpg"] = "i",
	["phun_hl2_grenade"] = "k",
	["phun_hl2_bugbait"] = "j",
	["phun_hl2_crowbar"] = "c",
	["phun_hl2_stunstick"] = "n",
	["phun_hl2_slam"] = "o",
}

SWEP.UseCustomWepSelectIcon = false
function SWEP:CustomWepSelectIcon(x, y, wide, tall, alpha) -- copy this to your swep and enable custom wepselecticons on it to draw custom weapon selection icons
end

function SWEP:FireAnimationEvent(pos,ang,event,name)
	return true
end

if CLIENT then
	surface.CreateFont( "PHUNBASE_HL2_SELECTICONS_1", { // weapon selecticon ghost font
		font = "HalfLife2",
		extended = true,
		size = ScreenScale(54),
		weight = 0,
		blursize = 8,
		scanlines = 3,
		antialias = true,
		additive = true,
	} )

	surface.CreateFont( "PHUNBASE_HL2_SELECTICONS_2", { // weapon selecticons
		font = "HalfLife2",
		extended = true,
		size = ScreenScale(54),
		weight = 0,
		antialias = true,
		additive = true,
	} )
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	if self.HL2IconLetters[self:GetClass()] then -- HL2 weapons
		draw.SimpleText(self.HL2IconLetters[self:GetClass()], "PHUNBASE_HL2_SELECTICONS_1", x + wide / 2, y + tall * 0.075, Color(255, 235, 20, alpha), TEXT_ALIGN_CENTER)
		draw.SimpleText(self.HL2IconLetters[self:GetClass()], "PHUNBASE_HL2_SELECTICONS_2", x + wide / 2, y + tall * 0.075, Color(255, 235, 20, alpha), TEXT_ALIGN_CENTER)
	elseif self.UseCustomWepSelectIcon then
		self:CustomWepSelectIcon(x, y, wide, tall, alpha)
	else -- default GMod swep select icon
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( surface.GetTextureID( "weapons/swep" ) )
		-- Borders
		y = y + 10
		x = x + 10
		wide = wide - 20
		surface.DrawTexturedRect(x, y, wide, wide / 2)
	end
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
	self:SetDualSide(self.DefaultDualSide)
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
	self:SetIsWaiting(false)
	
	self._deployedShells = {}
	
	if CLIENT then
		self:_CreateVM()
		self:_CreateHands()
		self:setupAttachmentModels()
		if self.AdditionalInit then
			self:AdditionalInit()
		end
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
	
	self:SetIsInUse(true)
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

	if self:GetIsDeploying() or self:GetIsReloading() or ( self:GetHolsterDelay() ~= 0 and CurTime() < self:GetHolsterDelay() ) or self:GetIsWaiting() then
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
			self:SetIsInUse(false)
		end
		return true
	end

	if IsFirstTimePredicted() then
		if self:GetActiveSequence() != "holster" then
			self:PlayVMSequence("holster", self.HolsterAnimSpeed or 1, self.HolsterAnimStartCyc or 0)
		end
	end
	
	self.SwitchWep = wep
end

function SWEP:CalcHoldType()
	if SERVER then
		/*if self.dt.Safe then
			if self.CurHoldType != self.SafeHoldType then
				self:SetHoldType(self.SafeHoldType)
				self.CurHoldType = self.SafeHoldType
			end
		else*/
			if self:GetIsReloading() then
				if self.ReloadHoldType != nil then
					if self.CurHoldType != self.ReloadHoldType then
						self:SetHoldType(self.ReloadHoldType)
						self.CurHoldType = self.ReloadHoldType
					end
				end
			else
				if self:GetIsSprinting() then
					if self.CurHoldType != self.SprintHoldType then
						self:SetHoldType(self.SprintHoldType)
						self.CurHoldType = self.SprintHoldType
					end
				else
					if self.lastOwner:Crouching() then
						if self.CrouchHoldType != nil then
							if self.CurHoldType != self.CrouchHoldType then
								self:SetHoldType(self.CrouchHoldType)
								self.CurHoldType = self.CrouchHoldType
							end
						end
					else
						if self.CurHoldType != self.HoldType then
							self:SetHoldType(self.HoldType)
							self.CurHoldType = self.HoldType
						end
					end
				end
			end
		--end
	end
end

function SWEP:Think()
	self.lastOwner = self.Owner
	//self:_IdleAnimThink()
	self:_IronThink()
	self:_SprintThink()
	self:_DeployThink()
	self:_NearWallThink()
	self:_WaterLadderThink()
	self:_ReloadThink()
	self:_SoundTableThink()
	
	if self.AdditionalThink then
		self:AdditionalThink()
	end
	
	self:CalcHoldType()
	
	if CLIENT then
		if self.ThinkOverrideClient then
			self:ThinkOverrideClient()
		end
		if GetConVarNumber("phunbase_dev_iron_toggle") == 1 then
			self.DrawCrosshair = true
		else
			self.DrawCrosshair = false
		end
	end
end

function SWEP:Cheap_WM_ShootEffects()
	self.Owner:MuzzleFlash()
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() then return end
	
	if self:Clip1() < 1 then
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:EmitSound(self.EmptySoundPrimary)
		return
	end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if IsFirstTimePredicted() then
		if type(self.FireSound) == "table" then
			for _, snd in pairs(self.FireSound) do
				if type(snd) == "string" then
					self:EmitSound(snd)
				end
			end			
		elseif type(self.FireSound) == "string" then
			self:EmitSound(self.FireSound)
		end
		
		if self.PrimaryAttackOverride then
			self:PrimaryAttackOverride()
		else
			self:_FireBullets() 
			self:StopViewModelParticles()
		end
		
		self:FireAnimLogic()
		self:PlayMuzzleFlashEffect()
		if !self.NoShells then
			self:MakeShell()
		end
		self:MakeRecoil()
		
		if CLIENT then
			self:simulateRecoil()
		end
		
		if game.SinglePlayer() and SERVER then
			if !self.Owner:IsPlayer() then return end
			SendUserMessage("PHUNBASE_Recoil", ply)
			SendUserMessage("PHUNBASE_PrimaryAttackOverride_CL", ply)
		end
		
		ply:DoAttackEvent()
		
		if self.ReloadAfterShot then
			timer.Simple(self.ReloadAfterShotTime or 0.5, function() if !IsValid(self) then return end self:_realReloadStart() end)
		end
		
		self:Cheap_WM_ShootEffects()
	end
	
	self:TakePrimaryAmmo(1)
	
end

function SWEP:FireAnimLogic()
	local clip = self:Clip1() // clip before firing anim played
	local last = clip == 1
	if !self:GetIsDual() then
		if self:GetIron() then
			self:PlayVMSequence(last and "fire_iron_last" or "fire_iron")
		else
			self:PlayVMSequence(last and "fire_last" or "fire")
		end
	else
		if self:GetDualSide() == "left" then
			if self:GetIron() then
				self:PlayVMSequence(clip == 2 and "fire_left_iron_last" or "fire_left_iron")
			else
				self:PlayVMSequence(clip == 2 and "fire_left_last" or "fire_left")
			end
			self:SetMuzzleAttachmentName(self.MuzzleAttachmentName_L)
			self:SetShellAttachmentName(self.ShellAttachmentName_L)
			self:SetDualSide("right")
		elseif self:GetDualSide() == "right" then
			if self:GetIron() then
				self:PlayVMSequence(clip == 1 and "fire_right_iron_last" or "fire_right_iron")
			else
				self:PlayVMSequence(clip == 1 and "fire_right_last" or "fire_right")
			end
			self:SetMuzzleAttachmentName(self.MuzzleAttachmentName_R)
			self:SetShellAttachmentName(self.ShellAttachmentName_R)
			self:SetDualSide("left")
		end
	end
end

function SWEP:SecondaryAttack()
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() then return end
	
	if IsFirstTimePredicted() then
		self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
	end
	
	if self.SecondaryAttackOverride then
		self:SecondaryAttackOverride()
	end
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

function SWEP:DrawWorldModel()
	self:DrawModel()
end

function SWEP:AdjustMouseSensitivity()
	return self:GetIron() and self.MouseSensitivityIron or self.MouseSensitivityHip
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
SWEP.FireMoveMod = 10
SWEP.LuaViewmodelRecoil = true
SWEP.FullAimViewmodelRecoil = true
SWEP.LuaVMRecoilIntensity = 1
SWEP.LuaVMRecoilLowerSpeed = 1
SWEP.LuaVMRecoilMod = 1 -- modifier of overall intensity for the code based recoil
SWEP.LuaVMRecoilAxisMod = {vert = 0, hor = 0, roll = 0, forward = 0, pitch = 0} -- modifier for intensity of the recoil on varying axes

function SWEP:simulateRecoil()
	if self:GetIron() then
		self.FireMove = math.Clamp(self.Recoil * self.FireMoveMod, -5, 5)
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
	
	if (game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT) then
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
	
	local function PHUNBASE_PrimaryAttackOverride_CL()
		ply = LocalPlayer()
		
		if not ply:Alive() then
			return
		end
		
		wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and wep.PHUNBASEWEP then
			if wep.PrimaryAttackOverride_CL then
				wep:PrimaryAttackOverride_CL()
			end
		end
	end
	
	usermessage.Hook("PHUNBASE_PrimaryAttackOverride_CL", PHUNBASE_PrimaryAttackOverride_CL)
	
end

hook.Add("PlayerPostThink", "PHUNBASE_LastWeaponSwitch", function(ply)
	if !ply.PHUNBASE_LastWeapon then ply.PHUNBASE_LastWeapon = ply:GetActiveWeapon() end
	if !ply.curWep then ply.curWep = ply:GetActiveWeapon() end
	if ply:GetActiveWeapon() != ply.curWep then
		ply.PHUNBASE_LastWeapon = ply.curWep
		ply.curWep = ply:GetActiveWeapon()
	end
end)
