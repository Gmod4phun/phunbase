/*
local Dir, Dir2, Src, Cone
local bul, tr = {}, {}
local Vec0 = Vector(0, 0, 0)

function SWEP:_FireBullets()
	Src = self.Owner:GetShootPos()
	Cone = self.Primary.Cone
	
	if self.Owner:IsPlayer() and self.Owner:Crouching() then
		Cone = Cone * 0.85
	end
	
	if self.Owner:IsPlayer() then
		Dir = (self.Owner:EyeAngles() + self.Owner:GetPunchAngle() + Angle(math.Rand(-Cone, Cone), math.Rand(-Cone, Cone), 0) * 25):Forward()
	elseif self.Owner:IsNPC() then
		Dir = (self.Owner:GetEnemy():GetPos() - self.Owner:GetShootPos())
	end

	for i = 1, self.Primary.Bullets do
		Dir2 = Dir
		
		if self.Primary.Spread and self.Primary.Spread > 0 then
			Dir2 = Dir + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)) * self.Primary.Spread
		end
		
		bul.Num = 1
		bul.Src = Src
		bul.Dir = Dir2
		bul.Spread 	= Vec0
		bul.Tracer	= 3
		bul.Force	= 1//self.Primary.Damage * 0.25
		bul.Damage = self.Primary.Damage
		--bul.Callback = self.bulletCallback
		
		self.Owner:FireBullets(bul)
	end
end
*/

/*
	PENETRATING BULLETS
*/

local Dir, Dir2, dot, sp, ent, trace, seed, hm

-- reminder: if I ever change these bit value masks, then I also have to update them in the physical bullets file
local trace_normal = bit.bor(CONTENTS_SOLID, CONTENTS_OPAQUE, CONTENTS_MOVEABLE, CONTENTS_DEBRIS, CONTENTS_MONSTER, CONTENTS_HITBOX, 402653442, CONTENTS_WATER)
local trace_walls = bit.bor(CONTENTS_TESTFOGVOLUME, CONTENTS_EMPTY, CONTENTS_MONSTER, CONTENTS_HITBOX)
SWEP.NoPenetration = {[MAT_SLOSH] = false}
SWEP.NoRicochet = {[MAT_FLESH] = true, [MAT_ANTLION] = true, [MAT_BLOODYFLESH] = true, [MAT_DIRT] = true, [MAT_SAND] = true, [MAT_GLASS] = true, [MAT_ALIENFLESH] = true, [MAT_GRASS] = true}
SWEP.PenetrationMaterialInteraction = {[MAT_SAND] = 0.5, [MAT_DIRT] = 0.8, [MAT_METAL] = 1.1, [MAT_TILE] = 0.9, [MAT_WOOD] = 1.2}
SWEP.PenetrativeRange = 2000
SWEP.PenStr = 20
SWEP.CanPenetrate = true
SWEP.CanRicochet = true

local bul, tr = {}, {}
local SP = game.SinglePlayer()
local zeroVec = Vector(0, 0, 0)

local reg = debug.getregistry()
local GetShootPos = reg.Player.GetShootPos

function SWEP:canPenetrate(traceData, direction)
	local dot = nil
	
	if not self.NoPenetration[traceData.MatType] then
		dot = -direction:DotProduct(traceData.HitNormal)
		ent = traceData.Entity
	
		--if not ent:IsNPC() and not ent:IsPlayer() then
			if dot > 0.26 and self.CanPenetrate then
				return true, dot
			end
		--end
	end
	
	return false, dot
end

function SWEP:canRicochet(traceData, penetrativeRange)
	penetrativeRange = penetrativeRange or self.PenetrativeRange

	if self.CanRicochet and not self.NoRicochet[traceData.MatType] and penetrativeRange * traceData.Fraction < penetrativeRange then
		return true
	end
	
	return false
end

function SWEP:_FireBullets()
	local damage, cone = self.Primary.Damage, self.Primary.Cone
	sp = GetShootPos(self.Owner)
	local commandNumber = self.Owner:GetCurrentCommand():CommandNumber()
	math.randomseed(commandNumber)
	
	if self.Owner:Crouching() then
		cone = cone * 0.85
	end
	
	if self.Owner:IsPlayer() then
		Dir = (self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles() + Angle(math.Rand(-cone, cone), math.Rand(-cone, cone), 0) * 25):Forward()
	elseif self.Owner:IsNPC() then
		Dir = (self.Owner:GetEnemy():GetPos() - self.Owner:GetShootPos())
	end
	
	Dir2 = Dir
	
	bul.Num = 1
	bul.Src = sp
	bul.Dir = Dir2
	bul.Spread 	= zeroVec --Vector(0, 0, 0)
	bul.Tracer	= 3
	bul.Force	= damage * 0.3
	bul.Damage = math.Round(damage)
	
	self.Owner:FireBullets(bul)
	
	tr.start = sp
	tr.endpos = tr.start + Dir2 * self.PenetrativeRange
	tr.filter = self.Owner
	tr.mask = trace_normal
	
	trace = util.TraceLine(tr)
		
	if trace.Hit and not trace.HitSky then
		local canPenetrate, dot = self:canPenetrate(trace, Dir2)
		//self.Owner:ChatPrint(tostring(canPenetrate, dot))
		if canPenetrate and dot > 0.26 then
			tr.start = trace.HitPos
			tr.endpos = tr.start + Dir2 * self.PenStr * (self.PenetrationMaterialInteraction[trace.MatType] and self.PenetrationMaterialInteraction[trace.MatType] or 1)
			tr.filter = self.Owner
			tr.mask = trace_walls
			
			trace = util.TraceLine(tr)
			
			tr.start = trace.HitPos
			tr.endpos = tr.start + Dir2 * 0.1
			tr.filter = self.Owner
			tr.mask = trace_normal
			
			trace = util.TraceLine(tr) -- run ANOTHER trace to check whether we've penetrated a surface or not
			
			if not trace.Hit then
				bul.Num = 1
				bul.Src = trace.HitPos
				bul.Dir = Dir2
				bul.Spread 	= Vec0
				bul.Tracer	= 4
				bul.Force	= damage * 0.15
				bul.Damage = bul.Damage * 0.5
				
				self.Owner:FireBullets(bul)
				
				bul.Num = 1
				bul.Src = trace.HitPos
				bul.Dir = -Dir2
				bul.Spread 	= Vec0
				bul.Tracer	= 4
				bul.Force	= damage * 0.15
				bul.Damage = bul.Damage * 0.5
				
				self.Owner:FireBullets(bul)
			end
		else
			if self:canRicochet(trace) then
				Dir2 = Dir2 + (trace.HitNormal * dot) * 3
				math.randomizeVector(Dir2, 0.06)
				
				bul.Num = 1
				bul.Src = trace.HitPos
				bul.Dir = Dir2
				bul.Spread 	= Vec0
				bul.Tracer	= 0
				bul.Force	= damage * 0.225
				bul.Damage = bul.Damage * 0.75
				
				self.Owner:FireBullets(bul)
			end
		end
	end
		
	tr.mask = trace_normal
end
