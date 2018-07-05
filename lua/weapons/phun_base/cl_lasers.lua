// lasers handling

if CLIENT then

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
	
    local laserClr = Color(250,10,10) // red laser
	local laserMat = Material("phunbase/laser/pb_laser_beam")
    local laserDotMat = Material("sprites/light_glow02_add")

    function SWEP:_drawLaser(attName)
        local velement = self:getVElementByName(attName)
        if velement then
            local att = velement:GetAttachment(1)
            local plyWepColVec = LocalPlayer():GetWeaponColor()

            if self.UsePlayerColorAsLaserColor and !plyWepColVec then return end // I think it has problems with non sandbox-derived gamemodes and shit, but not sure, just a precaution to avoid potential errors

            local realPlyWepCol = Color( math.Round( plyWepColVec.x * 255 ), math.Round( plyWepColVec.y * 255 ), math.Round( plyWepColVec.z * 255 ) )
			
			local finalLaserCol = self.UsePlayerColorAsLaserColor and realPlyWepCol or laserClr
			
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
					render.SetColorModulation(1,1,1)
					render.SetMaterial(laserDotMat)
					render.DrawQuadEasy( tr.HitPos, tr.HitNormal, 3, 3, finalLaserCol )
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
