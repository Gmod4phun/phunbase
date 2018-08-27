
// firemodes code

if SERVER then
	util.AddNetworkString("PB_FIREMODE_CHANGE_NETWORK")
end

SWEP.FireModes = {"semi"}
SWEP.FireModeSelectDelay = 0.25
SWEP.FireModeSelectSound = "weapons/smg1/switch_single.wav"
SWEP.BurstShotsFired = 0

function SWEP:SafeAnimLogic()
end

function SWEP:FiremodeAnimLogic()
end

function SWEP:SetupOrigFireMode()
	local name = self.FireModes[1]
	local t = PHUNBASE.firemodes.registeredByID[name]
	
	self.Primary.Automatic = t.auto
	self.FireMode = name
	self.BurstAmount = t.burstamt
end

function SWEP:SelectFiremode(n)
	if CLIENT then return end
	
	if self:GetWeaponMode() == PB_WEAPONMODE_GL_ACTIVE then return end
	
	local t = PHUNBASE.firemodes.registeredByID[n]
	if !t then return end
	
	self.Primary.Automatic = t.auto
	self.FireMode = n
	self.BurstAmount = t.burstamt
	
	if self.BurstAmount > 0 then
		self.BurstShotsFired = math.random(0, self.BurstAmount) // when switching firemode, we don't know the position of the firing mechanism
	end
	
	if IsValid(self.Owner) and self == self.Owner:GetActiveWeapon() then // retarded gmod is retarded
		self:SetIsSwitchingFiremode(true)
		self:DelayedEvent(self.FireModeSelectDelay, function() self:SetIsSwitchingFiremode(false) end)
		self:SetNextPrimaryFire(CurTime() + self.FireModeSelectDelay)
		self:FiremodeAnimLogic()
	end
	
	net.Start("PB_FIREMODE_CHANGE_NETWORK")
		net.WriteEntity(self.Owner)
		net.WriteEntity(self)
		net.WriteString(n)
	net.Send(self.Owner) // !reminder! maybe broadcast to all players when dropped/picked up/etc, work on that later
end

function SWEP:CycleFiremodes()
	if self:GetIsSwitchingFiremode() then return end

	local t = self.FireModes
	
	if not t.last then
		t.last = 2
	else
		if not t[t.last + 1] then
			t.last = 1
		else
			t.last = t.last + 1
		end
	end
	
	if self:GetIron() then
		if self.FireModes[t.last] == "safe" then
			t.last = 1
		end
	end
	
	if self.FireMode != self.FireModes[t.last] and self.FireModes[t.last] then
		if IsFirstTimePredicted() then
			self:SelectFiremode(self.FireModes[t.last])
		end
	end
end

function SWEP:InitFiremodes()	
	t = self.FireModes[1]
	self.FireMode = t
	t = PHUNBASE.firemodes.registeredByID[t]
	
	self.Primary.Auto = t.auto
	self.BurstAmount = t.burstamt
end

function SWEP:_FiremodeThink()
	if self.BurstShotsFired == self.BurstAmount then // reset when we reached max amount of burst shots
		if !self.Owner:KeyDown(IN_ATTACK) then
			if self.BurstAmount and self.BurstAmount > 0 then
				self.BurstShotsFired = 0
				self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
			end
		end
	end
end

if CLIENT then
	net.Receive("PB_FIREMODE_CHANGE_NETWORK", function()
		local ply = net.ReadEntity()
		local wep = net.ReadEntity()
		local Mode = net.ReadString()
		
		if IsValid(wep) and wep.PHUNBASEWEP then
			local t = PHUNBASE.firemodes.registeredByID[Mode]
			
			wep.FireMode = Mode

			if t then
				wep.Primary.Automatic = t.auto
				wep.BurstAmount = t.burstamt
				
				if !wep.wasSafe and wep:IsSafe() then
					wep.wasSafe = true
					wep:SafeAnimLogic()
				elseif wep.wasSafe and !wep:IsSafe() then
					wep.wasSafe = false
					wep:SafeAnimLogic()
				end
				
				if IsValid(ply) then
					ply:EmitSound(wep.FireModeSelectSound, 70, math.random(92, 112))
				end
			end
		end
	end)
end
