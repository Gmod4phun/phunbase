AddCSLuaFile()

PHUNBASE.registeredAmmoTypes = PHUNBASE.registeredAmmoTypes or {}
PHUNBASE.registeredAmmoCounts = PHUNBASE.registeredAmmoCounts or {}

function PHUNBASE.addAmmoType(globalName, prettyName, ammoCount)
	if PHUNBASE.registeredAmmoTypes[globalName] then
		print("The ammotype  "..globalName.."  already exists")
		return
	end

	game.AddAmmoType({name = globalName, dmgtype = DMG_BULLET, tracer = TRACER_NONE})
	if CLIENT then
		language.Add(globalName.."_ammo", prettyName)
	end

	PHUNBASE.registeredAmmoTypes[globalName] = prettyName
	PHUNBASE.registeredAmmoCounts[globalName] = ammoCount or 30
end

PHUNBASE.addAmmoType("phunbase_9x19mm", "9x19mm Parabellum", 30)
PHUNBASE.addAmmoType("phunbase_9x18mm", "9x18mm Makarov", 30)
PHUNBASE.addAmmoType("phunbase_45acp", ".45 ACP", 30)
PHUNBASE.addAmmoType("phunbase_357sig", ".357 SIG", 12)
PHUNBASE.addAmmoType("phunbase_57x28", "5.7x28mm", 30)
PHUNBASE.addAmmoType("phunbase_50ae", ".50 AE", 7)
PHUNBASE.addAmmoType("phunbase_556x45", "5.56x45mm NATO", 30)
PHUNBASE.addAmmoType("phunbase_762x51", "7.62x51mm NATO", 30)
PHUNBASE.addAmmoType("phunbase_338", ".338 Lapua Magnum", 5)
PHUNBASE.addAmmoType("phunbase_38special", ".38 Special", 12)
PHUNBASE.addAmmoType("phunbase_357mag", ".357 Magnum", 12)
PHUNBASE.addAmmoType("phunbase_50bmg", ".50 BMG", 5)
PHUNBASE.addAmmoType("phunbase_12gauge", "12 Gauge", 8)
PHUNBASE.addAmmoType("phunbase_545x39", "5.45x39mm", 30)
PHUNBASE.addAmmoType("phunbase_762x39", "7.62x39mm", 30)
PHUNBASE.addAmmoType("phunbase_40mm_he", "40MM HE Grenade", 1)
PHUNBASE.addAmmoType("phunbase_40mm_smoke", "40MM Smoke Grenade", 1)
PHUNBASE.addAmmoType("phunbase_303brit", ".303 British", 30)
PHUNBASE.addAmmoType("phunbase_763x25", "7.63x25mm Mauser", 30)
PHUNBASE.addAmmoType("phunbase_792x57", "7.92x57mm Mauser", 30)
PHUNBASE.addAmmoType("phunbase_30carbine", ".30 Carbine", 30)
PHUNBASE.addAmmoType("phunbase_30-06", ".30-06 Springfield", 30)
PHUNBASE.addAmmoType("phunbase_765x20", "7.65x20mm Longue", 30)
PHUNBASE.addAmmoType("phunbase_30luger", ".30 Luger", 30)
PHUNBASE.addAmmoType("phunbase_762x54", "7.62x54mmR", 30)
PHUNBASE.addAmmoType("phunbase_792x33", "7.92x33mm Kurz", 30)
PHUNBASE.addAmmoType("phunbase_10x25mm", "10mm Auto", 30)
PHUNBASE.addAmmoType("phunbase_762x33", "7.62x33mm", 30)
PHUNBASE.addAmmoType("phunbase_rocket", "Rocket", 1)
PHUNBASE.addAmmoType("phunbase_flare", "Flare", 1)

hook.Add( "Initialize", "PHUNBASE_createAmmoBoxes", function() // create an ammocrate entity for every ammo type (Daxble's idea)
	for k, v in pairs( PHUNBASE.registeredAmmoTypes ) do
		local ENT = scripted_ents.Get( "phun_ammocrate_base" )
		ENT.PrintName = v or "UNDEFINED"
		ENT.Spawnable = true
		ENT.AmmoCount = PHUNBASE.registeredAmmoCounts[k] or 30
		ENT.AmmoType = k
		local name = "phun_ammocrate_"..(k:Replace("phunbase_", ""))
		scripted_ents.Register( ENT, string.lower(name) )
	end
end )
