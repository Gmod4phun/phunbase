//-----------------------------------------------------------------------------
// _registerVMShell adds passed entity to SWEPs table of active shells
//-----------------------------------------------------------------------------

function SWEP:_registerVMShell(ent)
	ent:SetNoDraw(true)
	ent._drawAsVM = CurTime() + 0.4
	
	table.insert(self._deployedShells, ent)
	
	local i = 1

	for _ = 1, #self._deployedShells do
		if !IsValid(self._deployedShells[i]) then
			table.remove(self._deployedShells, i)
		else
			i = i + 1
		end
	end
end

//-----------------------------------------------------------------------------
// drawVMShells iterates SWEPs table of active shells and draws them
//-----------------------------------------------------------------------------

function SWEP:drawVMShells()
	for _,v in pairs(self._deployedShells) do
		if IsValid(v) then
			if v._drawAsVM > CurTime() then
				v:DrawModel()
			else
				v:SetNoDraw(false)
			end
		end
	end
end

//-----------------------------------------------------------------------------
// CreateShell edited to use 
// - custom makeShell function
// - registerVMShell
//-----------------------------------------------------------------------------

local vm, att, pos, ang, velocity, align, shellEnt
local shellTable = {}

function SWEP:_makeParticle(particlename, attname)
	local realVM = self.RealViewModel
	local att = realVM:LookupAttachment(attname)
	
	if att then
		ParticleEffectAttach(particlename, PATTACH_POINT_FOLLOW, realVM, att)
	end
end

function SWEP:_makeShell()
	if self.Owner:ShouldDrawLocalPlayer() then
		return
	end
	
	shellTable.model = self.ShellModel or "models/weapons/shell.mdl"
	shellTable.scale = self.ShellScale or 0.75
	shellTable.sound = self.ShellSound or "PB_SHELLIMPACT_BRASS"
	
	shellTable.velmin_P = self.ShellAngularVelocity.Pitch_Min or 0
	shellTable.velmax_P = self.ShellAngularVelocity.Pitch_Max or 0
	shellTable.velmin_Y = self.ShellAngularVelocity.Yaw_Min or 0
	shellTable.velmax_Y = self.ShellAngularVelocity.Yaw_Max or 0
	shellTable.velmin_R = self.ShellAngularVelocity.Roll_Min or 0
	shellTable.velmax_R = self.ShellAngularVelocity.Roll_Max or 0
	
	shellTable.veladd_X = self.ShellVelocity.X or 0
	shellTable.veladd_Y = self.ShellVelocity.Y or 0
	shellTable.veladd_Z = self.ShellVelocity.Z or 0
	
	shellTable.wep = self
	
	vm = self.VM
	att = vm:GetAttachment(vm:LookupAttachment( self:GetShellAttachmentName() ))
	
	if att then
		self:DelayedEvent(self.ShellDelay or 0.01, function()
			att = vm:GetAttachment(vm:LookupAttachment( self:GetShellAttachmentName() ))
			
			pos = att.Pos
			ang = att.Ang
			velocity = self.Owner:GetVelocity() + ang:Forward() * (self.ShellEjectVelocity or 80)
			
			align = self.ShellViewAngleAlign or Angle(0,-90,0)
			ang:RotateAroundAxis(ang:Forward(), align.Forward)
			ang:RotateAroundAxis(ang:Right(), align.Right)
			ang:RotateAroundAxis(ang:Up(), align.Up)
			
			shellEnt = PHUNBASE.shells:make(
				pos,
				ang,
				velocity,
				shellTable
			)
			
			self:_registerVMShell(shellEnt)
		end)
	end
end

local SP = game.SinglePlayer()

function SWEP:MakeShell()
	if SP and SERVER then
		if !self.Owner:IsPlayer() then return end
		SendUserMessage("PHUNBASE_MAKESHELL", self.Owner)
		return
	end
	
	if CLIENT then
		self:_makeShell()
	end
end

if CLIENT then
	local function PHUNBASE_MAKESHELL()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		
		if not IsValid(wep) or not wep.PHUNBASEWEP then
			return
		end
		
		wep:MakeShell()
	end
	usermessage.Hook("PHUNBASE_MAKESHELL", PHUNBASE_MAKESHELL)
end
