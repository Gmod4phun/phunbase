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
			util.Decal( Decal[tr.MatType] or "Impact.Concrete", trace.HitPos + tr.Normal * 0.1, trace.HitPos - tr.Normal * 2 )
		end)
	end
	
end
