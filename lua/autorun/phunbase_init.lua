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

PHUNBASE.LoadLua("includes/modules/halo_phunbase.lua") // Custom Halo lib

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
--hook.Add("CanPlayerEnterVehicle","PHUNBASE.VehicleWeapons",PHUNBASE.VehicleWeapons) -- dont use that now, still wip

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

function PHUNBASE.PlayerScreenFlash(ply, time, color)
	if !IsValid(ply) then return end
	time = time or 0.5
	color = color or Color(255,255,255,255)
	ply:ScreenFade(SCREENFADE.OUT, color, time/2, time/2)
	timer.Simple(time/2, function()
		ply:ScreenFade(SCREENFADE.IN, color, time/2, time/2)
	end)
end

local function PHUNBASE_GiveWeaponFix(ply,wep,swep) -- disable default behaviour of weapon giving for phunbase weapons, fixes deploy functions
	local IsSWEP = weapons.GetStored(wep) != nil
	if IsSWEP then
		local base = weapons.GetStored(wep).Base
		local basetable = weapons.GetStored(base)
		if ply:IsPlayer() and basetable.PHUNBASEWEP then
			if !ply:HasWeapon(wep) then
				ply:Give(wep)
			end
			umsg.Start("PHUNBASE_WEAPONGIVE_PLAYER", ply)
				umsg.String(wep)
			umsg.End()
			return false
		end
	end
end
hook.Add("PlayerGiveSWEP","PHUNBASE_GiveWeaponFix",PHUNBASE_GiveWeaponFix)

if CLIENT then
	local function PHUNBASE_WEAPONGIVE_PLAYER(um)
		local ply = LocalPlayer()
		local wep = um:ReadString()

		timer.Simple(0.01, function()
			if !IsValid(ply) or !IsValid(ply:GetWeapon(wep)) then
				return
			end
			input.SelectWeapon(ply:GetWeapon(wep))
		end)
		
	end
	usermessage.Hook("PHUNBASE_WEAPONGIVE_PLAYER", PHUNBASE_WEAPONGIVE_PLAYER)
end
