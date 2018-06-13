
// hud

SWEP.HUD_NoFiremodes = false

if CLIENT then
	surface.CreateFont( "PB_HUD_FONT_24",
    {
        font      = "BF4 Numbers",
        size      = 24,
        weight    = 200,
    })
	
	surface.CreateFont( "PB_HUD_FONT_30",
    {
        font      = "BF4 Numbers",
        size      = 30,
        weight    = 200,
    })
end

local clr_inactive = Color(255,255,255,255)
local clr_active = Color(0,130,250,255)

function SWEP:_drawCustomHud()
	local w, h = ScrW(), ScrH()
	
	if !self.HUD_NoFiremodes then
		local fm = PHUNBASE.firemodes.registeredByID[self.FireMode]
		for k, v in pairs(self.FireModes) do
			local fm = PHUNBASE.firemodes.registeredByID[v]
			if fm then
				local isCur = (fm.id == self.FireMode)
				PHUNBASE.drawShadowText(fm.display, isCur and "PB_HUD_FONT_30" or "PB_HUD_FONT_24", (w * 0.995) - (isCur and 6 or 0), (h * 0.85) - (k * 28), isCur and clr_active or clr_inactive, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, 1)
			end
		end
	end
	
	if self.UsesGrenadeLauncher then
		local glammo = self.Owner:GetAmmoCount(self.GrenadeLauncherAmmoType)
		
		local glclip = (self:GetGLState() == PB_GLSTATE_READY) and 1 or 0
		
		if glclip == 1 then glammo = glammo - 1 end
		
		PHUNBASE.drawShadowText("GL Ammo: "..glclip.."/"..glammo, "PB_HUD_FONT_30", (w * 0.995), (h * 0.85), clr_inactive, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, 1)
	end
	
end
