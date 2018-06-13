
// the basic phunbase HL2 weapon icons/fonts and other stuff

function SWEP:DoDrawCrosshair()
	if self.Owner:GetInfoNum("phunbase_dev_iron_toggle", 0) == 1 or self.ShouldDrawDefaultCrosshair then
		return false
	else
		return true
	end
end

SWEP.HL2KillIcons = {
	["phun_hl2_ar2"] = "2",
	["phun_hl2_crossbow"] = "1",
	["phun_hl2_pistol"] = "-",
	["phun_hl2_smg"] = "/",
	["phun_hl2_357"] = ".",
	["phun_hl2_shotgun"] = "0",
	["phun_hl2_rpg"] = "3",
	["phun_hl2_grenade"] = "4",
	["phun_hl2_bugbait"] = "5",
	["phun_hl2_crowbar"] = "6",
	["phun_hl2_stunstick"] = "!",
	["phun_hl2_slam"] = "*",
}

function SWEP:InitHL2KillIcons()
	if CLIENT then
		local icon = self.HL2KillIcons[self.ClassName]
		if icon and !killicon.Exists(self.ClassName) then
			killicon.AddFont(self.ClassName, "HL2MPTypeDeath", icon, Color( 255, 80, 0, 255 ))
		end
	end
end

SWEP.HL2IconLetters = {
	["phun_hl2_ar2"] = "l",
	["phun_hl2_crossbow"] = "g",
	["phun_hl2_pistol"] = "d",
	["phun_hl2_smg"] = "a",
	["phun_hl2_357"] = "e",
	["phun_hl2_shotgun"] = "b",
	["phun_hl2_rpg"] = "i",
	["phun_hl2_grenade"] = "k",
	["phun_hl2_bugbait"] = "j",
	["phun_hl2_crowbar"] = "c",
	["phun_hl2_stunstick"] = "n",
	["phun_hl2_slam"] = "o",
}

function SWEP:FireAnimationEvent(pos,ang,event,name)
	return true
end

if CLIENT then
	function PHUNBASE.SetupFonts()
		surface.CreateFont( "PHUNBASE_HL2_SELECTICONS_1", { // weapon selecticon ghost font
			font = "HalfLife2",
			extended = true,
			size = ScreenScale(54),
			weight = 0,
			blursize = 8,
			scanlines = 3,
			antialias = true,
			additive = true,
		} )

		surface.CreateFont( "PHUNBASE_HL2_SELECTICONS_2", { // weapon selecticons
			font = "HalfLife2",
			extended = true,
			size = ScreenScale(54),
			weight = 0,
			antialias = true,
			additive = true,
		} )
	end
	PHUNBASE.SetupFonts()
	
	local font_scrH = ScrH()
	hook.Add("Think", "PHUNBASE_FontThink", function()
		if font_scrH != ScrH() then
			font_scrH = ScrH()
			PHUNBASE.SetupFonts()
		end
	end)
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	local iconcolor = self.Owner:GetAmmoCount(self:GetPrimaryAmmoType()) + self:Clip1() == 0 and Color(255, 0, 0, alpha) or Color(255, 235, 20, alpha)
	if self.HL2IconLetters[self:GetClass()] then -- HL2 weapons
		draw.Text({
			text = self.HL2IconLetters[self:GetClass()],
			font = "PHUNBASE_HL2_SELECTICONS_1",
			pos = {x + wide/2, y + tall/10},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = iconcolor
		})
		draw.Text({
			text = self.HL2IconLetters[self:GetClass()],
			font = "PHUNBASE_HL2_SELECTICONS_2",
			pos = {x + wide/2, y + tall/10},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_TOP,
			color = iconcolor
		})
	elseif self.UseCustomWepSelectIcon and self.CustomWepSelectIcon then
		self:CustomWepSelectIcon(x, y, wide, tall, alpha)
	else -- default GMod swep select icon
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( self.WepSelectIcon or surface.GetTextureID( "weapons/swep" ) )
		-- Borders
		y = y + 10
		x = x + 10
		wide = wide - 20
		surface.DrawTexturedRect(x, y, wide, wide / 2)
	end
end

PB_HL2_Weapon_Counterparts = {
	["weapon_ar2"] = "phun_hl2_ar2",
	["weapon_crossbow"] = "phun_hl2_crossbow",
	["weapon_pistol"] = "phun_hl2_pistol",
	["weapon_smg1"] = "phun_hl2_smg",
	["weapon_357"] = "phun_hl2_357",
	["weapon_shotgun"] = "phun_hl2_shotgun",
	["weapon_rpg"] = "phun_hl2_rpg",
	["weapon_frag"] = "phun_hl2_grenade",
	["weapon_bugbait"] = "phun_hl2_bugbait",
	["weapon_crowbar"] = "phun_hl2_crowbar",
	["weapon_stunstick"] = "phun_hl2_stunstick",
	["weapon_slam"] = "phun_hl2_slam",
}

hook.Add("PlayerCanPickupWeapon", "PB_HL2_Weapons_CanPickup", function(ply, wep)
	if PHUNBASE_HL2_REPLACE_DEFAULT then
		local new = PB_HL2_Weapon_Counterparts[wep:GetClass()]
		local tbl = weapons.GetStored(new)
		if new and tbl then
			if IsFirstTimePredicted() then
				local clipsize = tbl.Primary.ClipSize
				if !clipsize then clipsize = 1 end // if not defined, probably -1, just give 1 ammo
				if ply:HasWeapon(new) then
					if !wep.didgiveammo then
						ply:GiveAmmo(clipsize, tbl.Primary.Ammo)
					end
				else
					ply:Give(new)
				end
				wep.didgiveammo = true
				wep:Remove()
			end
			return false
		end
	end
end)

hook.Add("PlayerGiveSWEP", "PB_HL2_Weapons_GiveSWEP", function(ply, wep)
	if PHUNBASE_HL2_REPLACE_DEFAULT then
		local new = PB_HL2_Weapon_Counterparts[wep]
		if new then
			if !ply:HasWeapon(new) then
				ply:Give(new)
			end
			ply:SelectWeapon(new)
			return false
		end
	end
end)
