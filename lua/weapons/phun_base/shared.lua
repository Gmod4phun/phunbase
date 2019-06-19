
/*
PHUNBASE BASE CODE
*/

AddCSLuaFile()

PHUNBASE.LoadLua("cl_blur.lua")
PHUNBASE.LoadLua("cl_calcview.lua")
PHUNBASE.LoadLua("cl_crosshair.lua")
PHUNBASE.LoadLua("cl_flashlight.lua")
PHUNBASE.LoadLua("cl_halo.lua")
PHUNBASE.LoadLua("cl_hooks.lua")
PHUNBASE.LoadLua("cl_hud.lua")
PHUNBASE.LoadLua("cl_lasers.lua")
PHUNBASE.LoadLua("cl_model.lua")
PHUNBASE.LoadLua("cl_model_movement.lua")
PHUNBASE.LoadLua("cl_rtscope.lua")
PHUNBASE.LoadLua("cl_shells.lua")
PHUNBASE.LoadLua("cl_stencilsights.lua")
PHUNBASE.LoadLua("cl_velements.lua")
PHUNBASE.LoadLua("sh_ammo.lua")
PHUNBASE.LoadLua("sh_basics.lua")
PHUNBASE.LoadLua("sh_bipod.lua")
PHUNBASE.LoadLua("sh_customization.lua")
PHUNBASE.LoadLua("sh_firebullets.lua")
PHUNBASE.LoadLua("sh_firemodes.lua")
PHUNBASE.LoadLua("sh_grenadelauncher.lua")
PHUNBASE.LoadLua("sh_networkfuncs.lua")
PHUNBASE.LoadLua("sh_orig_values.lua")
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
SWEP.DrawCrosshair = true
SWEP.ShouldDrawDefaultCrosshair = false
SWEP.SwayScale = 1
SWEP.BobScale = 1

SWEP.Base = "weapon_base"
SWEP.PHUNBASEWEP = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70 // the viewmodel fov
SWEP.AimViewModelFOV = 70 // the viewmodel fov when aiming

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.HoldType = "pistol"
SWEP.SafeHoldType = "passive"
SWEP.SprintHoldType = "passive"
SWEP.CrouchHoldType = "pistol"
SWEP.ReloadHoldType = "pistol"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Weight = -1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

// weapon specific variables
SWEP.Primary.Ammo = "phunbase_9mm" // ammo type used by the weapon
SWEP.Primary.ClipSize = 15 // clip size
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Automatic = false // automatic or not
SWEP.Primary.Damage = 20 // damage per bullet
SWEP.Primary.Delay = 0.1 // fire delay, use 60 divided by RPM when using RoundsPerMinute information about weapon, example 0.1 = 600RPM
SWEP.Primary.Force = 10 // bullet force, more force = better penetration
SWEP.Primary.Bullets = 1 // number of bullets per shot
SWEP.Primary.TakePerShot = 1 // ammo to take after each shot

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0.1

SWEP.PB_VMPOS = Vector(0,0,0) // ViewModel position, these are default values, shouldn't touch them
SWEP.PB_VMANG = Angle(0,0,0) // ViewModel angles

SWEP.BasePos = Vector(0,0,0) // base viewmodel position
SWEP.BaseAng = Vector(0,0,0)

SWEP.IronsightPos = Vector(0,0,0) // vm position when aiming
SWEP.IronsightAng = Vector(0,0,0)

SWEP.SprintPos = Vector(0,0,0) // vm position when sprinting
SWEP.SprintAng = Vector(0,0,0)

SWEP.HolsterPos = Vector(0,0,0) // vm position when holstering
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(0,0,0) // vm position when near a wall
SWEP.NearWallAng = Vector(0,0,0)

SWEP.InactivePos = Vector(4, 0, 0) // vm position underwater / on ladder
SWEP.InactiveAng = Vector(-45, 45, 0)

SWEP.CustomizePos = Vector(0,0,0) // vm position when customizing
SWEP.CustomizeAng = Vector(0,0,0)

SWEP.SafePos = Vector(0,0,0) // vm position when weapon safety is on
SWEP.SafeAng = Vector(0,0,0)

