if CLIENT then

local clrBlack = Color(0,0,0,255)

AddCSLuaFile()

PHUNBASE = PHUNBASE or {}
PHUNBASE.DEV = PHUNBASE.DEV or {}

CreateClientConVar("phunbase_devmode", "0", true, false)

CreateClientConVar("phunbase_dev_base_pos_x", "0", true, false)
CreateClientConVar("phunbase_dev_base_pos_y", "0", true, false)
CreateClientConVar("phunbase_dev_base_pos_z", "0", true, false)
CreateClientConVar("phunbase_dev_base_ang_p", "0", true, false)
CreateClientConVar("phunbase_dev_base_ang_y", "0", true, false)
CreateClientConVar("phunbase_dev_base_ang_r", "0", true, false)

CreateClientConVar("phunbase_dev_iron_toggle", "0", true, true) // save for serverside
CreateClientConVar("phunbase_dev_iron_pos_x", "0", true, false)
CreateClientConVar("phunbase_dev_iron_pos_y", "0", true, false)
CreateClientConVar("phunbase_dev_iron_pos_z", "0", true, false)
CreateClientConVar("phunbase_dev_iron_ang_p", "0", true, false)
CreateClientConVar("phunbase_dev_iron_ang_y", "0", true, false)
CreateClientConVar("phunbase_dev_iron_ang_r", "0", true, false)

CreateClientConVar("phunbase_dev_centerhelper", "0", true, false)
CreateClientConVar("phunbase_dev_centerhelper_pbonly", "0", true, false)

CreateClientConVar("phunbase_dev_vm_attachments_draw", "0", true, false)
CreateClientConVar("phunbase_dev_vm_attachments_all", "0", true, false)

CreateClientConVar("phunbase_hl2_crosshair", "0", true, false)

function PHUNBASE.DEV.ENABLED()
	return GetConVar("phunbase_devmode"):GetInt() == 1
end

function PHUNBASE.DEV.PlayViewModelSequence(wep, seq, speed, cycle)
	if !PHUNBASE.DEV.ENABLED() then return end
	local vm = wep.VM
	vm:ResetSequence(seq)
	if cycle > 0 then vm:SetCycle(cycle) else vm:SetCycle(0) end
	vm:SetPlaybackRate(speed)
	wep.RealViewModel:SendViewModelMatchingSequence(wep.RealViewModel:LookupSequence(seq))
end

function PHUNBASE.DEV.DrawViewmodelAttachments(wep)
	if GetConVar("phunbase_dev_vm_attachments_draw"):GetInt() == 0 then return end

	if LocalPlayer():ShouldDrawLocalPlayer() then return end

	local ent = wep.VM
	if !IsValid(ent) then return end

	local points = {}
	for id, t in pairs( ent:GetAttachments() or {} ) do
		local all = GetConVar("phunbase_dev_vm_attachments_all"):GetInt() == 1
		if all or (!all and (t.name == wep.MuzzleAttachmentName or t.name == wep.ShellAttachmentName)) then
			local angpos = ent:GetAttachment( t.id )

			local pos, pos_f, pos_r, pos_u // needs to be in the cam.Start3D for proper fov drawing

			cam.Start3D( EyePos(), EyeAngles(), wep:GetCorrectCameraFOV())
				render.DrawLine( angpos.Pos, angpos.Pos + angpos.Ang:Forward() * 2, Color( 255, 0, 0 ), false )
				render.DrawLine( angpos.Pos, angpos.Pos + angpos.Ang:Right() * 2, Color( 0, 255, 0 ), false )
				render.DrawLine( angpos.Pos, angpos.Pos + angpos.Ang:Up() * 2, Color( 0, 150, 250 ), false )

				pos = angpos.Pos:ToScreen()
				pos_f = (angpos.Pos + angpos.Ang:Forward() * 1):ToScreen()
				pos_r = (angpos.Pos + angpos.Ang:Right() * 1):ToScreen()
				pos_u = (angpos.Pos + angpos.Ang:Up() * 1):ToScreen()
			cam.End3D()

			draw.RoundedBox( 0, pos.x - 2, pos.y - 2, 4, 4, Color( 255, 255, 255 ) )

			draw.SimpleText( "FORWARD (X)", "DermaDefault", pos_f.x, pos_f.y, Color(255,0,0,255), 1, 0 )
			draw.SimpleText( "RIGHT (Y)", "DermaDefault", pos_r.x, pos_r.y, Color(0,255,0,255), 1, 0 )
			draw.SimpleText( "UP (Z)", "DermaDefault", pos_u.x, pos_u.y, Color(0,150,250,255), 1, 0 )
			draw.SimpleText( t.name .. " (" .. t.id .. ")", "DermaDefault", pos.x, pos.y, Color(255,255,255,255), 1, 0 )

			table.insert( points, pos )
		end
	end
