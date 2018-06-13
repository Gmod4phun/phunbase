
// weapon customization functions

if SERVER then
	util.AddNetworkString("PB_CUSTOMIZATION_CYCLEATTACHMENT")
end

if CLIENT then
	surface.CreateFont( "PB_CUSTMENU_FONT_60",
    {
        font      = "BF4 Numbers",
        size      = 60,
        weight    = 200,
    })
	
	surface.CreateFont( "PB_CUSTMENU_FONT_80",
    {
        font      = "BF4 Numbers",
        size      = 80,
        weight    = 200,
    })
end

SWEP.EnableCustomization = false
SWEP.CustomizationMenuSize = 1
SWEP.ActiveCategoriesData = {}

function SWEP:SetAttachmentIronsights(name) // if the attachment changes the ironsights, we call this on attach
	if self.AttachmentIronsights then
		local t = self.AttachmentIronsights[name]
		if t then
			self:SetIronsights(t.pos, t.ang)
		end
	end
end

function SWEP:RestoreAttachmentIronsights(name) // if the attachment was changing ironsights, we call this on detach and reset them
	if self.AttachmentIronsights then
		local t = self.AttachmentIronsights[name]
		if t then
			self:ResetPreviousIronsights()
		end
	end
end

function SWEP:unloadWeapon()
	local c = self:Clip1()
	local at = self:GetPrimaryAmmoType()
	local a = self.Owner:GetAmmoCount(at)
	self.Owner:SetAmmo(c + a, at)
	self:SetClip1(0)
end

function SWEP:CustomizeAnimLogic()
end

function SWEP:CloseCustomizationMenu()
	if self:GetIsCustomizing() then
		self:ToggleCustomizationMenu(true)
	end
end

function SWEP:ToggleCustomizationMenu(force)
	if !force then
		if self:IsBusyForCustomizing() then return end
	end
	
	if !self.EnableCustomization then return end
	
	self:SetIsCustomizing(!self:GetIsCustomizing())
	
	self:CustomizeAnimLogic()
end

function SWEP:SetupActiveAttachmentNames()
	local atts = self.Attachments
	if !self.Attachments then return end
	
	for categoryindex, data in pairs(atts) do
		self.ActiveCategoriesData[categoryindex] = {attname = "NONE", attindex = 0}
	end
end

function SWEP:RunAttachmentsThinkFunc()
	local atts = self.Attachments
	if !self.Attachments then return end
	
	for k, v in pairs(self.ActiveCategoriesData) do
		local _1, _2, attindex, _3 = self:GetActiveAttachmentInCategory(k)
		
		local atttable = PHUNBASE:getAttachmentTableByName(atts[k].attachments[attindex])
		
		if atttable and atttable.think then
			atttable.think(self)
		end
	end
end

function SWEP:RunAttachmentsRenderFunc()
	local atts = self.Attachments
	if !self.Attachments then return end
	
	for k, v in pairs(self.ActiveCategoriesData) do
		local _1, _2, attindex, _3 = self:GetActiveAttachmentInCategory(k)
		
		local atttable = PHUNBASE:getAttachmentTableByName(atts[k].attachments[attindex])
		
		if atttable and atttable.render then
			atttable.render(self)
		end
	end
end

function SWEP:GetAttachmentCategoryCount()
	local cats = self.Attachments
	if !cats then
		return 0
	else
		return #cats
	end
end

function SWEP:GetActiveAttachmentInCategory(categoryindex)
	local atts = self.Attachments
	if !atts then return 0, "NONE", 0, "NONE" end
	
	local categorydata = atts[categoryindex]
	local attsInCategory = categorydata.attachments
	
	local catindex = categoryindex
	local catname = atts[catindex].name
	local attindex = self.ActiveCategoriesData[catindex].attindex
	local attname = self.ActiveCategoriesData[catindex].attname
	
	return catindex, catname, attindex, attname
end

function SWEP:GetAttachmentInfo(categoryindex, attachmentindex)
	local atts = self.Attachments
	if !atts then return end
	
	local attinfo = PHUNBASE:getAttachmentTableByName(atts[categoryindex].attachments[attachmentindex])
	
	if attinfo then
		return attinfo
	else
		return nil
	end
end

function SWEP:GetAttachmentIndexAndName(cat, attindex)
	local info = self:GetAttachmentInfo(cat, attindex)
	if info then
		return attindex, info.menuName
	else
		return 0, "NONE"
	end
end

function SWEP:GetCurrentAttachmentInCategory(categoryindex)
	local curcati, curcatn, curai, curan = self:GetActiveAttachmentInCategory(categoryindex)
	return curai, curan
