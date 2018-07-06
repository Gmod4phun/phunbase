// lasers handling

if CLIENT then

	CreateClientConVar("pb_laser_dot_normal", "0", true, false)
	CreateClientConVar("pb_laser_option", "0", true, false)
	CreateClientConVar("pb_laser_color_r", "255", true, false)
	CreateClientConVar("pb_laser_color_g", "0", true, false)
	CreateClientConVar("pb_laser_color_b", "0", true, false)

    SWEP.UsePlayerColorAsLaserColor = false // either that, or default red laser
	SWEP.LaserDrawDistance = 128 // how far should the beam be drawn

    function SWEP:AddAttLaser(attName) // preferably call in att attachcallback
        self._activeAttLasers[attName] = true
    end

    function SWEP:RemoveAttLaser(attName) // preferably call in att detachcallback
        self._activeAttLasers[attName] = nil
    end
    
    SWEP._activeAttLasers = {}
    function SWEP:_handleAttLasers()
        for k, v in pairs(self._activeAttLasers) do
            self:_drawLaser(k)
        end
    end
	
	local laserMat = Material("phunbase/laser/pb_laser_beam")
    local laserDotMat = Material("sprites/light_glow02_add")

    function SWEP:_drawLaser(attName)
        local velement = self:getVElementByName(attName)
        if velement then
            local att = velement:GetAttachment(1)
            local plyWepColVec = LocalPlayer():GetWeaponColor()
			
			local laserOption = GetConVar("pb_laser_option"):GetInt()
			local laserDotNormalOption = GetConVar("pb_laser_dot_normal"):GetInt()
			
			local laserClr_r, laserClr_g, laserClr_b = GetConVar("pb_laser_color_r"):GetInt(), GetConVar("pb_laser_color_g"):GetInt(), GetConVar("pb_laser_color_b"):GetInt()
			local laserClr = Color(laserClr_r, laserClr_g, laserClr_b, 255)
			
			
			local finalLaserCol = laserClr
			
			if laserOption == 1 then // player weapon color
				if !plyWepColVec then // I think it has problems with non sandbox-derived gamemodes and shit, but not sure, just a precaution to avoid potential errors
					finalLaserCol = laserClr
				else
					finalLaserCol = Color( math.Round( plyWepColVec.x * 255 ), math.Round( plyWepColVec.y * 255 ), math.Round( plyWepColVec.z * 255 ), 255 )
				end
			elseif laserOption == 2 then // rainbow
				finalLaserCol = HSVToColor( CurTime() * 500 % 360, 1, 1 )
			end
			
			local angFwd = att.Ang:Forward()
            local tr = util.TraceLine( {
                start = att.Pos,
                endpos = att.Pos + angFwd * 4096,
                filter = { LocalPlayer(), velement, self.VM },
            } )

            if tr.HitPos then
				local laserLen = (tr.HitPos - tr.StartPos):Length()
				local laserDist = math.Clamp(laserLen, 0, self.LaserDrawDistance)
				
				local function drawLaserBeam()
					render.SetMaterial(laserMat)
					render.DrawBeam( tr.StartPos, tr.StartPos + angFwd * laserDist, 1.25, 0, (laserDist/self.LaserDrawDistance) * 0.95, finalLaserCol )
				end
				
				local function drawLaserDot()
					local dotNormal = tr.HitNormal
					
					if laserDotNormalOption == 1 then
						dotNormal = -EyeAngles():Forward()
					elseif laserDotNormalOption == 2 then
						dotNormal = -tr.Normal
					end
					
					render.SetColorModulation(1,1,1)
					render.SetMaterial(laserDotMat)
					render.DrawQuadEasy( tr.HitPos, dotNormal, 3, 3, finalLaserCol )
				end
				
				render.SetColorModulation(1,1,1)
					drawLaserBeam()
					
					if self.isDrawingLasersInScope then
						cam.Start3D() // if drawing in regular view, we need to init a new view with default values
							drawLaserDot()
						cam.End3D()
					else
						drawLaserDot()
					end
				render.SetColorModulation(1,1,1)
            end
        end
    end

end
