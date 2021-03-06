
if !SERVER then return end
	
function SWEP:ToggleFlashlight(dontUseAnim)
	if self:IsBusy() then return end
	if self:GetIsSprinting() and !dontUseAnim then return end
	
	if !self.CustomFlashlight then return end
	
	if self:GetNextFlashlightUse() <= CurTime() then
		self:SetFlashlightStateOld(self:GetFlashlightState())
		self:SetFlashlightState(!self:GetFlashlightState())
		if !dontUseAnim and self.CustomFlashlight then
			self:SetNextFlashlightUse(CurTime() + 0.75)
			SendUserMessage("PHUNBASE_FLASHLIGHT_PLAYANIM", ply)
		end
	end
end

function SWEP:CreateFlashlight()
	SendUserMessage("PHUNBASE_FLASHLIGHT_CREATE", self.Owner)
end

function SWEP:DestroyFlashlight()
	SendUserMessage("PHUNBASE_FLASHLIGHT_DESTROY", self.lastOwner)
end

local function PHUNBASE_FLASHLIGHT_POSTPLAYERDEATH(ply)
	SendUserMessage("PHUNBASE_FLASHLIGHT_DESTROY", ply)
end
hook.Add("PostPlayerDeath", "PHUNBASE_FLASHLIGHT_POSTPLAYERDEATH", PHUNBASE_FLASHLIGHT_POSTPLAYERDEATH)

local function PHUNBASE_FLASHLIGHT_SWITCH(ply, state)
	local wep = ply:GetActiveWeapon()
	if wep.PHUNBASEWEP and !wep.NormalFlashlight then
		if state then
			return false
		end
	end
end
hook.Add("PlayerSwitchFlashlight", "PHUNBASE_FLASHLIGHT_SWITCH", PHUNBASE_FLASHLIGHT_SWITCH)

local function PHUNBASE_FLASHLIGHT_BIND(ply, cmd)
	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	if wep.ToggleFlashlight and cmd:GetImpulse() == 100 then
		wep:ToggleFlashlight(tobool(wep.InstantFlashlight))
		return
	end
end
hook.Add("StartCommand", "PHUNBASE_FLASHLIGHT_BIND", PHUNBASE_FLASHLIGHT_BIND)
