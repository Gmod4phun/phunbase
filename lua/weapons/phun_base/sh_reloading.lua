function SWEP:Reload()
	if IsFirstTimePredicted() then
		if self.CockAfterShot and self.ShouldBeCocking then
			if !self:IsFiring() and !self:IsBusy() and !self.IsCocking then
				self:Cock()
			end
		else
			self:_realReloadStart()
		end
	end
end

function SWEP:Cock()
	if CLIENT then return end
	
	if !self.ShouldBeCocking then return end
	
	self:SetIsWaiting(true)
	self.ShouldBeCocking = false
	self.IsCocking = true
	self:DelayedEvent(self.CockAfterShotTime, function() self.IsCocking = false end)
	self:DelayedEvent(self.CockAfterShotTime + 0.1, function() self:SetIsWaiting(false) end)
	
	local CT = CurTime()
	self:SetNextPrimaryFire(CT + self.CockAfterShotTime + 0.05)
	self:SetNextSecondaryFire(CT + self.CockAfterShotTime + 0.05)
	
	self:PlayVMSequence("cock")
	if !self.NoShells and self.MakeShellOnCock then
		self:MakeShell()
	end
end

function SWEP:_realReloadStart()
	local ply = self.Owner
	if self:IsBusy() or self:IsFlashlightBusy() or self:IsFiring() or (ply:KeyDown(IN_ATTACK) and !self.ReloadAfterShot) or self.IsCocking or self.ShouldBeCocking or self.DisableReloading then return end
	
	self.HadInClip = self:Clip1()
	self.WasEmpty = self.HadInClip == 0
	
	if !(self.HadInClip < self.Primary.ClipSize + ((!self.WasEmpty and self.Chamberable and !self.ShotgunReload) and 1 or 0)) or ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then return end
	if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
	
	self:SetIsReloading(true)
	self:CalcHoldType()
	
	if IsFirstTimePredicted() then
		if !self.ShotgunReload then
			self.FinishReloadTime = CurTime() + ((self.WasEmpty and self.ReloadTime_Empty) and self.ReloadTime_Empty or self.ReloadTime)
			self.ReloadIdleSnapTime = CurTime() + (self.IdleAfterReloadTime and self.IdleAfterReloadTime or self.ReloadTime)
			self:_reloadBegin()
		else
			self:_shotgunReloadBegin()
		end
	end
	
	if !(self.NoReloadAnimation or (self:GetHoldType() == "shotgun" and self.ShotgunReload)) then // shotgun holdtype on shotgun reloads can glitch sounds, gmod bug
		ply:SetAnimation(PLAYER_RELOAD)
	end
end

function SWEP:_reloadBegin()
	local ply = self.Owner
	if IsFirstTimePredicted() then
		self:PlayVMSequence(((self.WasEmpty and self.Sequences.reload_empty) and "reload_empty" or "reload"))
		local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
		ply:SetAmmo(TotalAmmo + self.HadInClip, self:GetPrimaryAmmoType())
		self:SetClip1(0)
	end
end

function SWEP:calcAmmoLeft()
	local ply = self.Owner
	local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
	local MagCapacity = self.Primary.ClipSize + ((!self.WasEmpty and self.Chamberable) and 1 or 0)
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
function SWEP:_shotgunReloadAddAmmo(delay)
	timer.Simple(delay or 0, function() if !IsValid(self) or !IsValid(self.Owner) then return end
		local TotalAmmo = self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
		if TotalAmmo > 0 then
			self:SetClip1(self:Clip1() + 1)
			self.Owner:RemoveAmmo(1, self:GetPrimaryAmmoType())
		end
		if TotalAmmo == 1 then // if we plan to load last shell, stop reloading next time
			self.ShouldStopReloading = true
		end
	end)
end

function SWEP:_shotgunReloadBegin()
	local TotalAmmo = self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
	self.ShotgunReloadingState = 0
	self.ShouldStopReloading = false
	self.NextShotgunAction = self.WasEmpty and (CurTime() + self.ShotgunReloadTime_Start_Empty) or (CurTime() + self.ShotgunReloadTime_Start)
	self:PlayVMSequence(self.WasEmpty and "reload_shell_start_empty" or "reload_shell_start")
	
	// a very special occasion, but it can happen, so it needs to be taken care of
	if TotalAmmo == 1 and self.ShotgunReload_InsertOnStart and self.WasEmpty and self.ShotgunReload_InsertOnEndEmpty then // only inserts 1 last shell available, starts empty, and should insert shell on both start and end
		self.ShotgunReloadingState = 2
		self:DelayedEvent(self.ShotgunReloadTime_Start_EmptyOneAndOnly or 0.1, function() self:_shotgunReloadFinish() end)
		return
	end
	
	self.ShotgunInsertedShells = self.ShotgunReload_InsertOnStart and 1 or 0
	if self.ShotgunReload_InsertOnStart then
		self:_shotgunReloadAddAmmo(self.ShotgunReloadTime_InsertOnStartAmmoWait)
	end
end

function SWEP:_shotgunReloadInsert()
	self.NextShotgunAction = CurTime() + self.ShotgunReloadTime_Insert
	self:PlayVMSequence("reload_shell_insert")
	self.ShotgunInsertedShells = self.ShotgunInsertedShells + 1
	self:_shotgunReloadAddAmmo(self.ShotgunReloadTime_InsertAmmoWait)
end

function SWEP:_shotgunReloadFinish()
	self.ShotgunReloadingState = 2
	self.NextShotgunAction = self.WasEmpty and (CurTime() + self.ShotgunReloadTime_End_Empty) or (CurTime() + self.ShotgunReloadTime_End)
	self:PlayVMSequence(self.WasEmpty and "reload_shell_end_empty" or "reload_shell_end")
	if self.ShotgunReload_InsertOnEnd or (self.ShotgunReload_InsertOnEndEmpty and self.WasEmpty) then
		self:_shotgunReloadAddAmmo(self.ShotgunReloadTime_InsertOnEndAmmoWait)
	end
end
