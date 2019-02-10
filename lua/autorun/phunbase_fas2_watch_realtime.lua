
if CLIENT then
	local hr1 = Material("phunbase/attachments/fas2_watch_realtime/digit_hr_1")
	local hr2 = Material("phunbase/attachments/fas2_watch_realtime/digit_hr_2")
	local min1 = Material("phunbase/attachments/fas2_watch_realtime/digit_min_1")
	local min2 = Material("phunbase/attachments/fas2_watch_realtime/digit_min_2")
	local sec1 = Material("phunbase/attachments/fas2_watch_realtime/digit_sec_1")
	local sec2 = Material("phunbase/attachments/fas2_watch_realtime/digit_sec_2")
	
	PHUNBASE.FAS2_WATCH_TIME = {hours = 0, minutes = 0, seconds = 0}
	
	local nextThink = 0
	local timestr, t
	
	// code for the digits
	hook.Add("Think", "PHUNBASE_FAS2_WATCH_REALTIME_Think", function()	
		if nextThink < CurTime() then
			timestr = os.date("%H%M%S", os.time())
			t = timestr:ToTable()
			
			hr1:SetInt("$frame", t[1])
			hr2:SetInt("$frame", t[2])
			min1:SetInt("$frame", t[3])
			min2:SetInt("$frame", t[4])
			sec1:SetInt("$frame", t[5])
			sec2:SetInt("$frame", t[6])
			
			local hr = tostring(t[1])..tostring(t[2])
			local min = tostring(t[3])..tostring(t[4])
			local sec = tostring(t[5])..tostring(t[6])
			
			PHUNBASE.FAS2_WATCH_TIME = {hours = hr, minutes = min, seconds = sec}
			
			nextThink = CurTime() + 0.25
		end
	end)
	
	// proxies for the watch hands
	matproxy.Add( {
		name = "FAS2_WATCH_REALTIME_Hours",
		init = function( self, mat, values )
			self.degrees = values.resultvar
		end,
		bind = function( self, mat, ent )
			local time = PHUNBASE.FAS2_WATCH_TIME
			local hrdegrees = 360/43200 * (time.hours * 3600 + time.minutes * 60 + time.seconds)
			mat:SetFloat( self.degrees, tostring(-hrdegrees) )
		end
	} )
	
	matproxy.Add( {
		name = "FAS2_WATCH_REALTIME_Minutes",
		init = function( self, mat, values )
			self.degrees = values.resultvar
		end,
		bind = function( self, mat, ent )
			local time = PHUNBASE.FAS2_WATCH_TIME
			local mindegrees = 360/3600 * (time.minutes * 60 + time.seconds)
			mat:SetFloat( self.degrees, tostring(-mindegrees) )
		end
	} )
	
	matproxy.Add( {
		name = "FAS2_WATCH_REALTIME_Seconds",
		init = function( self, mat, values )
			self.degrees = values.resultvar
		end,
		bind = function( self, mat, ent )
			local time = PHUNBASE.FAS2_WATCH_TIME
			local secdegrees = 360/60 * time.seconds
			mat:SetFloat( self.degrees, tostring(-secdegrees) )
		end
	} )
	
	matproxy.Add( {
		name = "FAS2_WATCH_REALTIME_DigitColor",
		init = function( self, mat, values )
			self.color = values.resultvar
		end,
		bind = function( self, mat, ent )
			if IsValid(ent) then
				local col = ent.FAS2_WATCH_DigitColor
				if !col then col = Color(255,255,255) end
				
				col = Vector(col.r, col.g, col.b) / 255
				
				mat:SetVector( self.color, col )
			end
		end
	} )
end

if CLIENT then
	
	CreateClientConVar("pb_fas2_watch_hud_enable", "0", true, false)

	local watchsize = 128
	function PHUNBASE.FAS2_WATCH_DrawInHud()
		local ply = LocalPlayer()
		
		if !IsValid(ply) then return end
		
		if !ply.FAS2_WATCH_HudModel or !IsValid(ply.FAS2_WATCH_HudModel) then
			ply.FAS2_WATCH_HudModel = ClientsideModel("models/phunbase/fas2_watch_realtime.mdl", RENDERGROUP_BOTH)
			ply.FAS2_WATCH_HudModel:SetNoDraw(true)
		end
		
		local watch = ply.FAS2_WATCH_HudModel
		
		if !IsValid(watch) then return end
		
		watch.FAS2_WATCH_DigitColor = Color(135,235,105)
		
		local pos, ang = EyePos(), EyeAngles()
		local watchsizenormal = 128
		local watchsizezoom = 512
		
		watchsize = Lerp(FrameTime() * 10, watchsize, ply.FAS2_WATCH_HudZoom and watchsizezoom or watchsizenormal)
		
		local posA, angA = Vector(), Angle()
		
		local rotAng = Angle(ang)
		rotAng:RotateAroundAxis(rotAng:Right(), 90)
		rotAng:RotateAroundAxis(rotAng:Forward(), 0)
		rotAng:RotateAroundAxis(rotAng:Up(), 90)
		
		local x, y, w, h = 2, 10, watchsize, watchsize
		cam.Start3D( pos, ang, 60, x, y, w, h, 1, 128 )
			cam.IgnoreZ(false)
				render.SuppressEngineLighting( false )
					watch:SetPos(pos + ang:Forward() * 1.75)
					watch:SetAngles(rotAng)
					watch:DrawModel()
				render.SuppressEngineLighting( false )
			cam.IgnoreZ(false)
		cam.End3D()
	end
	
	concommand.Add("pb_fas2_watch_hud_zoom", function( ply, cmd, args )
		ply.FAS2_WATCH_HudZoom = !tobool(ply.FAS2_WATCH_HudZoom)
	end)
	
	concommand.Add("+pb_fas2_watch_hud_zoom", function( ply, cmd, args )
		ply.FAS2_WATCH_HudZoom = true
	end)
	
	concommand.Add("-pb_fas2_watch_hud_zoom", function( ply, cmd, args )
		ply.FAS2_WATCH_HudZoom = false
	end)
	
	hook.Add("HUDPaint", "PHUNBASE_FAS2_WATCH_REALTIME_HUDPaintDrawing", function()
		if GetConVar("pb_fas2_watch_hud_enable"):GetInt() > 0 then
			PHUNBASE.FAS2_WATCH_DrawInHud()
		end
	end)
end
