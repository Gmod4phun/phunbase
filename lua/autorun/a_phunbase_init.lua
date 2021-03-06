AddCSLuaFile()

PHUNBASE = PHUNBASE or {}
PHUNBASE.SpawnIcons = PHUNBASE.SpawnIcons or {}

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
		if basetable and ply:IsPlayer() and basetable.PHUNBASEWEP then
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

if SERVER then
	util.AddNetworkString("PHUNBASE_SELECTWEAPON")
	util.AddNetworkString("PHUNBASE_FORCEDEPLOYWEAPON")
	
	function PHUNBASE.ForceDeployWeapon(ply, class)
		if !IsValid(ply) then return end
		if !ply:HasWeapon(class) then return end
		
		local wep = ply:GetWeapon(class)
		
		if !wep.PHUNBASEWEP then return end
		
		net.Start("PHUNBASE_FORCEDEPLOYWEAPON")
			net.WriteString(class)
		net.Send(ply)
		
		ply:SetActiveWeapon(wep)
		wep:Deploy()
	end
end

function PHUNBASE.SelectWeapon(ply, class)
	if !IsValid(ply) then return end
	if !ply:HasWeapon(class) then return end
	
	if CLIENT then
		input.SelectWeapon(ply:GetWeapon(class))
	end
	
	if SERVER then
		net.Start("PHUNBASE_SELECTWEAPON")
			net.WriteString(class)
		net.Send(ply)
	end
end

function PHUNBASE.DropWeapon(ply, class)
	if !IsValid(ply) then return end
	if !ply:HasWeapon(class) then return end
	
	ply:DropWeapon(ply:GetWeapon(class))
end
concommand.Add("pb_dropactiveweapon", function(ply)
	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	PHUNBASE.DropWeapon(ply, ply:GetActiveWeapon():GetClass())
end)

function PHUNBASE.HL2_SLAM_BEAM_Fix()
	for k, v in pairs(ents.FindByClass("beam")) do // removes SLAM beams that no longer have a parent
		if !IsValid(v:GetParent()) then
			v:Remove()
		end
	end
end

hook.Add("EntityRemoved", "PB_HL2_SLAM_BEAM_OnRemove", function(ent)
	if ent:GetClass() == "npc_tripmine" then
		PHUNBASE.HL2_SLAM_BEAM_Fix()
	end	
end)

if CLIENT then
	net.Receive("PHUNBASE_SELECTWEAPON", function()
		input.SelectWeapon(LocalPlayer():GetWeapon(net.ReadString()))
	end)
	
	net.Receive("PHUNBASE_FORCEDEPLOYWEAPON", function()
		LocalPlayer():GetWeapon(net.ReadString()):Deploy()
	end)

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
	
	/* // does not work yet, since Subrect shader is not creatable from Lua
	function PHUNBASE.SubrectMaterial(name, file, x, y, w, h)
		local params = {
			["$Material"] = file,
			["$Pos"] = string.format("%d %d", x, y),
			["$Size"] = string.format("%d %d", w, h)
		}
		return CreateMaterial(name, "Subrect", params)
	end
	*/
	
	/* // wip, still sux ass
	function PHUNBASE.DrawSubrect(mat, x, y, pU, pV, sU, sV, base, custW, custH)
		custW = custW or 0
		custH = custH or 0
		x, y = x + 1, y + 1
		local pU1, pV1, sU1, sV1  = pU/base, pV/base, sU/base, sV/base
		local w, h = math.abs(sU - pU), math.abs(sV - pV)
		if custW != 0 then w = custW end
		if custH != 0 then h = custH end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(mat)
		surface.DrawTexturedRectUV(x - w/2, y - h/2, w, h, (0 - 2.3)/base, (48)/base, (0 + 24 - 2.3)/base, (48 + 24)/base)
	end
	*/
end

-- local pbFilesToLoad = {
	-- "phunbase_ammotypes.lua",
	-- "phunbase_attachments.lua",
	-- "phunbase_fas2_watch_realtime.lua",
	-- "phunbase_firemodes.lua",
	-- "phunbase_halo_experiments.lua",
	-- "phunbase_hl2_spawnicons.lua",
	-- "phunbase_menu.lua",
	-- "phunbase_particles.lua",
	-- "phunbase_shells_init.lua",
	-- "phunbase_sound.lua",
	-- "phunbase_version.lua",
-- }

-- for k, v in pairs(pbFilesToLoad) do
	-- PHUNBASE.LoadLua(v)
-- end
