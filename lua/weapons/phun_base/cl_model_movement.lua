-- FAS 2.0 vm movement, modified

CreateClientConVar("phunbase_vm_crouchoffset", "1", true, false)

local vm, EP, EA, FT, CT, TargetPos, TargetAng, cos1, cos2, sin1, sin2, vel, ong, len, delta, tan, mod, tr, move, rs, pos, ang, wm, VM
local AngDif, AngleTable = Angle(0,0,0), Angle(0,0,0)
local BlendSpeed = 8
local Vec0, Ang0 = Vector(0,0,0), Angle(0, 0, 0)
local veldepend = {pitch = 0, yaw = 0, roll = 0}
local td = {}

local PosMod, AngMod = Vector(0, 0, 0), Vector(0, 0, 0)
local CurPosMod, CurAngMod = Vector(0, 0, 0), Vector(0, 0, 0)

local reg = debug.getregistry()
local Right = reg.Angle.Right
local Up = reg.Angle.Up
local Forward = reg.Angle.Forward
local RotateAroundAxis = reg.Angle.RotateAroundAxis

local dif1, dif2 // bipod diffs

function SWEP:performViewmodelMovement()
	vm = self.VM
	self.Cycle = vm:GetCycle()
	self.Sequence = vm:GetSequenceName(vm:GetSequence())
	
	VM, EP, EA, FT, CT = self.Owner:GetViewModel(), EyePos(), EyeAngles(), FrameTime(), CurTime()
	vel, ong = self.Owner:GetVelocity(), self.Owner:OnGround()
	len = vel:Length()
	
	AngleTable.p = EA.P
	AngleTable.y = EA.Y
	delta = AngleTable - self.OldDelta
	
	self.OldDelta.p = EA.p
	self.OldDelta.y = EA.y
	
	if !self:GetIsDeploying() then
		if self.SwayInterpolation == "linear" then
			self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, delta)
			self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -15, 15)
		else
			delta.p = math.Clamp(delta.p, -5, 5)
			self.AngleDelta2 = LerpAngle(math.Clamp(FT * 12, 0, 1), self.AngleDelta2, self.AngleDelta)
			AngDif.x = (self.AngleDelta.p - self.AngleDelta2.p)
			AngDif.y = (self.AngleDelta.y - self.AngleDelta2.y)
			self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, delta + AngDif)
			self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -25, 25)
		end
	else
		self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, Ang0)
		TargetPos, TargetAng = self.BasePos * 1, self.BaseAng * 1
	end
	
	EP, EA = EyePos(), EyeAngles()
	
	if IsValid(vm) then
		
		self:processFOVChanges(FT)
		
		// base idle pos
		TargetPos = self.BasePos * 1
		TargetAng = self.BaseAng * 1
		BlendSpeed = math.Approach(BlendSpeed, 5, FT * 200)
		
		move = math.Clamp(len / self.Owner:GetWalkSpeed(), 0, 1)
		
		if self:GetIsSprinting() and !self:GetIsReloading() and self.NoSprintVMMovement then
			move = 0
		end
		
		if self:GetIron() then
			TargetPos = self.IronsightPos * 1
			TargetAng = self.IronsightAng * 1
			
			if self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then
				TargetPos, TargetAng = self.GrenadeLauncherIronPos * 1, self.GrenadeLauncherIronAng * 1
			end
			
			BlendSpeed = math.Approach(BlendSpeed, 10, FT * 300)
			CurPosMod, CurAngMod = Vec0 * 1, Vec0 * 1
		
			self.SlowDownBlend = true
			
			if len > 30 and ong then
				cos1, sin1 = math.cos(CT * 8), math.sin(CT * 8)
				tan = math.atan(cos1 * sin1, cos1 * sin1)
				
				TargetAng[1] = TargetAng[1] + tan * 0.5 * move 
				TargetAng[2] = TargetAng[2] + cos1 * 0.25 * move 
				TargetAng[3] = TargetAng[3] + sin1 * 0.25 * move 
				
				TargetPos[1] = TargetPos[1] + sin1 * 0.05 * move 
				TargetPos[2] = TargetPos[2] + tan * 0.1 * move 
				TargetPos[3] = TargetPos[3] + tan * 0.05 * move 
			end
			
			AngMod = PHUNBASE_LerpVector(FT * 10, AngMod, Vec0)
			PosMod = PHUNBASE_LerpVector(FT * 10, PosMod, Vec0)
		elseif self:GetIsUnderwater() or self:GetIsOnLadder() then
			TargetPos, TargetAng = self.InactivePos * 1, self.InactiveAng * 1
			BlendSpeed = math.Approach(BlendSpeed, 5, FT * 100)
		elseif self:GetIsSprinting() then			
			if self:GetIsReloading() then
				TargetPos, TargetAng = self.BasePos * 1, self.BaseAng * 1
				BlendSpeed = math.Approach(BlendSpeed, 5, FT * 100)
			elseif self:GetIsDeploying() then
				TargetPos, TargetAng = self.SprintPos * 1, self.SprintAng * 1
				BlendSpeed = math.Approach(BlendSpeed, 5, FT * 500)
			else
				TargetPos, TargetAng = self.SprintPos * 1, self.SprintAng * 1
				BlendSpeed = math.Approach(BlendSpeed, 5, FT * 200)
			end
		
			rs = self.Owner:GetRunSpeed()
			mul = math.Clamp(len / rs, 0, 1)
			
			self.RunTime = self.RunTime + FT * (7.5 + math.Clamp(len / 120, 0, 5))
			local runTime = self.RunTime
			sin1 = math.sin(runTime) * mul
			cos1 = math.cos(runTime) * mul
			tan1 = math.atan(cos1 * sin1, cos1 * sin1) * mul
			
			if self.FireMode == "safe" then
				tan = math.atan(cos1 * sin1, cos1 * sin1)
				AngMod[1] = Lerp(FT * 15, AngMod[1], tan * 7.5 * move * self.ViewModelMovementScale)
				AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * 3 * move * self.ViewModelMovementScale)
				AngMod[3] = Lerp(FT * 15, AngMod[3], tan * -5 * move * self.ViewModelMovementScale)
				PosMod[1] = Lerp(FT * 15, PosMod[1], tan * 2.5 * move * self.ViewModelMovementScale)
				PosMod[2] = Lerp(FT * 15, PosMod[2], sin1 * 2 * move * self.ViewModelMovementScale)
				PosMod[3] = Lerp(FT * 15, PosMod[3], math.atan(cos1, sin1) * 5 * move * self.ViewModelMovementScale)
			else
				if self.MoveType == 2 then
					tan = math.atan(cos1 * sin1, cos1 * sin1)
					
					AngMod[1] = Lerp(FT * 15, AngMod[1], tan * 6 * move * self.ViewModelMovementScale)
					AngMod[2] = Lerp(FT * 15, AngMod[2], cos1 * 1.5 * move * self.ViewModelMovementScale)
					AngMod[3] = Lerp(FT * 15, AngMod[3], cos1 * -4 * move * self.ViewModelMovementScale)
					PosMod[1] = Lerp(FT * 15, PosMod[1], tan * 4 * move * self.ViewModelMovementScale)
					PosMod[2] = Lerp(FT * 15, PosMod[2], cos1 * 2 * move * self.ViewModelMovementScale)
					PosMod[3] = Lerp(FT * 15, PosMod[3], math.atan(cos1, sin1) * 5 * move * self.ViewModelMovementScale)
				elseif self.MoveType == 3 then
					tan = math.atan(cos1 * sin1, cos1 * sin1)
					AngMod[1] = Lerp(FT * 15, AngMod[1], tan * 4 * move * self.ViewModelMovementScale)
					AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * 1.5 * move * self.ViewModelMovementScale)
					AngMod[3] = Lerp(FT * 15, AngMod[3], tan * -4 * move * self.ViewModelMovementScale)
					PosMod[1] = Lerp(FT * 15, PosMod[1], tan * 2 * move * self.ViewModelMovementScale)
					PosMod[2] = Lerp(FT * 15, PosMod[2], sin1 * 2 * move * self.ViewModelMovementScale)
					PosMod[3] = Lerp(FT * 15, PosMod[3], math.atan(cos1, sin1) * 5 * move * self.ViewModelMovementScale)
				else
					AngMod[1] = Lerp(FT * 15, AngMod[1], cos1 * -2.5 * move * self.ViewModelMovementScale)
					AngMod[2] = Lerp(FT * 15, AngMod[2], sin1 * -1.5 * move * self.ViewModelMovementScale)
					AngMod[3] = Lerp(FT * 15, AngMod[3], sin1 * -1.5 * move * self.ViewModelMovementScale)
					PosMod[1] = Lerp(FT * 15, PosMod[1], math.atan(cos1, sin1) * 3 * move * self.ViewModelMovementScale)
					PosMod[2] = Lerp(FT * 15, PosMod[2], cos1 * 5 * move * self.ViewModelMovementScale)
					PosMod[3] = Lerp(FT * 15, PosMod[3], sin1 * cos1 * 9 * move * self.ViewModelMovementScale)
				end
			end
		else
			
			if self:GetIsCustomizing() then
				TargetPos = self.CustomizePos * 1
				TargetAng = self.CustomizeAng * 1
			else
				if self.FireMode == "safe" then
					TargetPos = self.SafePos * 1
					TargetAng = self.SafeAng * 1
				end
			end
			
			if !self:GetIsReloading() and self:GetIsNearWall() and !self:GetIsCustomizing() then -- NearWall
				td.start = self.Owner:GetShootPos()
				td.endpos = td.start + self.Owner:EyeAngles():Forward() * 30
				td.filter = self.Owner
				
				tr = util.TraceLine(td)
				if tr.Hit or (IsValid(tr.Entity) and not tr.Entity:IsPlayer()) then				
					TargetPos = self.NearWallPos * ( (1.04 - tr.Fraction)*2 )
					TargetAng = self.NearWallAng * ( (1.04 - tr.Fraction)*2 )
				end
			end
			
			BlendSpeed = math.Approach(BlendSpeed, 12, FT * 300)
			
			if len > 30 and ong then
				move = math.Clamp(len / self.Owner:GetWalkSpeed(), 0, 1)
				
				if self.Owner:Crouching() then
					cos1, sin1 = math.cos(CT * 6), math.sin(CT * 6)
					tan = math.atan(cos1 * sin1, cos1 * sin1)
				else
					cos1, sin1 = math.cos(CT * 8.5), math.sin(CT * 8.5)
					tan = math.atan(cos1 * sin1, cos1 * sin1)
				end
				
				TargetAng[1] = TargetAng[1] + self:scaleMovement(tan * 2) * move
				TargetAng[2] = TargetAng[2] + self:scaleMovement(cos1) * move
				TargetAng[3] = TargetAng[3] + self:scaleMovement(sin1) * move
				
				TargetPos[1] = TargetPos[1] + self:scaleMovement(sin1 * 0.1) * move
				TargetPos[2] = TargetPos[2] + self:scaleMovement(tan * 0.2) * move
				TargetPos[3] = TargetPos[3] + self:scaleMovement(tan * 0.1) * move
			else
				if !self:GetIron() and !self:IsBipodDeployed() then
					cos1, sin1 = math.cos(CT), math.sin(CT)
					tan = math.atan(cos1 * sin1, cos1 * sin1)
					
					TargetAng[1] = TargetAng[1] + tan * 1.15
					TargetAng[2] = TargetAng[2] + cos1 * 0.4
					TargetAng[3] = TargetAng[3] + tan
					
					TargetPos[2] = TargetPos[2] + tan * 0.2
				end
			end
			
			AngMod = PHUNBASE_LerpVector(FT * 10, AngMod, Vec0)
			PosMod = PHUNBASE_LerpVector(FT * 10, PosMod, Vec0)
		end
		
		-- the viewmodel movement position of the weapon
		CurPosMod = PHUNBASE_LerpVector(FT * 10, CurPosMod, PosMod)
		CurAngMod = PHUNBASE_LerpVector(FT * 10, CurAngMod, AngMod)
		
		if self.LuaViewmodelRecoil then
			-- the 'fake' viewmodel weapon recoil should only be reset if the weapon in question is using it 
			self.RecoilRestoreSpeed = math.Approach(self.RecoilRestoreSpeed, 10, FT * 10)
			self.RecoilPos2 = PHUNBASE_LerpVector(FT * self.RecoilRestoreSpeed * 0.9, self.RecoilPos2, self.RecoilPos)
			self.RecoilAng2 = PHUNBASE_LerpAngle(FT * self.RecoilRestoreSpeed * 0.9, self.RecoilAng2, self.RecoilAng)
			
			self.RecoilPosDiff.x = self.RecoilPos.x - self.RecoilPos2.x
			self.RecoilPosDiff.y = self.RecoilPos.y - self.RecoilPos2.y
			self.RecoilPosDiff.z = self.RecoilPos.z - self.RecoilPos2.z
			
			self.RecoilAngDiff.x = self.RecoilAng.x - self.RecoilAng2.x
			self.RecoilAngDiff.y = self.RecoilAng.y - self.RecoilAng2.y
			self.RecoilAngDiff.z = self.RecoilAng.z - self.RecoilAng2.z
			
			self.RecoilPos = PHUNBASE_LerpVector(FT * self.RecoilRestoreSpeed, self.RecoilPos, Vec0 + self.RecoilPosDiff)
			self.RecoilAng = PHUNBASE_LerpAngle(FT * self.RecoilRestoreSpeed, self.RecoilAng, Ang0 + self.RecoilAngDiff)
		end
		
		-- the 'fake' viewmodel recoil from shooting while aiming
		self.FireMove = PHUNBASE_Lerp(FT * 15, self.FireMove, 0)
		
		mod = 1 // intensity modifier
		
		if self:GetIron() then
			mod = 0.25
		end
		
		if self:GetIsSprinting() then
			mod = self.SprintShakeMod
		end
		
		if self:GetIsReloading() then
			mod = 0.05
		end
		
		if GetConVar("phunbase_vm_crouchoffset"):GetInt() > 0 then
			if ong and (self.Owner:Crouching() or self.Owner:KeyDown(IN_DUCK)) and !self:GetIron() then
				TargetPos[3] = TargetPos[3] - 0.5
				TargetPos[1] = TargetPos[1] - 0.5
				TargetPos[2] = TargetPos[2] - 0.5
			end
		end
		
		// bipod
		-- if LEGACYBIPOD then
			if self:ShouldBeUsingBipodOffsets() then
				dif1 = math.AngleDifference(self.BipodDeployAngle.y, EA.y)
				dif2 = math.AngleDifference(self.BipodDeployAngle.p, EA.p)
				
				if !self:GetIron() then
					TargetPos[1] = TargetPos[1] - 0.5
					TargetPos[2] = TargetPos[2] + 1.5
					TargetPos[3] = TargetPos[3] - 1.5
				end
				
				if CT < self.BipodMoveTime then
					self.BipodPos[1] = math.Approach(self.BipodPos[1], dif1 * 0.3, FT * 5)
					self.BipodPos[3] = math.Approach(self.BipodPos[3], dif2 * 0.3, FT * 5)
					
					self.BipodAng[1] = math.Approach(self.BipodAng[1], dif1 * 0.1, FT * 5)
					self.BipodAng[3] = math.Approach(self.BipodAng[3], dif2 * 0.1, FT * 5)
				else
					if self:GetIron() then			
						self.BipodPos = LerpVector(FT * 10, self.BipodPos, Vec0)
						self.BipodAng = LerpVector(FT * 10, self.BipodAng, Vec0)
					else
						self.BipodPos[1] = dif1 * 0.3
						self.BipodPos[3] = dif2 * 0.3
						
						self.BipodAng[1] = dif1 * 0.1
						self.BipodAng[3] = dif2 * 0.1
					end
				end
			else
				self.BipodPos = LerpVector(FT * 10, self.BipodPos, Vec0)
				self.BipodAng = LerpVector(FT * 10, self.BipodAng, Vec0)
				self.BipodMoveTime = CT + 0.2
			end
		-- else
			-- self.BipodPos[1] = 0
			-- self.BipodPos[3] = 0
			
			-- self.BipodAng[1] = 0
			-- self.BipodAng[3] = 0
		-- end
		
		if self.ViewModelFlip then
			TargetPos.x = -TargetPos.x
		end
		
		veldepend.roll = math.Clamp((vel:DotProduct(EA:Right()) * 0.04) * len / self.Owner:GetWalkSpeed(), -5, 5)
		
		self.BlendPos[1] = Lerp(FT * BlendSpeed, self.BlendPos[1], TargetPos[1] + self.AngleDelta.y * (0.15 * mod))
		self.BlendPos[2] = Lerp(FT * BlendSpeed * 0.6, self.BlendPos[2], TargetPos[2])
		self.BlendPos[3] = Lerp(FT * BlendSpeed * 0.75, self.BlendPos[3], TargetPos[3] + self.AngleDelta.p * (0.2 * mod) + math.abs(self.AngleDelta.y) * (0.02 * mod))
		
		self.BlendAng[1] = Lerp(FT * BlendSpeed * 0.75, self.BlendAng[1], TargetAng[1] + AngMod[1] - self.AngleDelta.p * (1.5 * mod))
		self.BlendAng[2] = Lerp(FT * BlendSpeed, self.BlendAng[2], TargetAng[2] + AngMod[2] + self.AngleDelta.y * (0.3 * mod))
		self.BlendAng[3] = Lerp(FT * BlendSpeed, self.BlendAng[3], TargetAng[3] + AngMod[3] + self.AngleDelta.y * (0.6 * mod) + veldepend.roll)
		
		EA = EA * 1
		RotateAroundAxis(EA, Right(EA), self.BlendAng[1] + PosMod[1] + self.BipodAng[3] + self.RecoilAng.p)
		RotateAroundAxis(EA, Up(EA), self.BlendAng[2] + PosMod[2] - self.BipodAng[1] + self.RecoilAng.y)
		RotateAroundAxis(EA, Forward(EA), self.BlendAng[3] + PosMod[3] + self.RecoilAng.r)
		
		EP = EP + (self.BlendPos[1] - self.BipodPos[1] + self.RecoilPos.z) * Right(EA)
		EP = EP + (self.BlendPos[2] - self.FireMove - self.RecoilPos.y) * Forward(EA)
		EP = EP + (self.BlendPos[3] - self.BipodPos[3] - self.RecoilPos.z) * Up(EA)

		-- then we apply the viewmodel movement
		RotateAroundAxis(EA, Right(EA), CurAngMod.x )
		RotateAroundAxis(EA, Up(EA), CurAngMod.y)
		RotateAroundAxis(EA, Forward(EA), CurAngMod.z)
		
		EP = EP + (CurPosMod.x + self.RecoilAng.y) * Right(EA) * mod
		EP = EP + (CurPosMod.y) * Forward(EA) * mod
		EP = EP + (CurPosMod.z) * Up(EA) * mod
		
		self.PB_VMPOS, self.PB_VMANG = EP, EA
		
		self.VM:SetPos(self.PB_VMPOS)
		self.VM:SetAngles(self.PB_VMANG)
		
		self.RealViewModel:SetPos(self.PB_VMPOS)
		self.RealViewModel:SetAngles(self.PB_VMANG)
		self.RealViewModel:SetPredictable(false)
	end
	
end