SWEP.Sequences = {} // a table of sequences, can be either single anim or a table of anims, for things like multiple fire animations
/* // example table with sequence names and what they are used for

SWEP.Sequences = {
	idle = "", // base idle
	idle_empty = "", // empty idle
	idle_iron = "", // iron idle
	idle_iron_empty = "", // empty iron idle
	fire = "", // fire
	fire_last = "", // last shot fire
	fire_iron = "", // fire when aiming
	fire_iron_last = "", // last shot fire when aiming
	fire_left = "", // used by dual weapons, left weapon fire
	fire_left_iron = "", // used by dual weapons, left weapon fire when aiming
	fire_right = "", // used by dual weapons, right weapon fire
	fire_right_iron = "", // used by dual weapons, right weapon fire when aiming
	fire_left_last = "", // used by dual weapons, last shot left weapon fire, if not defined, uses non-last variant
	fire_left_iron_last = "", // used by dual weapons, last shot left weapon fire when aiming, if not defined, uses non-last variant
	fire_right_last = "", // used by dual weapons, last shot right weapon fire, if not defined, uses non-last variant
	fire_right_iron_last = "", // used by dual weapons, last shot right weapon fire when aiming, if not defined, uses non-last variant
	reload = "", // normal/wet reload (weapon is not empty)
	reload_empty = "", // empty/dry reload (weapon is empty), if not defined, uses the non-empty variant
	deploy = "", // deploy
	deploy_empty = "", // empty deploy
	deploy_first = "", // first time deploy
	holster = "", // holster
	goto_iron = "", // transition to ironsights, used by dual weapons or nondual when ForceGotoTransitionAnims is enabled
	goto_hip = "", // transition to hip, used by dual weapons or nondual when ForceGotoTransitionAnims is enabled
	reload_shell_start = "", // starting a shotgun reload
	reload_shell_start_empty = "", // starting empty shotgun reload, if not defined, uses the non-empty variant
	reload_shell_insert = "", // inserting a round when we did not start reloading an empty gun
	reload_shell_insert_empty = "", // inserting a round, when we started reloading an empty gun, if not defined, uses the non-empty variant
	reload_shell_end = "", // ending shotgun reload
	reload_shell_end_empty = "", // ending empty shotgun reload, if not defined, uses the non-empty variant
	sprint_start = "", // starting sprinting
	sprint_idle = "", // sprinting loop
	sprint_end = "", // ending sprint
	lighton = "", // sequence when toggling flashlight, InstantFlashlight must be disabled
	lighton_iron = "", // sequence when toggling flashlight while aiming, InstantFlashlight must be disabled
}

*/

SWEP.Sounds = {} // a table of sounds
/* // example sound table, anim name is the viewmodel animation name, aka the right part of SWEP.Sequences, check example files, can have an optional callback function, where self is the weapon

SWEP.Sounds = {
	glock_deploy = {
		{time = 0, sound = "GLOCK_DRAW", callback = function(self) end}
	},
	glock_reload = {
		{time = 0, sound = "GLOCK_MAGOUT"},
		{time = 0.2, sound = "GLOCK_MAGIN"},
		{time = 0.7, sound = "GLOCK_SLIDE"}
	}
}

*/

SWEP.DeployTime = 0.5 // time taken to finish deploying the weapon
SWEP.HolsterTime = 0.5 // time taken to finish holstering the weapon
SWEP.HolsterAnimSpeed = 1 // the speed of holster sequence, use -1 to play backwards
SWEP.HolsterAnimStartCyc = 0 // the starting cycle of holster sequence, use 1 to start at the end

/* // this is old, update your weapons to the new system if needed
//SWEP.ReloadTime = 0.5 // time taken to reload
//SWEP.ReloadTime_Empty = SWEP.ReloadTime // time taken to reload, when empty, if not specified, is the same as ReloadTime
*/

SWEP.ReloadTimes = { // reload times, self explanatory
	Base = 1,
	Base_Empty = 1,
	Bipod = 1,
	Bipod_Empty = 1,
}

SWEP.IdleAfterReload = true // should the weapon play idle sequence after a non-empty reload
//SWEP.IdleAfterReloadTime = SWEP.ReloadTime // time to play the idle sequence, if enabled

