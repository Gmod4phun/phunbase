
function SWEP:PlayIdleAnim()
	local empty = self:Clip1() == 0
	local anim = self:GetIron() and "idle_iron" or "idle"
	if empty then
		anim = anim.."_empty"
	end
	if self.Sequences[anim] then
		self:PlayVMSequence(anim, 1)
	end
end

function SWEP:_DeployThink()
	if !self:GetIsDeploying() then return end
	if self.FinishDeployTime and CurTime() >= self.FinishDeployTime then
		self:SetIsDeploying(false)
		if !self.DisableIdleAfterDeploy then
			self:PlayIdleAnim()
		end
	end
end

function SWEP:_ReloadThink()
	if !self:GetIsReloading() then return end
	if IsFirstTimePredicted() then
		if !self.ShotgunReload then // normal magazine reload think logic
			if CurTime() >= self.FinishReloadTime and self:GetIsReloading() then
				self:_reloadFinish()
				self:PlayIdleAnim()
			end
		else // shotgun reload think logic
			if self.ShotgunReloadingState == 0 then
				if self:GetOwner():KeyDown(IN_ATTACK) and (self.ShotgunReload_InsertOnEnd or (self.ShotgunReload_InsertOnEndEmpty and self.WasEmpty)) then
					self.ShouldStopReloading = true
				end
				if CurTime() >= self.NextShotgunAction then
					self.ShotgunReloadingState = 1
				end
			elseif self.ShotgunReloadingState == 1 then
				if self:GetOwner():KeyDown(IN_ATTACK) and self.ShotgunInsertedShells > 0 then
					self.ShouldStopReloading = true
				end
				if CurTime() >= self.NextShotgunAction then
					local ammo = self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
					local clip, cSize = self:Clip1(), self.Primary.ClipSize
					if self.ShouldStopReloading then
						self:_shotgunReloadFinish()
						return
					end
					if self.ShotgunInsertedShells < (cSize - self.HadInClip - (self.ShotgunReload_InsertOnEnd and 1 or 0)) then
						if ( (self.ShotgunReload_InsertOnEnd or (self.ShotgunReload_InsertOnEndEmpty and self.WasEmpty)) and ((clip == cSize - 1) or (ammo == 1)) ) then
							self:_shotgunReloadFinish()
						else
							self:_shotgunReloadInsert()
						end
					else
						self:_shotgunReloadFinish()
					end
				end
			elseif self.ShotgunReloadingState == 2 then
				if CurTime() >= self.NextShotgunAction then
					self:SetIsReloading(false)
					self:PlayIdleAnim()
				end
			end
		end
	end
end

function SWEP:_IronThink()
	if self.Owner:GetInfoNum("phunbase_dev_iron_toggle", 0) == 1 then
		if !self:GetIron() then
			self:SetIron(true)
		end
		return
	end
	
	if CLIENT then // idle anim stuff
		if self:GetIron() then
			if self:CanFire() and self.Cycle > 0.99 and !self:GetIsWaiting() then
				self:PlayIdleAnim()
			end
		else
			if self:CanFire() and self.Cycle > 0.99 and !self:GetIsWaiting() and !self:IsBusy() and !self:GetIsSprinting() and (self.Sequences.sprint_end and (self.Sequence:lower() != self.Sequences.sprint_end:lower()) or true) then
				self:PlayIdleAnim()
			end
		end
	end
	
	if self.IronTransitionWait and self.IronTransitionWait < CurTime() then
		self.IronTransitionWait = nil
		self.IronTransitionWaiting = false
	end
	
	if self.DisableIronsights then
		if self:GetIron() then
			self:SetIron(false)
		end
		return
	end
	
	local ply = self.Owner
	local empty = self:Clip1() == 0
	if ((ply:KeyDown(IN_ATTACK2) and !self:GetIron())) and !self:GetIsSprinting() and !self:IsBusy() and !self:IsFlashlightBusy() and (!self.DisableIronWhileFiring or (self.DisableIronWhileFiring and !self:IsFiring())) then
		self:SetIron(true)
		
		if IsFirstTimePredicted() then
			self:EmitSound("PB_IronIn")
			ply:SetAnimation(PLAYER_START_AIMING)
			if self:IsFlashlightBusy() then return end
			if self.UseIronTransitionAnims and !self:IsBusy() and self:CanFire() then
				if !self:GetIsDual()then
					if !self.ForceGotoTransitionAnims then
						self:PlayVMSequence((empty and self.Sequences.idle_iron_empty) and "idle_iron_empty" or "idle_iron", self.IronTransitionAnimsSpeed)
					else
						self:PlayVMSequence("goto_iron", self.IronTransitionAnimsSpeed)
					end
				else
					self:PlayVMSequence("goto_iron", self.IronTransitionAnimsSpeed)
				end
			end
		end
		if CLIENT then
			if self.CurIronIdleIndex then
				self:RemoveDelayedEvent(self.CurIronIdleIndex)
			end
			if self.Sequences.goto_iron then
				self.CurIronIdleIndex = self:DelayedEvent(self.VM:SequenceDuration(self.VM:LookupSequence(self.Sequences.goto_iron)), function()
					if self.Sequence:lower() == self.Sequences.goto_iron:lower() then
						self:PlayIdleAnim()
					end
					self.CurIronIdleIndex = nil
				end)
			end
		end
		
		if self.IronTransitionFireWaitTime > 0 then
			self.IronTransitionWait = CurTime() + self.IronTransitionFireWaitTime
			self:SetNextPrimaryFire(self.IronTransitionWait)
			self.IronTransitionWaiting = true
		end
	end

	if (!ply:KeyDown(IN_ATTACK2) and self:GetIron()) or ((self:GetIsSprinting() or self:IsBusy()) and self:GetIron() and !string.find(self:GetActiveSequence(), "lighton") ) then
		self:SetIron(false)
		
		if (self.DisableIronWhileFiring and !self.IronTransitionWaiting and self:IsFiring()) then return end
		
		if IsFirstTimePredicted() then
			self:EmitSound("PB_IronOut")
			ply:SetAnimation(PLAYER_LEAVE_AIMING)
			if self:GetIsReloading() or self:GetIsHolstering() or self:IsFlashlightBusy() then return end
			if self.UseIronTransitionAnims and !self:IsBusy() and self:CanFire() then
				if !self:GetIsDual()then
					if !self.ForceGotoTransitionAnims then
						self:PlayVMSequence((empty and self.Sequences.idle_empty) and "idle_empty" or "idle", self.IronTransitionAnimsSpeed)
					else
						self:PlayVMSequence("goto_hip", self.IronTransitionAnimsSpeed)
					end
				else
					self:PlayVMSequence("goto_hip", self.IronTransitionAnimsSpeed)
				end
			end
		end
		if CLIENT then
			if self.CurIronIdleIndex then
				self:RemoveDelayedEvent(self.CurIronIdleIndex)
			end
			if self.Sequences.goto_iron then
				self.CurIronIdleIndex = self:DelayedEvent(self.VM:SequenceDuration(self.VM:LookupSequence(self.Sequences.goto_hip)), function()
					if self.Sequence:lower() == self.Sequences.goto_hip:lower() then
						self:PlayIdleAnim()
					end
					self.CurIronIdleIndex = nil
				end)
			end
		end
	end