end

local _colAnimButtonHover = Color(0,255,0,25)
local _colAnimButtonIdle = Color(0,0,0,60)
local _colAnimButtonClick = Color(0,0,255,25)

local function PHUNBASE_DEV_MENU_PANEL_ANIMS(panel, wep)

	local vm = wep.VM
	local animlist = vgui.Create("DListView", panel)
	animlist:SetMultiSelect(false)
	local animlistcolumn = animlist:AddColumn("Click anim to play, right click here to print all")
	animlist:SetHeight(40 + (20 *(vm:GetSequenceCount() - 1)))
	for i = 0, vm:GetSequenceCount() - 1 do
		local seq = vm:GetSequenceName(i)
		animlist:AddLine(seq)
	end

	animlist.OnRowSelected = function( lst, index, pnl )
		PHUNBASE.DEV.PlayViewModelSequence(wep, pnl:GetColumnText(1), 1, 0)
	end

	animlistcolumn.DoRightClick = function( lst, index, pnl )
		local t = {}
		for i = 0, vm:GetSequenceCount() - 1 do
			local seq = vm:GetSequenceName(i)
			t[seq] = "\""..seq.."\","
		end
		print("Sequence table:")
		PrintTable(t)
	end
	panel:AddItem(animlist)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(2)
	slider:SetMin(0)
	slider:SetMax(1)
	slider:SetValue(0)
	slider:SetText("Set ViewModel cycle: ")
	function slider:Think()
		if PHUNBASE.DEV.ENABLED() then
			if self:GetValue() > 0 then
				vm:SetCycle(self:GetValue())
			end
		end
	end
	panel:AddItem(slider)

	//BASEPOS
	panel:AddControl("Label", {Text = "BASEPOS SETUP"})

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_base_pos_x")
	slider:SetValue(GetConVarNumber("phunbase_dev_base_pos_x"))
	slider:SetText("POS X (left/right)")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_base_pos_y")
	slider:SetValue(GetConVarNumber("phunbase_dev_base_pos_y"))
	slider:SetText("POS Y (fwd/bwd)")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_base_pos_z")
	slider:SetValue(GetConVarNumber("phunbase_dev_base_pos_z"))
	slider:SetText("POS Z (up/down)")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_base_ang_p")
	slider:SetValue(GetConVarNumber("phunbase_dev_base_ang_p"))
	slider:SetText("ANG Pitch")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_base_ang_y")
	slider:SetValue(GetConVarNumber("phunbase_dev_base_ang_y"))
	slider:SetText("ANG Yaw")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_base_ang_r")
	slider:SetValue(GetConVarNumber("phunbase_dev_base_ang_r"))
	slider:SetText("ANG Roll")
	panel:AddItem(slider)

	local newPos, newAng
	local copybtn = vgui.Create("DButton", panel)
	copybtn:SetText("Copy Basepos data to clipboard")
	copybtn:SetHeight(40)
	copybtn.DoClick = function()
		SetClipboardText( string.format("SWEP.BasePos = Vector(%.3f, %.3f, %.3f)\nSWEP.BaseAng = Vector(%.3f, %.3f, %.3f)", newPos.x, newPos.y, newPos.z, newAng.x, newAng.y, newAng.z) )
	end
	panel:AddItem(copybtn)

	local resetbtn = vgui.Create("DButton", panel)
	resetbtn:SetText("Reset all values to 0")
	resetbtn.DoClick = function()
		GetConVar("phunbase_dev_base_pos_x"):SetFloat(0)
		GetConVar("phunbase_dev_base_pos_y"):SetFloat(0)
		GetConVar("phunbase_dev_base_pos_z"):SetFloat(0)
		GetConVar("phunbase_dev_base_ang_p"):SetFloat(0)
		GetConVar("phunbase_dev_base_ang_y"):SetFloat(0)
		GetConVar("phunbase_dev_base_ang_r"):SetFloat(0)
	end

	function resetbtn:Think()
		newPos = Vector(GetConVar("phunbase_dev_base_pos_x"):GetFloat(), GetConVar("phunbase_dev_base_pos_y"):GetFloat(), GetConVar("phunbase_dev_base_pos_z"):GetFloat())
		newAng = Vector(GetConVar("phunbase_dev_base_ang_p"):GetFloat(), GetConVar("phunbase_dev_base_ang_y"):GetFloat(), GetConVar("phunbase_dev_base_ang_r"):GetFloat())
		if IsValid(wep) then
			if PHUNBASE.DEV.ENABLED() then
				if wep.BasePos != newPos then
					wep.BasePos = newPos
				end
				if wep.BaseAng != newAng then
					wep.BaseAng = newAng
				end
			else
				if wep.BasePos != weapons.GetStored(wep:GetClass()).BasePos then
					wep.BasePos = weapons.GetStored(wep:GetClass()).BasePos
				end
				if wep.BaseAng != weapons.GetStored(wep:GetClass()).BaseAng then
					wep.BaseAng = weapons.GetStored(wep:GetClass()).BaseAng
				end
			end
		end
	end
	panel:AddItem(resetbtn)

	local restorebtn = vgui.Create("DButton", panel)
	restorebtn:SetText("Restore from weapon's .lua file")
	restorebtn.DoClick = function()
		GetConVar("phunbase_dev_base_pos_x"):SetFloat(weapons.GetStored(wep:GetClass()).BasePos.x)
		GetConVar("phunbase_dev_base_pos_y"):SetFloat(weapons.GetStored(wep:GetClass()).BasePos.y)
		GetConVar("phunbase_dev_base_pos_z"):SetFloat(weapons.GetStored(wep:GetClass()).BasePos.z)
		GetConVar("phunbase_dev_base_ang_p"):SetFloat(weapons.GetStored(wep:GetClass()).BaseAng.x)
		GetConVar("phunbase_dev_base_ang_y"):SetFloat(weapons.GetStored(wep:GetClass()).BaseAng.y)
		GetConVar("phunbase_dev_base_ang_r"):SetFloat(weapons.GetStored(wep:GetClass()).BaseAng.z)
	end
	panel:AddItem(restorebtn)
	restorebtn:DoClick()

	//IRONPOS
	panel:AddControl("Label", {Text = "IRONSIGHT SETUP"})

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_iron_pos_x")
	slider:SetValue(GetConVarNumber("phunbase_dev_iron_pos_x"))
	slider:SetText("POS X (left/right)")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_iron_pos_y")
	slider:SetValue(GetConVarNumber("phunbase_dev_iron_pos_y"))
	slider:SetText("POS Y (fwd/bwd)")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_iron_pos_z")
	slider:SetValue(GetConVarNumber("phunbase_dev_iron_pos_z"))
	slider:SetText("POS Z (up/down)")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_iron_ang_p")
	slider:SetValue(GetConVarNumber("phunbase_dev_iron_ang_p"))
	slider:SetText("ANG Pitch")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_iron_ang_y")
	slider:SetValue(GetConVarNumber("phunbase_dev_iron_ang_y"))
	slider:SetText("ANG Yaw")
	panel:AddItem(slider)

	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(4)
	slider:SetMin(-100)
	slider:SetMax(100)
	slider:SetConVar("phunbase_dev_iron_ang_r")
	slider:SetValue(GetConVarNumber("phunbase_dev_iron_ang_r"))
	slider:SetText("ANG Roll")
	panel:AddItem(slider)

	local newPos, newAng
	local copybtn = vgui.Create("DButton", panel)
	copybtn:SetText("Copy Ironsight data to clipboard")
	copybtn:SetHeight(40)
	copybtn.DoClick = function()
		SetClipboardText( string.format("SWEP.IronsightPos = Vector(%.3f, %.3f, %.3f)\nSWEP.IronsightAng = Vector(%.3f, %.3f, %.3f)", newPos.x, newPos.y, newPos.z, newAng.x, newAng.y, newAng.z) )
	end
	panel:AddItem(copybtn)

	local resetbtn = vgui.Create("DButton", panel)
	resetbtn:SetText("Reset all values to 0")
	resetbtn.DoClick = function()
		GetConVar("phunbase_dev_iron_pos_x"):SetFloat(0)
		GetConVar("phunbase_dev_iron_pos_y"):SetFloat(0)
		GetConVar("phunbase_dev_iron_pos_z"):SetFloat(0)
		GetConVar("phunbase_dev_iron_ang_p"):SetFloat(0)
		GetConVar("phunbase_dev_iron_ang_y"):SetFloat(0)
		GetConVar("phunbase_dev_iron_ang_r"):SetFloat(0)
	end

	function resetbtn:Think()
		newPos = Vector(GetConVar("phunbase_dev_iron_pos_x"):GetFloat(), GetConVar("phunbase_dev_iron_pos_y"):GetFloat(), GetConVar("phunbase_dev_iron_pos_z"):GetFloat())
		newAng = Vector(GetConVar("phunbase_dev_iron_ang_p"):GetFloat(), GetConVar("phunbase_dev_iron_ang_y"):GetFloat(), GetConVar("phunbase_dev_iron_ang_r"):GetFloat())
		if IsValid(wep) then
			if PHUNBASE.DEV.ENABLED() then
				if wep.IronsightPos != newPos then
					wep.IronsightPos = newPos
				end
				if wep.IronsightAng != newAng then
					wep.IronsightAng = newAng
				end
			else
				if wep.IronsightPos != wep.IronsightPos_CUR then
					wep.IronsightPos = wep.IronsightPos_CUR or weapons.GetStored(wep:GetClass()).IronsightPos
				end
				if wep.IronsightAng != wep.IronsightAng_CUR then
					wep.IronsightAng = wep.IronsightAng_CUR or weapons.GetStored(wep:GetClass()).IronsightAng
				end
			end
		end
	end
	panel:AddItem(resetbtn)

	local restorebtn = vgui.Create("DButton", panel)
	restorebtn:SetText("Restore from weapon's .lua file")
	restorebtn.DoClick = function()
		GetConVar("phunbase_dev_iron_pos_x"):SetFloat(weapons.GetStored(wep:GetClass()).IronsightPos.x)
		GetConVar("phunbase_dev_iron_pos_y"):SetFloat(weapons.GetStored(wep:GetClass()).IronsightPos.y)
		GetConVar("phunbase_dev_iron_pos_z"):SetFloat(weapons.GetStored(wep:GetClass()).IronsightPos.z)
		GetConVar("phunbase_dev_iron_ang_p"):SetFloat(weapons.GetStored(wep:GetClass()).IronsightAng.x)
		GetConVar("phunbase_dev_iron_ang_y"):SetFloat(weapons.GetStored(wep:GetClass()).IronsightAng.y)
		GetConVar("phunbase_dev_iron_ang_r"):SetFloat(weapons.GetStored(wep:GetClass()).IronsightAng.z)
	end
	panel:AddItem(restorebtn)
	restorebtn:DoClick()

