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
		if !self.ShotgunReload then
			self.FinishReloadTime = CurTime() + self.ReloadTime
			self:_reloadBegin()
		else
			self:_shotgunReloadBegin()
		end
	end
	if !self.NoReloadAnimation then
		ply:SetAnimation(PLAYER_RELOAD)
	end
end

function SWEP:_reloadBegin()
	if IsFirstTimePredicted() then
		self:PlayVMSequence("reload")
		local ply = self.Owner
		local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
		ply:SetAmmo(TotalAmmo + self:Clip1(), self:GetPrimaryAmmoType())
		self:SetClip1(0)
	end
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

function SWEP:_reloadFinish()
	if IsFirstTimePredicted() then
		local ply = self.Owner
		local AmmoToReload = self:calcAmmoLeft()
		self:SetClip1(AmmoToReload)
		ply:RemoveAmmo(AmmoToReload, self:GetPrimaryAmmoType())
		self:PlayVMSequence("idle")
		if AmmoToReload % 2 == self.Primary.ClipSize % 2 then
			self:SetDualSide(self.DefaultDualSide)
		else
			if self.DefaultDualSide == "right" then
				self:SetDualSide("left")
			else
				self:SetDualSide("right")
			end
		end
	end
	self:SetIsReloading(false)
end

// ShotgunReloadingState - 0 = start, 1 = inserting, 2 = end
function SWEP:_shotgunReloadBegin()
	self.HadInClip = self:Clip1()
	self.WasEmpty = self.HadInClip == 0
	self.ShotgunReloadingState = 0
	self.ShouldStopReloading = false
	self.NextShotgunAction = self.WasEmpty and (CurTime() + self.ShotgunReloadTime_Start_Empty) or (CurTime() + self.ShotgunReloadTime_Start)
	self:PlayVMSequence(self.WasEmpty and "reload_shell_start_empty" or "reload_shell_start")
	self.ShotgunInsertedShells = 0
end

function SWEP:_shotgunReloadInsert()
	self.NextShotgunAction = CurTime() + self.ShotgunReloadTime_Insert
	self:PlayVMSequence("reload_shell_insert")
	self.ShotgunInsertedShells = self.ShotgunInsertedShells + 1
	local ply = self.Owner
	local clip = self:Clip1()
	local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
	if TotalAmmo > 0 then
		self:SetClip1(clip + 1)
		ply:RemoveAmmo(1, self:GetPrimaryAmmoType())
	end
	if TotalAmmo == 1 then // if we plan to load last shell, stop reloading next time
		self.ShouldStopReloading = true
	end
end

function SWEP:_shotgunReloadFinish()
	self.NextShotgunAction = self.WasEmpty and (CurTime() + self.ShotgunReloadTime_End_Empty) or CurTime() + self.ShotgunReloadTime_End
	self:PlayVMSequence(self.WasEmpty and "reload_shell_end_empty" or "reload_shell_end")
end