SWEP.IdleAfterFire = true // should the weapon play idle sequence after the fire sequence ends

SWEP.Chamberable = true // enables room for an extra round in the chamber, should be disabled for revolvers/projectile type weapons
SWEP.UsesAmmoCountLogic = false // uses a different logic that takes away ammo per each shot, no clips/magazines

SWEP.ShotgunReload = false // enables shotgun reload mechanics

SWEP.ShotgunReloadActions = {
	InsertOnStart = false, // should insert a round on reload start
	InsertOnStartEmpty = false, // should insert a round on reload start, when starting empty
	InsertOnEnd = false, // should insert a round on reload end
	InsertOnEndEmpty = false, // should insert a round on reload end, started by empty reload
}

SWEP.ShotgunReloadTimes = {
	Start = 1, // time until inserting begins
	Start_Empty = 1, // time until inserting begins, started by empty reload
	Start_EmptyOneAndOnly = 0.25, // very special case only, happens when start and empty end inserts are enabled and there is 1 round available, time to wait between starting and ending the reload
	Insert = 0.5, // time between the individual inserts
	End = 1, // time taken for the weapon to stop reloading
	End_Empty = 1.5, // time for the weapon to stop reloading, started by empty reload

	InsertAmmoWait = 0, // time until ammo changes on insert
	InsertOnStartAmmoWait = 0.25, // time until ammo changes on reload start, if start insert is enabled
	InsertOnStartEmptyAmmoWait = 0.5, // time until ammo changes on empty reload start, if empty start insert is enabled
	InsertOnEndAmmoWait = 0.25, // time until ammo changes on reload end, if end or empty end insert is enabled
	InsertOnEndEmptyAmmoWait = 0.3, // time until ammo changes on empty reload end, if empty end insert is enabled
}

SWEP.FireActionDelay = 0 // delay between initiating the attack and firing the bullet, like revolvers
SWEP.LastShotFireDelay = 0.65 // delay to be able to attack again after firing the last shot, used to reduce snapping of dryfire anims

SWEP.UseHands = true // use gmod hands or not

SWEP.IsDual = false // is the weapon akimbo
SWEP.DefaultDualSide = "left" // which side is default, used to determine if left or right gun fires last

SWEP.NormalFlashlight = true // enables the HL2 flashlight
SWEP.CustomFlashlight = false // enables a ProjectedTexture flashlight, you should disable the Normal one
SWEP.InstantFlashlight = false // whether turning the flashlight on/off is instant or it has a 0.5 second delay

SWEP.MuzzleAttachmentName = "muzzle" // vm attachment name for muzzleflash
SWEP.MuzzleAttachmentName_L = "muzzle_left" // used by dual weapons, vm attachment name for muzzleflash, left gun
SWEP.MuzzleAttachmentName_R = "muzzle_right" // used by dual weapons, vm attachment name for muzzleflash, right gun
SWEP.MuzzleEffect = {"smoke_trail"} // table of Particle Effect names to use as muzzleflash
SWEP.MuzzleEffectSuppressed = {"smoke_trail"} // same as above, when suppressed
SWEP.DisableMuzzleLight = false // disables muzzle light when firing

SWEP.NoShells = false // disables shells when firing
SWEP.ShellVelocity = {X = 0, Y = 0, Z = 0} // the directional velocity applied to the shell based on the axis of the ShellEject Attachment
SWEP.ShellAngularVelocity = {Pitch_Min = 0, Pitch_Max = 0, Yaw_Min = 0, Yaw_Max = 0, Roll_Min = 0, Roll_Max = 0} // angular velocity of the shell
SWEP.ShellViewAngleAlign = {Forward = 0, Right = 0, Up = 0} // adjustment of the shell angles (eq. rotate the shell if its sideways)
SWEP.ShellAttachmentName = "shelleject" // vm attachment name for shell ejection
SWEP.ShellAttachmentName_L = "shelleject_left" // used by dual weapons, vm attachment name for shell ejection, left gun
SWEP.ShellAttachmentName_R = "shelleject_right" // used by dual weapons, vm attachment name for shell ejection, right gun
SWEP.ShellDelay = 0.03 // time taken to create the shell after firing the weapon
SWEP.ShellScale = 0.5 // scale of the shell model
SWEP.ShellModel = "models/weapons/shell.mdl" // the shell model
SWEP.ShellSound = "PB_SHELLIMPACT_BRASS" // the sound the shell makes on impact

