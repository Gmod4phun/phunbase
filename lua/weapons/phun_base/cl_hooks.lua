
local function PHUNBASE_PostDrawVM(viewmodel,player,weapon)
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.PHUNBASEWEP then
		return
	end
	
	render.SetBlend(1)
	
	wep:processBlur()
	wep:performViewmodelMovement()
	
	-- cam.Start3D(EyePos(), EyeAngles(), wep:GetCorrectCameraFOV(), nil, nil, ScrW(), ScrH(), 0.1, 1024)
		wep:drawViewModel()
	-- cam.End3D()
end
hook.Add("PostDrawViewModel", "PHUNBASE_PostDrawVM", PHUNBASE_PostDrawVM)

function PHUNBASE_StartCommand(ply, ucmd)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.PHUNBASEWEP then
		if wep == wep.SwitchWep then
			wep.SwitchWep = nil
		end
		local switchTo = wep.SwitchWep
		if IsValid(switchTo) then
			ucmd:SelectWeapon(switchTo)
		else
			wep.SwitchWep = nil
		end
	end
end
hook.Add("StartCommand", "PHUNBASE_StartCommand", PHUNBASE_StartCommand)

local function PHUNBASE_PreDrawGMHands()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.PHUNBASEWEP then
		return
	end
	render.SetBlend(0) // dont draw GM hands if using PhunBase weapon
end
hook.Add("PreDrawPlayerHands", "PHUNBASE_PreDrawGMHands", PHUNBASE_PreDrawGMHands)

local function PHUNBASE_PostDrawGMHands()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	if not IsValid(wep) or not wep.PHUNBASEWEP then
		return
	end
	render.SetBlend(1) // back to normal drawing
end
hook.Add("PostDrawPlayerHands", "PHUNBASE_PostDrawGMHands", PHUNBASE_PostDrawGMHands)

function PHUNBASE_RenderScene()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
		
	if not IsValid(wep) or not wep.PHUNBASEWEP then
		return
	end
	
	if wep.DrawRT and wep.RTScope_Enabled then
		wep:DrawRT()
	end
	
end
hook.Add("RenderScene", "PHUNBASE_RenderScene", PHUNBASE_RenderScene)

if CLIENT then

// SOUND HOOKER
local function PHUNBASE_SoundThink()
	local ply = LocalPlayer()

	if ply:Alive() then
		local wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and wep.PHUNBASEWEP then
			if wep.CurSoundTable then
				local t = wep.CurSoundTable[wep.CurSoundEntry]
				local CT = UnPredictedCurTime()
				
				//if t.time == 0 then t.time = 0.035 end // double sound fix
				
				if CT >= wep.SoundTime + t.time / wep.SoundSpeed then
					if t.sound and t.sound ~= "" and !t.wasplayed then
						wep:EmitSound(t.sound, 70, 100)
						//print(wep.Sequence)
						//print(t.sound)
						t.wasplayed = true
						wep:DelayedEvent(0.1, function() t.wasplayed = false end) // double sound fix
					end
					
					if t.callback then
						t.callback(wep)
					end
					
					if wep.CurSoundEntry and wep.CurSoundTable[wep.CurSoundEntry + 1] then
						wep.CurSoundEntry = wep.CurSoundEntry + 1
					else
						wep.CurSoundTable = nil
						wep.CurSoundEntry = nil
						wep.SoundTime = nil
					end
				end
			end
		end
	end
end
hook.Add("Think", "PHUNBASE_SoundThink", PHUNBASE_SoundThink)

end
