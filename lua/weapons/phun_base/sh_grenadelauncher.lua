
PHUNBASE:addFireSound("PB_GRENADELAUNCHER_FIRE", "weapons/ar2/ar2_altfire.wav")

// grenade launcher status
PB_GLSTATE_READY = 0
PB_GLSTATE_ENTER = 1
PB_GLSTATE_EXIT = 2
PB_GLSTATE_EMPTY = 3
PB_GLSTATE_RELOADING = 4

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
	if !self.UsesGrenadeLauncher then return end
	
	if !nodelay then self:AddGlobalDelay(self.GrenadeLauncherTransitionDelay) end
	
	self:SetGLState(PB_GLSTATE_ENTER)
	self:DelayedEvent(self.GrenadeLauncherTransitionDelay, function() self:SetGLState(self:GetIsGLLoaded() and PB_GLSTATE_READY or PB_GLSTATE_EMPTY) end)
	self:SetWeaponMode(PB_WEAPONMODE_GL_ACTIVE)
	
	self:GrenadeLauncherModeAnimLogic()
end

function SWEP:ExitGrenadeLauncherMode(nodelay)
	if !self.UsesGrenadeLauncher then return end
	
	if !nodelay then self:AddGlobalDelay(self.GrenadeLauncherTransitionDelay) end
	
	self:SetGLState(PB_GLSTATE_EXIT)
	self:GrenadeLauncherModeAnimLogic()
	
	self:SetWeaponMode(PB_WEAPONMODE_NORMAL)
end

function SWEP:IsGLActive()
	return self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE
end

function SWEP:AllowGLMode()
	self.UsesGrenadeLauncher = true
end

function SWEP:DisallowGLMode()
	if self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then
		self:ExitGrenadeLauncherMode(true)
	end
	self.UsesGrenadeLauncher = false
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
	
	-- PrintTable(nade:GetSaveTable())
	
	nade:SetSaveValue("m_flDamage", 150)
	
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
	
	if self:GetGLState() == PB_GLSTATE_READY /*and self:HasEnoughGLAmmo()*/ then
		self:AddGlobalDelay(self.GrenadeLauncherFireDelay)
		self:EmitSound(self.GrenadeLauncherFireSound)
		if SERVER then
			self:GLFireProjectile()
		end
		self:GrenadeLauncherFireAnimLogic()
	else
		self:AddGlobalDelay(self.GrenadeLauncherDryFireDelay)
		self:DryFireAnimLogic()
	end
	
	self:SetGLState(PB_GLSTATE_EMPTY)
	self:SetIsGLLoaded(false)
end

function SWEP:GrenadeLauncherModeReload()	
	if self:IsGlobalDelayActive() or self:IsBusy() or self:GetIsSprinting() then return end
	
	if self:GetGLState() != PB_GLSTATE_EMPTY or !self:HasEnoughGLAmmo() then return end
	
	self:SetGLState(PB_GLSTATE_RELOADING)
	
	local delay = self.GrenadeLauncherReloadTime
	self:AddGlobalDelay(delay)
	self:SetIsReloading(true)
	
	self:DelayedEvent(delay, function()
		self.Owner:RemoveAmmo(1, self.GrenadeLauncherAmmoType)
		self:SetGLState(PB_GLSTATE_READY)
		self:SetIsGLLoaded(true)
		self:SetIsReloading(false)
	end)
	
	self:GrenadeLauncherReloadAnimLogic()
end

hook.Add("PlayerUse", "PB_GLPROJECTILE_GREN_AR2_DISABLEUSE", function(ply, ent) // stop it from exploding when pressing USE it
	if ent.IsPBGL_AR2Projectile then return false end
end)
