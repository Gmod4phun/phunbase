
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
    
    CreateClientConVar("pb_hud_enable", "1", true, false)
    CreateClientConVar("pb_hud_firemodes_always", "0", true, false)
end

local clr_inactive = Color(255,255,255,255)
local clr_active = Color(0,130,250,255)

local fAlphaShouldStart = false
local fAlphaTime = 0
local fAlpha = 0
local oldFM = ""
local fireMode

local FT
local oldWep = NULL

function SWEP:_drawPhunbaseHud()
    if GetConVar("pb_hud_enable"):GetInt() < 1 then return end
    
	local w, h = ScrW(), ScrH()
    FT = FrameTime()
    
    fireMode = PHUNBASE.firemodes.registeredByID[self.FireMode]
    
    if GetConVar("pb_hud_firemodes_always"):GetInt() < 1 then
        if oldFM != fireMode.id or oldWep != self then
            fAlphaShouldStart = true
            fAlphaTime = CurTime() + 1.5
        end
        
        oldFM = fireMode.id
        oldWep = self
        
        fAlpha = Lerp(FT * 10, fAlpha, fAlphaShouldStart and 255 or 0)
        fAlpha = math.Clamp(fAlpha, 0.05, 255)
        
        if !fAlphaShouldStart and fAlpha == 0.05 then
            fAlpha = 0
        end
        
        if fAlphaShouldStart and fAlpha > 254 and fAlphaTime < CurTime() then
            fAlphaShouldStart = false
        end
    else
        fAlpha = 255
    end
    
	if !self.HUD_NoFiremodes then
		for k, v in pairs(self.FireModes) do
			local fm = PHUNBASE.firemodes.registeredByID[v]
			if fm then
				local isCur = (fm.id == self.FireMode)
				PHUNBASE.drawShadowText(fm.display, isCur and "PB_HUD_FONT_30" or "PB_HUD_FONT_24", (w * 0.995) - (isCur and 6 or 0), (h * 0.85) - (k * 28), isCur and ColorAlpha(clr_active, fAlpha) or ColorAlpha(clr_inactive,fAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, 1)
			end
		end
	end
	
	if self.UsesGrenadeLauncher then
		local glammo = self.Owner:GetAmmoCount(self.GrenadeLauncherAmmoType)
		glammo = (self:GetGLState() == PB_GLSTATE_RELOADING) and glammo + 1 or glammo
        
		local glclip = (self:GetGLState() == PB_GLSTATE_READY) and 1 or 0
		
		PHUNBASE.drawShadowText("GL Ammo: "..glclip.."/"..glammo, "PB_HUD_FONT_30", (w * 0.995), (h * 0.85), clr_inactive, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, 1)
	end
	
end
