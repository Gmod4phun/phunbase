// some code from cw 2.0

if CLIENT then
	CreateMaterial("PHUNBASE_INVIS_MAT", "UnlitGeneric", {["$no_draw"] = "1"}) // convenience material
end

SWEP.BlendPos = Vector(0, 0, 0)
SWEP.BlendAng = Vector(0, 0, 0)
SWEP.OldDelta = Angle(0, 0, 0)
SWEP.AngleDelta = Angle(0, 0, 0)
SWEP.AngleDelta2 = Angle(0, 0, 0)
SWEP.AngDiff = Angle(0, 0, 0)
SWEP.RecoilPos = Vector(0, 0, 0)
SWEP.RecoilAng = Angle(0, 0, 0)
SWEP.RecoilPos2 = Vector(0, 0, 0)
SWEP.RecoilAng2 = Angle(0, 0, 0)
SWEP.RecoilPosDiff = Vector(0, 0, 0)
SWEP.RecoilAngDiff = Angle(0, 0, 0)
SWEP.GrenadePos = Vector(0, 0, -10)
SWEP.FireMove = 0
SWEP.ViewModelMovementScale = 1
SWEP.RecoilRestoreSpeed = 5
SWEP.Sequence = ""
SWEP.Cycle = 0
SWEP.NoStockShells = true
SWEP.NoStockMuzzle = true
SWEP.SprintViewNormals = {x = 1, y = 1, z = 1}

local Vec0, Ang0 = Vector(0, 0, 0), Angle(0, 0, 0)
local TargetPos, TargetAng, cos1, sin1, tan, ws, rs, mod, EA, EA2, delta, sin2, mul, vm, muz, muz2, tr, att, CT
local td = {}
local LerpVector, LerpAngle, Lerp = LerpVector, LerpAngle, Lerp

local reg = debug.getregistry()
local Right = reg.Angle.Right
local Up = reg.Angle.Up
local Forward = reg.Angle.Forward
local RotateAroundAxis = reg.Angle.RotateAroundAxis

SWEP.ApproachSpeed = 10
SWEP.RunTime = 0
local SP = game.SinglePlayer() 
local PosMod, AngMod = Vector(0, 0, 0), Vector(0, 0, 0)
local CurPosMod, CurAngMod = Vector(0, 0, 0), Vector(0, 0, 0)
local veldepend = {pitch = 0, yaw = 0, roll = 0}
local mod2 = 0

local PB_VMPOS, PB_VMANG

function SWEP:scaleMovement(val, mod)
	if !mod then mod = 1 end
	return val * self.ViewModelMovementScale * mod
end

-- since these are often-called functions (and somewhat expensive), we make local references to them to reduce the overhead as much as possible
local ManipulateBonePosition, ManipulateBoneAngles = reg.Entity.ManipulateBonePosition, reg.Entity.ManipulateBoneAngles

-- default GMod LerpVector/LerpAngle generate a new vector/angle object every time they're called (wtf garry ???), so I wrote my own to keep garbage generation low
function PHUNBASE_LerpVector(delta, start, finish)
	delta = delta > 1 and 1 or delta
	
	start.x = start.x + delta * (finish.x - start.x)
	start.y = start.y + delta * (finish.y - start.y)
	start.z = start.z + delta * (finish.z - start.z)
	
	return start
end

function PHUNBASE_LerpAngle(delta, start, finish)
	delta = delta > 1 and 1 or delta

	start.p = start.p + delta * (finish.p - start.p)
	start.y = start.y + delta * (finish.y - start.y)
	start.r = start.r + delta * (finish.r - start.r)
	
	return start
end

function PHUNBASE_Lerp(val, min, max) -- basically a wrapper that limits 'val' (aka progress) to a max of 1
	val = val > 1 and 1 or val
	return Lerp(val, min, max)
end

