AddCSLuaFile()

function EFFECT:Init(fx)
	local ent = fx:GetEntity()
	local pos = fx:GetOrigin()
	
	if not IsValid(ent) then
		self:Remove()
		return
	end
	
	ParticleEffect("blood_impact_synth_01", pos, ent:GetAngles(), ent)
	
	timer.Simple(2, function() if IsValid(self) then self:Remove() end end)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
