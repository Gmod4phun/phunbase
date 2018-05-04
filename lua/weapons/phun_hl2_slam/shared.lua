SWEP.Base = "phun_base_nade"

SWEP.PrintName = "SLAM"
SWEP.Category = "PHUNBASE | HL2"
SWEP.Slot = 4
SWEP.SlotPos = 0

SWEP.ViewModelFOV = 54
SWEP.AimViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.HoldType = "slam"
SWEP.SprintHoldType = "normal"
SWEP.CrouchHoldType = "slam"
SWEP.ReloadHoldType = "slam"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ScriptedEntityType = "phunbase_weapon_hl2"

// weapon specific variables

SWEP.Primary.Ammo = "slam"
SWEP.Primary.DefaultClip = 3

SWEP.BasePos = Vector(0.000, 0.000, 0.000)
SWEP.BaseAng = Vector(0.000, 0.000, 0.000)

SWEP.IronsightPos = Vector(0.000, 0.000, 0.000)
SWEP.IronsightAng = Vector(0.000, 0.000, 0.000)

SWEP.SprintPos = Vector(0, 0, 0)
SWEP.SprintAng = Vector(-10, 0, 0)

SWEP.HolsterPos = Vector(0,0,20)
SWEP.HolsterAng = Vector(0,0,0)

SWEP.NearWallPos = Vector(1.510, -4.800, 1.030)
SWEP.NearWallAng = Vector(-13.560, 20.560, -11.080)

SWEP.NearWallPos = Vector(0.000, 0.000, 0.000)
SWEP.NearWallAng = Vector(0.000, 0.000, 0.000)

SWEP.PistolSprintSway = true
SWEP.UseIronTransitionAnims = false

SWEP.Sequences = {
	idle = "idle01",
	deploy = "draw",
	pullpin = "drawbackhigh",
	pullpin_alt = "drawbacklow",
	throw = "throw",
	underhand = "lob",
	holster = "drawbacklow",
	
	throw_idle = "throw_idle",
	throw_idle_ND = "throw_idle_ND",
	throw_throw1 = "throw_throw1",
	throw_throw2 = "throw_throw2",
	throw_throw1_ND = "throw_throw_ND1",
	throw_throw2_ND = "throw_throw_ND2",
	throw_draw = "throw_draw",
	throw_draw_ND = "throw_draw_ND",
	throw_to_tripmine_ND = "throw_to_tripmine_ND",
	throw_detonate = "throw_detonate",
	throw_to_stickwall = "throw_to_stickwall",
	throw_to_stickwall_ND = "throw_to_stickwall_ND",
	detonator_draw = "detonator_draw",
	detonator_idle = "detonator_idle",
	detonator_detonate = "detonator_detonate",
	detonator_throw_draw = "detonator_throw_draw",
	detonator_holster = "detonator_holster",
	tripmine_idle = "tripmine_idle",
	tripmine_draw = "tripmine_draw",
	tripmine_to_throw = "tripmine_to_throw",
	tripmine_attach1 = "tripmine_attach1",
	tripmine_attach2 = "tripmine_attach2",
	stickwall_idle = "stickwall_idle",
	stickwall_idle_ND = "stickwall_idle_ND",
	stickwall_attach1 = "stickwall_attach1",
	stickwall_attach2 = "stickwall_attach2",
	stickwall_to_throw = "stickwall_to_throw",
	stickwall_to_throw_ND = "stickwall_to_throw_ND",
}

SWEP.DeployTime = 1.1
SWEP.HolsterTime = 0.35
SWEP.ReloadTime = 2.4

SWEP.ViewModelMovementScale = 0.75

SWEP.NormalFlashlight = true
SWEP.CustomFlashlight = false
SWEP.FlashlightAttachmentName = "1"
SWEP.InstantFlashlight = false

SWEP.HL2_IconParams = {dist = 16, mdlOffset = Vector(0,0,0), camOffset = 0}

SWEP.NadeClass = "npc_satchel"
SWEP.NadeClassStick = "npc_tripmine"
SWEP.NadeModel = "models/weapons/w_slam.mdl"

