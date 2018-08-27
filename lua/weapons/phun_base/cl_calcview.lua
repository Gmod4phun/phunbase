// experimental calcview stuff

SWEP.ViewbobEnabled = true
SWEP.ViewbobIntensity = 1.5

SWEP.FOV_IronMod = 10

local cos1, cos2, FT, CT, engineFov
local curviewbob, Ang0 = Angle(), Angle()

function SWEP:HandleExtraCalcView(ply, pos, ang, fov) // additional calcview for adding stuff like attachment/bone related view movement without overriding the base view bobbing
	return pos, ang, fov
end

function SWEP:CalcView(ply, pos, ang, fov) // base view bobbing, you should not override this unless you know what you are doing
	FT, CT = FrameTime(), CurTime()
	
	if self.ViewbobEnabled then
		local ws = ply:GetWalkSpeed()
		local vel = ply:GetVelocity():Length()
		
		if ply:OnGround() and vel > ws * 0.3 then
			if vel < ws * 1.2 then
				cos1 = math.cos(CT * 15)
				cos2 = math.cos(CT * 12)
				curviewbob.p = cos1 * 0.15
				curviewbob.y = cos2 * 0.1
			else
				cos1 = math.cos(CT * 20)
				cos2 = math.cos(CT * 15)
				curviewbob.p = cos1 * 0.25
				curviewbob.y = cos2 * 0.15
			end
		else
			curviewbob = LerpAngle(FT * 10, curviewbob, Ang0)
		end
	else
		curviewbob = LerpAngle(FT * 10, curviewbob, Ang0)
	end
	
	engineFov = GetConVar("fov_desired"):GetInt()
	targetFov = PHUNBASE_Lerp(FT * 10, targetFov or engineFov, self:GetIron() and engineFov - self.FOV_IronMod or engineFov)
	
	local newP, newA, newF = pos, ang + curviewbob * self.ViewbobIntensity, targetFov
	
	newP, newA, newF = self:HandleExtraCalcView(ply, newP, newA, newF)
	
	self.currentFOV = newF
	
	return newP, newA, newF
end