end

local oldWepModel = nil
local oldWep = nil
local function PHUNBASE_DEV_MENU_PANEL_UPDATE(panel)

	if !IsValid(panel) then return end

	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()

	panel:ClearControls()

	panel:AddControl("Label", {Text = "Weapon DEV Panel"})

	if !wep.PHUNBASEWEP then
		panel:AddControl("Label", {Text = "Current weapon is not a valid PHUNBASE weapon"})
		return
	else
		panel:AddControl("CheckBox", {Label = "Enable DEV Mode?", Command = "phunbase_devmode"})
		panel:AddControl("CheckBox", {Label = "Force toggle Ironsights?", Command = "phunbase_dev_iron_toggle"})
		panel:AddControl("CheckBox", {Label = "Enable center green sphere helper?", Command = "phunbase_dev_centerhelper"})
		panel:AddControl("CheckBox", {Label = "Center helper only for PHUNABSE weapons?", Command = "phunbase_dev_centerhelper_pbonly"})
		panel:AddControl("CheckBox", {Label = "Draw muzzle and shell attachment directions?", Command = "phunbase_dev_vm_attachments_draw"})
		panel:AddControl("CheckBox", {Label = "Draw directions for all attachments?", Command = "phunbase_dev_vm_attachments_all"})
	end

	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) or !wep.PHUNBASEWEP then return end

	panel:AddControl("Label", {Text = "Set VM model: "})
	local model_text_entry = vgui.Create("DTextEntry", panel)
	model_text_entry:SetText("")
	model_text_entry.OnEnter = function(self)
		if PHUNBASE.DEV.ENABLED() then
			wep.VM:SetModel(self:GetValue())
		end
	end
	panel:AddItem(model_text_entry)

	panel:AddControl("Label", {Text = "Set Hands model: "})
	local model_text_entry = vgui.Create("DTextEntry", panel)
	model_text_entry:SetText("")
	model_text_entry.OnEnter = function(self)
		if PHUNBASE.DEV.ENABLED() then
			//wep.Owner:GetHands():SetModel(self:GetValue())
			wep.Hands:SetModel(self:GetValue())
			//wep:_UpdateHands()
			self:SetText("")
		end
	end
	panel:AddItem(model_text_entry)

	oldWepModel = wep.VM:GetModel()
	oldWep = wep

	PHUNBASE_DEV_MENU_PANEL_ANIMS(panel, wep)
