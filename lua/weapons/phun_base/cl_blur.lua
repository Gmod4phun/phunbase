if !CLIENT then return end

CreateClientConVar("phunbase_blur_reload", "1", true, false)
CreateClientConVar("phunbase_blur_iron", "1", true, false)
CreateClientConVar("phunbase_blur_iron_mod", "1", true, false)

SWEP.BlurAmount = 0

local blurMaterial = Material("pp/toytown-top")
blurMaterial:SetTexture("$fbtexture", render.GetScreenEffectTexture())

function SWEP:drawBlur()
	local x, y = ScrW(), ScrH()
	
	if GetConVar("phunbase_blur_reload"):GetInt() > 0 then
		cam.Start2D()
			surface.SetMaterial(blurMaterial)
			surface.SetDrawColor(255, 255, 255, 255)
			for i = 1, self.BlurAmount do
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, x, y * 2)
			end
		cam.End2D()
	end
end

function SWEP:processBlur()
	-- if we're aiming and have enabled telescopic sight aim blur, blur our stuff
	local FT = FrameTime()
	
	local can = false
	
	if (!self.ShotgunReload and self:GetIsReloading() and self.Cycle < 0.95) or (self.ShotgunReload and self:GetIsReloading() ) then
		can = true
	end
	
	if self.DisableReloadBlur then
		can = false
	end
	
	if can then
		self.BlurAmount = math.Approach(self.BlurAmount, 10, FT * 30)
	else
		self.BlurAmount = math.Approach(self.BlurAmount, 0, FT * 30)
	end
	
	if self.BlurAmount > 0 then
		self:drawBlur()
	end
end

SWEP.TT_Blur = 0 
local function PHUNBASE_ToyTown_Blur()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.PHUNBASEWEP then
		return
	end
	
	local FT = FrameTime()
	
	if wep:GetIron() then
		wep.TT_Blur = math.Approach(wep.TT_Blur, 15, FT * 90)
	else
		wep.TT_Blur = math.Approach(wep.TT_Blur, 0, FT * 90)
	end
	
	if wep.TT_Blur > 20 then
		DrawToyTown(1, ScrH() * 0.55)
	end
	
	if tobool(GetConVarNumber("mat_motion_blur_enabled") == 0) then // enable engine blur if disabled
		RunConsoleCommand("mat_motion_blur_enabled", 1)
	end
end

hook.Add("RenderScreenspaceEffects", "PHUNBASE_ToyTown_Blur", PHUNBASE_ToyTown_Blur)

local function GetNewMotionBlurValues( h, v, f, r )
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if wep.TT_Blur and GetConVar("phunbase_blur_iron"):GetInt() > 0 then
		local blurMod = GetConVar("phunbase_blur_iron_mod"):GetFloat()
		if wep.TT_Blur > 0 then
			f = f + wep.TT_Blur * 0.01
			f = f * blurMod
			return h, v, f, r
		end
	end
end
hook.Add("GetMotionBlurValues", "GetNewMotionBlurValues", GetNewMotionBlurValues)
