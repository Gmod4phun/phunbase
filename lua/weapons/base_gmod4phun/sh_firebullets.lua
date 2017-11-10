
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