SWEP.FireSound = {} // can be a single sound, or a table of sounds
SWEP.FireSoundSuppressed = {} // same rules as firesound

SWEP.IsSuppressed = false // whether or not the weapon is suppressed, changes the fire sound

SWEP.DisableIronsights = false // disable the usage of ironsights
SWEP.DisableReloading = false // disable reloading for the weapon, useful when using AmmoCount logic
SWEP.DisableReloadBlur = false // disables blur while reloading
SWEP.ReloadAfterShot = false // automatically reloads the weapon after shooting, but only on the last shot (does not make sense to reload not on the last shot -_-)
SWEP.ReloadAfterShotTime = 0.5 // delay between firing and starting the reloading
SWEP.UseIronTransitionAnims = true // enables iron transition sequences to be used
SWEP.ForceGotoTransitionAnims = false // forces the use of goto_iron and goto_idle sequences instead of a built-in function to decide between individual idle animations
SWEP.IronTransitionAnimsSpeed = 1 // speed of the transition sequences
SWEP.DisableIronWhileFiring = false // disables going into ironsights while there is a PrimaryAttack delay
SWEP.IronTransitionFireWaitTime = 0 // delay between going into ironsights and being able to shoot
SWEP.OnlyIronFire = false // only allow firing when in ironsights
SWEP.UnIronAfterShot = false // force back to hip after shooting
SWEP.UnIronAfterShotTime = 0 // delay to wait between firing and hip

SWEP.CockAfterShot = false // does the weapon need to be cocked after each shot
SWEP.CockAfterShotTime = 0.5 // the time it takes to cock the weapon
SWEP.MakeShellOnCock = true // should the shell be ejected on the cock rather than on the attack

SWEP.AutoCockStart = false // should the weapon automatically cock itself after each shot, needs CockAfterShot enabled
SWEP.AutoCockStartTime = 0.5 // the time after the weapon starts automatically cocking

SWEP.EmptySoundPrimary = "PB_WeaponEmpty_Primary"
SWEP.EmptySoundSecondary = "PB_WeaponEmpty_Secondary"
SWEP.DryFireSound = "PB_WeaponDryFire"

SWEP.MouseSensitivityHip = 1 // mouse sensitivity when not aiming
SWEP.MouseSensitivityIron = 1 // mouse sensitivity when aiming

// Recoil variables
SWEP.Recoil	= 0.5 // how much does the weapon kick
SWEP.Spread	= 0.02 // how precise is the weapon: smaller values = more precise
SWEP.Spread_Iron = 0.01 // how precise is the weapon when aiming: smaller values = more precise
SWEP.SpreadVel = 1.2 // additional spread multiplier depending on player velocity
SWEP.SpreadVel_Iron = 0.9 // additional spread multiplier depending on player velocity when aiming
SWEP.SpreadAdd = 0.3 // additional spread multiplier
SWEP.SpreadAdd_Iron	= 0.2 // additional spread multiplier when aiming

SWEP.MoveType = 1
SWEP.SprintShakeMod = 0.5 // how much the viewmodel shakes when sprinting
SWEP.NoSprintVMMovement = false // disables vm movement when sprinting, useful for custom sprinting animations

SWEP.RTScope_Material = Material("phunbase/rt_scope/pb_scope_rt") // the default material for RT scope to draw on, used in the Scope RT model
SWEP.RTScope_Enabled = false // enable or disable the RT scope
SWEP.RTScope_Zoom = 6 // the zoom of the scope (infact the FOV of the scope, smaller values = bigger zoom)
SWEP.RTScope_Align = Angle(0,0,0) // Angle to align/rotate the scope properly if needed. THIS AFFECTS RT ONLY. Disable iris/parallax if you see only black, and align the scope, then reenable iris/parallax
SWEP.RTScope_Lense = Material("phunbase/rt_scope/optic_lense") // the default material of the scope lense, becomes more transparent on aim
SWEP.RTScope_Reticle = Material("phunbase/reticles/scope_crosshair_simple") // the default material for the reticle of the scope
SWEP.RTScope_ReticleAlways = false // should the reticle be drawn even when not aiming
SWEP.RTScope_Rotate = 0 // how much to rotate the reticle/lense if needed. THIS DOES NOT AFFECT THE RT
SWEP.RTScope_DrawIris = true // should an iris effect be drawn
SWEP.RTScope_DrawParallax = true // should a parallax effect be drawn
SWEP.RTScope_ShakeMul = 15 // how strong is the parallax effect