end

local function PHUNBASE_DEV_MENU_PANEL(panel)

	panel.PHUNPANELS = {}

	function panel:Think()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.VM and wep.PHUNBASEWEP then
			if oldWepModel != wep.VM:GetModel() then
				PHUNBASE_DEV_MENU_PANEL_UPDATE(panel)
				oldWepModel = wep.VM:GetModel()
			end
		end
		if IsValid(wep) then
			if oldWep != wep then
				PHUNBASE_DEV_MENU_PANEL_UPDATE(panel)
				oldWep = wep
			end
		end
	end

	PHUNBASE_DEV_MENU_PANEL_UPDATE(panel)

end

local function PHUNBASE_KATKA_PANELPART(panel)
	local katkaID64 = "76561198024742819"
	local katkaName = ""
	local pbby = "PHUNBASE by "

	local bg = vgui.Create("DPanel", panel)
	bg:DockMargin(35,0,35,0)
	bg.Paint = function(self, w, h)
		surface.SetDrawColor(Color(85,165,195,255))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(Color(65,120,145,255))
		surface.DrawRect(2, 2, w-4, h-4)
	end
	local katka = vgui.Create("AvatarImage", bg)
	katka:Dock(FILL)
	katka:DockMargin(4,4,4,4)
	katka:SetSteamID(katkaID64, 184)
	katka.Think = function(self)
		bg:SetTall(bg:GetWide())
		self:SetSize(bg:GetWide() - 8, bg:GetWide() - 8)
	end
	katka.OnMousePressed = function()
		gui.OpenURL("http://steamcommunity.com/profiles/76561198024742819/")
	end

	local txt = vgui.Create("DButton", panel)
	txt:SetTextColor(Color(0,0,0,255))
	txt:DockMargin(2,0,2,0)
	txt:SetText(pbby..katkaName)
	txt:SetCursor("arrow")
	txt.Paint = function(self, w, h) end
	panel:AddItem(txt)
	steamworks.RequestPlayerInfo( katkaID64 , function(returnedName) katkaName = returnedName txt:SetText(pbby..katkaName) end) // update name

	panel:AddItem(bg)