SWEP.NadeFuseTime = 2.5
SWEP.NadeGetReadyTime = 0.45
SWEP.NadeThrowWaitTime = 0.17
SWEP.NadeRedeployWaitTime = 0.6

SWEP.SwitchAfterThrow = false

SWEP.CanUseUnderwater = true

SWEP.ActiveSatchels = {}

function SWEP:PutAwayAndRemove()
	local wep = self:GetOwner().PHUNBASE_LastWeapon
	if IsValid(wep) then
		self.HolsterTime = 0.01
		PHUNBASE.SelectWeapon(self:GetOwner(), wep:GetClass())
	end
	SafeRemoveEntity(self)
end

function SWEP:BlowUpSatchel(satchel)
	if IsValid(satchel) then
		satchel:Input("Explode", self:GetOwner(), self:GetOwner(), 0)
		self:RemoveSatchel(satchel)
	end
end

function SWEP:BlowUpSatchels()
	if self:GetAmmo() < 1 then
		self:PlayVMSequence("detonator_detonate")
		self:DelayedEvent(0.25, function() self:PlayVMSequence("detonator_holster") end)
	else
		self:PlayVMSequence("throw_detonate")
	end
	
	self:DelayedEvent(0.15, function()
		for _, satchel in pairs(self.ActiveSatchels) do
			self:BlowUpSatchel(satchel)
		end
	end)
	
	self:DelayedEvent(0.75, function()
		if self:GetAmmo() < 1 then
			self:PutAwayAndRemove()
		end
	end)
end

function SWEP:CreateTripmine()
	if SERVER and IsFirstTimePredicted() then
		local ply = self.Owner
		local EA =  ply:EyeAngles()
		local pos = ply:GetShootPos()
		pos = pos + EA:Right() * 5 - EA:Up() * 4 + EA:Forward() * 8
		local ang = Angle(30, 160, 65)
		
		local tr = util.TraceLine( {
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 64,
			filter = ply
		})
		
		if tr.Hit and tr.HitPos then
			local trip = ents.Create(self.AttachableSatchel and self.NadeClass or self.NadeClassStick)
			trip:SetPos(tr.HitPos - tr.HitNormal:Angle():Forward() * - 2)
			trip:SetAngles(tr.HitNormal:Angle() + Angle(90,0,0))
			
			trip.Owner = ply
			trip:SetSaveValue("m_hOwner", ply)
			trip:Spawn()
			trip:Activate()
			
			if self.AttachableSatchel then
				if tr.Entity or tr.HitWorld then
					local o = trip:GetPhysicsObject()
					if IsValid(o) then o:Sleep() end
					if IsValid(tr.Entity) then
						trip:SetParent(tr.Entity)
					end
				end
				self:AddSatchel(trip)
			else
				if tr.Entity and IsValid(tr.Entity) then
					constraint.NoCollide(trip, tr.Entity, 0, 0)
				end
			end
			
			self:TakePrimaryAmmo(1)
		end
	end
end

function SWEP:TripMineAnimLogic()
	local ND = self:GetSatchels() == 0
	
	self:PlayVMSequence(ND and "tripmine_attach1" or "stickwall_attach1")
	self:DelayedEvent(0.25, function()
		self:PlayVMSequence(ND and "tripmine_attach2" or "stickwall_attach2")
	end)
end

function SWEP:InitiateTripMine()
	local ply = self.Owner
	
	if self:GetAmmo() < 1 or self:GetIsWaiting() then return end
	
	self:SetNextPrimaryFire(CurTime() + 2)
	self:SetNextSecondaryFire(CurTime() + 2)
	
	self:SetIsWaiting(true)
	
	if IsFirstTimePredicted() then
		self:TripMineAnimLogic()
	end
	
	local ND = self:GetSatchels() == 0
	
	self:DelayedEvent(0.2, function()
		self:CreateTripmine()
	end)
	
	self:DelayedEvent(1, function()
		if self:GetAmmo() < 1 then
			self:PutAwayAndRemove()
		else
			self:PlayVMSequence(ND and "throw_draw_ND" or "throw_draw")
			self.ShouldBeTripMine = false
			self._slamIsNearwall = false
		end
	end)
	self:DelayedEvent(2, function() self:SetIsWaiting(false) end)
