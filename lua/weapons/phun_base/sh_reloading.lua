
SWEP.ReloadTimes = {
	Base = 1,
	Base_Empty = 1,
	Base_Drum = 1,
	Base_Empty_Drum = 1,
	Base_Ext = 1,
	Base_Empty_Ext = 1,
	
	Bipod = 1,
	Bipod_Empty = 1,
	Bipod_Drum = 1,
	Bipod_Empty_Drum = 1,
	Bipod_Ext = 1,
	Bipod_Empty_Ext = 1,
}

SWEP.UsesEmptyReloadTimes = false

SWEP.ReloadClipChangeDelay = 0 // delay for when the clip should be discarded/returned to total ammo (aka when the mag should get out of the gun)

SWEP.DiscardClipOnReload = false // should the ammo in clip get discarded instead of returning to the total ammo
SWEP.DiscardClipOnReloadKeepChambered = true // if discard ammo is enabled and if the weapon is chamberable and has a round in the chamber, it does not get discarded

function SWEP:discardClip()
	if self.Chamberable and !self.WasEmpty and self.DiscardClipOnReloadKeepChambered then
		self:SetClip1(1)
	else
		self:SetClip1(0)
	end
end

function SWEP:getReloadTime()
	local empty = self.WasEmpty and self.UsesEmptyReloadTimes
	local bipod = self:IsBipodDeployed()
	local drum = self.UsesDrumMag
	local extmag = self.UsesExtMag
	
	local reltype = "Base"
	
	if bipod then reltype = "Bipod" end
	
	if empty then reltype = reltype.."_Empty" end
	
	if drum then
		reltype = reltype.."_Drum"
	elseif extmag then
		reltype = reltype.."_Ext"
	end
	
	return self.ReloadTimes[reltype]
end

function SWEP:Reload()
	if self:GetIsCustomizing() then return end
	
	//if IsFirstTimePredicted() then
		if #self.FireModes > 1 and self.Owner:KeyDown(IN_USE) and !self:GetIsSprinting() and !self:IsBusy() and !self:GetIsWaiting() and !self:GetIsNearWall() and !self:GetIsOnLadder() then
			self:CycleFiremodes()
			return
		end
	
		if self.CockAfterShot and self:GetShouldBeCocking() and (!self.DontCockWhenEmpty or (self.DontCockWhenEmpty and self:Clip1() > 0)) then
			if !self:IsFiring() and !self:IsBusy() and !self.IsCocking then
				if self.DontCockWhenSprinting and self:GetIsSprinting() then return end
				if IsFirstTimePredicted() then
					self:Cock()
				end
			end
		else
			if (self:Clip1() < 1 and self.DontCockWhenEmpty) then
				self.IsCocking = false
				self:SetShouldBeCocking(false)
			end
			if !self:GetIron() then
				if IsFirstTimePredicted() then
					self:_realReloadStart()
				end
			end
		end
	//end
end

function SWEP:CockAnimLogic()
	if self.Sequences.cock then	self:PlayVMSequence("cock") end
end

function SWEP:Cock()
	if CLIENT then return end
	
	if !self:GetShouldBeCocking() then return end
	
	self:AddGlobalDelay(self.CockAfterShotTime)
	
	self:SetIsWaiting(true)
	self:SetShouldBeCocking(false)
	self.IsCocking = true
	self:DelayedEvent(self.CockAfterShotTime, function() self.IsCocking = false end)
	self:DelayedEvent(self.CockAfterShotTime + 0.1, function() self:SetIsWaiting(false) end)
	
	local CT = CurTime()
	self:SetNextPrimaryFire(CT + self.CockAfterShotTime + 0.05)
	self:SetNextSecondaryFire(CT + self.CockAfterShotTime + 0.05)
	
	self:CockAnimLogic()
	
	if !self.NoShells and self.MakeShellOnCock then
		self:MakeShell()
	end
end

if SERVER then
    util.AddNetworkString("PB_NET_RELOADING_HADINCLIP_WASEMPTY")
