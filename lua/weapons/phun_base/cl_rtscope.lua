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

	function PHUNBASE.DrawTexturedRectRotatedPoint(x, y, w, h, rot, x0, y0)
		local c = math.cos(math.rad(rot))
		local s = math.sin(math.rad(rot))

		local newx = y0 * s - x0 * c
		local newy = y0 * c + x0 * s

		surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
	end

	function PHUNBASE.DrawCenterRotatedRect(x, y, w, h, rot)
		PHUNBASE.DrawTexturedRectRotatedPoint(x + w/2, y + h/2, w, h, rot, 0, 0)
	end

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
	SWEP.RTScope_ReticleAlways = false
	SWEP.RTScope_Lense = Material("phunbase/rt_scope/optic_lense")
	SWEP.RTScope_DrawIris = true
	SWEP.RTScope_DrawParallax = true
	SWEP.RTScope_ShakeMul = 15
	SWEP.RTScope_Rotate = 0

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

	local texturizeMat = Material("pp/texturize/rainbow.png")
	local pb_rtscope_texturizeMat = Material( "phunbase/rt_scope/pb_scope_rt_texturize" )
	local oldE = NULL

	function SWEP:DrawRT()
		if !IsValid(self.VM) then return end

		if !RTSize or !self._ScopeRT then
			self:InitRT(ScrH())
		end

		local oldX, oldY = ScrW(), ScrH()
		local oldRT = render.GetRenderTarget()

		self.ScopeAlpha = math.Approach(self.ScopeAlpha, (self:GetIsReloading() or !self:GetIron()) and 255 or 0, FrameTime() * 15 * 50 )

		local att = self.VM:GetAttachment(self.RTScope_AttachmentName and self.VM:LookupAttachment(self.RTScope_AttachmentName) or 1) // regular viewmodel and its attachment

		if self.RTScope_Entity and IsValid(self.RTScope_Entity) then // use custom entity (preferably a VElement and its attachment)
			att = self.RTScope_Entity:GetAttachment(self.RTScope_AttachmentName and self.RTScope_Entity:LookupAttachment(self.RTScope_AttachmentName) or 1)
		end

		if !att then return end

		local attPos, attAng = att.Pos, att.Ang

		if self.RTScope_Align then
			attAng:RotateAroundAxis(attAng:Right(), self.RTScope_Align.p )
			attAng:RotateAroundAxis(attAng:Up(), self.RTScope_Align.y )
			attAng:RotateAroundAxis(attAng:Forward(), self.RTScope_Align.r )
		end

		local angDif = PHUNBASE.NormalizeAngles( (attAng - EyeAngles()) - (self.AngleDelta or Angle()) * 3 ) * self.RTScope_ShakeMul

		viewdata.origin = attPos// - Vector(angDif.y, angDif.p, 0) * 0.1
		viewdata.angles = attAng
		viewdata.fov = self.RTScope_Zoom
		viewdata.w = RTSize
		viewdata.h = RTSize

		render.SetRenderTarget(self._ScopeRT)
		render.SetViewPort(0, 0, RTSize, RTSize)

		render.RenderView(viewdata)

		// drawing viewmodel and attachments inside the rt scope
		cam.Start3D(viewdata.origin + viewdata.angles:Forward() * -5, viewdata.angles)
<<<<<<< HEAD
			cam.IgnoreZ( true )
=======
            cam.IgnoreZ(true)
>>>>>>> upstream/master
			if self.drawViewModelInRT then
				self.VM:DrawModel()
			end

			local attmdls = self.VElements
			if attmdls then
				for k, v in pairs(attmdls) do
					if v.drawInRT and v.active and v.ent_for_RT then
						if v.bonemerge then
							v.ent_for_RT:DrawModel()
						else
							self:_drawAttachmentModel_for_RT(v)
						end
					end
				end
			end
<<<<<<< HEAD
			cam.IgnoreZ( false )
=======
            cam.IgnoreZ(false)
>>>>>>> upstream/master
		cam.End3D()

		local lens_color = render.ComputeLighting(attPos, -attAng:Forward())

		cam.Start2D()
<<<<<<< HEAD
			cam.IgnoreZ( true )
=======
            cam.IgnoreZ(true)
>>>>>>> upstream/master
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

			if self.RTScope_IsThermal then
				surface.SetMaterial(pb_rtscope_texturizeMat)
				surface.DrawTexturedRect(0, 0, RTSize, RTSize)
			end

			surface.SetMaterial(self.LensVignette)
			surface.DrawTexturedRect(0, 0, RTSize, RTSize)

			surface.SetDrawColor(255, 255, 255, self.RTScope_ReticleAlways and 255 or (255 - self.ScopeAlpha))
			surface.SetMaterial(self.RTScope_Reticle)
			PHUNBASE.DrawCenterRotatedRect(0, 0, RTSize, RTSize, self.RTScope_Rotate)

			if self.RTScope_DrawIris then
				self:DrawScopeIris()
			end
<<<<<<< HEAD
			cam.IgnoreZ( false )
=======
            cam.IgnoreZ(false)
>>>>>>> upstream/master
		cam.End2D()

		if !self._Scope then
			self._Scope = self.RTScope_Material
			self._Scope:SetTexture("$basetexture", self._ScopeRT)
			pb_rtscope_texturizeMat:SetTexture( "$fbtexture", self._ScopeRT )
		end

		PB_RTScope_Texturize_Draw( pb_rtscope_texturizeMat, 1, texturizeMat )

		render.SetViewPort(0, 0, oldX, oldY)
		render.SetRenderTarget(oldRT)

		self:DrawScopeLense()
	end

	function PB_RTScope_Texturize_Draw( targetMat, scale, pMaterial )
		targetMat:SetFloat( "$scalex", ( ScrW() / 64 ) * scale )
		targetMat:SetFloat( "$scaley", ( ScrH() / 64 / 8 ) * scale )
		targetMat:SetTexture( "$basetexture", pMaterial:GetTexture( "$basetexture" ) )
	end

end