local AngleTable = Angle(0,0,0)
function SWEP:processSwayDelta(deltaTime, eyeAngles)
	delta = Angle(eyeAngles.p, eyeAngles.y, 0) - self.OldDelta
	delta.p = math.Clamp(delta.p, -10, 10)
	
	AngleTable.p = eyeAngles.P
	AngleTable.y = eyeAngles.Y
	delta = AngleTable - self.OldDelta
		
	self.OldDelta.p = eyeAngles.p
	self.OldDelta.y = eyeAngles.y
	
	local FT = deltaTime
	
	if self.SwayInterpolation == "linear" then
		self.AngleDelta = LerpAngle(math.Clamp(FT * 15, 0, 1), self.AngleDelta, delta)
		self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -15, 15)
	else
		delta.p = math.Clamp(delta.p, -5, 5)
		self.AngleDelta2 = LerpAngle(math.Clamp(FT * 12, 0, 1), self.AngleDelta2, self.AngleDelta)
		self.AngDiff.p = (self.AngleDelta.p - self.AngleDelta2.p)
		self.AngDiff.y = (self.AngleDelta.y - self.AngleDelta2.y)
		self.AngleDelta = LerpAngle(math.Clamp(FT * 10, 0, 1), self.AngleDelta, delta + self.AngDiff)
		self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -25, 25)
	end
	
	self.OldDelta.p = eyeAngles.p
	self.OldDelta.y = eyeAngles.y
end

function SWEP:processFOVChanges(deltaTime)
	if self:GetIron() then
		self.CurVMFOV = PHUNBASE_Lerp(deltaTime * 10, self.CurVMFOV, self.AimViewModelFOV)
	else
		self.CurVMFOV = PHUNBASE_Lerp(deltaTime * 10, self.CurVMFOV, self.ViewModelFOV_Orig)
	end
	
	self.ViewModelFOV = self.CurVMFOV
end