end

if CLIENT then
    net.Receive("PB_NET_RELOADING_HADINCLIP_WASEMPTY", function()
        local wep, had, was = net.ReadEntity(), net.ReadFloat(), net.ReadBool()
        wep.HadInClip = had
        wep.WasEmpty = was
    end)
end

function SWEP:changeHadInClip()
	self.HadInClip = self:Clip1()
	self.WasEmpty = self.HadInClip == 0
    
    if SERVER then // send this to the client
        net.Start("PB_NET_RELOADING_HADINCLIP_WASEMPTY")
            net.WriteEntity(self)
            net.WriteFloat(self.HadInClip)
            net.WriteBool(self.WasEmpty)
        net.Send(self.Owner)
    end
end

function SWEP:_realReloadStart()
	local ply = self.Owner
	if self:IsBusy() or self:IsFlashlightBusy() or self:IsFiring() or (ply:KeyDown(IN_ATTACK) and !self.ReloadAfterShot) or self.IsCocking or self:GetShouldBeCocking() or self.DisableReloading or self:IsGlobalDelayActive() then return end
	
	if self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then
			if IsFirstTimePredicted() then
				self:GrenadeLauncherModeReload()
			end
		return
	end
	
	self:changeHadInClip()
	
	if !(self.HadInClip < self.Primary.ClipSize + ((!self.WasEmpty and self.Chamberable and !self.ShotgunReload) and 1 or 0)) or ply:GetAmmoCount(self:GetPrimaryAmmoType()) < 1 then return end
	if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
	
	self:SetIsReloading(true)
	self:CalcHoldType()
	
	if self.DiscardClipOnReload then
		self:DelayedEvent(self.ReloadClipChangeDelay, function()
			self:discardClip()
			self:changeHadInClip()
		end)
	end
	
	if IsFirstTimePredicted() then
		if !self.ShotgunReload then
			self.FinishReloadTime = CurTime() + self:getReloadTime()
			self.ReloadIdleSnapTime = CurTime() + (self.IdleAfterReloadTime and self.IdleAfterReloadTime or self:getReloadTime())
			self:_reloadBegin()
		else
			self:_shotgunReloadBegin()
		end
	end
	
	self:SetIsNearWall(false)
	
	if !(self.NoReloadAnimation or (self:GetHoldType() == "shotgun" and self.ShotgunReload)) then // shotgun holdtype on shotgun reloads can glitch sounds, gmod bug
		ply:SetAnimation(PLAYER_RELOAD)
	end
end

function SWEP:ReloadAnimLogic()
	self:PlayVMSequence(((self.WasEmpty and self.Sequences.reload_empty) and "reload_empty" or "reload"))
end

function SWEP:_reloadDiscardbla()

end

function SWEP:_reloadBegin()
	local ply = self.Owner
	if IsFirstTimePredicted() then
		self:ReloadAnimLogic()
		if !self.DiscardClipOnReload and SERVER then
			self:DelayedEvent(self.ReloadClipChangeDelay, function()
				if self.HadInClip > 1 then
					ply:GiveAmmo(self.HadInClip, self:GetPrimaryAmmoType(), true)
					if self:_wasChamberedDuringReload() then
						self:SetClip1(1)
						ply:RemoveAmmo(1, self:GetPrimaryAmmoType())
					end
				end
				self:discardClip()
			end)
		end
	end
end

function SWEP:_wasChamberedDuringReload()
	return (self.Chamberable and !self.WasEmpty and (!self.DiscardClipOnReload or self.DiscardClipOnReloadKeepChambered))
end

function SWEP:getAmmoCount()
	return self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
end

function SWEP:calcAmmoLeft()
	local MagCapacity = self.Primary.ClipSize// + (self:_wasChamberedDuringReload() and 1 or 0)
	if self:getAmmoCount() >= MagCapacity then
		return MagCapacity
	else
		return self:getAmmoCount()
	end
end

