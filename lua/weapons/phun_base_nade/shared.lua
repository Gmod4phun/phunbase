AddCSLuaFile()

local SP = game.SinglePlayer()

if SERVER then
    util.AddNetworkString("PB_BASE_NADE_SPOONEJECT")
end

SWEP.PrintName = "PHUNBASE NADE"
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

SWEP.HoldType = "grenade"
SWEP.SafeHoldType = "passive"
SWEP.SprintHoldType = "passive"
SWEP.CrouchHoldType = "grenade"
SWEP.ReloadHoldType = "grenade"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Weight = -1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true

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

SWEP.NadeClass = ""
SWEP.NadeFuseTime = 3
SWEP.NadeGetReadyTime = 1

SWEP.NadeCookable = false
SWEP.NadeCookableAlt = false
SWEP.NadeGetReadyTimeCooking = 1
SWEP.NadeCookStartTime = 1

SWEP.NadeThrowPower = 1
SWEP.NadeThrowPowerAlt = 0.2

SWEP.NadeThrowWaitTime = 0.15
SWEP.NadeRedeployWaitTime = 0.25

SWEP.SwitchAfterThrow = false
SWEP.LockThrowStateOnInit = false

SWEP._WasCookedThrow = false
SWEP._IsCooking = false

function SWEP:OnNadeTossed() // called after creating the nade, use when needed
end

function SWEP:TossNade(ent)
	local ply = self.Owner
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local force = 1000
		
		if ply:KeyDown(IN_FORWARD) then
			force = force + ply:GetVelocity():Length()
		end
		
		phys:SetVelocity(ply:EyeAngles():Forward() * force * self._ThrowPower + Vector(0, 0, 100))
		phys:AddAngleVelocity(Vector(450, -550, -420))
	end
end

function SWEP:CreateNade(fuseDelay)
	if SERVER then
		local ply = self.Owner
		local EA =  ply:EyeAngles()
		local pos = ply:GetShootPos()
		pos = pos + EA:Right() * 5 - EA:Up() * 4 + EA:Forward() * 8
		local ang = Angle(30, 160, 65) 
		
		local nade = ents.Create(self.NadeClass)
		nade:SetPos(pos)
		nade:SetAngles(ang)
		
		nade.Weapon = self
		nade.Owner = ply
		nade.IsPBGrenade = true
		nade:Spawn()
		nade:Activate()
        
        nade.FuseTime = CurTime() + fuseDelay
		
		self.NadeEnt = nade
		
		self:TossNade(nade)
		
		if self.OnNadeTossed then
			self:OnNadeTossed()
		end
	end
	
	self:TakePrimaryAmmo(1)
end

function SWEP:PrimaryAttack()
	self:InitiateThrow()
end

function SWEP:SecondaryAttack()
	self:InitiateThrow()
end

function SWEP:NadePullpinAnimLogic()
    self:PlayVMSequence(self.WasAltThrow and "pullpin_alt" or "pullpin")
end

function SWEP:NadeThrowNormal()
    self:PlayVMSequence("throw")
end

function SWEP:NadeThrowLow()
    self:PlayVMSequence("underhand")
end

// NadeThrowState - 0 = getting ready to throw, 1 = throwing, 2 = redeploying
function SWEP:InitiateThrow()
	local ply = self.Owner
	
	if self:GetIsDeploying() or self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:GetIsWaiting() then return end
	
	self:SetIsWaiting(true)
    
    self.WasAltThrow = ply:KeyDown(IN_ATTACK2)
    
    if self.NadeCookable and !self.WasAltThrow then
        self._WasCookedThrow = ply:KeyDown(IN_USE)
    end
    
    if self.NadeCookableAlt and self.WasAltThrow then
        self._WasCookedThrow = ply:KeyDown(IN_USE)
    end
	
	if IsFirstTimePredicted() then
		self:NadePullpinAnimLogic()
	end
	
	self.NadeThrowState = 0
	self.NextNadeAction = CurTime() + (self._WasCookedThrow and self.NadeGetReadyTimeCooking or self.NadeGetReadyTime)
    self.StartNadeCooking = CurTime() + self.NadeCookStartTime
end

function SWEP:OnNadeOvercook() // override this for your own nades
    self:CreateNade(0)
    self.Owner:Kill()
end

function SWEP:OnNadeCookStart() // override this for your own nades
end

function SWEP:NadeFuseStart()
    self.WhenShouldDetonateTime = CurTime() + self.NadeFuseTime
    self._IsCooking = true
end

function SWEP:NadeFuseCreateNade()
    self:CreateNade(self.WhenShouldDetonateTime - CurTime())
end

function SWEP:NadeFuseBlowUp()
    self._ThrowPower = 0
    self._IsCooking = false
    self.WhenShouldDetonateTime = nil
    self.NadeThrowState = 2
    self:OnNadeOvercook()
end

