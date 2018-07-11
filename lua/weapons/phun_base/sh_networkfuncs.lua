// weapon modes

PB_WEAPONMODE_NORMAL = 0
PB_WEAPONMODE_GL_ACTIVE = 1
PB_WEAPONMODE_BIPOD_ACTIVE = 2

// DATATABLES

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Iron" )
	self:NetworkVar( "Bool", 1, "IsDual" )
	self:NetworkVar( "String", 0, "DualSide" )
	self:NetworkVar( "Bool", 2, "IsReloading" )
	self:NetworkVar( "Bool", 3, "IsSprinting" )
	self:NetworkVar( "Bool", 4, "IsDeploying" )
	self:NetworkVar( "Bool", 5, "IsHolstering" )
	self:NetworkVar( "Bool", 6, "IsNearWall" )
	self:NetworkVar( "Bool", 7, "IsUnderwater" )
	self:NetworkVar( "Bool", 8, "IsOnLadder" )
	self:NetworkVar( "Float", 0, "HolsterDelay" )
	self:NetworkVar( "String", 1, "ActiveSequence" )
	self:NetworkVar( "String", 2, "MuzzleAttachmentName" )
	self:NetworkVar( "String", 3, "ShellAttachmentName" )
	self:NetworkVar( "Bool", 9, "FlashlightState" )
	self:NetworkVar( "Bool", 10, "FlashlightStateOld" )
	self:NetworkVar( "Float", 1, "NextFlashlightUse" )
	self:NetworkVar( "Bool", 11, "IsWaiting" )
	self:NetworkVar( "Bool", 12, "IsInUse" )
	self:NetworkVar( "Float", 2, "NextMeleeAction" )
	self:NetworkVar( "Bool", 13, "IsCustomizing" )
	self:NetworkVar( "Bool", 14, "IsSwitchingFiremode" )
	self:NetworkVar( "Bool", 15, "ShouldBeCocking" )
	self:NetworkVar( "Int", 0, "WeaponMode" )
	self:NetworkVar( "Int", 1, "GLState" )
	self:NetworkVar( "Int", 2, "BipodState" )
	self:NetworkVar( "Float", 3, "GlobalDelay" )
end

function SWEP:IsBusy()
	return self:GetIsReloading() or self:GetIsDeploying() or self:GetIsHolstering() or self:GetIsUnderwater() or self:GetIsOnLadder()
end

function SWEP:IsFlashlightBusy()
	return self:GetNextFlashlightUse() > CurTime()
end

function SWEP:IsBusyForCustomizing()
	return self:IsBusy() or self:GetIron() or self:IsFlashlightBusy() or self:GetIsSprinting() or self:GetIsSwitchingFiremode() or self:IsGlobalDelayActive() or self:IsBipodDeployed()
end

function SWEP:IsBusyForBipodDeploying()
	return self:IsBusy() or self:IsFlashlightBusy() or self:GetIsSprinting() or self:GetIsSwitchingFiremode() or self:IsGlobalDelayActive() or self:GetIsCustomizing()
end

function SWEP:IsSafe()
	return self.FireMode == "safe"
end

function SWEP:AddGlobalDelay(sec)
	self:SetGlobalDelay(CurTime() + sec)
end

function SWEP:IsGlobalDelayActive()
	local delay = self:GetGlobalDelay()
	if delay > CurTime() then
		return true
	else
		return false
	end
end
