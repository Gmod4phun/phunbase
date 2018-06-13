function SWEP:getVElementByName(name)
	if self.VElements and self.VElements[name] then
		if self.VElements[name].ent then
			return self.VElements[name].ent
		else
			return nil
		end
	else
		return nil
	end
end

function SWEP:_setupAttachmentModel(data, updateOnly)
	updateOnly = updateOnly or false
	if !data.pos then data.pos = Vector() end
	if !data.angle then data.angle = Angle() end

	data.origPos = data.pos
	data.origAng = data.angle
	
	if !updateOnly then // if we not updating, create new attachments
	
		-- remove old if there by any means is and create new model
		if IsValid(data.ent) then data.ent:Remove() end
		if IsValid(data.ent_for_RT) then data.ent_for_RT:Remove() end
	
		data.ent = self:CreateClientModel(data.model)
		data.ent:SetNoDraw(true)
		self._currentCModels[#self._currentCModels + 1] = data.ent
		
		// needs a second instance if we want to draw it inside the rt scope
		if data.drawInRT then
			data.ent_for_RT = self:CreateClientModel(data.model)
			data.ent_for_RT:SetNoDraw(true)
			self._currentCModels[#self._currentCModels + 1] = data.ent_for_RT
		end
	end
	
	-- make it active if it's supposed to be active, or not, if nothing is defined
	//data.active = data.active or false
	
	if data.default then
		data.active = true
	else
		data.active = false
	end
	
	-- scale the model if there is a scaling vector
	-- keep in mind that I scale it once upon creation, in order to not call Matrix and EnableMatrix over and over again each frame
	if data.size then
		data.matrix = Matrix()
		
		data.matrix:Scale(data.size)
		data.ent:EnableMatrix("RenderMultiply", data.matrix)
		if data.ent_for_RT then
			data.ent_for_RT:EnableMatrix("RenderMultiply", data.matrix)
		end
	end
	
	-- get the bone ID in advance so that we don't have to look it up every frame for every attachment that's active on the weapon
	if data.bone then
		data._bone = self.VM:LookupBone(data.bone)
	end
	
	-- set the skin if defined
	if data.skin then
		data.ent:SetSkin(data.skin)
	end
	
	-- set bodygroups in case they are defined
	if data.bodygroups then
		if type(data.bodygroups) == "table" then
			for main, sec in pairs(data.bodygroups) do
				data.ent:SetBodygroup(main, sec)
				if data.ent_for_RT then
					data.ent_for_RT:SetBodygroup(main, sec)
				end
			end
		elseif type(data.bodygroups) == "string" then
			data.ent:SetBodyGroups(data.bodygroups)
			if data.ent_for_RT then
				data.ent_for_RT:SetBodyGroups(data.bodygroups)
			end
		end
	end
	
	// set default materials, just in case, then override them if needed
	for i = 0, #data.ent:GetMaterials() do
		data.ent:SetSubMaterial(i, nil)
	end
	
	// material override for attachment
	if data.material then 
		data.ent:SetMaterial(data.material)
	elseif data.materials then
		for k, v in pairs(data.materials) do
			data.ent:SetSubMaterial(k, v)
		end
	elseif data.stencilmaterials then
		for i = 0, #data.ent:GetMaterials() do // set all invisible
			data.ent:SetSubMaterial(i, "phunbase/stencil_sights/invis")
		end
		for _, v in pairs(data.stencilmaterials) do // set the ones we want for stencil drawing
			data.ent:SetSubMaterial(v, data.stencilDebug and "phunbase/stencil_sights/debug" or "phunbase/stencil_sights/barelyvis")
		end
	end
	
	data.ent:SetupBones()
	if data.ent_for_RT then
		data.ent_for_RT:SetupBones()
	end
end

function SWEP:_setupAttachmentModelsMerge(data) // merging after they are all created to prevent merging nonexistent entities
	if data.bonemerge then
		if data.mergeparent and self.VElements[data.mergeparent] then
			data.ent:SetParent(self.VElements[data.mergeparent].ent)
			if data.ent_for_RT then
				data.ent_for_RT:SetParent(self.VElements[data.mergeparent].ent)
			end
		else
			data.ent:SetParent(self.VM)
			if data.ent_for_RT then
				data.ent_for_RT:SetParent(self.VM)
			end
		end
		
		data.ent:AddEffects(EF_BONEMERGE)
		if data.ent_for_RT then
			data.ent_for_RT:AddEffects(EF_BONEMERGE)
		end
		if data.mergefast then
			data.ent:AddEffects(EF_BONEMERGE_FASTCULL)
			if data.ent_for_RT then
				data.ent_for_RT:AddEffects(EF_BONEMERGE_FASTCULL)
			end
		end
	else
		if data.parent and self.VElements[data.parent] then
			data.ent:SetParent(self.VElements[data.parent].ent)
			if data.ent_for_RT then
				data.ent_for_RT:SetParent(self.VElements[data.parent].ent)
			end
			data._parent = self.VElements[data.parent].ent
		else
			data.ent:SetParent(self.VM)
			if data.ent_for_RT then
				data.ent_for_RT:SetParent(self.VM)
			end
			data._parent = self.VM
		end
	end
	
	data.ent:SetupBones()
	if data.ent_for_RT then
		data.ent_for_RT:SetupBones()
	end
end

function SWEP:setupAttachmentModels(updateOnly) // true to only update them, not to re-create them
	if self.VElements then
		for k, v in pairs(self.VElements) do
			if v.models then
				for key, data in ipairs(v.models) do
					data.name = key
					self:_setupAttachmentModel(data, updateOnly)
				end
			else
				v.name = k
				self:_setupAttachmentModel(v, updateOnly)
			end
		end
	end
	
	if self.VElements then
		for k, v in pairs(self.VElements) do
			if v.models then
				for key, data in ipairs(v.models) do
					self:_setupAttachmentModelsMerge(data)
				end
			else
				self:_setupAttachmentModelsMerge(v)
			end
		end
	end
end

function SWEP:getBoneOrientation(boneId)
	local m = self.VM:GetBoneMatrix(boneId)
	
	if m then
		local pos, ang = m:GetTranslation(), m:GetAngles()

		if self.ViewModelFlip then
			ang.r = -ang.r
		end
		
		return pos, ang
	end
	
	return Vector(), Angle()
end

function SWEP:getAttachmentOrientation(ent, dataAtt)
	local att = ent:GetAttachment(ent:LookupAttachment(dataAtt))
	
	if att then
		local pos, ang = att.Pos, att.Ang

		if self.ViewModelFlip then
			ang.r = -ang.r
		end
		
		return pos, ang
	end
	
	return Vector(), Angle()
end

function SWEP:_drawAttachmentModel(data)
	local model = data.ent
	local pos, ang
	
	if IsValid(model) then
		if data.bone then
			pos, ang = self:getBoneOrientation(data._bone)
			model:SetPos(pos + ang:Forward() * data.pos.x + ang:Right() * data.pos.y + ang:Up() * data.pos.z)
			ang:RotateAroundAxis(ang:Up(), data.angle.y)
			ang:RotateAroundAxis(ang:Right(), data.angle.p)
			ang:RotateAroundAxis(ang:Forward(), data.angle.r)

			model:SetAngles(ang)
		end
		
		if data.attachment then
			pos, ang = self:getAttachmentOrientation(data._parent, data.attachment)
			model:SetPos(pos + ang:Forward() * data.pos.x + ang:Right() * data.pos.y + ang:Up() * data.pos.z)
			ang:RotateAroundAxis(ang:Up(), data.angle.y)
			ang:RotateAroundAxis(ang:Right(), data.angle.p)
			ang:RotateAroundAxis(ang:Forward(), data.angle.r)

			model:SetAngles(ang)
		end
		
		if data.animated then
			model:FrameAdvance(FrameTime())
			model:SetupBones()
		end
		
		if data.bonemerge and self.ViewModelFlip then
			render.CullMode(MATERIAL_CULLMODE_CW)
				model:DrawModel()
			render.CullMode(MATERIAL_CULLMODE_CCW)
		else
			model:DrawModel()
		end
	end
end

function SWEP:_drawAttachmentModel_for_RT(data)
	local model = data.ent_for_RT
	local pos, ang
	
	if IsValid(model) then
		if data.bone then
			pos, ang = self:getBoneOrientation(data._bone)
			model:SetPos(pos + ang:Forward() * data.pos.x + ang:Right() * data.pos.y + ang:Up() * data.pos.z)
			ang:RotateAroundAxis(ang:Up(), data.angle.y)
			ang:RotateAroundAxis(ang:Right(), data.angle.p)
			ang:RotateAroundAxis(ang:Forward(), data.angle.r)

			model:SetAngles(ang)
		end
		
		if data.attachment then
			pos, ang = self:getAttachmentOrientation(data._parent, data.attachment)
			model:SetPos(pos + ang:Forward() * data.pos.x + ang:Right() * data.pos.y + ang:Up() * data.pos.z)
			ang:RotateAroundAxis(ang:Up(), data.angle.y)
			ang:RotateAroundAxis(ang:Right(), data.angle.p)
			ang:RotateAroundAxis(ang:Forward(), data.angle.r)

			model:SetAngles(ang)
		end
		
		if data.animated then
			model:FrameAdvance(FrameTime())
			model:SetupBones()
		end
		
		model:DrawModel()
	end
end

function SWEP:_drawAttachmentModels(data)
	if data.models then
		for key, modelData in ipairs(data.models) do
			self:_drawAttachmentModels(modelData)
		end
	else
		self:_drawAttachmentModel(data)
	end
end

function SWEP:drawAttachments()
	if not self.VElements then
		return false
	end
	
	local FT = FrameTime()
	
	for k, v in pairs(self.VElements) do
		if v.reticleTable then // if an attachment has a stencil entity and is active, also make the stencil element active
			if v.reticleTable.stencilElementName then
				if self.VElements[v.reticleTable.stencilElementName] then
					self.VElements[v.reticleTable.stencilElementName].active = v.active
				end
			end
		end
	
		if v.active then
			self:_drawAttachmentModels(v)
		end
		
		if v.thinkFunc and v.ent and IsValid(v.ent) then
			v.thinkFunc(self, v.ent)
		end
	end
	
	self:RunAttachmentsRenderFunc()
	
	return true
end
