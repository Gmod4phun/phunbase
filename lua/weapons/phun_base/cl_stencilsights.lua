if SERVER then return end

function SWEP:_drawStencilEntity(att)
	local v = self.VElements[att.name]
	local data = v.reticleTable
	local stVElementName
	
	if not v._stencilEntity or !IsValid(v._stencilEntity) then
		stVElementName = self.VElements[data.stencilElementName]
		if !stVElementName then return end

		v._stencilEntity = stVElementName.ent
	else
		if IsValid(v._stencilEntity) then
			render.SetBlend(0)
				v._stencilEntity:DrawModel()
			render.SetBlend(1)
		end
	end
end

local colWhite = Color(255,255,255)
local colWhiteTr = Color(255,255,255,123)

local attachmEnt, retAtt, retDist, retPos, retNorm, retAng, retSize, retTable

function SWEP:_renderStencilReticle(att)
	if not att then return end
	if not self.VElements[att.name] then return end
	
	attachmEnt = self.VElements[att.name].ent
	if !IsValid(attachmEnt) then return end
	
	retTable = self.VElements[att.name].reticleTable
	if !retTable then return end
	
	if !retTable.useMuzzleAngles then
		retAtt = attachmEnt:GetAttachment(1)
		if not retAtt then return end
	else
		retAtt = self.VM:GetAttachment(self.VM:LookupAttachment(self.MuzzleAttachmentName))
		if not retAtt then return end
	end
	
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	
	// draw stencil entity (the part where the reticle will be visible)
	self:_drawStencilEntity(att)
	
	render.SetStencilWriteMask(2)
	render.SetStencilTestMask(2)
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	
	retDist = retTable.useMuzzleAngles and ((attachmEnt:GetPos():Distance(EyePos())) * 64) or ((retAtt.Pos:Distance(EyePos())) * 64)
	retPos =  retTable.useMuzzleAngles and (EyePos() + retAtt.Ang:Forward() * retDist) or (retAtt.Pos + retAtt.Ang:Forward() * retDist)
	
	retNorm = retAtt.Ang:Forward()
	retAng =  -retAtt.Ang.z + (retTable.reticleRotate or 0)
	
	retSize = retTable.reticleSize
	
	// draw the reticle
	cam.IgnoreZ(true)
		render.SetMaterial(retTable.reticleMaterial)
		render.DrawQuadEasy(retPos, -retNorm, retSize, retSize, colWhite, retAng)
		render.DrawQuadEasy(retPos, -retNorm, retSize, retSize, colWhiteTr, retAng)
	cam.IgnoreZ(false)

	render.SetStencilEnable(false)
end

function SWEP:renderStencilReticles()
	if self.VElements then
		for k, v in pairs(self.VElements) do
			if v.active and v.reticleTable and !v.reticleTable.dontRender then // only render for active velements
				self:_renderStencilReticleForVElement(k)
			end
		end
	end
end

function SWEP:_renderStencilReticleForVElement(velement_name)
	if !self.VElements then return end
	local t = self.VElements[velement_name]
	if !t then return end
	self:_renderStencilReticle(t)
end
