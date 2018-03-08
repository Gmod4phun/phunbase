AddCSLuaFile()

PHUNBASE = PHUNBASE or {}

function PHUNBASE.addAmmoType(globalName,prettyName)
	game.AddAmmoType({name = globalName, dmgtype = DMG_BULLET, tracer = TRACER_NONE})
	if CLIENT then
		language.Add(globalName.."_ammo", prettyName)
	end
end

PHUNBASE.addAmmoType("phunbase_9mm","9x19mm Parabellum")
PHUNBASE.addAmmoType("phunbase_45acp",".45 ACP")
PHUNBASE.addAmmoType("phunbase_357sig",".357 SIG")
PHUNBASE.addAmmoType("phunbase_57x28FN","5.7x28mm FN")
PHUNBASE.addAmmoType("phunbase_50ae",".50 AE")
PHUNBASE.addAmmoType("phunbase_556","5.56x45mm NATO")
PHUNBASE.addAmmoType("phunbase_762x51","7.62x51mm NATO")
PHUNBASE.addAmmoType("phunbase_338",".338 Lapua Magnum")
PHUNBASE.addAmmoType("phunbase_50bmg",".50 BMG")
PHUNBASE.addAmmoType("phunbase_12gauge","12 Gauge")

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
	PHUNBASE.cmodel.Models[#PHUNBASE.cmodel.Models + 1] = ent
end

function PHUNBASE.cmodel:Empty()
	PHUNBASE.cmodel.Models = {}
end

function PHUNBASE.cmodel:LoopCheck()
	local tableindex = 1
	for i = 1, #self.Models do
		local ent = self.Models[tableindex]
		if !IsValid(ent) or !IsValid(ent.Parent) /*or ( IsValid(ent) and IsValid(ent.WeaponObject) and !ent.WeaponObject:GetIsInUse() )*/ then
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

local npc_fix_table = {
	["npc_rollermine"] = "models/roller.mdl",
	["npc_turret_floor"] = "models/combine_turrets/floor_turret.mdl",
}

hook.Add("OnNPCKilled", "PHUNBASE_NPC_KillFix", function(npc)
	local phys, vel, angvel, fake, fakephys, fakeangvel
	phys = npc:GetPhysicsObject()
	
	if IsValid(phys) then
		vel = phys:GetVelocity()
		fakeangvel = phys:GetAngleVelocity()
	end
	
	if npc_fix_table[npc:GetClass()] then
		fake = ents.Create("prop_physics")
		fake:SetModel(npc_fix_table[npc:GetClass()])
		fake:SetPos(npc:GetPos())
		fake:SetAngles(npc:GetAngles())
		fake:Spawn()
		
		fakephys = fake:GetPhysicsObject()
		
		if IsValid(fakephys) then
			fakephys:SetVelocity(vel)
			fakephys:AddAngleVelocity(fakeangvel)
		end
		
		undo.ReplaceEntity(npc, fake)
		npc:Remove()
	end
end)

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
