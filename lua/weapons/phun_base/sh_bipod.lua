
SWEP.BipodPos = Vector()
SWEP.BipodAng = Vector()

SWEP.BipodTransitionDelay = 1 // time it takes to change to/from bipod mode

function SWEP:BipodModeAnimLogic()
end

function SWEP:EnterBipodMode()
	if !self.UsesBipod then return end
	
	self:AddGlobalDelay(self.BipodTransitionDelay)
	self:SetWeaponMode(PB_WEAPONMODE_BIPOD_ACTIVE)
	self:BipodModeAnimLogic()
end

function SWEP:ExitBipodMode(nodelay)
	if !self.UsesBipod then return end
	
	if !nodelay then
		self:AddGlobalDelay(self.BipodTransitionDelay)
	end
	self:SetWeaponMode(PB_WEAPONMODE_NORMAL)
	self:BipodModeAnimLogic()
end

function SWEP:AllowBipodMode()
	self.UsesBipod = true
end

function SWEP:DisallowBipodMode()
	if self:GetWeaponMode() == PB_WEAPONMODE_BIPOD_ACTIVE then
		self:ExitBipodMode(true)
	end
	self.UsesBipod = false
end
