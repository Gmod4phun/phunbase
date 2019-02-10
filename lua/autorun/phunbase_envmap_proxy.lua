
// Material proxy for using realtime envmap color tint (best used with static envmaps rather than cubemaps), some are in materials/phunbase/envmaps, see the vmt for example usage

if CLIENT then	
	matproxy.Add( {
		name = "PB_ENVMAPTINT_REALTIME_COLOR",
		init = function( self, mat, values )
			self.envMin = values.min
			self.envMax = values.max
			self.col = Vector()
		end,
		bind = function( self, mat, ent )
			if IsValid(ent) then
				self.col = PHUNBASE_LerpVector(FrameTime() * 10, self.col, render.GetLightColor(ent:GetPos()))

				if self.envMin and self.envMax and self.col then
					self.col.x = math.Clamp(self.col.x, self.envMin, self.envMax)
					self.col.y = math.Clamp(self.col.x, self.envMin, self.envMax)
					self.col.z = math.Clamp(self.col.x, self.envMin, self.envMax)

					mat:SetVector( "$envmaptint", self.col )
				end
			end
		end
	} )
end
