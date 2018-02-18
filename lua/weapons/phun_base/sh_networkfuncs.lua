// networked stuff is here

function SWEP:SetIron(b)
	self:SetNW2Bool("Iron",b)
end

function SWEP:GetIron()
	return self:GetNW2Bool("Iron")
end

function SWEP:SetIsDual(b)
	self:SetNW2Bool("IsDual",b)
end

function SWEP:GetIsDual()
	return self:GetNW2Bool("IsDual")
end

function SWEP:SetDualSide(left_right)
	self:SetNW2String("DualSide",left_right)
end

function SWEP:GetDualSide()
	return self:GetNW2String("DualSide")
end

function SWEP:SetIsReloading(b)
	self:SetNW2Bool("IsReloading",b)
end

function SWEP:GetIsReloading()
	return self:GetNW2Bool("IsReloading")
end

function SWEP:SetIsSprinting(b)
	self:SetNW2Bool("IsSprinting",b)
end

function SWEP:GetIsSprinting()
	return self:GetNW2Bool("IsSprinting")
end

function SWEP:SetIsDeploying(b)
	self:SetNW2Bool("IsDeploying",b)
end

function SWEP:GetIsDeploying()
	return self:GetNW2Bool("IsDeploying")
end

function SWEP:SetIsHolstering(b)
	self:SetNW2Bool("IsHolstering",b)
end

function SWEP:GetIsHolstering()
	return self:GetNW2Bool("IsHolstering")
end

function SWEP:SetIsNearWall(b)
	self:SetNW2Bool("IsNearWall",b)
end

function SWEP:GetIsNearWall()
	return self:GetNW2Bool("IsNearWall")
end

function SWEP:SetIsUnderwater(b)
	self:SetNW2Bool("IsUnderwater",b)
end

function SWEP:GetIsUnderwater()
	return self:GetNW2Bool("IsUnderwater")
end

function SWEP:SetIsOnLadder(b)
	self:SetNW2Bool("IsOnLadder",b)
end

function SWEP:GetIsOnLadder()
	return self:GetNW2Bool("IsOnLadder")
end

function SWEP:SetHolsterDelay(n)
	self:SetNW2Float("HolsterDelay",n)
end

function SWEP:GetHolsterDelay()
	return self:GetNW2Float("HolsterDelay")
end

function SWEP:SetActiveSequence(name)
	self:SetNW2String("ActiveSequence",name)
end

function SWEP:GetActiveSequence()
	return self:GetNW2String("ActiveSequence")
end

function SWEP:SetMuzzleAttachmentName(name)
	self:SetNW2String("MuzzleAttachmentName",name)
end

function SWEP:GetMuzzleAttachmentName()
	return self:GetNW2String("MuzzleAttachmentName")
end

function SWEP:SetShellAttachmentName(name)
	self:SetNW2String("ShellAttachmentName",name)
end

function SWEP:GetShellAttachmentName()
	return self:GetNW2String("ShellAttachmentName")
end

function SWEP:SetFlashlightState(b)
	self:SetNW2Bool("FlashlightState",b)
end

function SWEP:GetFlashlightState()
	return self:GetNW2Bool("FlashlightState")
end

function SWEP:SetFlashlightStateOld(b)
	self:SetNW2Bool("FlashlightStateOld",b)
end

function SWEP:GetFlashlightStateOld()
	return self:GetNW2Bool("FlashlightStateOld")
end

function SWEP:SetNextFlashlightUse(n)
	self:SetNW2Float("NextFlashlightUse",n)
end

function SWEP:GetNextFlashlightUse()
	return self:GetNW2Float("NextFlashlightUse")
end

function SWEP:IsBusy()
	return self:GetIsReloading() or self:GetIsDeploying() or self:GetIsHolstering() or self:GetIsUnderwater() or self:GetIsOnLadder()
end

function SWEP:IsFlashlightBusy()
	return self:GetNextFlashlightUse() > CurTime()
end

function SWEP:SetIsWaiting(b)
	self:SetNW2Bool("IsWaiting",b)
end

function SWEP:GetIsWaiting()
	return self:GetNW2Bool("IsWaiting")
end
