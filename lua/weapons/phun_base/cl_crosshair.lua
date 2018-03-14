if !CLIENT then return end

surface.CreateFont( "PHUNBASE_HL2_CROSSHAIR", { // hl2 crosshair
	font = "HL2Cross",
	extended = true,
	size = 57,
	weight = 0,
	antialias = true,
	additive = true,
} )

local hl2_cross_font = "PHUNBASE_HL2_CROSSHAIR"
local ammo, hp, alpha, crossalpha = 0, 0, 0, 0

local gap = 30
local col_yel = Color(255, 208, 64)
local col_red = Color(255, 48, 0)

function SWEP:DrawHUD()
	local scrw, scrh = ScrW(), ScrH()
	surface.SetFont("PHUNBASE_HL2_CROSSHAIR")
	local t_w, t_h = surface.GetTextSize("[")
	local x = scrw/2
	local y = scrh/2
	
	local FT = FrameTime()
	hp = Lerp(FT*10, hp, self.Owner:Health() / self.Owner:GetMaxHealth())
	ammo = Lerp(FT*10, ammo, self:Clip1() / self:GetMaxClip1())
	alpha = Lerp(FT*10, alpha, self:GetIron() and 0 or 64)
	crossalpha = Lerp(FT*20, crossalpha, self:GetIron() and 0 or 255)
	
	local perc_hp = hp
	local perc_ammo = ammo
	local col_cur = ColorAlpha(col_yel, alpha)
	local col_cross = ColorAlpha(Color(255,255,255), crossalpha)
	
	if (self.HL2IconLetters[self:GetClass()] and GetConVar("phunbase_hl2_crosshair"):GetInt() == 1) or GetConVar("phunbase_hl2_crosshair"):GetInt() == 2 then
	
		// default 5dot crosshair
		surface.SetDrawColor(col_cross)
		surface.DrawRect(x - 1, y, 1, 1)
		surface.DrawRect(x - 1 + 10, y, 1, 1)
		surface.DrawRect(x - 1 - 10, y, 1, 1)
		surface.DrawRect(x - 1, y + 8, 1, 1)
		surface.DrawRect(x - 1, y - 8, 1, 1)
		
		render.SetScissorRect( 0, y - t_h/2 + (t_h * (1 - perc_hp)), x, y + t_h/2, true )
		draw.Text({
			text = "[",
			font = hl2_cross_font,
			pos = {x - gap, y},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = col_cur
		})
		render.SetScissorRect( 0, 0, 0, 0, false )
		
		render.SetScissorRect( x, y - t_h/2 + (t_h * (1 - perc_ammo)), scrw, y + t_h/2, true )
		draw.Text({
			text = "]",
			font = hl2_cross_font,
			pos = {x + gap, y},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = col_cur
		})
		render.SetScissorRect( 0, 0, 0, 0, false )
		
		draw.Text({
			text = "{",
			font = hl2_cross_font,
			pos = {x - gap, y},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = col_cur
		})
		
		draw.Text({
			text = "}",
			font = hl2_cross_font,
			pos = {x + gap, y},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = col_cur
		})
		
	end
end
