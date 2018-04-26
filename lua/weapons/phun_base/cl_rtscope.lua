function PHUNBASE.NormalizeAngles(a)
	a.p = math.NormalizeAngle(a.p)
	a.y = math.NormalizeAngle(a.y)
	a.r = math.NormalizeAngle(a.r)
	return a
end

function PHUNBASE.ApproachVector(v, t, c)
	v.x = math.Approach(v.x, t.x, c)
	v.y = math.Approach(v.y, t.y, c)
	v.z = math.Approach(v.z, t.z, c)
	return v
end

if CLIENT then
	local RTSize
	function SWEP:InitRT(size)
		RTSize = size
		self._ScopeRT = GetRenderTarget("phunbase_scope_rt_"..RTSize, RTSize, RTSize, false) // make sure we dont go further than this, or things get screwed up
	end

	SWEP.ScopeAlpha = 0
	SWEP.Lens = surface.GetTextureID("phunbase/rt_scope/lens")
	SWEP.LensMask = Material("phunbase/rt_scope/lensring")
	SWEP.LensVignette = Material("phunbase/rt_scope/lensvignette")
	SWEP.ScopeIris = Material("phunbase/rt_scope/parallax_mask")
	
	// weapon specific values
	SWEP.RTScope_Material = Material("phunbase/rt_scope/pb_scope_rt") // the material where the rt scope is drawn
	SWEP.RTScope_Enabled = false
	SWEP.RTScope_Zoom = 6
	SWEP.RTScope_Align = Angle(0,0,0)
	SWEP.RTScope_Reticle = Material("phunbase/reticles/mk4_crosshair")
	SWEP.RTScope_Lense = Material("phunbase/rt_scope/optic_lense")
	SWEP.RTScope_DrawIris = true
	SWEP.RTScope_DrawParallax = true
	SWEP.RTScope_ShakeMul = 15

	local angle = Angle(0,0,0)
	local viewdata = {
		x = 0,
		y = 0,
		drawviewmodel = false,
		drawhud = false,
		dopostprocess = false
	}
	
	function SWEP:DrawScopeIris()
		local mod = math.abs(1 - (self.ScopeAlpha / 255)) + 0.35
		
		local size = (RTSize * mod)
		
		local pos = RTSize/2 - size/2
		
		local b1 = {
			{ x = 0, y = 0 },
			{ x = pos + 2, y = 0 },
			{ x = pos + 2, y = RTSize},
			{ x = 0, y = RTSize}
		}
		
		local b2 = {
			{ x = 0, y = 0 },
			{ x = RTSize, y = 0 },
			{ x = RTSize, y = pos + 2},
			{ x = 0, y = pos + 2}
		}
		
		local b3 = {
			{ x = pos + size - 2, y = 0 },
			{ x = RTSize, y = 0 },
			{ x = RTSize, y = RTSize},
			{ x = pos + size - 2, y = RTSize}
		}
		
		local b4 = {
			{ x = 0, y = pos + size - 2},
			{ x = RTSize, y = pos + size -2},
			{ x = RTSize, y = RTSize},
			{ x = 0, y = RTSize}
		}
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self.ScopeIris)
		surface.DrawTexturedRect(pos, pos, size, size)
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawPoly(b1)
		surface.DrawPoly(b2)
		surface.DrawPoly(b3)
		surface.DrawPoly(b4)
	end
	
	SWEP.LenseTintIdle = Vector(2.0, 2.0, 2.5)
	SWEP.LenseTintZoom = Vector(0.1, 0.1, 0.15)
	SWEP.LenseTint = Vector(1, 1, 1)
	
	function SWEP:DrawScopeLense()
		if self:GetIron() then
			self.LenseTint = PHUNBASE.ApproachVector(self.LenseTint, self.LenseTintZoom, FrameTime() * 15)
		else
			self.LenseTint = PHUNBASE.ApproachVector(self.LenseTint, self.LenseTintIdle, FrameTime() * 15)
		end
		self.RTScope_Lense:SetVector("$envmaptint", self.LenseTint)
	end
	
	function SWEP:DrawRT()
		if !RTSize or !self._ScopeRT then
			self:InitRT(ScrH())
		end
		
		local oldX, oldY = ScrW(), ScrH()
		local oldRT = render.GetRenderTarget()

		self.ScopeAlpha = math.Approach(self.ScopeAlpha, (self:GetIsReloading() or !self:GetIron()) and 255 or 0, FrameTime() * 15 * 50 )
		
		if !IsValid(self.VM) then return end
		
		local att = self.VM:GetAttachment( self.VM:LookupAttachment(self.MuzzleAttachmentName) or 1)
		local vm_pos, vm_ang = att.Pos, att.Ang
		
		if wep.RTScope_Align then
			vm_ang:RotateAroundAxis(vm_ang:Right(), wep.RTScope_Align.p )
			vm_ang:RotateAroundAxis(vm_ang:Up(), wep.RTScope_Align.y )
			vm_ang:RotateAroundAxis(vm_ang:Forward(), wep.RTScope_Align.r )
		end

		local angDif = PHUNBASE.NormalizeAngles( (vm_ang - EyeAngles()) - (self.AngleDelta or angle) * 3 ) * self.RTScope_ShakeMul

		viewdata.origin = self.Owner:GetShootPos() - Vector(angDif.y, angDif.p, 0) * 0.1
		viewdata.angles = vm_ang
		viewdata.fov = self.RTScope_Zoom
		viewdata.w = RTSize
		viewdata.h = RTSize
		
		render.SetRenderTarget(self._ScopeRT)
		render.SetViewPort(0, 0, RTSize, RTSize)

		render.RenderView(viewdata)
		
		local lens_color = render.ComputeLighting(vm_pos, -vm_ang:Forward())

		cam.Start2D()
		
			if self.RTScope_DrawParallax then
				surface.SetDrawColor(255, 255, 255, 255 - self.ScopeAlpha)
				surface.SetMaterial(self.LensMask)
				surface.DrawTexturedRect(angDif.y, angDif.p, RTSize, RTSize)

				surface.SetDrawColor(0, 0, 0, 255 - self.ScopeAlpha)
				surface.DrawRect(angDif.y - RTSize * 2, angDif.p, RTSize * 2, RTSize) --left
				surface.DrawRect(angDif.y - RTSize * 2, angDif.p - RTSize * 4, RTSize * 4, RTSize * 4) --up
				surface.DrawRect(angDif.y - RTSize * 2, angDif.p + RTSize, RTSize * 4, RTSize * 4) --down
				surface.DrawRect(angDif.y + RTSize, angDif.p, RTSize * 4, RTSize * 4) --right

				surface.SetDrawColor(255 * lens_color[1], 255 * lens_color[2], 255 * lens_color[3], 255)			
				surface.SetTexture(self.Lens)
				surface.DrawTexturedRect(0, 0, RTSize, RTSize)
			end
			
			surface.SetMaterial(self.LensVignette)
			surface.DrawTexturedRect(0, 0, RTSize, RTSize)

			surface.SetDrawColor(255, 255, 255, 255 - self.ScopeAlpha)
			surface.SetMaterial(self.RTScope_Reticle)
			surface.DrawTexturedRect(0, 0, RTSize, RTSize)
			
			if self.RTScope_DrawIris then
				self:DrawScopeIris()
			end
			
		cam.End2D()

		if !self._Scope then
			self._Scope = self.RTScope_Material
			self._Scope:SetTexture("$basetexture", self._ScopeRT)
		end
		render.SetViewPort(0, 0, oldX, oldY)
		render.SetRenderTarget(oldRT)
		
		self:DrawScopeLense()
	end
end