function SWEP:performViewmodelMovement_old() // old, CW 2.0 vm movement
	CT = UnPredictedCurTime()
	vm = self.VM
	
	self.Cycle = vm:GetCycle()
	self.Sequence = vm:GetSequenceName(vm:GetSequence())
	
	local FT = FrameTime()
	local EA = EyeAngles()
	
	self:processSwayDelta(FT, EA)
	
	EA = EyeAngles()
	self:processFOVChanges(FT)
	
	vel = self.Owner:GetVelocity()
	len = vel:Length()
	ws = self.Owner:GetWalkSpeed()
	
	PosMod, AngMod = Vec0 * 1, Vec0 * 1
	mod2 = 1
	
	veldepend.roll = math.Clamp((vel:DotProduct(EA:Right()) * 0.04) * len / ws, -5, 5)
	
	if self:GetIron() then
		-- aim VM movement modifiers
		mod2 = 1

		TargetPos, TargetAng = self.IronsightPos * 1, self.IronsightAng * 1

		self.ApproachSpeed = math.Approach(self.ApproachSpeed, 10, FT * 300)
		CurPosMod, CurAngMod = Vec0 * 1, Vec0 * 1
		
	elseif self:GetIsUnderwater() or self:GetIsOnLadder() then
		-- ladder climb/swim movement modifiers
		TargetPos, TargetAng = self.InactivePos * 1, self.InactiveAng * 1
		self.ApproachSpeed = math.Approach(self.ApproachSpeed, 5, FT * 100)
		
	elseif self:GetIsSprinting() then
		local runMod = 1
		
		-- if we're running and our movement speed is fit for run movement speed
		if self:GetIsReloading() then
			-- if we're reloading, then go back to the 'gun forward' position
			TargetPos, TargetAng = self.BasePos * 1, self.BaseAng * 1
			self.ApproachSpeed = math.Approach(self.ApproachSpeed, 4, FT * 100)
			runMod = 0.25
		else
			TargetPos, TargetAng = self.SprintPos * 1, self.SprintAng * 1
			self.ApproachSpeed = math.Approach(self.ApproachSpeed, 5, FT * 200)
		end
		
		-- move the weapon away if the player is looking up/down while sprinting
		local verticalOffset = EyeAngles().p * 0.4 * runMod
		TargetAng.x = TargetAng.x - math.Clamp(verticalOffset, 0, 10) * self.SprintViewNormals.x
		TargetAng.y = TargetAng.y - verticalOffset * 0.5 * self.SprintViewNormals.y
		TargetAng.z = TargetAng.z - verticalOffset * 0.2 * self.SprintViewNormals.z
		TargetPos.z = TargetPos.z + math.Clamp(verticalOffset * 0.2, -10, 3)
		
		rs = self.Owner:GetRunSpeed()
		mul = math.Clamp(len / rs, 0, 1)
		
		self.RunTime = self.RunTime + FT * (7.5 + math.Clamp(len / 120, 0, 5))
		local runTime = self.RunTime
		sin1 = math.sin(runTime) * mul
		cos1 = math.cos(runTime) * mul
		tan1 = math.atan(cos1 * sin1, cos1 * sin1) * mul

		if self.PistolSprintSway then
			AngMod.x = AngMod.x + tan1 * 0.2 * self.ViewModelMovementScale * mul
			AngMod.y = AngMod.y - cos1 * 3 * self.ViewModelMovementScale * mul
			AngMod.z = AngMod.z + cos1 * 3 * self.ViewModelMovementScale * mul
			PosMod.x = PosMod.x - sin1 * 0.8 * self.ViewModelMovementScale * mul
			PosMod.y = PosMod.y + tan1 * 1.8 * self.ViewModelMovementScale * mul
			PosMod.z = PosMod.z + tan1 * 1.5 * self.ViewModelMovementScale * mul
		else
			AngMod.x = AngMod.x + tan1 * self.ViewModelMovementScale * mul
			AngMod.y = AngMod.y - sin1 * -10 * self.ViewModelMovementScale * mul
			AngMod.z = AngMod.z + cos1 * 4 * self.ViewModelMovementScale * mul
			
			PosMod.x = PosMod.x - cos1 * 0.6 * self.ViewModelMovementScale * mul
			PosMod.y = PosMod.y + sin1 * 0.6 * self.ViewModelMovementScale * mul
			PosMod.z = PosMod.z + tan1 * 2 * self.ViewModelMovementScale * mul
		end
		
	else
		if self.BasePos and self.BaseAng then
			TargetPos, TargetAng = self.BasePos * 1, self.BaseAng * 1
		else
			TargetPos, TargetAng = Vec0 * 1, Vec0 * 1
		end

		if !self:GetIsReloading() and self:GetIsNearWall() then -- NearWall
			-- get anything in front of us, if there is something, enable near wall
			td.start = self.Owner:GetShootPos()
			td.endpos = td.start + self.Owner:EyeAngles():Forward() * 30
			td.filter = self.Owner
			
			tr = util.TraceLine(td)
			if tr.Hit or (IsValid(tr.Entity) and not tr.Entity:IsPlayer()) then				
				TargetPos = self.NearWallPos * ( (1.04 - tr.Fraction)*2 )
				TargetAng = self.NearWallAng * ( (1.04 - tr.Fraction)*2 )
			end
		end
		
		self.ApproachSpeed = math.Approach(self.ApproachSpeed, 10, FT * 100)

	end
	
	if self:GetIsDeploying() and !self:GetIsSprinting() then
		TargetPos, TargetAng = self.BasePos * 1, self.BaseAng * 1
		self.ApproachSpeed = math.Approach(self.ApproachSpeed, 5, FT * 100)
	end
	
	if len < 10 or not self.Owner:OnGround() then
		-- idle viewmodel movement
		if !self:GetIron() then
			cos1, sin1 = math.cos(CT), math.sin(CT)
			tan = math.atan(cos1 * sin1, cos1 * sin1)
			
			AngMod.x = AngMod.x + tan * 1.15
			AngMod.y = AngMod.y + cos1 * 0.4
			AngMod.z = AngMod.z + tan
			
			PosMod.y = PosMod.y + tan * 0.2 * mod2
		end
	elseif len > 10 and len < ws * 1.2 then
		-- walk viewmodel movement
		mod = 6 + ws / 130
		mul = math.Clamp(len / ws, 0, 1)
		
		if self:GetIron() then
			mul = mul * 0.5
		end
		
		sin1 = math.sin(CT * mod) * mul
		cos1 = math.cos(CT * mod) * mul
		tan1 = math.atan(cos1 * sin1, cos1 * sin1) * mul
		
		local xMod = 1
		
		if self.ViewModelFlip then
			xMod = -1
		end
		
		AngMod.x = AngMod.x + self:scaleMovement(tan1 * 2, mod2) -- up/down
		AngMod.y = AngMod.y + self:scaleMovement(cos1, mod2) -- left/right
		AngMod.z = AngMod.z + self:scaleMovement(sin1, mod2) -- rotation left/right
		
		PosMod.x = PosMod.x + self:scaleMovement(sin1 * 0.1, mod2) -- left/right
		PosMod.y = PosMod.y + self:scaleMovement(tan1 * 0.4, mod2) -- forward/backwards
		PosMod.z = PosMod.z - self:scaleMovement(tan1 * 0.1, mod2) -- up/down
		
		-- apply viewmodel tilt when moving and not aiming based on velocity dot product relative to aim direction
		local norm = math.Clamp(vel:GetNormal():DotProduct(self.Owner:EyeAngles():Forward()), 0, 1)
		
		if !self:GetIron() then
			TargetPos[2] = TargetPos[2] - mul * 0.8 * norm
			TargetPos[3] = TargetPos[3] - mul * 0.5 * norm
		end
	end
	
	FT = FrameTime()
	
	if self.ViewModelFlip then
		TargetAng.z = TargetAng.z - veldepend.roll
	else
		TargetAng.z = TargetAng.z + veldepend.roll
	end
	
	-- the position of the weapon (running/walking/aiming)
	self.BlendPos = PHUNBASE_LerpVector(FT * self.ApproachSpeed, self.BlendPos, TargetPos)
	self.BlendAng = PHUNBASE_LerpVector(FT * self.ApproachSpeed, self.BlendAng, TargetAng)
	
	-- the viewmodel movement position of the weapon
	CurPosMod = PHUNBASE_LerpVector(FT * 10, CurPosMod, PosMod)
	CurAngMod = PHUNBASE_LerpVector(FT * 10, CurAngMod, AngMod)
	
	-- the 'fake' weapon recoil
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

