include("shared.lua")

local displayColor = Color(255,255,255,255)

local startHeight = 36
local spacing = 36

function ENT:Draw()
	self:DrawModel()
	
	local ply = LocalPlayer()

	if ply:GetPos():Distance(self:GetPos()) > 256 then
		return
	end
	
	local pos, ang = self:GetPos(), self:GetAngles()
	
	pos = pos + ang:Forward() * 5.6
	pos = pos + ang:Up() * 6.5
	
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Right(), -90)
	
	local displayName = PHUNBASE.registeredAmmoTypes[self.AmmoType]
	local displayCount = PHUNBASE.registeredAmmoCounts[self.AmmoType]
	
	cam.Start3D2D(pos, ang, 0.05)
		PHUNBASE.drawShadowText(displayCount.."x", "PB_HUD_FONT_48", 0, -startHeight, displayColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2)
		PHUNBASE.drawShadowText(displayName, "PB_HUD_FONT_48", 0, -startHeight + spacing, displayColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2)
		PHUNBASE.drawShadowText("rounds", "PB_HUD_FONT_48", 0, -startHeight + spacing*2, displayColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2)
	cam.End3D2D()
end
