
if SERVER then
	util.AddNetworkString("pb_values_setironsights")
	util.AddNetworkString("pb_values_setglironsights")
end

// called on init
function SWEP:SetupOrigValues()
	self.IsSuppressed = false
	self.UsesForegrip = false
	self.UsesGrenadeLauncher = false
	self.UsesExtMag = false
	self.UsesDrumMag = false

	self:SetupOrigClipSize()
	self:SetupOrigIronsights()
end

// clipsize
function SWEP:SetupOrigClipSize()
	self.Primary.ClipSize_ORIG = self.Primary.ClipSize
end

function SWEP:SetClipSize(size)
	self.Primary.ClipSize = size
end

function SWEP:RestoreClipSize()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG
end

// ironsights
function SWEP:SetupOrigIronsights()
	self.IronsightPos_ORIG = weapons.GetStored(self:GetClass()).IronsightPos or Vector()
	self.IronsightAng_ORIG = weapons.GetStored(self:GetClass()).IronsightAng or Vector()
	self.IronsightPos_CUR = self.IronsightPos_ORIG
	self.IronsightAng_CUR = self.IronsightAng_ORIG
end

function SWEP:SetIronsights(pos, ang)
	if SERVER then
		net.Start("pb_values_setironsights") // you lose precision by networking vectors, so, fuck this
			net.WriteEntity(self)
			net.WriteFloat(pos.x)
			net.WriteFloat(pos.y)
			net.WriteFloat(pos.z)
			net.WriteFloat(ang.x)
			net.WriteFloat(ang.y)
			net.WriteFloat(ang.z)
		net.Send(self.Owner)
	end
	
	self.IronsightPos_PREV = self.IronsightPos
	self.IronsightAng_PREV = self.IronsightAng
	self.IronsightPos = pos
	self.IronsightAng = ang
	self.IronsightPos_CUR = pos
	self.IronsightAng_CUR = ang
end

net.Receive("pb_values_setironsights", function()
	local wep = net.ReadEntity()
	local px, py, pz = net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
	local ax, ay, az = net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
	local pos, ang = Vector(px, py, pz), Vector(ax, ay, az)
	wep:SetIronsights(pos, ang)
end)

function SWEP:ResetPreviousIronsights()
	self:SetIronsights(self.IronsightPos_PREV, self.IronsightAng_PREV)
end

function SWEP:RestoreOriginalIronsights()
	self:SetIronsights(self.IronsightPos_ORIG, self.IronsightAng_ORIG)
end