end

function SWEP:makeVMRecoil(mod)
	mod = mod or 1
	
	/*if self:GetIron() then
		mod = 0
	end*/
	
	-- make the recoil get stronger as the player spends more time firing the weapon non-stop
	local overallMul = 0.25 + 0.75 * self.LuaVMRecoilIntensity * self.LuaVMRecoilMod
	
	-- get the offset multipliers
	local vertMul = math.Rand(0.3, 0.4) * overallMul * 2 * mod
	local forwardMul = math.Rand(0.75, 0.85) * overallMul  * mod
	local sideMul = math.Rand(-0.2, 0.2) * overallMul * 0.5 * mod
	local rollMul = math.Rand(-0.25, 0.25) * overallMul * 5 * mod
	
	-- clamp the maximum kick
	local strength = math.Clamp(self.Recoil, 0.3, 1.8)
	
	self.RecoilRestoreSpeed = 5
	self.RecoilPos.x = strength * sideMul * self.LuaVMRecoilAxisMod.hor
	self.RecoilPos.y = strength * forwardMul * 2 * self.LuaVMRecoilAxisMod.forward --math.Rand(self.Recoil * 0.75, self.Recoil)
	self.RecoilPos.z = strength * vertMul * self.LuaVMRecoilAxisMod.vert
	
	self.RecoilAng.p = strength * vertMul * 5 * self.LuaVMRecoilAxisMod.pitch
	self.RecoilAng.y = strength * sideMul * self.LuaVMRecoilAxisMod.hor --math.Rand(-self.Recoil, self.Recoil) * 0.1
	self.RecoilAng.r = strength * rollMul * self.LuaVMRecoilAxisMod.roll --math.Rand(-self.Recoil, self.Recoil) * 0.1
