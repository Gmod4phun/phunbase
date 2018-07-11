
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
	
	surface.CreateFont( "PB_HUD_FONT_48",
    {
        font      = "BF4 Numbers",
        size      = 48,
        weight    = 200,
    })
    
    CreateClientConVar("pb_hud_enable", "1", true, false)
    CreateClientConVar("pb_hud_firemodes_enable", "1", true, false)
    CreateClientConVar("pb_hud_firemodes_displaymode", "0", true, false)
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
local fmA

local bipodAlpha = 0

function SWEP:_drawPhunbaseHud()
    if GetConVar("pb_hud_enable"):GetInt() < 1 then return end
    
	local w, h = ScrW(), ScrH()
    FT = FrameTime()
    
    fireMode = PHUNBASE.firemodes.registeredByID[self.FireMode]
    
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
    
    local fmDisplayMode = GetConVar("pb_hud_firemodes_displaymode"):GetInt()
    
	if !self.HUD_NoFiremodes then
		for k, v in pairs(self.FireModes) do
			local fm = PHUNBASE.firemodes.registeredByID[v]
			if fm then
				local isCur = (fm.id == self.FireMode)
                
                // which firemodes to keep displaying after switching the firemode
                if fmDisplayMode == 0 then // all firemodes
                    fmA = 255
                elseif fmDisplayMode == 1 then // only the active one
                    if isCur then fmA = 255 else fmA = fAlpha end
                elseif fmDisplayMode == 2 then // only the active one if it's "safe"
                    if isCur and fm.id == "safe" then fmA = 255 else fmA = fAlpha end
                elseif fmDisplayMode == 3 then // none
                    fmA = fAlpha
                end
                
                if GetConVar("pb_hud_firemodes_enable"):GetInt() < 1 then fmA = 0 end
                
				PHUNBASE.drawShadowText(fm.display, isCur and "PB_HUD_FONT_30" or "PB_HUD_FONT_24", (w * 0.995) - (isCur and 6 or 0), (h * 0.85) - (k * 28), isCur and ColorAlpha(clr_active, fmA) or ColorAlpha(clr_inactive, fmA), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, 1)
			end
		end
	end
	
	if self.UsesGrenadeLauncher then
		local glammo = self.Owner:GetAmmoCount(self.GrenadeLauncherAmmoType)
		glammo = (self:GetGLState() == PB_GLSTATE_RELOADING) and glammo + 1 or glammo
        
		local glclip = (self:GetGLState() == PB_GLSTATE_READY) and 1 or 0
		
		PHUNBASE.drawShadowText("GL Ammo: "..glclip.."/"..glammo, "PB_HUD_FONT_30", (w * 0.995), (h * 0.85), clr_inactive, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, 1)
	end
	
	if self.UsesBipod then
		local show = self:CanDeployBipod() and !self:IsBipodDeployed() and !self:IsBusyForBipodDeploying()
		
		bipodAlpha = Lerp(FT * 10, bipodAlpha, show and 255 or 0)
		bipodAlpha = math.Clamp(bipodAlpha, 0.05, 255)
		
		if !show and bipodAlpha == 0.05 then
			bipodAlpha = 0
		end
		
		local bipodCol = ColorAlpha(clr_inactive, bipodAlpha)
		PHUNBASE.drawShadowText("(E)", "PB_HUD_FONT_48", (w * 0.5), (h * 0.7), bipodCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, 1)
		PHUNBASE.drawShadowText("DEPLOY BIPOD", "PB_HUD_FONT_30", (w * 0.5), (h * 0.7), bipodCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 1)
	end
	
end
