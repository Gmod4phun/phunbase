if !CLIENT then return end

function SWEP:DrawHUD()
	local W, H = ScrW(), ScrH()
	surface.SetFont("PHUNBASE_HL2_SELECTICONS_2")
	local t_w, t_h = surface.GetTextSize("O")
	if self.HL2IconLetters[self:GetClass()] then
		draw.SimpleText("O", "PHUNBASE_HL2_SELECTICONS_1", W/2, H/2 - t_h/2 - ScreenScale(6), Color(255, 235, 20, alpha), TEXT_ALIGN_CENTER)
		draw.SimpleText("O", "PHUNBASE_HL2_SELECTICONS_2", W/2, H/2 - t_h/2 - ScreenScale(6), Color(255, 235, 20, alpha), TEXT_ALIGN_CENTER)
	end
end