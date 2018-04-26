function SWEP:_setupAttachmentModel(data)
	data.origPos = data.pos
	data.origAng = data.angle
	
	-- create the attachment model
	data.ent = self:CreateClientModel(data.model)
	data.ent:SetNoDraw(true)
	
	-- make it active if it's supposed to be active, or not, if nothing is defined
	data.active = data.active or false
	
	-- scale the model if there is a scaling vector
	-- keep in mind that I scale it once upon creation, in order to not call Matrix and EnableMatrix over and over again each frame
	if data.size then
		data.matrix = Matrix()
		
		data.matrix:Scale(data.size)
		data.ent:EnableMatrix("RenderMultiply", data.matrix)
	end
	
	-- get the bone ID in advance so that we don't have to look it up every frame for every attachment that's active on the weapon
	if data.bone then
		data._bone = self.VM:LookupBone(data.bone)
	end
	
	-- set bodygroups in case they are defined
	if data.bodygroups then
		for main, sec in pairs(data.bodygroups) do
			data.ent:SetBodygroup(main, sec)
		end
	end
	
	-- if data.bonemerge then
		-- if data.mergeparent and self.VElements[data.mergeparent] then
			-- data.ent:SetParent(self.VElements[data.mergeparent].ent)
		-- else
			-- data.ent:SetParent(self.VM)
		-- end
		-- print("Merging ", data.model, "to ", data.ent:GetParent())
		-- data.ent:AddEffects(EF_BONEMERGE)
	-- end
	
	data.ent:SetupBones()
end

function SWEP:_setupAttachmentModelsMerge(data)
	if data.bonemerge then
		if data.mergeparent and self.VElements[data.mergeparent] then
			data.ent:SetParent(self.VElements[data.mergeparent].ent)
		else
			data.ent:SetParent(self.VM)
		end
		//print("Merging ", data.model, "to ", data.ent:GetParent())
		data.ent:AddEffects(EF_BONEMERGE)
		if data.mergefast then
			data.ent:AddEffects(EF_BONEMERGE_FASTCULL)
		end
	end
	
	data.ent:SetupBones()
end

function SWEP:setupAttachmentModels()
	if self.VElements then
		for k, v in pairs(self.VElements) do
			if v.models then
				for key, data in ipairs(v.models) do
					self:_setupAttachmentModel(data)
				end
			else
				self:_setupAttachmentModel(v)
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
		if v.active then
			self:_drawAttachmentModels(v)
		end
		
		if v.thinkFunc then
			v.thinkFunc(self, v.ent)
		end
	end
	
	return true
end
