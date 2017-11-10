AddCSLuaFile()

PHUNBASE = PHUNBASE or {}

function PHUNBASE.addAmmoType(globalName,prettyName)
	game.AddAmmoType({name = globalName, dmgtype = DMG_BULLET, tracer = TRACER_NONE})
	if CLIENT then
		language.Add(globalName.."_ammo", prettyName)
	end
end

PHUNBASE.addAmmoType("phunbase_9mm","9x19MM Ammo")
PHUNBASE.addAmmoType("phunbase_50ae",".50 AE Ammo")

function PHUNBASE.LoadLua(file)
	if file then
		AddCSLuaFile(file)
		include(file)
	end
end

PHUNBASE.cmodel = PHUNBASE.cmodel or {}
PHUNBASE.cmodel.Models = PHUNBASE.cmodel.Models or {}

function PHUNBASE.cmodel:Add(ent,weapon)
	ent.Parent = weapon
	PHUNBASE.cmodel[#PHUNBASE.cmodel.Models + 1] = ent
end

function PHUNBASE.cmodel:Empty()
	PHUNBASE.cmodel.Models = {}
end

function PHUNBASE.cmodel:LoopCheck()
	local tableindex = 1
	for i = 1, #self.Models do
		local ent = self.Models[tableindex]
		if !IsValid(ent) or !IsValid(ent.Parent) then
			SafeRemoveEntity(ent)
			table.remove(self.Models, tableindex)
		else
			tableindex = tableindex + 1
		end
	end
end

function PHUNBASE.VehicleWeapons(ply,vehicle,role)
	if vehicle:GetVehicleClass() == "Jalopy" and ply:GetActiveWeapon().PHUNBASEWEP then
		ply:SetAllowWeaponsInVehicle(true)
	else
		ply:SetAllowWeaponsInVehicle(false)
	end
end
hook.Add("CanPlayerEnterVehicle","PHUNBASE.VehicleWeapons",PHUNBASE.VehicleWeapons)

function PHUNBASE.VehicleDamage(target, dmginfo)
	if target:IsVehicle() then // if we shot our vehicle, dont damage us
		local driver = target:GetDriver()
		if IsValid( driver ) then
			if driver == dmginfo:GetAttacker() and dmginfo:IsBulletDamage() then
				return true
			end
		end
	end
end
hook.Add("EntityTakeDamage","PHUNBASE.VehicleDamage",PHUNBASE.VehicleDamage)

/*
local function PHUNBASE_GiveWeaponFix(ply,wep) -- disable default behaviour of weapon giving, fixes deploy functions
	--ply:Give(wep)
	--ply:ConCommand("use "..wep)
	return true
end
hook.Add("PlayerGiveSWEP","PHUNBASE_GiveWeaponFix",PHUNBASE_GiveWeaponFix)
*/