end

function SWEP:applyOffsetToVM()
	local CT = UnPredictedCurTime()
	
	local pos = EyePos()
	local ang = EyeAngles()
	
	RotateAroundAxis(ang, Right(ang), self.BlendAng.x + self.RecoilAng.p)
	
	local swayIntensity = 2
	
	-- first we offset the viewmodel position
	if not self.ViewModelFlip then
		RotateAroundAxis(ang, Up(ang), self.BlendAng.y + self.RecoilAng.y - self.AngleDelta.y * 0.4 * swayIntensity)
		RotateAroundAxis(ang, Forward(ang), self.BlendAng.z + self.RecoilAng.r + self.AngleDelta.y * 0.4 * swayIntensity)
	else
		RotateAroundAxis(ang, Up(ang), -self.BlendAng.y + self.RecoilAng.y - self.AngleDelta.y * 0.4 * swayIntensity)
		RotateAroundAxis(ang, Forward(ang), -self.BlendAng.z + self.RecoilAng.r + self.AngleDelta.y * 0.4 * swayIntensity)
	end

	if not self.ViewModelFlip then
		pos = pos + (self.BlendPos.x + self.AngleDelta.y * 0.05 * swayIntensity + self.RecoilPos.z) * Right(ang)
	else
		pos = pos - (self.BlendPos.x - self.AngleDelta.y * 0.05 * swayIntensity - self.RecoilPos.z) * Right(ang)
	end
	
	pos = pos + (self.BlendPos.y - self.FireMove - self.RecoilPos.y) * Forward(ang)
	pos = pos + (self.BlendPos.z - self.AngleDelta.p * 0.1 * swayIntensity - self.RecoilPos.z) * Up(ang)
	
	-- then we apply the viewmodel movement
	RotateAroundAxis(ang, Right(ang), CurAngMod.x)
	
	if not self.ViewModelFlip then
		RotateAroundAxis(ang, Up(ang), CurAngMod.y)
		RotateAroundAxis(ang, Forward(ang), CurAngMod.z)
	else
		RotateAroundAxis(ang, Up(ang), CurAngMod.y)
		RotateAroundAxis(ang, Forward(ang), CurAngMod.z)
	end
	
	if not self.ViewModelFlip then
		pos = pos + (CurPosMod.x + self.RecoilAng.y) * Right(ang)
	else
		pos = pos + (CurPosMod.x + self.RecoilAng.y) * Right(ang)
	end
	
	pos = pos + (CurPosMod.y) * Forward(ang)
	pos = pos + (CurPosMod.z) * Up(ang)
	
	self.PB_VMPOS, self.PB_VMANG = pos, ang
	
	if self.Owner.SHARPEYE_HASFOCUS and self.SHARPEYE_SUPPORT then
		self.PB_VMANG = self.SHARPEYE_VMANG
	end
	
	self.VM:SetPos(self.PB_VMPOS)
	self.VM:SetAngles(self.PB_VMANG)
	
	self.RealViewModel:SetPos(pos)
	self.RealViewModel:SetAngles(ang)
	self.RealViewModel:SetPredictable(false)
end

function SWEP:CreateClientModel(model)
	if !CLIENT then return end
	local ent = ClientsideModel(model, RENDERGROUP_BOTH)
	ent.WeaponObject = self
	PHUNBASE.cmodel:Add(ent, self)
	return ent
