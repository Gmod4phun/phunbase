
// firemodes code

SWEP.FireModes = {"semi"}
SWEP.FireModeSelectDelay = 0.25
SWEP.FireModeSelectSound = "weapons/smg1/switch_single.wav"
SWEP.BurstShotsFired = 0

function SWEP:SafeAnimLogic()
end

function SWEP:FiremodeAnimLogic()
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
	
	self:SetIsSwitchingFiremode(true)
	self:DelayedEvent(self.FireModeSelectDelay, function() self:SetIsSwitchingFiremode(false) end)
	self:SetNextPrimaryFire(CurTime() + self.FireModeSelectDelay)
	self:FiremodeAnimLogic()
	
	umsg.Start("PHUNBASE_Firemode")
		umsg.Entity(self.Owner)
		umsg.String(n)
	umsg.End()
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
	local function PHUNBASE_ReceiveFiremode(um)
		local ply = um:ReadEntity()
		local Mode = um:ReadString()
		
		if IsValid(ply) then
			local wep = ply:GetActiveWeapon()
			wep.FireMode = Mode
			
			if IsValid(ply) and IsValid(wep) and wep.PHUNBASEWEP then
				local t = PHUNBASE.firemodes.registeredByID[Mode]
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
					
					if ply == LocalPlayer() then
						ply:EmitSound(wep.FireModeSelectSound, 70, math.random(92, 112))
					end
				end
			end
		end
	end
	usermessage.Hook("PHUNBASE_Firemode", PHUNBASE_ReceiveFiremode)
end
