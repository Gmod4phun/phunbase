
if !CLIENT then return end

function SWEP:_drawFlashlight()	
	local vm = self.VM
	local att, att2
	local att = vm:LookupAttachment(self.FlashlightAttachmentName or "flashlight")
	
	if att then
		att2 = vm:GetAttachment(att)
	end
	
	local ply = self.Owner
	if !IsValid(ply) then return end
	
	if !self:GetFlashlightStateOld() and self:GetFlashlightState() then
		if !self.FLBrightness then
			self.FLBrightness = 20
		end
		self.FLBrightness = math.Approach(self.FLBrightness, 4, FrameTime() * 2 * 200/self.FLBrightness)
	end
	
	if !self.FLBrightness then return end
	
	if self:GetFlashlightStateOld() and !self:GetFlashlightState() then
		self.FLBrightness = 20
	end
	
	if IsValid(ply.PHUNBASE_Flashlight) then
		ply.PHUNBASE_Flashlight:SetPos(att2 and att2.Pos or ply:EyePos())
		ply.PHUNBASE_Flashlight:SetAngles(att2 and att2.Ang or ply:EyeAngles())
		ply.PHUNBASE_Flashlight:SetColor(Color(200,200,255))
		ply.PHUNBASE_Flashlight:SetBrightness( (ply:ShouldDrawLocalPlayer() or !self:GetFlashlightState() or !self.CustomFlashlight) and 0 or self.FLBrightness)
		ply.PHUNBASE_Flashlight:SetFOV(45 + self.FLBrightness/2)
		ply.PHUNBASE_Flashlight:Update()
	end
end

local function PHUNBASE_FLASHLIGHT_THINK_CL()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if !wep.PHUNBASEWEP then
		if ply.PHUNBASE_Flashlight then
			ply.PHUNBASE_Flashlight:Remove()
		end
		return
	end
	wep:_drawFlashlight()
end
hook.Add("Think","PHUNBASE_FLASHLIGHT_THINK_CL",PHUNBASE_FLASHLIGHT_THINK_CL)

local function PHUNBASE_FLASHLIGHT_CREATE()
	local ply = LocalPlayer()
	
	if IsValid(ply.PHUNBASE_Flashlight) then
		ply.PHUNBASE_Flashlight:Remove()
	end
	
	if !ply:Alive() then // if we are dead, dont even try to create a flashlight
		return
	end
	
	ply.PHUNBASE_Flashlight = ProjectedTexture()
	if IsValid(ply.PHUNBASE_Flashlight) then
		ply.PHUNBASE_Flashlight:SetPos(ply:GetPos())
		ply.PHUNBASE_Flashlight:SetAngles(ply:GetAngles())
		ply.PHUNBASE_Flashlight:SetColor(Color(0,0,0))
		ply.PHUNBASE_Flashlight:SetNearZ(1)
		ply.PHUNBASE_Flashlight:SetFarZ(732)
		ply.PHUNBASE_Flashlight:SetBrightness(1)
		ply.PHUNBASE_Flashlight:SetFOV(45)
		ply.PHUNBASE_Flashlight:SetEnableShadows(true)
		ply.PHUNBASE_Flashlight:SetTexture("effects/flashlight001")
		ply.PHUNBASE_Flashlight:Update()
	end
end
usermessage.Hook("PHUNBASE_FLASHLIGHT_CREATE", PHUNBASE_FLASHLIGHT_CREATE)

local function PHUNBASE_FLASHLIGHT_DESTROY()
	local ply = LocalPlayer()

	if IsValid(ply.PHUNBASE_Flashlight) then
		ply.PHUNBASE_Flashlight:Remove()
	end
end
usermessage.Hook("PHUNBASE_FLASHLIGHT_DESTROY", PHUNBASE_FLASHLIGHT_DESTROY)

local function PHUNBASE_FLASHLIGHT_PLAYANIM()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if IsValid(ply.PHUNBASE_Flashlight) and IsValid(wep) and wep.PHUNBASEWEP then
		wep:PlayVMSequence(wep:GetIron() and "lighton_iron" or "lighton")
	end
end
usermessage.Hook("PHUNBASE_FLASHLIGHT_PLAYANIM", PHUNBASE_FLASHLIGHT_PLAYANIM)
