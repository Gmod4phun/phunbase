
PHUNBASE:addFireSound("PB_GRENADELAUNCHER_FIRE", "weapons/ar2/ar2_altfire.wav")

// grenade launcher status
PB_GLSTATE_READY = 0
PB_GLSTATE_EMPTY = 1
PB_GLSTATE_RELOADING = 2

SWEP.GrenadeLauncherIronPos = Vector()
SWEP.GrenadeLauncherIronAng = Vector()

SWEP.GrenadeLauncherAmmoType = "phunbase_40mm_he"
SWEP.GrenadeLauncherReloadTime = 2 // reload delay of the gl
SWEP.GrenadeLauncherFireDelay = 0.5 // the time period during which the gl is considered firing
SWEP.GrenadeLauncherDryFireDelay = 0.25 // same as above, for dryfiring
SWEP.GrenadeLauncherTransitionDelay = 1 // time it takes to change to/from gl mode

SWEP.GrenadeLauncherFireSound = "PB_GRENADELAUNCHER_FIRE"

function SWEP:GrenadeLauncherModeAnimLogic()
end

function SWEP:GrenadeLauncherFireAnimLogic()
end

function SWEP:GrenadeLauncherReloadAnimLogic()
end

function SWEP:EnterGrenadeLauncherMode()
	self:AddGlobalDelay(self.GrenadeLauncherTransitionDelay)
	self:SetWeaponMode(PB_WEAPONMODE_GL_ACTIVE)
	self:GrenadeLauncherModeAnimLogic()
end

function SWEP:ExitGrenadeLauncherMode(nodelay)
	if !nodelay then
		self:AddGlobalDelay(self.GrenadeLauncherTransitionDelay)
	end
	self:SetWeaponMode(PB_WEAPONMODE_NORMAL)
	self:GrenadeLauncherModeAnimLogic()
end

function SWEP:AllowGLMode()
	self.UsesGrenadeLauncher = true
end

function SWEP:DisallowGLMode()
	self.UsesGrenadeLauncher = false
	if self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then
		self:ExitGrenadeLauncherMode(true)
	end
end

function SWEP:GLFireProjectile()
	local ply = self.Owner
	local pos = ply:GetShootPos()
	local eyeAng = ply:EyeAngles()
	local forward = eyeAng:Forward()
	local offset = forward * 30 + eyeAng:Right() * 4 - eyeAng:Up() * 3
	
	local nade = ents.Create("grenade_ar2")
	nade:SetPos(pos + offset)
	nade:SetAngles(eyeAng)
	nade:Spawn()
	nade:Activate()
	nade:SetOwner(ply)
	nade.IsPBGL_AR2Projectile = true
	
	nade:SetVelocity(forward * 2000)
	
	-- local phys = nade:GetPhysicsObject()
	-- if IsValid(phys) then
		-- phys:SetVelocity(forward * 2500)
	-- end
end

function SWEP:HasEnoughGLAmmo()
	return self.Owner:GetAmmoCount(self.GrenadeLauncherAmmoType) > 0
end

function SWEP:GrenadeLauncherModeFire()
	if self:IsGlobalDelayActive() or self:IsBusy() then return end
	
	if self:GetGLState() == PB_GLSTATE_READY and self:HasEnoughGLAmmo() then
		self:AddGlobalDelay(self.GrenadeLauncherFireDelay)
		self:EmitSound(self.GrenadeLauncherFireSound)
		self:GLFireProjectile()
		self.Owner:RemoveAmmo(1, self.GrenadeLauncherAmmoType)
		self:GrenadeLauncherFireAnimLogic()
	else
		self:AddGlobalDelay(self.GrenadeLauncherDryFireDelay)
		self:DryFireAnimLogic()
	end
	
	self:SetGLState(PB_GLSTATE_EMPTY)
end

function SWEP:GrenadeLauncherModeReload()	
	if self:IsGlobalDelayActive() or self:IsBusy() or self:GetIsSprinting() then return end
	
	if self:GetGLState() != PB_GLSTATE_EMPTY or !self:HasEnoughGLAmmo() then return end
	
	self:SetGLState(PB_GLSTATE_RELOADING)
	
	local delay = self.GrenadeLauncherReloadTime
	self:AddGlobalDelay(delay)
	self:SetIsReloading(true)
	self:DelayedEvent(delay, function() self:SetGLState(PB_GLSTATE_READY) self:SetIsReloading(false) end)
	
	self:GrenadeLauncherReloadAnimLogic()
end

hook.Add("PlayerUse", "PB_GLPROJECTILE_GREN_AR2_DISABLEUSE", function(ply, ent) // stop it from exploding when pressing USE it
	if ent.IsPBGL_AR2Projectile then return false end
end)