end

function SWEP:GetNextAttachmentInCategory(categoryindex)
	local curcati, curcatn, curai, curan = self:GetActiveAttachmentInCategory(categoryindex)
	local nextai, nextan = self:GetAttachmentIndexAndName(curcati, curai+1)
	return nextai, nextan
end

function SWEP:IsValidCategoryIndex(categoryindex)
	local atts = self.Attachments
	if !self.Attachments then return false end
	if self.Attachments[categoryindex] then return true else return false end
end

function SWEP:CycleAttachmentInCategory(categoryindex)
	if !self:IsValidCategoryIndex(categoryindex) then return end
	
	if SERVER then
		net.Start("PB_CUSTOMIZATION_CYCLEATTACHMENT")
			net.WriteEntity(self)
			net.WriteUInt(categoryindex, 4)
		net.Send(self.Owner)
	end

	local curai, curan = self:GetCurrentAttachmentInCategory(categoryindex)
	self:RemoveAttachmentData(categoryindex, curai)
	
	local nextai, nextan = self:GetNextAttachmentInCategory(categoryindex)
	self.ActiveCategoriesData[categoryindex] = {attname = nextan, attindex = nextai}
	
	self:ApplyAttachmentData(categoryindex, nextai)
	
	self:CustomizeAnimLogic()
	
	if CLIENT and self:GetIsCustomizing() then
		self.Owner:EmitSound("PB_CUSTMENU_Select")
	end
end

function SWEP:RemoveAllAttachments()
	local cats = self:GetAttachmentCategoryCount()
	if cats > 0 then
		for i = 1, cats do
			local catindex, catname, attindex, attname = self:GetActiveAttachmentInCategory(i)
			if attindex > 0 then
				self:RemoveAttachmentData(catindex, attindex)
			end
		end
	end
end

function SWEP:RemoveAttachmentData(catindex, attindex)
	local atts = self.Attachments
	if !self.Attachments then return end
	
	local oldAttTbl = PHUNBASE:getAttachmentTableByName(atts[catindex].attachments[attindex])
	
	if oldAttTbl then // oldAttTbl is the attachment table we are going to unequip, so run shit from it if needed
		if self.VElements then
			local velementTable = self.VElements[oldAttTbl.name]
			if velementTable then
				velementTable.active = false // deactivate our velement
			end
		end
		
		if self.VElements and self.DisableVElements then // reactivate any velements if they were deactivated by this attachment
			local toDisable = self.DisableVElements[oldAttTbl.name]
			if toDisable then
				for _, name in pairs(toDisable) do
					local element = self.VElements[name]
					if element then
						element.active = true
					end
				end
			end
		end

		if self.VElements and self.EnableVElements then // deactivate velements that were activated by this attachment on equip
			local toEnable = self.EnableVElements[oldAttTbl.name]
			if toEnable then
				for _, name in pairs(toEnable) do
					local element = self.VElements[name]
					if element then
						element.active = false
					end
				end
			end
		end
		
		if self.VElements and self.ReplaceVElements then // restore the replaced velements
			local toReplace = self.ReplaceVElements[oldAttTbl.name]
			if toReplace then
				for old, new in pairs(toReplace) do
					local oldElement, newElement = self.VElements[old], self.VElements[new]
					if oldElement and newElement then // we are enabling the old and disabling the new one
						oldElement.active = true
						newElement.active = false
					end
				end
			end
		end
		
		if oldAttTbl.detachCallback then
			oldAttTbl.detachCallback(self)
		end
		
		self:RestoreAttachmentIronsights(oldAttTbl.name)
	end
end