end

function SWEP:PrimaryAttack()
	if self:IsBusy() or self:GetIsWaiting() then return end
	if self.ShouldBeTripMine then
		self:InitiateTripMine()
	else
		self:InitiateThrow()
	end
end

function SWEP:SecondaryAttack()
	if self:GetSatchels() > 0 and !self:GetIsWaiting() and !self:GetIsDeploying() then
		self:BlowUpSatchels()
		self:SetNextPrimaryFire(CurTime() + 0.75)
		self:SetNextSecondaryFire(CurTime() + 0.75)
	end
end

function SWEP:AddSatchel(ent)
	local index = #self.ActiveSatchels + 1
	self.ActiveSatchels[index] = ent
	ent.ActiveSatchelIndex = index
end

function SWEP:RemoveSatchel(ent)
	self.ActiveSatchels[ent.ActiveSatchelIndex] = nil
end

function SWEP:GetSatchels()
	return #self.ActiveSatchels
end

function SWEP:GetAmmo()
	return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
end

function SWEP:DeployAnimLogic()
	local ammo = self:GetAmmo()
	
	if self:GetIsWaiting() then // after throwing, should have a detonator in hand
		if ammo > 0 then
			self:PlayVMSequence(self.SatchelsOnThrow != 0 and "throw_draw" or "detonator_throw_draw")
		else
			self:PlayVMSequence(self.SatchelsOnThrow != 0 and "detonator_idle" or "detonator_draw")
		end
	else
		if ammo > 0 then
			self:PlayVMSequence(self:GetSatchels() == 0 and "throw_draw_ND" or "detonator_throw_draw")
		else
			self:PlayVMSequence("detonator_draw")
		end
	end
end

function SWEP:HolsterAnimLogic()
	local ND = self:GetSatchels() == 0
	local ammo = self:GetAmmo()
	
	if ammo > 0 then
		self:PlayVMSequence(ND and "throw_draw_ND" or "detonator_throw_draw", -2, 1)
	else
		self:PlayVMSequence("detonator_holster")
	end
end

function SWEP:PlayIdleAnim() // overidden function
	local empty = self:Clip1() == 0
	local anim = self:GetIron() and "idle_iron" or "idle"
	if empty then
		anim = anim.."_empty"
	end
	if self.Sequences[anim] then
		//self:PlayVMSequence(anim, 1)
	end
end

function SWEP:ThrowAnimLogic(prepare)
	local ND = self:GetSatchels() == 0
	
	if prepare then
		self:PlayVMSequence(ND and "throw_throw1_ND" or "throw_throw1")
	else
		self:PlayVMSequence(ND and "throw_throw2_ND" or "throw_throw2")
	end
end

function SWEP:TossNade(ent)
	local ply = self.Owner
	local EA =  ply:EyeAngles()
	local dummy = self.NadeEnt

	local phys = dummy:GetPhysicsObject()
	if IsValid(phys) then
		local force = 1000
		
		if ply:KeyDown(IN_FORWARD) then
			force = force + ply:GetVelocity():Length()
		end
		
		if ply:Crouching() and ply:OnGround() and !self.WasPrimary then
			local ea = EA
			ea.p = 0
			local grenang = ea
			grenang:RotateAroundAxis(grenang:Forward(), 90)
			
			local b, t = ply:GetHullDuck()
			local diff = t.z - b.z
			
			dummy:SetPos(ply:GetShootPos() - Vector(0,0,diff - 12))
			dummy:SetAngles(grenang)
			phys:SetVelocity(ea:Forward() * force * 0.75)
			phys:AddAngleVelocity(Vector(0, 0, 0))
		else
			phys:SetVelocity(EA:Forward() * force * self.ThrowPower + Vector(0, 0, 100))
			phys:AddAngleVelocity(Vector(450, -550, -420))
		end
	end
	
	self:AddSatchel(ent)
end

