if !CLIENT then return end

SWEP.UseHaloEffect = false -- disabled by default

function PHUNBASE.CalcCameraFromVMFOV( num ) // calculates the camera FOV for the halo rendering depending on viewmodel FOV
	local r = ScrW() / ScrH() // our resolution
	r =  r / (4/3) // 4/3 is base Source resolution, so we have do divide our resolution by that
	local tan, atan, deg, rad = math.tan, math.atan, math.deg, math.rad
	
	local vFoV = rad(num)
	local hFoV = deg( 2 * atan(tan(vFoV/2)*r) ) // this was a bitch
	
	return hFoV
end

function SWEP:GetCorrectCameraFOV()
	return PHUNBASE.CalcCameraFromVMFOV( self.ViewModelFOV - (LocalPlayer():GetFOV() - (self.currentFOV or 0)) )
end

hook.Add("PreDrawHalos", "PHUNBASE_VM_Halo_Test", function() // uses modified halo_phunbase module
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	local haloents = {}
	if IsValid(wep) and wep.PHUNBASEWEP and wep.UseHaloEffect then
		if IsValid(wep.VM) then
			table.insert(haloents, wep.VM)
		end
		if IsValid(wep.Hands) then
			table.insert(haloents, wep.Hands)
		end
		local atts = wep.VElements
		if atts then
			for k, v in pairs(atts) do
				local att = atts[k]
				if att.ent and IsValid(att.ent) and att.active then
					table.insert(haloents, att.ent)
				end
			end
		end
		for _, shellent in pairs(PHUNBASE.shells._cache) do
			if !shellent._soundPlayed then
				table.insert(haloents, shellent)
			end
		end
		
		halo_phunbase.Add(haloents, HSVToColor( CurTime() * 500 % 360, 1, 1 ), 2, 2, 2, true, true, wep:GetCorrectCameraFOV())
	end
end)