end

local function PHUNBASE_MENU_PANEL(panel)
	panel:ClearControls()

	PHUNBASE_KATKA_PANELPART(panel)

	local vercheckbtn = vgui.Create("DButton", panel)
	vercheckbtn:SetText("Check PHUNBASE version")
	vercheckbtn:SetTextColor(Color(0,120,0,255))
	vercheckbtn.DoClick = function() PHUNBASE.CheckVersion() end
	panel:AddItem(vercheckbtn)

	local rebuildiconsbtn = vgui.Create("DButton", panel)
	rebuildiconsbtn:SetText("Rebuild PHUNBASE Spawn Icons")
	rebuildiconsbtn:SetTextColor(Color(0,0,0,255))
	rebuildiconsbtn.DoClick = function()
		for classname, icon in pairs(PHUNBASE.SpawnIcons) do
			if IsValid(icon) and icon.PB_UpdateSpawnIcon then
				icon:PB_UpdateSpawnIcon()
			end
		end
	end
	panel:AddItem(rebuildiconsbtn)

	panel:AddControl("Label", {Text = "\nHL2 Weapon Settings"})

	local hl2_replace_checkbox = vgui.Create("DCheckBoxLabel", panel)
	hl2_replace_checkbox:SetText("ADMIN: Replace default HL2 Weapons?")
	hl2_replace_checkbox:SetTextColor(Color(0,0,0,255))
	hl2_replace_checkbox:SetConVar("phunbase_hl2_replace_weapons")
	hl2_replace_checkbox:SetValue(0)
	hl2_replace_checkbox:SizeToContents()
	hl2_replace_checkbox.Think = function(self)
		if !LocalPlayer():IsAdmin() then
			self:SetTextColor(Color(255,10,10,255))
			self.Button:SetEnabled(false)
			self.Label:SetEnabled(false)
		else
			self:SetTextColor(Color(0,0,0,255))
			self.Button:SetEnabled(true)
			self.Label:SetEnabled(true)
		end
	end
	panel:AddItem(hl2_replace_checkbox)
	
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(0)
	slider:SetMin(0)
	slider:SetMax(2)
	slider:SetConVar("phunbase_hl2_crosshair")
	slider:SetValue(GetConVarNumber("phunbase_hl2_crosshair"))
	slider:SetText("Use HL2 crosshair?")
	slider:SetTooltip("0 = disable, 1 = HL2 weapons only, 2 = all weapons")
	panel:AddItem(slider)
	
	panel:AddControl("Label", {Text = "\nPHUNBASE Settings"})
	
	local cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Offset VM slightly when crouching?")
	cb:SetConVar("phunbase_vm_crouchoffset")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable engine Blur?")
	cb:SetConVar("mat_motion_blur_enabled")
	cb:SetTooltip("Toggles engine blur. Required for IRON blur")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable reload Blur?")
	cb:SetConVar("phunbase_blur_reload")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable customize Blur?")
	cb:SetConVar("phunbase_blur_custmenu")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable ironsight Blur?")
	cb:SetConVar("phunbase_blur_iron")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(2)
	slider:SetMin(0)
	slider:SetMax(20)
	slider:SetConVar("phunbase_blur_iron_mod")
	slider:SetValue(GetConVarNumber("phunbase_blur_iron_mod"))
	slider:SetText("Ironsight Blur modifier")
	panel:AddItem(slider)
	
	panel:AddControl("Label", {Text = "\nPHUNBASE HUD Settings"})
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable PHUNBASE Hud?")
	cb:SetConVar("pb_hud_enable")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable a real-time wrist watch on Hud?")
	cb:SetConVar("pb_fas2_watch_hud_enable")
	cb:SetTooltip("bind +pb_fas2_watch_hud_zoom to a button to zoom it")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	cb = vgui.Create("DCheckBoxLabel", panel)
	cb:SetText("Enable Firemodes Display on HUD?")
	cb:SetConVar("pb_hud_firemodes_enable")
	cb:SetTextColor(clrBlack)
	panel:AddItem(cb)
	
	slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(0)
	slider:SetMin(0)
	slider:SetMax(3)
	slider:SetConVar("pb_hud_firemodes_displaymode")
	slider:SetValue(GetConVarNumber("pb_hud_firemodes_displaymode"))
	slider:SetText("Firemode Display type")
	slider:SetTooltip("Which Firemodes to show after switching: 0 = all, 1 = active firemode, 2 = active firemode if safe, 3 = none")
	panel:AddItem(slider)
	
	panel:AddControl("Label", {Text = "\nPHUNBASE Laser Settings"})
	
	slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(0)
	slider:SetMin(0)
	slider:SetMax(2)
	slider:SetConVar("pb_laser_dot_normal")
	slider:SetValue(GetConVarNumber("pb_laser_dot_normal"))
	slider:SetText("Laser Dot direction")
	slider:SetTooltip("0 = hit surface normal, 1 = eyeangles normal, 2 = beam normal")
	panel:AddItem(slider)
	
	slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(0)
	slider:SetMin(0)
	slider:SetMax(2)
	slider:SetConVar("pb_laser_option")
	slider:SetValue(GetConVarNumber("pb_laser_option"))
	slider:SetText("Laser Option")
	slider:SetTooltip("0 = selected color, 1 = player weapon color, 2 = rainbow")
	panel:AddItem(slider)
	
	panel:AddControl( "Color", { Label = "Laser Color", Red = "pb_laser_color_r", Green = "pb_laser_color_g", Blue = "pb_laser_color_b"} )
	
	panel:AddControl("Label", {Text = ""}) // makes menu bottom look better
