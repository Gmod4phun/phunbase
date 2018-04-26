if CLIENT then
	spawnmenu.AddContentType("phunbase_weapon_hl2", function(container, obj) // spawn icons for hl2 weapons
	
		if ( !obj.material ) then return end
		if ( !obj.nicename ) then return end
		if ( !obj.spawnname ) then return end

		local icon = vgui.Create( "ContentIcon", container )
		icon:SetContentType( "weapon" )
		icon:SetSpawnName( obj.spawnname )
		icon:SetName( "HL2 | "..obj.nicename )
		icon:SetMaterial( obj.material )
		icon:SetAdminOnly( obj.admin )
		icon:SetColor( Color( 135, 206, 250, 255 ) )
		
		icon.DoClick = function()
			RunConsoleCommand( "gm_giveswep", obj.spawnname )
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end

		icon.DoMiddleClick = function()
			RunConsoleCommand( "gm_spawnswep", obj.spawnname )
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end

		icon.OpenMenu = function( icon )
			local menu = DermaMenu()
				menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
				menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "creator" ) RunConsoleCommand( "creator_type", "3" ) RunConsoleCommand( "creator_name", obj.spawnname ) end )
				menu:AddSpacer()
				menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
			menu:Open()
		end
		
		local wepTable = weapons.GetStored(obj.spawnname)
		local params = wepTable.HL2_IconParams
		
		if !params then
			if ( IsValid( container ) ) then
				container:Add( icon )
			end
			return icon
		end // if no icon params exist, keep default
		
		icon.Paint = function() return end
		icon.Label:SetTextColor(Color(255,255,255,255))
		
		local modelpanel = vgui.Create("DModelPanel", icon)
		modelpanel:SetSize(icon:GetSize())
		modelpanel:SetModel(wepTable.WorldModel)
		modelpanel:SetFOV( 60 )
		modelpanel:SetCamPos( Vector( 0, -params.dist, -params.camOffset ) )
		modelpanel:SetLookAng( Angle(0,90,0) )
		
		modelpanel.Entity:ManipulateBonePosition(0, params.mdlOffset)
		
		function modelpanel:LayoutEntity()
			local mdl = self.Entity
			mdl:SetAngles( Angle( 0, RealTime() * 100 % 360, 0 ) )
		end
		
		modelpanel.DoClick = function(self) icon:DoClick() end
		modelpanel.DoMiddleClick = function(self) icon:DoMiddleClick() end
		modelpanel.DoRightClick = function(self) icon:OpenMenu() end

		if ( IsValid( container ) ) then
			container:Add( icon )
		end

		return icon

	end)
end
