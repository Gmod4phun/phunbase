
if SERVER then
	util.AddNetworkString("PB_UPDATEAMMO") // true for primary, false for secondary

	function SWEP:UpdatePrimaryAmmo(new) // dont update if we already use the new one, or if weapon is dropped (no owner)
		if self.Primary.Ammo == new or !IsValid(self.Owner) then return end
		
		local ply = self.Owner
		local TotalAmmo = ply:GetAmmoCount(self:GetPrimaryAmmoType())
		ply:SetAmmo(TotalAmmo + self:Clip1(), self:GetPrimaryAmmoType())
		self:SetClip1(0)
		
		self.Primary.Ammo = new
		net.Start("PB_UPDATEAMMO")
			net.WriteBool(true)
			net.WriteEntity(self)
			net.WriteString(new)
		net.Broadcast()
	end
	
	function SWEP:UpdateSecondaryAmmo(new)
		if self.Secondary.Ammo == new or !IsValid(self.Owner) then return end
	
		local ply = self.Owner
		local TotalAmmo = ply:GetAmmoCount(self:GetSecondaryAmmoType())
		ply:SetAmmo(TotalAmmo + self:Clip2(), self:GetSecondaryAmmoType())
		self:SetClip2(0)
		
		self.Secondary.Ammo = new
		net.Start("PB_UPDATEAMMO")
			net.WriteBool(false)
			net.WriteEntity(self)
			net.WriteString(new)
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive("PB_UPDATEAMMO", function()
		local primary, wep, ammo = net.ReadBool(), net.ReadEntity(), net.ReadString()
		if primary then
			wep.Primary.Ammo = ammo
		else
			wep.Secondary.Ammo = ammo
		end
	end)
end