end

local function PHUNBASE_CONTENTINFO_MENU_PANEL(panel)
	panel:ClearControls()
	
	panel:AddControl("Label", {Text = "List of registered things for quick use"})
	
	// attachments
	local dlist = vgui.Create("DListView", panel)
	dlist:SetMultiSelect(false)
	dlist:SetSortable(false)
	local dlistcolumn = dlist:AddColumn("Registered Attachments")
	
	function dlistcolumn:fillWithInfo()
		for k, _ in pairs(dlist:GetLines()) do
			dlist:RemoveLine(k)
		end
		
		for k, v in pairs(PHUNBASE.registeredAttachments) do
			local l = dlist:AddLine((v.name).."  |  "..(v.menuName))
			l.strToCopy = v.name
		end
		dlist:SortByColumn(1)
	end
	dlistcolumn:fillWithInfo()
	
	dlist:SetHeight(200)
	dlist.OnRowSelected = function( lst, index, pnl )
		SetClipboardText(pnl.strToCopy)
	end
	function dlistcolumn:DoClick()
		self:fillWithInfo()
	end
	panel:AddItem(dlist)
	
	// ammotypes
	local dlist = vgui.Create("DListView", panel)
	dlist:SetMultiSelect(false)
	dlist:SetSortable(false)
	local dlistcolumn = dlist:AddColumn("Registered AmmoTypes")
	
	function dlistcolumn:fillWithInfo()
		for k, _ in pairs(dlist:GetLines()) do
			dlist:RemoveLine(k)
		end
		
		for k, v in pairs(PHUNBASE.registeredAmmoTypes) do
			local l = dlist:AddLine(k.."  |  "..v)
			l.strToCopy = k
		end
		dlist:SortByColumn(1)
	end
	dlistcolumn:fillWithInfo()
	
	dlist:SetHeight(200)
	dlist.OnRowSelected = function( lst, index, pnl )
		SetClipboardText(pnl.strToCopy)
	end
	function dlistcolumn:DoClick()
		self:fillWithInfo()
	end
	panel:AddItem(dlist)
	
	// firemodes
	local dlist = vgui.Create("DListView", panel)
	dlist:SetMultiSelect(false)
	dlist:SetSortable(false)
	local dlistcolumn = dlist:AddColumn("Registered FireModes")
	
	function dlistcolumn:fillWithInfo()
		for k, _ in pairs(dlist:GetLines()) do
			dlist:RemoveLine(k)
		end
		
		for k, v in pairs(PHUNBASE.firemodes.registeredByID) do
			local l = dlist:AddLine(k.."  |  "..v.display)
			l.strToCopy = k
		end
		dlist:SortByColumn(1)
	end
	dlistcolumn:fillWithInfo()
	
	dlist:SetHeight(200)
	dlist.OnRowSelected = function( lst, index, pnl )
		SetClipboardText(pnl.strToCopy)
	end
	function dlistcolumn:DoClick()
		self:fillWithInfo()
	end
	panel:AddItem(dlist)