end

function SWEP:_SprintThink()
	local ply = self.Owner
	local curspeed = ply:GetVelocity():Length()
	if curspeed > ply:GetWalkSpeed() and ply:KeyDown(IN_SPEED) and ply:OnGround() then
		if !self:GetIsSprinting() then
			self:SetIsSprinting(true)
		end
	else
		if self:GetIsSprinting() then
			self:SetIsSprinting(false)
		end
	end
	
	if CLIENT then
		if !self:IsBusy() and !self:IsFiring() then
			if self:GetIsSprinting() and !self.WasSprinting then
				self.WasSprinting = true
				// sprint start code here
				if self.Sequences.sprint_start then
					self:PlayVMSequence("sprint_start")
				end
				if self.Sequences.sprint_idle then
					self.CurSprintIdleIndex = self:DelayedEvent(self.VM:SequenceDuration(self.VM:LookupSequence(self.Sequences.sprint_start)), function()
						if self.Sequence:lower() == self.Sequences.sprint_start:lower() then // if we still in sprint start
							self:PlayVMSequence("sprint_idle")
						end
						self.CurSprintIdleIndex = nil
					end)
				end
			elseif !self:GetIsSprinting() and self.WasSprinting then
				self.WasSprinting = false
				// sprint end code here
				if self.CurSprintIdleIndex then
					self:RemoveDelayedEvent(self.CurSprintIdleIndex)
				end
				if self.Sequences.sprint_end then
					self:PlayVMSequence("sprint_end")
				end
			end
		end
		
		if self:GetIsSprinting() and (self:IsBusy()) then
			self.WasSprinting = false
		end
	end
end

local td = {}
function SWEP:_NearWallThink()
	local ply = self.Owner
	if SERVER then
		if self.DisableNearwall then return end
		td.start = ply:GetShootPos()
		td.endpos = td.start + ply:EyeAngles():Forward() * 30
		td.filter = ply
		
		tr = util.TraceLine(td)
		
		if tr.Hit or (IsValid(tr.Entity) and not tr.Entity:IsPlayer()) then				
			self:SetIsNearWall(true)
		else
			self:SetIsNearWall(false)
		end
	end
end

function SWEP:_WaterLadderThink()
	local ply = self.Owner
	if SERVER then
		self:SetIsUnderwater(ply:WaterLevel() >= 3)
		self:SetIsOnLadder(ply:GetMoveType() == MOVETYPE_LADDER)
	end
end

function SWEP:_SoundTableThink()
	if SERVER and game.SinglePlayer() then
		if self.CurSoundTable then
			local t = self.CurSoundTable[self.CurSoundEntry]
			
			if UnPredictedCurTime() >= self.SoundTime + t.time / self.SoundSpeed then
				if t.sound and t.sound ~= "" then
					self:EmitSound(t.sound, 70, 100)
				end
				
				if t.callback then
					t.callback(self)
				end
				
				if self.CurSoundEntry and self.CurSoundTable[self.CurSoundEntry + 1] then
					self.CurSoundEntry = self.CurSoundEntry + 1
				else
					self.CurSoundTable = nil
					self.CurSoundEntry = nil
					self.SoundTime = nil
				end
			end
		end
	end
end
