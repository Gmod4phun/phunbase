local bullet = {}

function SWEP:GetMuzzleOrigin()
	return self.Owner:GetShootPos()
end

function SWEP:CalcSpread()
	local BaseSpread = (self:GetIron() and self.Spread_Iron or self.Spread)
	local VelocityMul = (self.Owner:GetVelocity():Length()/10000) * (self:GetIron() and self.SpreadVel_Iron or self.SpreadVel)
	local SpreadAdd = (math.max(-self.Owner:GetViewPunchAngles().p, 0)/50) * (self:GetIron() and self.SpreadAdd_Iron or self.SpreadAdd)

	return (BaseSpread) + VelocityMul + SpreadAdd
end

function SWEP:_FireBullets(num)
	local src = self:GetMuzzleOrigin()
	local ang = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()

	local spread = self:CalcSpread()

	bullet.Num 		= num or self.Primary.Bullets
	bullet.Src 		= src
	bullet.Dir 		= ang:Forward()
	bullet.Spread 	= Vector(spread, spread, spread)
	bullet.Tracer	= 0
	bullet.TracerName = "Tracer"
	bullet.Force	= self.Primary.Force
	bullet.Damage	= self.Primary.Damage
	bullet.PenTime 	= 0
	bullet.Callback	= function(attacker, tr, dmginfo)
		return bullet:penetrate(attacker, tr, dmginfo)
	end

	self.Owner:FireBullets(bullet)
end

local Density = {
	[MAT_GLASS] = 4,
	[MAT_PLASTIC] = 3.5,
	[MAT_WOOD] = 2,
	[MAT_FLESH] = 4,
	[MAT_ALIENFLESH] = 4,
	[MAT_METAL] = 1,
	[MAT_CONCRETE] = 2
}

local Decal = {
	[MAT_ALIENFLESH] = "Impact.BloodyFlesh",
	[MAT_ANTLION] = "Impact.Antlion",
	[MAT_BLOODYFLESH] = "Impact.BloodyFlesh",
	[MAT_COMPUTER] = "Impact.Metal",
	[MAT_CONCRETE] = "Impact.Concrete",
	[MAT_DIRT] = "Impact.Concrete",
	[MAT_EGGSHELL] = "Impact.Sand",
	[MAT_FLESH] = "Impact.BloodyFlesh",
	[MAT_FOLIAGE] = "Impact.Concrete",
	[MAT_GLASS] = "Impact.Glass",
	[MAT_GRATE] = "Impact.Metal",
	[MAT_SNOW] = "Impact.Concrete",
	[MAT_METAL] = "Impact.Metal",
	[MAT_PLASTIC] = "Impact.Concrete",
	[MAT_SAND] = "Impact.Sand",
	[MAT_SLOSH] = "Impact.BloodyFlesh",
	[MAT_TILE] = "Impact.Concrete",
	[MAT_GRASS] = "Impact.Concrete",
	[MAT_VENT] = "Impact.Metal",
	[MAT_WOOD] = "Impact.Wood",
	[MAT_DEFAULT] = "Impact.Concrete",
	[MAT_WARPSHIELD] = "BulletProof"
}

function bullet:penetrate(attacker, tr, dmginfo)

	if self.PenTime > 5 then return end

	local maxPenetration = self.Force

	local density = Density[tr.MatType] or 3
	local penPos = tr.Normal * (maxPenetration*(density*2))
	
	local trace 	= {}
	trace.endpos 	= tr.HitPos
	trace.start 	= tr.HitPos + penPos
	trace.mask 		= MASK_SHOT
	trace.filter 	= {}
	
	trace 	= util.TraceLine(trace)
	
	if (trace.StartSolid or trace.Fraction >= 1.0 or tr.Fraction <= 0.0) then return end
	
	local penDamage = (density/4)
	
	self.Num 		= 1
	self.Src 		= trace.HitPos
	self.Dir 		= tr.Normal
	self.Spread 	= Vector(0, 0, 0)
	self.Tracer 	= 0
	self.Force		= self.Force * 0.33
	self.PenTime 	= self.PenTime + 1
	self.Damage		= (dmginfo:GetDamage() * penDamage)
	self.Callback   = function(a, b, c) self:penetrate(a, b, c) end
	
	if IsFirstTimePredicted() then
		timer.Simple(0.001, function() 
			attacker.FireBullets(attacker, self, true)
			util.Decal( Decal[tr.MatType] or "Impact.Concrete", trace.HitPos + tr.Normal * 2, trace.HitPos - tr.Normal * 8 )
		end)
	end
end

/*
local Dir, Dir2, Src, Cone
local bul, tr = {}, {}
local Vec0 = Vector(0, 0, 0)

function SWEP:GetMuzzleOrigin()
	return self.Owner:GetShootPos()
end

function SWEP:_FireBullets()
	Src = self:GetMuzzleOrigin()
	Cone = self.Primary.Cone
	
	if self.Owner:IsPlayer() and self.Owner:Crouching() then
		Cone = Cone * 0.85
	end
	
	if self.Owner:IsPlayer() then
		Dir = (self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles() + Angle(math.Rand(-Cone, Cone), math.Rand(-Cone, Cone), 0) * 25):Forward()
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
		bul.Damage = self.Primary.Damage / (self.Primary.Bullets / 2)
		--bul.Callback = self.bulletCallback
		
		self.Owner:FireBullets(bul)
	end
end



-- PENETRATING BULLETS


if 1 == 1 then return end

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
*/