end

local function PHUNBASE_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "PHUNBASE", "PHUNBASE_DEV_MENU", "_DEV MENU_", "", "", PHUNBASE_DEV_MENU_PANEL)
	spawnmenu.AddToolMenuOption("Utilities", "PHUNBASE", "PHUNBASE_MENU", "Settings", "", "", PHUNBASE_MENU_PANEL)
	spawnmenu.AddToolMenuOption("Utilities", "PHUNBASE", "PHUNBASE_CONTENTINFO_MENU", "Content Info", "", "", PHUNBASE_CONTENTINFO_MENU_PANEL)
end

hook.Add("PopulateToolMenu", "PHUNBASE_PopulateToolMenu", PHUNBASE_PopulateToolMenu)

local dst = draw.SimpleText
surface.CreateFont("CVMT_24", {font = "Default", size = 24, weight = 700, blursize = 0, antialias = true, shadow = false})

function draw.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
	dst(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
	dst(text, font, x, y, colortext, xalign, yalign)
end

local ShadowText = draw.ShadowText

local ply, wep, ent, cyc, seqdur, x, y, seqlist, amt
local White, Black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)

local function PHUNBASE_CVMT_HUDPaint()
	if PHUNBASE.DEV.ENABLED() then
		ply = LocalPlayer()

		if ply:Alive() then
			wep = ply:GetActiveWeapon()
			if !wep.PHUNBASEWEP then return end
			x, y = ScrW(), ScrH()

			if IsValid(wep) then
				ent = wep.VM

				if ent then
					cyc = ent:GetCycle()
					seqdur = ent:SequenceDuration()

					ShadowText("Animation: " .. ent:GetSequenceName(ent:GetSequence()), "CVMT_24", x * 0.5, y * 0.5 - 250, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					ShadowText("Playback rate: " .. ent:GetPlaybackRate() .. "x", "CVMT_24", x * 0.5, y * 0.5 - 225, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					ShadowText("Cycle: " .. math.Round(cyc, 3), "CVMT_24", x * 0.5, y * 0.5 - 200, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					ShadowText("Duration: " .. math.Round(seqdur, 2) .. " seconds", "CVMT_24", x * 0.5, y * 0.5 - 175, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					ShadowText("Seek: " .. math.Round(seqdur * cyc, 2) .. " seconds", "CVMT_24", x * 0.5, y * 0.5 - 150, White, Black, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					PHUNBASE.DEV.DrawViewmodelAttachments(wep)
				end
			end
		end
	end
end

hook.Add("HUDPaint", "PHUNBASE_CVMT_HUDPaint", PHUNBASE_CVMT_HUDPaint)

hook.Add( "PostDrawTranslucentRenderables", "test", function()
	if PHUNBASE.DEV.ENABLED() and GetConVar("phunbase_dev_centerhelper"):GetBool() then
		if (GetConVar("phunbase_dev_centerhelper_pbonly"):GetBool() and LocalPlayer():GetActiveWeapon().PHUNBASEWEP) or !GetConVar("phunbase_dev_centerhelper_pbonly"):GetBool() then
			render.SetColorMaterial()
			render.DrawSphere(LocalPlayer():GetEyeTrace().HitPos, 2, 30, 30, Color(0,255,0,255))
		end
	end
end)

end

if SERVER then
	CreateConVar("phunbase_hl2_replace_weapons", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

	PHUNBASE_HL2_REPLACE_DEFAULT = GetConVar("phunbase_hl2_replace_weapons"):GetInt() == 1

	cvars.RemoveChangeCallback("phunbase_hl2_replace_weapons", "phunbase_hl2_replace_weapons_callbackidentifier")
	cvars.AddChangeCallback("phunbase_hl2_replace_weapons", function(cvar, old, new)
		PHUNBASE_HL2_REPLACE_DEFAULT = tobool(new)
	end, "phunbase_hl2_replace_weapons_callbackidentifier")
end
