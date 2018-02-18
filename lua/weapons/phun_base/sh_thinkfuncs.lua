function SWEP:_DeployThink()
	if !self:GetIsDeploying() then return end
	if SERVER then
		if CurTime() >= self.FinishDeployTime and self:GetIsDeploying() then
			self:SetIsDeploying(false)
		end
	end
end

function SWEP:_ReloadThink()
	if !self:GetIsReloading() then return end
	if SERVER then
		if IsFirstTimePredicted() then
			if !self.ShotgunReload then // normal magazine reload think logic
				if CurTime() >= self.FinishReloadTime and self:GetIsReloading() then
					self:_reloadFinish()
				end
			else // shotgun reload think logic
				if self.ShotgunReloadingState == 0 then
					if CurTime() >= self.NextShotgunAction then
						self.ShotgunReloadingState = 1
					end
				elseif self.ShotgunReloadingState == 1 then
					if self.Owner:KeyDown(IN_ATTACK) and self.ShotgunInsertedShells > 0 then
						self.ShouldStopReloading = true
					end
					if CurTime() >= self.NextShotgunAction then
						if self.ShotgunInsertedShells < self.Primary.ClipSize - self.HadInClip and !self.ShouldStopReloading then
							self:_shotgunReloadInsert()
						else
							self.ShotgunReloadingState = 2
							self:_shotgunReloadFinish()
						end
					end
				elseif self.ShotgunReloadingState == 2 then
					if CurTime() >= self.NextShotgunAction then
						self:SetIsReloading(false)
					end
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
	
	if self.DisableIronsights then return end
	local ply = self.Owner
	local empty = self:Clip1() == 0
	if ((ply:KeyDown(IN_ATTACK2) and !self:GetIron())) and !self:GetIsSprinting() and !self:IsBusy() and !self:IsFlashlightBusy() then
		self:SetIron(true)
		if IsFirstTimePredicted() then
			//self:FrostSound( self.SND.IronIn[math.random(1,3)] )
			if self:IsFlashlightBusy() then return end
			if self.UseIronTransitionAnims then
				if !self:GetIsDual()then
					self:PlayVMSequence(empty and "idle_empty" or "idle")
				else
					self:PlayVMSequence("goto_iron", 2)
				end
			end
		end
	end

	if (!ply:KeyDown(IN_ATTACK2) and self:GetIron()) or ((self:GetIsSprinting() or self:IsBusy()) and self:GetIron() and !string.find(self:GetActiveSequence(), "lighton") ) then
		self:SetIron(false)
		if IsFirstTimePredicted() then
			//self:FrostSound( self.SND.IronOut[math.random(1,3)] )
			if self:GetIsReloading() or self:GetIsHolstering() or self:IsFlashlightBusy() then return end
			if self.UseIronTransitionAnims then
				if !self:GetIsDual()then
					self:PlayVMSequence(empty and "idle_empty" or "idle")
				else
					self:PlayVMSequence("goto_hip", 2)
				end
			end
		end
	end
end

function SWEP:_SprintThink()
	local ply = self.Owner
	local curspeed = ply:GetVelocity():Length()
	if curspeed > ply:GetWalkSpeed() and ply:KeyDown(IN_SPEED) and ply:OnGround() and !self:GetIsDeploying() then
		self:SetIsSprinting(true)
	else
		self:SetIsSprinting(false)
	end
end

local td = {}
function SWEP:_NearWallThink()
	local ply = self.Owner
	if SERVER then
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
	//if !game.SinglePlayer() then return end
	if SERVER then
		if self.CurSoundTable then
			local t = self.CurSoundTable[self.CurSoundEntry]
			--[[if CLIENT then
				if CT >= self.SoundTime + t.time / self.SoundSpeed then
					self:EmitSound(t.sound, 70, 100)
					if self.CurSoundTable[self.CurSoundEntry + 1] then
						self.CurSoundEntry = self.CurSoundEntry + 1
					else
						self.CurSoundTable = nil
						self.CurSoundEntry = nil
						self.SoundTime = nil
					end
				end
			else]]--
			
			if UnPredictedCurTime() >= self.SoundTime + t.time / self.SoundSpeed then
				if t.sound and t.sound ~= "" then
					self:EmitSound(t.sound, 70, 100)
				end
				
				if t.callback then
					t.callback(self)
				end
				
				if self.CurSoundTable[self.CurSoundEntry + 1] then
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