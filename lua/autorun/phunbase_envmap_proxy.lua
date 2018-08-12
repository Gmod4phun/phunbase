
// Material proxy for using realtime envmap color tint (best used with static envmaps rather than cubemaps), some are in materials/phunbase/envmaps, see the vmt for example usage

if CLIENT then
	local col = Vector()
	local fallback = Vector(0.2, 0.2, 0.2)
	
	matproxy.Add( {
		name = "PB_ENVMAPTINT_REALTIME_COLOR",
		init = function( self, mat, values )
			self.envMin = values.min
			self.envMax = values.max
		end,
		bind = function( self, mat, ent )
			if IsValid(ent) then
				col = PHUNBASE_LerpVector(FrameTime() * 10, col, render.GetLightColor(ent:GetPos()))
			else
				col = fallback
			end
			
			local min, max = self.envMin, self.envMax
			
			if min and max and col then
				col.x = math.Clamp(col.x, min, max)
				col.y = math.Clamp(col.x, min, max)
				col.z = math.Clamp(col.x, min, max)

				mat:SetVector( "$envmaptint", col )
			end
		end
	} )
end
