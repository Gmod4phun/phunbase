
local CrossbowImpactParticles = {
	["npc_dog"] = "ricochet_sparks",
	["npc_hunter"] = "none",
	["npc_turret_floor"] = "none",
	["npc_combine_camera"] = "none",
	["npc_turret_ceiling"] = "none",
	["npc_cscanner"] = "none",
	["npc_manhack"] = "none",
	["npc_rollermine"] = "ricochet_sparks",
	["npc_clawscanner"] = "none",
	["npc_strider"] = "ricochet_sparks",
	["npc_antlionguard"] = "blood_impact_antlion_01",
	["npc_antlionguardian"] = "blood_impact_green_01",
	["npc_antlion"] = "blood_impact_antlion_01",
	["npc_antlion_worker"] = "blood_impact_antlion_worker_01",
	["npc_zombie"] = "blood_impact_zombie_01",
	["npc_zombine"] = "blood_impact_zombie_01",
	["npc_fastzombie"] = "blood_impact_zombie_01",
	["npc_poisonzombie"] = "blood_impact_zombie_01",
	["npc_zombie_torso"] = "blood_impact_zombie_01",
	["npc_fastzombie_torso"] = "blood_impact_zombie_01",
	["npc_headcrab"] = "blood_impact_green_01",
	["npc_headcrab_black"] = "blood_impact_green_01",
	["npc_headcrab_poison"] = "blood_impact_green_01", //dropped black headcrabs, wtf, why different classes
	["npc_headcrab_fast"] = "blood_impact_green_01",
	["npc_vortigaunt"] = "blood_impact_zombie_01",
}
	
for _, v in pairs(CrossbowImpactParticles) do
	if v != "none" then
		PrecacheParticleSystem(v)
	end
end

if SERVER then

	hook.Add("EntityTakeDamage", "PHUNBASE_Crossbow_Bolt_TakeDamage", function( target, dmginfo )
		local ent = dmginfo:GetInflictor()
		if ent:GetClass() == "crossbow_bolt" and ent.CustomXBOWBolt then	
			dmginfo:SetMaxDamage(100)
			dmginfo:SetDamage(100)
			dmginfo:SetDamageForce( ent:GetVelocity() * 6)
			dmginfo:SetDamageType( bit.bor(DMG_GENERIC, DMG_NEVERGIB) )
			
			target.MatType = target:GetMaterialType()
			//print(target.MatType)
			if target:IsNPC() then
				effect = CrossbowImpactParticles[target:GetClass()]
				if effect != "none" then
					ParticleEffect((effect and effect or "blood_impact_red_01"), dmginfo:GetDamagePosition(), target:GetAngles())
				end
			end
		end
	end)

end