function SWEP:NadeFuseThink()
    if self._WasCookedThrow and !self._IsCooking and self.StartNadeCooking and CurTime() > self.StartNadeCooking then
        self:NadeFuseStart()
        self.StartNadeCooking = nil
    end

    if self._IsCooking and self.WhenShouldDetonateTime and CurTime() > self.WhenShouldDetonateTime then
        self:NadeFuseBlowUp()
        self.WhenShouldDetonateTime = nil
        self.NadeThrowState = 2
        self.NextNadeAction = CurTime()
        self._IsCooking = false
    end
end

if SERVER then
    function SWEP:SpoonEject_Network()
        self:OnNadeCookStart()
        net.Start("PB_BASE_NADE_SPOONEJECT")
            net.WriteEntity(self)
        net.Send(self.Owner)
    end
end

if CLIENT then
    net.Receive("PB_BASE_NADE_SPOONEJECT", function()
        local wep = net.ReadEntity()
        if !IsValid(wep) then return end
        
        wep:OnNadeCookStart()
    end)
end

function SWEP:AdditionalThink()
	if (SP and SERVER) or IsFirstTimePredicted() then
		local ply = self.Owner
        
        self:NadeFuseThink()
        
		if self.NadeThrowState == 0 and self.NextNadeAction and CurTime() > self.NextNadeAction then
            if self.LockThrowStateOnInit then
                if !self._IsCooking then
                    if (self.WasAltThrow and self.NadeCookableAlt and ply:KeyDown(IN_ATTACK)) or (!self.WasAltThrow and self.NadeCookable and ply:KeyDown(IN_ATTACK2)) then
                        self:NadeFuseStart()
                        if SERVER then
                            self:SpoonEject_Network()
                        end
                    end
                end
            end
        
			if (self.LockThrowStateOnInit and ( (!self.WasAltThrow and !ply:KeyDown(IN_ATTACK)) or (self.WasAltThrow and !ply:KeyDown(IN_ATTACK2)) ) ) or (!self.LockThrowStateOnInit and !ply:KeyDown(IN_ATTACK) and !ply:KeyDown(IN_ATTACK2)) then
                
                if !self.LockThrowStateOnInit then
                    if ply:KeyDownLast(IN_ATTACK) then
                        self.WasAltThrow = false
                    elseif ply:KeyDownLast(IN_ATTACK2) then
                        self.WasAltThrow = true
                    end
                end
                
				if self.WasAltThrow then
					self._ThrowPower = self.NadeThrowPowerAlt //0.2
					self:NadeThrowLow()
					self.WasPrimary = false
				else
					self:NadeThrowNormal()
					self._ThrowPower = self.NadeThrowPower //1
					self.WasPrimary = true
				end
				
				self.NadeThrowState = 1
				self.NextNadeAction = CurTime() + self.NadeThrowWaitTime
			end
		end
		
		if self.NadeThrowState == 1 and self.NextNadeAction and CurTime() > self.NextNadeAction then
            if self._IsCooking then
                self:NadeFuseCreateNade()
            else
                self:CreateNade(self.NadeFuseTime)
            end
            
			ply:SetAnimation(PLAYER_ATTACK1)
            self.NadeThrowState = 2
            self.NextNadeAction = CurTime() + self.NadeRedeployWaitTime
            self._IsCooking = false
		end
		
		if self.NadeThrowState == 2 and self.NextNadeAction and CurTime() > self.NextNadeAction then
			if SERVER then
				if !self.SwitchAfterThrow then
					if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then // remove weapon, and switch to previous one
						local wep = ply.PHUNBASE_LastWeapon
						if IsValid(wep) then
                            self.HolsterTime = 0 // put away instantly
							PHUNBASE.SelectWeapon(self.Owner, wep:GetClass())
						end
						timer.Simple(self.HolsterTime + 0.05, function() if IsValid(ply) and IsValid(self) then ply:StripWeapon(self:GetClass()) end end)
					else
						PHUNBASE.ForceDeployWeapon(self.Owner, self:GetClass())
					end
				else
					local wep = ply.PHUNBASE_LastWeapon
					if IsValid(wep) then
						PHUNBASE.SelectWeapon(self.Owner, wep:GetClass())
					end
					if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then
						timer.Simple(self.HolsterTime + 0.05, function() if IsValid(ply) and IsValid(self) then ply:StripWeapon(self:GetClass()) end end)
					end
				end
			end
			
			self.NadeThrowState = nil
			self.NextNadeAction = nil
			self:SetIsWaiting(false)
		end
	end
end

function SWEP:OnRemove()
    if SERVER then
        if self._IsCooking then
            self:NadeFuseCreateNade()
            local grenade = self.NadeEnt
            if IsValid(grenade) then	
                grenade:SetPos(self:GetPos())
                grenade:SetAngles(self:GetAngles())
                local phy = grenade:GetPhysicsObject()
                if IsValid(phy) then 
                    phy:SetVelocity(self:GetVelocity())
                end
            end
        end
    end
end

function SWEP:Reload()
end