function SWEP:_reloadFinish()
	if IsFirstTimePredicted() then
		local ply = self.Owner
		local AmmoToReload = self:calcAmmoLeft()
		
		ply:RemoveAmmo(AmmoToReload, self:GetPrimaryAmmoType())
		self:SetClip1(self:Clip1() + AmmoToReload)
		
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

function SWEP:_shotgunReloadRemoveAmmo(delay)
	self:DelayedEvent(delay or 0, function()
		self:SetClip1(self:Clip1() - 1)
	end)
end

function SWEP:ShotgunReloadStartLogic()
	self:PlayVMSequence(self.WasEmpty and "reload_shell_start_empty" or "reload_shell_start")
end

function SWEP:_shotgunReloadBegin()
	local TotalAmmo = self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
	self.ShotgunReloadingState = 0
	self.ShouldStopReloading = false
	self.NextShotgunAction = self.WasEmpty and (CurTime() + self.ShotgunReloadTimes.Start_Empty) or (CurTime() + self.ShotgunReloadTimes.Start)
	
	self:ShotgunReloadStartLogic()
	
	// a very special occasion, but it can happen, so it needs to be taken care of
	if TotalAmmo == 1 and self.ShotgunReloadActions.InsertOnStart and self.WasEmpty and self.ShotgunReloadActions.InsertOnEndEmpty then // only inserts 1 last shell available, starts empty, and should insert shell on both start and end
		self.ShotgunReloadingState = 2
		self:DelayedEvent(self.ShotgunReloadTimes.Start_EmptyOneAndOnly or 0.1, function() self:_shotgunReloadFinish() end)
		return
	end
	
	self.ShotgunInsertedShells = ((self.ShotgunReloadActions.InsertOnStart and !self.WasEmpty) or (self.ShotgunReloadActions.InsertOnStartEmpty and self.WasEmpty)) and 1 or 0
	
	if self.ShotgunReloadActions.EjectOnStart and !self.WasEmpty then
		self.ShotgunInsertedShells = self.ShotgunInsertedShells - 1
		self:_shotgunReloadRemoveAmmo(self.ShotgunReloadTimes.EjectOnStart)
	end
	
	if (self.ShotgunReloadActions.InsertOnStart and !self.WasEmpty) or (self.ShotgunReloadActions.InsertOnStartEmpty and self.WasEmpty) then
		self:_shotgunReloadAddAmmo(self.WasEmpty and self.ShotgunReloadTimes.InsertOnStartEmptyAmmoWait or self.ShotgunReloadTimes.InsertOnStartAmmoWait)
	end
end

function SWEP:ShotgunReloadInsertLogic()
	self:PlayVMSequence("reload_shell_insert")
end

function SWEP:_shotgunReloadInsert()
	self.NextShotgunAction = CurTime() + self.ShotgunReloadTimes.Insert
	
	self:ShotgunReloadInsertLogic()
	
	self.ShotgunInsertedShells = self.ShotgunInsertedShells + 1
	self:_shotgunReloadAddAmmo(self.ShotgunReloadTimes.InsertAmmoWait)
end

function SWEP:ShotgunReloadEndLogic()
	self:PlayVMSequence(self.WasEmpty and "reload_shell_end_empty" or "reload_shell_end")
end

function SWEP:_shotgunReloadFinish()
	self.ShotgunReloadingState = 2
	self.NextShotgunAction = self.WasEmpty and (CurTime() + self.ShotgunReloadTimes.End_Empty) or (CurTime() + self.ShotgunReloadTimes.End)
	
	self:ShotgunReloadEndLogic()
	
	if (self.ShotgunReloadActions.InsertOnEnd and !self.WasEmpty) or (self.ShotgunReloadActions.InsertOnEndEmpty and self.WasEmpty) then
		self:_shotgunReloadAddAmmo(self.WasEmpty and self.ShotgunReloadTimes.InsertOnEndEmptyAmmoWait or self.ShotgunReloadTimes.InsertOnEndAmmoWait)
	end
end
