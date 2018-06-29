include("shared.lua")

-- function ENT:Initialize()
	-- killicon.AddFont(self.ClassName, "pb_killicon_font", self.PrintName, Color(255,255,255,255))
-- end
	
function ENT:Draw()
	self:DrawModel()
end