SWEP.UseCustomWepSelectIcon = false // enables using a custom weapon selection icon
function SWEP:CustomWepSelectIcon(x, y, wide, tall, alpha) -- copy this to your swep and enable custom wepselecticons to draw custom weapon selection icons
end

function SWEP:Initialize()
	self._currentCModels = {}
	self._deployedShells = {}
	self.Events = {}
	self.RealSequence = ""

	self:InitHL2KillIcons()
	self:InitRealViewModel()
	self:InitFiremodes()

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
	self:SetIsCustomizing(false)
	self:SetIsSwitchingFiremode(false)
	self:SetShouldBeCocking(false)
	self:SetWeaponMode(PB_WEAPONMODE_NORMAL)
	self:SetIsGLLoaded(true)
	self:SetGlobalDelay(0)

	if CLIENT then
		self:_CreateVM()
		self:_CreateWM()
		self:setupAttachmentModels()
		self:setupBoneTable()
		self:_CreateHands()
		if self.AdditionalInit then
			self:AdditionalInit()
		end
	end

	self.IronRollOffset = 0
	self.RealIronRoll = 0

	self:SetupOrigValues()
	self:SetupActiveAttachmentNames()

	self:SetupOrigFireMode()

	self:_saveAllOrigValues()
end

function SWEP:OnReloaded()
	self:SetIsDual(self.IsDual)
	self:SetIsReloading(false)
	self:SetIsSprinting(false)
	self:SetIsDeploying(false)
	self:SetIsHolstering(false)
	self:SetIsNearWall(false)
	self:SetIsUnderwater(false)
	self:SetIsOnLadder(false)
	self:SetHolsterDelay(0)
	self:SetIsCustomizing(false)
	self:SetIsSwitchingFiremode(false)
	self:SetShouldBeCocking(false)
	self:SetWeaponMode(PB_WEAPONMODE_NORMAL)

	self:SetMuzzleAttachmentName(self.MuzzleAttachmentName)
	self:SetShellAttachmentName(self.ShellAttachmentName)

	self:RemoveAllAttachments()

	if self.FireModes and #self.FireModes > 0 then
		self.FireModes.last = 1
		self:SelectFiremode(self.FireModes[1])
	end

	if CLIENT then
		self:setupAttachmentModels()
		self:_UpdateHands()
	end

	self:RestoreOriginalIronsights()

	self:SetupOrigValues()
	self:SetupActiveAttachmentNames()
	
	self:SetupOrigFireMode()

	if !self.Owner:IsNPC() then
		timer.Simple(0.01, function()
			if IsValid(self.Owner) and self.Owner:GetActiveWeapon() == self then
				if self:Clip1() > 0 then
					self._wasFirstTimeDeployed = false
				else
					self._wasFirstTimeDeployed = true
				end
				self:Deploy()
			end
		end)
	end
end

function SWEP:DeployAnimLogic()
	local clip = self:Clip1()
	local empty = clip < 1

	self:PlayVMSequence((empty and self.Sequences.deploy_empty) and "deploy_empty" or ((self.Sequences.deploy_first and !self._wasFirstTimeDeployed) and "deploy_first" or "deploy"))
end

function SWEP:PreDeployAnimLogic() // aka UnFuckDeploy, tries to put the vm in a holstered position before playing the actual deploy anim
	self:PlayVMSequence("deploy", -1, 0)
end

