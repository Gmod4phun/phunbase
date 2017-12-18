/*
local Rags = {}

hook.Add("PreDrawHalos", "PHUNBASE_Halo_Experiments", function() // uses modified halo_phunbase module
	table.Empty(Rags)
	for k, v in pairs(ents.FindByClass("npc_*")) do
		table.insert(Rags, v)
	end
	for k, v in pairs(ents.FindByClass("prop_ragdoll*")) do
		if !v.Deleted then
			table.insert(Rags, v)
		end
		if !v.Deleting then
			v.Deleting = true
			timer.Simple(4, function() if !IsValid(v) then return end table.RemoveByValue(Rags, v) v.Deleted = true end)
		end
	end
	halo_phunbase.Add(Rags, Color(255,0,0, math.abs(math.sin(CurTime()*2)) * 255), 2, 2, 2, true, true, nil)
end)
*/

hook.Add("EntityTakeDamage", "PHUNBASE_BulletsHurtStriders", function(target, dmginfo)
	if target:GetClass() == "npc_strider" then
		if dmginfo:IsBulletDamage() then
			target:SetHealth(target:Health() - 2)
		end
	end
end)