function SWEP:ApplyAttachmentData(catindex, attindex)
	local atts = self.Attachments
	if !self.Attachments then return end

	local newAttTbl = PHUNBASE:getAttachmentTableByName(atts[catindex].attachments[attindex])
	
	if newAttTbl then // newAttTbl is the attachment table we have just equipped
		if self.VElements then
			local velementTable = self.VElements[newAttTbl.name]
			if velementTable then
				velementTable.active = true // activate our velement
				
				if newAttTbl.reticleTable then // setup the reticle table for the velement if the attachment uses one
					velementTable.reticleTable = newAttTbl.reticleTable
				end
			end
		end
		
		if self.VElements and self.DisableVElements then // deactivate velements that are supposed to be deactivated by this attachment
			local toDisable = self.DisableVElements[newAttTbl.name]
			if toDisable then
				for _, name in pairs(toDisable) do
					local element = self.VElements[name]
					if element then
						element.active = false
					end
				end
			end
		end
		
		if self.VElements and self.EnableVElements then // activate velements that are supposed to be activated by this attachment
			local toEnable = self.EnableVElements[newAttTbl.name]
			if toEnable then
				for _, name in pairs(toEnable) do
					local element = self.VElements[name]
					if element then
						element.active = true
					end
				end
			end
		end
		
		if self.VElements and self.ReplaceVElements then // replace velements if defined
			local toReplace = self.ReplaceVElements[newAttTbl.name]
			if toReplace then
				for old, new in pairs(toReplace) do
					local oldElement, newElement = self.VElements[old], self.VElements[new]
					if oldElement and newElement then
						oldElement.active = false
						newElement.active = true
					end
				end
			end
		end
		
		if newAttTbl.attachCallback then
			newAttTbl.attachCallback(self)
		end
		
		self:SetAttachmentIronsights(newAttTbl.name)
	end
end

if SERVER then
	concommand.Add("pb_custmenu_cycleslot", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()
		local slot = tonumber(args[1])
		
		if wep.PHUNBASEWEP and wep.EnableCustomization then
			wep:CycleAttachmentInCategory(slot)
		end
	end)

	concommand.Add( "pb_custmenu_toggle", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()

		if wep.PHUNBASEWEP then
			wep:ToggleCustomizationMenu()
		end
	end)
end

if CLIENT then
	function PHUNBASE.drawShadowText(text, font, x, y, color, alignx, aligny, shiftx, shifty)
		shiftx = shiftx or 0
		shifty = shifty or 0
		draw.SimpleText(text, font, x + shiftx, y + shifty, Color(0,0,0,color.a), alignx, aligny)
		draw.SimpleText(text, font, x, y, color, alignx, aligny)
	end

	local menuAlpha = 0
	local camStartPos
	function SWEP:_drawCustomizationMenu()
		if !self.Attachments then return end
		
		menuAlpha = math.Approach(menuAlpha, self:GetIsCustomizing() and !self:GetIsHolstering() and 1 or 0, FrameTime() * 5)
		
		if menuAlpha > 0 then
			local att = self.VM:GetAttachment(self.CustomizationMenuAttachmentName and self.VM:LookupAttachment(self.CustomizationMenuAttachmentName) or 1)
			
			if att then
				camStartPos = att.Pos
			else
				camStartPos = EyePos() + EyeAngles():Forward() * 16
			end
			
			local ang = EyeAngles()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), -90)
			
			local catdata = self.ActiveCategoriesData
			
			cam.Start3D2D(camStartPos, ang, 0.01 * self.CustomizationMenuSize)
				cam.IgnoreZ(true)
					PHUNBASE.drawShadowText("ACCESSORY CUSTOMIZATION", "PB_CUSTMENU_FONT_80", 0, -10, Color(255,255,255,255 * menuAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 4, 4)
					
					for categoryindex, attdata in pairs(catdata) do
						local catindex, catname, attindex, attname = self:GetActiveAttachmentInCategory(categoryindex)
						PHUNBASE.drawShadowText("["..catindex.."] "..catname..": "..attname, "PB_CUSTMENU_FONT_60", 0, catindex * 70, Color(0,130,250,255 * menuAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, 2)
					end
				cam.IgnoreZ(false)
			cam.End3D2D()
		end
	end
	
	local stopBinds = {
		["invprev"] = true,
		["invnext"] = true,
	}
	hook.Add("PlayerBindPress", "PB_CUSTOMIZATION_MENU_BINDPRESS", function(ply, bind, pressed)
		local wep = ply:GetActiveWeapon()

		if pressed and wep.PHUNBASEWEP and wep.EnableCustomization and !wep:IsBusyForCustomizing() then
			
			if wep:GetIsCustomizing() and stopBinds[bind] then return true end
		
			if bind == "+menu_context" then
				ply:ConCommand("pb_custmenu_toggle")
				return true
			end

			if wep:GetIsCustomizing() and bind:find("slot") then
				local slotnum = tonumber(string.Right(bind, 1))
				ply:ConCommand("pb_custmenu_cycleslot "..slotnum)
				return true
			end
		end
	end)
	
	net.Receive("PB_CUSTOMIZATION_CYCLEATTACHMENT", function()
		local wep = net.ReadEntity()
		local cat = net.ReadUInt(4)
		if IsValid(wep) and cat > 0 then
			wep:CycleAttachmentInCategory(cat)
		end
	end)
end