end

function SWEP:_IdleAnimThink()
	if !CLIENT then return end
	local vm = self.VM
	local empty = self:Clip1() == 0
	if vm:GetCycle() > 0.99999 and !string.find(self:GetActiveSequence(), "holster") then
		if !string.find(self:GetActiveSequence(), "idle") then
			if self:GetIron() then
				self:PlayVMSequence((!self:GetIsDual() and !self:GetIsReloading() and empty) and "idle_iron_empty" or "idle_iron")
			else
				self:PlayVMSequence((!self:GetIsDual() and !self:GetIsReloading() and empty) and "idle_empty" or "idle")
			end
		end
	end
end

function SWEP:InitRealViewModel()
	if CLIENT then
		self.RealViewModel = LocalPlayer():GetViewModel() // the REAL ViewModel - used for particle positions
	end
end

function SWEP:_CreateVM()
	if !CLIENT then return end
	
	self.VM = self:CreateClientModel(self.ViewModel)
	self.VM:SetNoDraw(true)
	self.VM:SetupBones()
	self.VM.IsPHUNBASEVM = true
	
	if self.ViewModelFlip then
		local mat = Matrix()
		mat:Scale(Vector(1, -1, 1))
		self.VM:EnableMatrix("RenderMultiply", mat)
	end
end

function SWEP:_GetPlayerColor()
	local owner = LocalPlayer()
	if owner:IsValid() and owner:IsPlayer() and owner.GetPlayerColor then
		return owner:GetPlayerColor()
	end

	return Vector(1, 1, 1)
end

function SWEP:_CopyBodyGroups(source, target)
	for num, _ in pairs(source:GetBodyGroups()) do
		target:SetBodygroup(num-1, source:GetBodygroup(num-1))
		target:SetSkin(source:GetSkin())
	end
end

function SWEP:_CreateHands()
	if !CLIENT then return end
	local handModel = ""
	if self.UseHands then
		if self.CustomHandsModel then
			handModel = self.CustomHandsModel
		else
			handModel = LocalPlayer():GetHands():GetModel()
		end
		self.Hands = self:CreateClientModel(handModel)
		self.Hands:SetNoDraw(true)
		self.Hands:SetupBones()
		self.Hands:SetParent(self.VM)
		self.Hands:AddEffects(EF_BONEMERGE)
		self.Hands:AddEffects(EF_BONEMERGE_FASTCULL)
		self.Hands.GetPlayerColor = self._GetPlayerColor
		self:_CopyBodyGroups(LocalPlayer():GetHands(), self.Hands)
	end
end

function SWEP:_UpdateHands()
	if SERVER then
		SendUserMessage("PHUNBASE_UMSG_UPDATEHANDS", self.Owner)
	else
		if !IsValid(self.Hands) then return end
		local ply = LocalPlayer()
		local hands = ply:GetHands()
		if !IsValid(hands) then return end
		if self.CustomHandsModel then return end
		self.Hands:SetModel(hands:GetModel())
		self:_CopyBodyGroups(hands,self.Hands)
	end
end

if CLIENT then
	local function PHUNBASE_UMSG_UPDATEHANDS()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) or not wep.PHUNBASEWEP then
			return
		end
		
		wep:_UpdateHands()
	end
	usermessage.Hook("PHUNBASE_UMSG_UPDATEHANDS", PHUNBASE_UMSG_UPDATEHANDS)
end

function SWEP:drawViewModel()
	if not self.VM then
		return
	end
	
	//self:offsetBones() // not today :)
	
	//self:applyOffsetToVM()
	self:_drawViewModel()
end

function SWEP:_drawViewModel()
	if !CLIENT then return end
	if self.ViewModelFlip then
		render.CullMode(MATERIAL_CULLMODE_CW)
	end
	
	self.VM:FrameAdvance(FrameTime())
	self.VM:SetupBones()
	self.VM:DrawModel()
	
	self:_drawHands()
	
	if self.ViewModelFlip then
		render.CullMode(MATERIAL_CULLMODE_CCW)
	end
	
	self:drawVMShells()
	self:drawAttachments()
	
	self.Cycle = self.VM:GetCycle()
	
