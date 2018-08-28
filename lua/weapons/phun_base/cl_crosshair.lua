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
local ammo, hp, alpha, crossalpha, cross_bwalpha = 0, 0, 0, 0, 0

local gap = 30
local col_yel = Color(255, 208, 64)
local col_red = Color(255, 48, 0)

function SWEP:DrawHUD()
	self:_drawPhunbaseHud()
	
	local ply = LocalPlayer()
	
	local scrw, scrh = ScrW(), ScrH()
	surface.SetFont("PHUNBASE_HL2_CROSSHAIR")
	local t_w, t_h = surface.GetTextSize("[")
	
	local x = scrw/2
	local y = scrh/2
	
	if ply:ShouldDrawLocalPlayer() then // thirdperson crosshair
		local crossHit = ply:GetEyeTrace().HitPos
		local cross2D = nil
		
		if crossHit then
			cross2D = crossHit:ToScreen()
		end
		
		if cross2D then
			x = cross2D.x
			y = cross2D.y
		end
	end
	
	local FT = FrameTime()
	hp = Lerp(FT*10, hp, self.Owner:Health() / self.Owner:GetMaxHealth())
	ammo = Lerp(FT*10, ammo, self:Clip1() / self:GetMaxClip1())
	alpha = Lerp(FT*10, alpha, self:GetIron() and 0 or 64)
	crossalpha = Lerp(FT*20, crossalpha, self:GetIron() and 0 or 255)
	
	local perc_hp = hp
	local perc_ammo = ammo
	local col_cur = ColorAlpha(col_yel, alpha)
	local col_cross = ColorAlpha(Color(255,255,255), crossalpha)
	
	cross_bwalpha = Lerp(FT*10, cross_bwalpha, self.ShouldDrawBWCross and 255 or 0)
	local cross_gap = 0 + (cross_bwalpha/5)
	
	local cross_bwin = Color(255,255,255, cross_bwalpha)
	local cross_bwout = Color(0,0,0, math.Clamp(cross_bwalpha-50, 0, 255))
	
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
	
	if (!self.HL2IconLetters[self:GetClass()] and GetConVar("phunbase_hl2_crosshair"):GetInt() == 1) then
		draw.OutlinedRect(cross_bwin, cross_bwout, x - cross_gap, y, 18, 3, 1)
		draw.OutlinedRect(cross_bwin, cross_bwout, x + cross_gap, y, 18, 3, 1)
		draw.OutlinedRect(cross_bwin, cross_bwout, x, y - cross_gap, 3, 18, 1)
		draw.OutlinedRect(cross_bwin, cross_bwout, x, y + cross_gap, 3, 18, 1)
	end
	
	if self:GetIron() or self:GetIsReloading() or self:GetIsSprinting() or self:GetIsNearWall() or self:GetIsUnderwater() or self:GetIsOnLadder() or self:GetIsCustomizing() or (self:GetIsDeploying() and self:GetIsSprinting()) or self:GetIsHolstering() then
		self.ShouldDrawBWCross = false
	else
		self.ShouldDrawBWCross = true
	end
end

function draw.OutlinedRect(clrIn, clrOut, x, y, w, h, thick)
	local win, hin = w - thick, h - thick

	surface.SetDrawColor( clrOut )
	surface.DrawRect( x - w/2, y - h/2, w, h )
	
	surface.SetDrawColor( clrIn )
	surface.DrawRect( x - win/2 + 0.5, y - hin/2 + 0.5, win - 0.5, hin - 0.5 )
end