function SWEP:Deploy()
	self:InitRealViewModel() // needed both in Init and Deploy, so that picked up weapons dont error
	self:_UpdateVM()
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
	self.FinishDeployTime = CurTime() + ((self.DeployTime_First and !self._wasFirstTimeDeployed) and self.DeployTime_First or self.DeployTime)

	self:SetIsDeploying(true)
	self:DelayedEvent(self.FinishDeployTime - CurTime(), function() self:SetIsDeploying(false) end)

	if !self.IdleAfterDeployTime then
		self.IdleAfterDeployTime = self.FinishDeployTime - CurTime() - 0.1
	end

	if self.PreDeployAnimLogic then // you should play a vm sequence so that it appears holstered (invisible), used to unfuck idle pose before deploy anim if it's fucked (pretty much always)
		self:PreDeployAnimLogic()
	end

	-- if !self._wasFirstTimeDeployed then
		self:DeployAnimLogic() // this alone probably works just fine
	-- else
		-- self:DelayedEvent(0, function() self:DeployAnimLogic() end) // fixes deploy anim because of vm position not being adjusted yet
	-- end

	if !self._wasFirstTimeDeployed then
		self._wasFirstTimeDeployed = true
	end

	if !self.DisableIdleAfterDeploy then
		self:DelayedEvent(self.IdleAfterDeployTime, function() self:PlayIdleAnim() end)
	end

	self.SwitchWep = nil
	return true
end

function SWEP:HolsterAnimLogic()
	local clip = self:Clip1()
	local empty = clip < 1

	self:PlayVMSequence((empty and self.Sequences.holster_empty) and "holster_empty" or "holster", self.HolsterAnimSpeed or 1, self.HolsterAnimStartCyc or 0)
end

function SWEP:Holster(wep)
	if self.Owner.PB_IsPickingUpObject and !self:IsBusy() and !self:GetIsWaiting() then
		self.Owner.PB_IsPickingUpObject = false
		return true
	end

	if not IsValid(wep) and not IsValid(self.SwitchWep) then
		self.SwitchWep = nil
		return false
	end

	if self:GetIsDeploying() or self:GetIsReloading() or ( self:GetHolsterDelay() ~= 0 and CurTime() < self:GetHolsterDelay() ) or self:GetIsWaiting() or self:IsFiring() or self:IsGlobalDelayActive() or self:IsBipodDeployed() then
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
		self:SetIsSprinting(false)
		self:SetIsInUse(false)
		self:CloseCustomizationMenu()
		if SERVER then
			self:DestroyFlashlight()
		end
		return true
	end

	if IsFirstTimePredicted() then
		if self:GetActiveSequence() != "holster" then
			self:HolsterAnimLogic()
		end
	end

	self.SwitchWep = wep
end

function SWEP:CalcHoldType()
	if SERVER then
		if self:GetIsReloading() then
			if self.ReloadHoldType != nil then
				if self.CurHoldType != self.ReloadHoldType then
					self:SetHoldType(self.ReloadHoldType)
					self.CurHoldType = self.ReloadHoldType
				end
			end
		else
			if self:IsSafe() and !self.Owner:Crouching() then
				if self.CurHoldType != self.SafeHoldType then
					self:SetHoldType(self.SafeHoldType)
					self.CurHoldType = self.SafeHoldType
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
		end
	end
end

function SWEP:Think()
	if IsValid(self.Owner) then
		self.lastOwner = self.Owner
	end

	self:_IronThink()
	self:_SprintThink()
	self:_NearWallThink()
	self:_WaterLadderThink()
	self:_ReloadThink()
	self:_SoundTableThink()
	self:_FiremodeThink()
	self:_BipodThink()

	if self.AdditionalThink then
		self:AdditionalThink()
	end

	self:CalcHoldType()

	if CLIENT then
		if self.ThinkOverrideClient then
			self:ThinkOverrideClient()
		end
	end

	self:RunAttachmentsThinkFunc()

	for k, v in pairs(self.Events) do
		if CurTime() > v.time then
			v.func()
			table.remove(self.Events, k)
		end
	end
end

function SWEP:DelayedEvent(t, f)
	if t <= 0 then // if time is 0 or less, just run the function
		f()
		return nil
	else
		local i = #self.Events + 1
		self.Events[i] = {time = CurTime() + t, func = function() if !IsValid(self) then return end f() end}
		return i
	end
end

function SWEP:RemoveDelayedEvent(i)
	if !i then return end
	table.remove(self.Events, i)
end