end

function SWEP:_drawHands()
	if self.UseHands and self.Hands then
		self.Hands.GetPlayerColor = self._GetPlayerColor
		self.Hands:DrawModel()
	end
end

SWEP.BoneManipTable = {}

function SWEP:buildBoneTable()
	local vm = self.VM
	
	for i = 0, vm:GetBoneCount() - 1 do
		local boneName = vm:GetBoneName(i)
		local bone
		
		if boneName then
			bone = vm:LookupBone(boneName)
		end
		
		self.vmBones[i + 1] = {boneName = boneName, bone = bone, curPos = Vector(0, 0, 0), curAng = Angle(0, 0, 0), targetPos = Vector(0, 0, 0), targetAng = Angle(0, 0, 0)}
	end
end

function SWEP:setupBoneTable()
	self.vmBones = {}
	-- this sets up a table for things like bone position/angle manipulation
	-- we do everything in advance to avoid expensive function calls (such as LookupBone) later on
	self:buildBoneTable()
end

function SWEP:offsetBones()
	local vm = self.VM
	
	-- if the animation cycle is past reload/draw no offset time of bones, then it falls within the bone offset timeline
	local FT = FrameTime()
	
	local can = !self:IsBusy() and self.EnableBoneManipulation
	local canModifyBones = true
	
	local targetTbl = false
	
	-- select the desired offset table
	if self.BoneManipTable then
		local desiredTarget = self.BoneManipTable
		
		if desiredTarget then
			targetTbl = desiredTarget
			canModifyBones = true
		end
	end
	
	if not targetTbl then
		can = false
	end
	
	if canModifyBones then
		for k, v in pairs(self.vmBones) do
			if can then
				local index = targetTbl[v.boneName]

				v.curPos = PHUNBASE_LerpVector(FT * 15, v.curPos, (index and index.pos or Vec0))
				v.curAng = PHUNBASE_LerpAngle(FT * 15, v.curAng, (index and index.angle or Ang0))
			else
				v.curPos = PHUNBASE_LerpVector(FT * 15, v.curPos, Vec0)
				v.curAng = PHUNBASE_LerpAngle(FT * 15, v.curAng, Ang0)
			end
			
			ManipulateBonePosition(vm, v.bone, v.curPos)
			ManipulateBoneAngles(vm, v.bone, v.curAng)
		end
	end
	
end

//viewmodel fixes

function PHUNBASE.RealVM_Hide(b) // true to hide, false to restore
	if CLIENT then
		local ply = LocalPlayer()
		local vm = ply:GetViewModel()
		if b then
			if !ply.pbFixed then
				vm:SetMaterial("!PHUNBASE_INVIS_MAT", true)
				ply.pbFixed = true
			end
		else
			if ply.pbFixed then
				vm:SetMaterial(ply.oldPBVMMat, true)
				ply.pbFixed = false
			end
		end
	else
		return
	end
end

local function PHUNBASE_RealVM_Fix(ply)
	if !CLIENT then return end
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if !IsValid(wep) then return end
	
	if !wep.PHUNBASEWEP then
		ply.oldPBVMMat = ply:GetViewModel():GetMaterial()
	end

	PHUNBASE.RealVM_Hide(tobool(wep.PHUNBASEWEP))
end
hook.Add("Think","PHUNBASE_RealVM_Fix",PHUNBASE_RealVM_Fix)

local function PHUNBASE_UpdateHands(ply)
	if !CLIENT then return end
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if !IsValid(wep) then return end
	
	if !wep.PHUNBASEWEP then return end
	wep:_UpdateHands()
end
concommand.Add("pb_updatehands",PHUNBASE_UpdateHands)
