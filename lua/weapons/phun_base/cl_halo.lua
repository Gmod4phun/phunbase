if !CLIENT then return end

SWEP.UseHaloEffect = false -- disabled by default

function PHUNBASE_CalcHaloFOV( num ) // calculates the camera FOV for the halo rendering depending on viewmodel FOV
	local r = ScrW() / ScrH() // our resolution
	r =  r / (4/3) // 4/3 is base Source resolution, so we have do divide our resolution by that
	local tan, atan, deg, rad = math.tan, math.atan, math.deg, math.rad
	
	local vFoV = rad(num)
	local hFoV = deg( 2 * atan(tan(vFoV/2)*r) ) // this was a bitch
	
	return hFoV
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
		for _, shellent in pairs(PHUNBASE.shells._cache) do
			if !shellent._soundPlayed then
				table.insert(haloents, shellent)
			end
		end
		halo_phunbase.Add(haloents, HSVToColor( CurTime() * 500 % 360, 1, 1 ), 2, 2, 2, true, true, PHUNBASE_CalcHaloFOV( wep.ViewModelFOV ))
	end
end)