function SWEP:ThirdPersonParticleMuzzle()
	self:StopParticles()

	local muz = self:GetAttachment( 1 )

	if muz then
		if type(self.MuzzleEffect) == "table" then
			for _, particle in pairs(self.MuzzleEffect) do
				if type(particle) == "string" then
					ParticleEffectAttach(particle, PATTACH_POINT_FOLLOW, self, 1)
				end
			end
		elseif type(self.MuzzleEffect) == "string" then
			ParticleEffectAttach(self.MuzzleEffect, PATTACH_POINT_FOLLOW, self, 1)
		end
	end
end

function SWEP:Cheap_WM_ShootEffects()
	self.Owner:MuzzleFlash()

	-- self:ThirdPersonParticleMuzzle() // faggot drawing issues
end

function SWEP:IsFiring()
	return self:GetNextPrimaryFire() > CurTime()
end

function SWEP:CanFire()
	if self:IsFiring() or self:GetIsReloading() or self:IsGlobalDelayActive() then
		return false
	else
		return true
	end
end

function SWEP:HasEnoughAmmo()
	if self.Owner:IsNPC() then return true end

	local ammo = self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
	local clip = self:Clip1()

	if (self.UsesAmmoCountLogic and ammo > 0) or (!self.UsesAmmoCountLogic and clip > 0) then
		return true
	else
		return false
	end
end

function SWEP:DryFireAnimLogic()
	if self.Sequences.fire_dry then
		self:PlayVMSequence("fire_dry")
	end
end

function SWEP:PerformFireAction()
	local ply = self.Owner
	
	local firesnd = self.IsSuppressed and self.FireSoundSuppressed or self.FireSound
	
	if type(firesnd) == "table" then
		for _, snd in pairs(firesnd) do
			if type(snd) == "string" then
				self:EmitSound(snd)
			end
		end
	elseif type(firesnd) == "string" then
		self:EmitSound(firesnd)
	end

	if self.PrimaryAttackOverride then
		self:PrimaryAttackOverride()
	else
		self:_FireBullets()
		self:StopViewModelParticles()
	end

	self:PlayMuzzleFlashEffect()
	self:MakeRecoil()

	if CLIENT then
		self:simulateRecoil()
	end

	if game.SinglePlayer() and SERVER then
		if self.Owner:IsPlayer() then
			SendUserMessage("PHUNBASE_Recoil", ply)
			SendUserMessage("PHUNBASE_PrimaryAttackOverride_CL", ply)
		end
	end

	ply:SetAnimation(PLAYER_ATTACK1)
	
	self:Cheap_WM_ShootEffects()
end

function SWEP:InitFireAction()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if IsFirstTimePredicted() then
		if (game.SinglePlayer() and SERVER) or CLIENT then
			self:FireAnimLogic(isSecondary)
		end
		
		if !((self.CockAfterShot and self.MakeShellOnCock) or self.NoShells) then
			self:MakeShell()
		end
	
		self:DelayedEvent(self.FireActionDelay, function()
			self:PerformFireAction()
		end)

		if self.ReloadAfterShot and self:Clip1() == 1 then
			self:DelayedEvent(self.ReloadAfterShotTime, function() self._ReloadAfterShotOverride = true self:_realReloadStart() self._ReloadAfterShotOverride = false end)
		end

		if self.UnIronAfterShot then
			self:DelayedEvent(self.UnIronAfterShotTime, function() self:SetIron(false) end)
		end

		if self.CockAfterShot then
			self:SetShouldBeCocking(true)
		end

		if self.CockAfterShot and self.AutoCockStart then // auto cock - per weapon
			self:DelayedEvent(self.AutoCockStartTime, function() self:Cock() end)
		end
		
		if self.CockAfterShot and self.Owner:GetInfoNum("phunbase_global_auto_cock", 0) == 1 then // auto cock - global - all weapons
			if (self.DontCockWhenEmpty and self:Clip1() != 1) or !self.DontCockWhenEmpty then 
				self:DelayedEvent(self.Primary.Delay, function() self:Cock() end)
			end
		end
	end
	
	self:TakePrimaryAmmo(self.Primary.TakePerShot)
end

