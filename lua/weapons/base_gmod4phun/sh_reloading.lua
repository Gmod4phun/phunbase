function SWEP:Reload()
	self:_realReloadStart()
end

function SWEP:_realReloadStart()
	local ply = self.Owner
	if self:IsBusy() or self:IsFlashlightBusy() then return end
	if !(self:Clip1() < self.Primary.ClipSize) or ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then return end
	if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
	self:SetIsReloading(true)
	self:CalcHoldType()
	if IsFirstTimePredicted() then
		self.FinishReloadTime = CurTime() + self.ReloadTime
		self:PlayVMSequence("reload")
		self:_reloadBegin()
	end
end

function SWEP:_reloadBegin()
	if IsFirstTimePredicted() then
		local ply = self.Owner
		local C1 = self:Clip1()
		local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
		self:SetClip1(0)
		ply:SetAmmo(TotalAmmo + C1, self:GetPrimaryAmmoType())
		ply:DoReloadEvent()
	end
end

function SWEP:_reloadFinish()
	if IsFirstTimePredicted() then
		local ply = self.Owner
		local AmmoToReload = self:calcAmmoLeft()
		self:SetClip1(AmmoToReload)
		ply:RemoveAmmo(AmmoToReload, self:GetPrimaryAmmoType())
		self:PlayVMSequence("idle")
	end
	self:SetIsReloading(false)
end

function SWEP:calcAmmoLeft()
	local ply = self.Owner
	local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
	local MagCapacity = self.Primary.ClipSize
	if TotalAmmo >= MagCapacity then
		return MagCapacity
	else
		return TotalAmmo
	end
end
