if !CLIENT then return end

local W,H = ScrW(), ScrH()
local CrosshairMat = Material("gmod4phun/kf/Scope_finall")

function SWEP:DrawHUD()
	if !self:GetIron() and !self:GetIsSprinting() and !self:IsBusy() and !self:GetIsReloading() then
		/*surface.SetMaterial(CrosshairMat)
		surface.SetDrawColor(Color(255,255,255,255))
		surface.DrawTexturedRectRotated(W/2,H/2,64,64,0)*/
	end
end