function SWEP:_primaryAttack(isSecondary) // I hate to do this but whatever, I dont want to copy shitton of code just for sequences
	if self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or (self.OnlyIronFire and !self:GetIron()) or self.IronTransitionWaiting then return end

	if self:GetIsCustomizing() or self:IsGlobalDelayActive() then return end

	if self.Owner:KeyDown(IN_USE) and self.UsesGrenadeLauncher then
		if self:GetWeaponMode() == PB_WEAPONMODE_NORMAL then
			self:EnterGrenadeLauncherMode()
			return
		elseif self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then
			self:ExitGrenadeLauncherMode()
			return
		end
	end

	if self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then
		self:GrenadeLauncherModeFire()
		return
	end

	if self:GetShouldBeCocking() or self:IsSafe() then
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:EmitSound(self.DryFireSound)
		self:DryFireAnimLogic()
		return
	end

	if !self:HasEnoughAmmo() then
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:EmitSound(self.EmptySoundPrimary)
		self:DryFireAnimLogic()
		return
	end

	if self.BurstAmount and self.BurstAmount > 0 then
		if self.BurstShotsFired >= self.BurstAmount then
			return
		end

		self.BurstShotsFired = self.BurstShotsFired + 1
	end

	self:InitFireAction()
	
	if self:Clip1() == 0 then // fire delay after last shot, mostly to prevent snapping dryfire anims
		self:SetNextPrimaryFire(CurTime() + self.LastShotFireDelay)
	end
end

function SWEP:PrimaryAttack()
	self:_primaryAttack()
end

function SWEP:FireAnimLogic(isSecondary)
	local clip = self:Clip1() // clip before firing anim played
	local last = clip == 1

	local suffix = isSecondary and "_secondary" or ""

	if !self:GetIsDual() then
		if self:GetIron() then
			self:PlayVMSequence(last and "fire_iron_last"..suffix or "fire_iron"..suffix)
		else
			self:PlayVMSequence(last and "fire_last"..suffix or "fire"..suffix)
		end
	else
		if self:GetDualSide() == "left" then
			if self:GetIron() then
				self:PlayVMSequence(clip == 2 and (self.Sequences.fire_left_iron_last and "fire_left_iron_last" or "fire_left_iron") or "fire_left_iron")
			else
				self:PlayVMSequence(clip == 2 and (self.Sequences.fire_left_last and "fire_left_last" or "fire_left") or "fire_left")
			end
			self:SetMuzzleAttachmentName(self.MuzzleAttachmentName_L)
			self:SetShellAttachmentName(self.ShellAttachmentName_L)
			self:SetDualSide("right")
		elseif self:GetDualSide() == "right" then
			if self:GetIron() then
				self:PlayVMSequence(clip == 1 and (self.Sequences.fire_right_iron_last and "fire_right_iron_last" or "fire_right_iron") or "fire_right_iron")
			else
				self:PlayVMSequence(clip == 1 and (self.Sequences.fire_right_last and "fire_right_last" or "fire_right") or "fire_right")
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

function SWEP:AdjustMouseSensitivity()
	return self:GetIron() and self.MouseSensitivityIron or self.MouseSensitivityHip
end

// RECOIL
SWEP.FireMoveMod = 1
SWEP.FireMoveMod_Iron = 10
SWEP.LuaViewmodelRecoil = true
SWEP.FullAimViewmodelRecoil = true
SWEP.LuaVMRecoilIntensity = 1
SWEP.LuaVMRecoilLowerSpeed = 1
SWEP.LuaVMRecoilMod = 1 -- modifier of overall intensity for the code based recoil
SWEP.LuaVMRecoilAxisMod = {vert = 0, hor = 0, roll = 0, forward = 0, pitch = 0} -- modifier for intensity of the recoil on varying axes

function SWEP:simulateRecoil()
	if self:GetIron() then
		self.FireMove = math.Clamp(self.Recoil * self.FireMoveMod_Iron, -5, 5)
	else
		if self.FullAimViewmodelRecoil then
			self.FireMove = math.Clamp(self.Recoil * self.FireMoveMod, -5, 5)
		else
			self.FireMove = 0.4
		end
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

	if !self.Owner:IsPlayer() or self.Owner:InVehicle() then return end

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