function SWEP:OnNadeTossed()
	local nade = self.NadeEnt
	local ply = self.Owner
	nade:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	nade:SetSaveValue("m_hThrower", ply)
	nade:SetSaveValue("m_hOwner", ply)
	nade:SetSaveValue("m_bIsLive", true)
	nade:SetSaveValue("m_flDamage", 150)
	nade:SetSaveValue("m_takedamage", 2) // gets blown up by stuff
	nade:CallOnRemove( "OnRemoveSatchel", function(nade)
		if IsValid(nade.Weapon) then
			nade.Weapon:RemoveSatchel(nade)
		end
	end)
end

// NadeThrowState - 0 = getting ready to throw, 1 = throwing, 2 = redeploying
function SWEP:InitiateThrow()
	local ply = self.Owner
	
	if self:GetAmmo() < 1 then return end
	
	if self:GetIsDeploying() or self:GetIsSprinting() or self:GetIsNearWall() or self:IsBusy() or self:IsFlashlightBusy() or self:GetIsWaiting() then return end
	
	self:SetIsWaiting(true)
	
	if IsFirstTimePredicted() then
		self:ThrowAnimLogic(true)
	end
	
	self.SatchelsOnThrow = self:GetSatchels()
	
	self.NadeThrowState = 0
	self.NextNadeAction = CurTime() + self.NadeGetReadyTime
end

SWEP.ShouldBeTripMine = false
SWEP._slamIsNearwall = false

function SWEP:AdditionalThink()
	local ply = self:GetOwner()
	if SERVER then
		if ply and self:GetAmmo() > 0 then
		
			local tr = util.TraceLine( {
				start = ply:EyePos(),
				endpos = ply:EyePos() + ply:EyeAngles():Forward() * 64,
				filter = ply
			})
			
			if !self:GetIsWaiting() then
				if tr.Hit or tr.HitWorld then
					if !self.ShouldBeTripMine then
						if !self._slamIsNearwall then
							self:SetIsWaiting(true)
							self.ShouldBeTripMine = true
							self:PlayVMSequence(self:GetSatchels() > 0 and "throw_to_stickwall" or "throw_to_tripmine_ND")
							self:DelayedEvent(1.3, function() self._slamIsNearwall = true self:SetIsWaiting(false) self:SetNextPrimaryFire(CurTime() + 0.1) end)
						end
					end
				else
					if self.ShouldBeTripMine then
						if self._slamIsNearwall then
							self:SetIsWaiting(true)
							self.ShouldBeTripMine = false
							self:PlayVMSequence(self:GetSatchels() > 0 and "stickwall_to_throw" or "tripmine_to_throw")
							self:DelayedEvent(1.3, function() self._slamIsNearwall = false self:SetIsWaiting(false) end)
						end
					end
				end
			end
		end
		
		if !self.lastAmmo or self.lastAmmo != self:GetAmmo() then
			if self.lastAmmo == 0 and self:GetAmmo() >= 1 then
				local ND = self:GetSatchels() == 0
				
				if self:GetActiveSequence() != "detonator_throw_draw" then
					self:PlayVMSequence(ND and "throw_draw_ND" or "throw_draw")
				end
			end
			self.lastAmmo = self:GetAmmo()
		end
		
	end
	
	if (SP and SERVER) or IsFirstTimePredicted() then
		local ply = self.Owner
		if self.NadeThrowState == 0 and self.NextNadeAction and CurTime() > self.NextNadeAction then
			//if !ply:KeyDown(IN_ATTACK) then
				self:ThrowAnimLogic(false)
				self.ThrowPower = 0.35
				self.WasPrimary = true
				
				self.NadeThrowState = 1
				self.NextNadeAction = CurTime() + self.NadeThrowWaitTime
			//end
		end
		
		if self.NadeThrowState == 1 and self.NextNadeAction and CurTime() > self.NextNadeAction then
			self:CreateNade()
			ply:SetAnimation(PLAYER_ATTACK1)
			
			self.NadeThrowState = 2
			self.NextNadeAction = CurTime() + self.NadeRedeployWaitTime
		end
		
		if self.NadeThrowState == 2 and self.NextNadeAction and CurTime() > self.NextNadeAction then
			if SERVER then
				PHUNBASE.ForceDeployWeapon(self.Owner, self:GetClass())
			end
			
			self.NadeThrowState = nil
			self.NextNadeAction = nil
			self:SetIsWaiting(false)
		end
	end
end
