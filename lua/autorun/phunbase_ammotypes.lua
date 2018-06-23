AddCSLuaFile()

PHUNBASE.registeredAmmoTypes = PHUNBASE.registeredAmmoTypes or {}

function PHUNBASE.addAmmoType(globalName, prettyName)
    if PHUNBASE.registeredAmmoTypes[globalName] then
        print("The ammotype  "..globalName.."  already exists")
        return
    end
    
	game.AddAmmoType({name = globalName, dmgtype = DMG_BULLET, tracer = TRACER_NONE})
	if CLIENT then
		language.Add(globalName.."_ammo", prettyName)
	end
    
	PHUNBASE.registeredAmmoTypes[globalName] = prettyName
end

PHUNBASE.addAmmoType("phunbase_9mm","9x19mm Parabellum")
PHUNBASE.addAmmoType("phunbase_45acp",".45 ACP")
PHUNBASE.addAmmoType("phunbase_357sig",".357 SIG")
PHUNBASE.addAmmoType("phunbase_57x28FN","5.7x28mm")
PHUNBASE.addAmmoType("phunbase_50ae",".50 AE")
PHUNBASE.addAmmoType("phunbase_556x45","5.56x45mm NATO")
PHUNBASE.addAmmoType("phunbase_762x51","7.62x51mm NATO")
PHUNBASE.addAmmoType("phunbase_338",".338 Lapua Magnum")
PHUNBASE.addAmmoType("phunbase_50bmg",".50 BMG")
PHUNBASE.addAmmoType("phunbase_12gauge","12 Gauge")
PHUNBASE.addAmmoType("phunbase_545x39","5.45x39mm")
PHUNBASE.addAmmoType("phunbase_762x39","7.62x39mm")
PHUNBASE.addAmmoType("phunbase_40mm_he","40MM HE Grenade")
PHUNBASE.addAmmoType("phunbase_40mm_smoke","40MM Smoke Grenade")

PHUNBASE.addAmmoType("phunbase_303brit",".303 British")
PHUNBASE.addAmmoType("phunbase_763x25","7.63x25mm Mauser")
PHUNBASE.addAmmoType("phunbase_792x57","7.92x57mm Mauser")
PHUNBASE.addAmmoType("phunbase_30carbine",".30 Carbine")
PHUNBASE.addAmmoType("phunbase_30-06",".30-06 Springfield")
PHUNBASE.addAmmoType("phunbase_765x20","7.65x20mm Longue")
PHUNBASE.addAmmoType("phunbase_30luger",".30 Luger")
PHUNBASE.addAmmoType("phunbase_762x54","7.62x54mmR")
PHUNBASE.addAmmoType("phunbase_792x33","7.92x33mm Kurz")
