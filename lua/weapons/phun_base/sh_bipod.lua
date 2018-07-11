
local SP = game.SinglePlayer()

if SERVER then
    util.AddNetworkString("PHUNBASE_BipodDeployAngle")
end

// bipod status
PB_BIPODSTATE_READY = 0
PB_BIPODSTATE_ENTER = 1
PB_BIPODSTATE_EXIT = 2
PB_BIPODSTATE_SHOULDEXIT = 3

SWEP.BipodPos = Vector()
SWEP.BipodAng = Vector()

SWEP.BipodTransitionDelay = 1 // time it takes to change to/from bipod mode

SWEP.BipodMoveTime = 0

SWEP.BipodAngleLimitPitch = 18
SWEP.BipodAngleLimitYaw = 35

function SWEP:BipodModeAnimLogic()
end

function SWEP:EnterBipodMode(nodelay)
	if !self.UsesBipod then return end
	
	if !nodelay then self:AddGlobalDelay(self.BipodTransitionDelay) end
	
	self:SetBipodState(PB_BIPODSTATE_ENTER)
	self:DelayedEvent(self.BipodTransitionDelay, function() self:SetBipodState(PB_BIPODSTATE_READY) end)
	self:SetWeaponMode(PB_WEAPONMODE_BIPOD_ACTIVE)
	
	self:BipodModeAnimLogic()
	self:RememberBipodDeployAngle()
end

function SWEP:ExitBipodMode(nodelay)
	if !self.UsesBipod then return end
	
	if !nodelay then self:AddGlobalDelay(self.BipodTransitionDelay) end
	
	self:SetBipodState(PB_BIPODSTATE_EXIT)
	self:BipodModeAnimLogic()
	
	self:SetWeaponMode(PB_WEAPONMODE_NORMAL)
end

function SWEP:IsBipodDeployed()
	return self:GetWeaponMode() == PB_WEAPONMODE_BIPOD_ACTIVE
end

function SWEP:IsBipodTransitioning()
	return self:IsBipodDeployed() and (self:GetBipodState() == PB_BIPODSTATE_ENTER or self:GetBipodState() == PB_BIPODSTATE_EXIT)
end

function SWEP:ShouldBipodExit()
	return self:IsBipodDeployed() and self:GetBipodState() == PB_BIPODSTATE_SHOULDEXIT
end

function SWEP:ShouldBeUsingBipodOffsets()
	return self:IsBipodDeployed() and self.BipodDeployAngle and (self:GetBipodState() == PB_BIPODSTATE_READY or self:GetBipodState() == PB_BIPODSTATE_ENTER)
end

function SWEP:AllowBipodMode()
	self.UsesBipod = true
end

function SWEP:DisallowBipodMode()
	if self:IsBipodDeployed() then
		self:ExitBipodMode(true)
	end
	self.UsesBipod = false
end

local td = {}
local tr

function SWEP:CanDeployBipod()
	if self.Owner:GetVelocity():Length() == 0 and self.Owner:EyeAngles().p <= 45 and self.Owner:EyeAngles().p >= -30 then
		local sp = self.Owner:GetShootPos()
		local aim = self.Owner:GetAimVector()
		
		td.start = sp
		td.endpos = td.start + aim * 50
		td.filter = self.Owner
		
		tr = util.TraceLine(td)
		
		if not tr.Hit then
			td.start = sp
			td.endpos = td.start + Vector(aim.x, aim.y, -1) * 25
			td.filter = self.Owner
			td.mins = Vector(-8, -8, -1)
			td.maxs = Vector(8, 8, 1)
			
			tr = util.TraceHull(td)
			
			if tr.Hit and tr.HitPos.z + 10 < sp.z and tr.Entity then
				if not tr.Entity:IsPlayer() and not tr.Entity:IsNPC() then
					return true
				end
			end
		end
	end
	
	return false
end

function SWEP:RememberBipodDeployAngle()
	if SP and SERVER then
		net.Start("PHUNBASE_BipodDeployAngle")
			net.WriteAngle(self.Owner:EyeAngles())
		net.Send(self.Owner)
	else
		self.BipodDeployAngle = self.Owner:EyeAngles()
	end
end

if CLIENT then
	net.Receive("PHUNBASE_BipodDeployAngle", function()
		local ang = net.ReadAngle()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and wep.PHUNBASEWEP then
			wep.BipodDeployAngle = ang
		end
	end)
end

function SWEP:_BipodThink()
	if (SP and SERVER) or !SP then
		if self:IsBipodDeployed() then
			if !self:CanDeployBipod() and !self:ShouldBipodExit() then
				self:SetBipodState(PB_BIPODSTATE_SHOULDEXIT)
			end
			
			if !self:GetIsReloading() and !self:IsGlobalDelayActive() and self:ShouldBipodExit() then
				self:ExitBipodMode()
			end
		end
		
		if !self:GetIsReloading() and !self:IsGlobalDelayActive() then
			if self.UsesBipod and self.Owner:KeyPressed(IN_USE) then
				if self:IsBipodDeployed() then
					self:ExitBipodMode()
				else
					if self:CanDeployBipod() and !self:IsBusyForBipodDeploying() then
						self:EnterBipodMode()
					end
				end
			end
		end
	end
end

local ang, CT, ply, wep, EA, dif

local function PHUNBASE_Bipod_CreateMove(cmd)
	ang = cmd:GetViewAngles()
	CT = CurTime()
	
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.PHUNBASEWEP then
		if wep:ShouldBeUsingBipodOffsets() then
			EA = ply:EyeAngles()
			dif = math.AngleDifference(EA.y, wep.BipodDeployAngle.y)
			
			if dif >= wep.BipodAngleLimitYaw then
				ang.y = wep.BipodDeployAngle.y + wep.BipodAngleLimitYaw
			elseif dif <= -wep.BipodAngleLimitYaw then
				ang.y = wep.BipodDeployAngle.y - wep.BipodAngleLimitYaw
			end
			
			dif = math.AngleDifference(EA.p, wep.BipodDeployAngle.p)
			
			if dif >= wep.BipodAngleLimitPitch then
				ang.p = wep.BipodDeployAngle.p + wep.BipodAngleLimitPitch
			elseif dif <= -wep.BipodAngleLimitPitch then
				ang.p = wep.BipodDeployAngle.p - wep.BipodAngleLimitPitch
			end

			cmd:SetViewAngles(ang)
		end
	end
end
hook.Add("CreateMove", "PHUNBASE_Bipod_CreateMove", PHUNBASE_Bipod_CreateMove)
