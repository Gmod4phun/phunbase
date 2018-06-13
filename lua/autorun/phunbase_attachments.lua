AddCSLuaFile()

PHUNBASE.registeredAttachments = {}
PHUNBASE.registeredAttachmentsSKey = {} -- SKey stands for 'string key', whereas the registeredAttachments has numerical indexes

PHUNBASE.knownStatTexts = {}
PHUNBASE.knownVariableTexts = {}
PHUNBASE.giveAllAttachmentsOnSpawn = 1 -- set to 0 to disable all attachments on spawn
PHUNBASE.canOpenInteractionMenu = true -- whether the interaction menu can be opened
PHUNBASE.playSoundsOnInteract = true -- whether it should play sounds when interacting with the weapon (attaching stuff, changing ammo, etc)
PHUNBASE.customizationEnabled = true -- whether we can customize our guns in general
PHUNBASE.customizationMenuKey = "+menu_context" -- the key we need to press to toggle the customization menu

local fallbackFuncs = {}
function fallbackFuncs:canEquip()
	return true
end

local totalAtts = 1

-- base func for registering atts
function PHUNBASE:registerAttachment(tbl)	
	tbl.id = totalAtts
	
	-- set the metatable of the current attachment to a fallback table, so that we can fallback to pre-defined funcs in case we're calling a nil method
	setmetatable(tbl, {__index = fallbackFuncs})
	
	local val, key = self:findAttachment(tbl.name) 
	
	if val then -- don't register attachments that are already registered, instead, just override them
		self.registeredAttachments[key] = tbl
		self.registeredAttachmentsSKey[tbl.name] = tbl
		return
	end

	table.insert(self.registeredAttachments, tbl)
	
	self.registeredAttachmentsSKey[tbl.name] = tbl
	
	totalAtts = totalAtts + 1
end

function PHUNBASE:getAttachmentTableByName(name)
	if !name then return nil end

	local att = self.registeredAttachmentsSKey[name]
	
	if att then
		return att
	else
		return nil
	end
end

function PHUNBASE:findAttachment(name)
	-- find the matching attachment
	for k, v in ipairs(self.registeredAttachments) do
		if v.name == name then
			return v, k
		end
	end
	
	-- if there is none, return nil
	return nil
end

function PHUNBASE:canBeAttached(attachmentData, attachmentList, currentAttachmentIndex, currentAttachmentCategory, currentAttachment)
	if not attachmentData.dependencies then
		return true
	end
	
	attachmentList = attachmentList or self.Attachments
	
	local dependency = nil
	
	for k, v in pairs(attachmentList) do
		if v.last then
			for k2, v2 in ipairs(v.atts) do
				if attachmentData.dependencies[v2] then
					if v.last == k2 then
						return true
					else
						dependency = attachmentData.dependencies[v2]
					end
				end
			end
		end
	end
	
	return false, dependency
end

function PHUNBASE:cycleSubCustomization()
	if self.SightColorTarget then
		PHUNBASE.colorableParts.cycleColor(self, self.SightColorTarget)
	elseif self.GrenadeTarget then
		PHUNBASE.grenadeTypes.cycleGrenades(self)
	end
	
	self.SubCustomizationCycleTime = nil
end

function PHUNBASE:registerRecognizedStat(name, lesser, greater)
	self.knownStatTexts[name] = {lesser = lesser, greater = greater}
end

function PHUNBASE:registerRecognizedVariable(name, lesser, greater, attachCallback, detachCallback)
	self.knownVariableTexts[name] = {lesser = lesser, greater = greater, attachCallback = attachCallback, detachCallback = detachCallback}
end

-- register the recognized stats so that people just have to fill out the 'statModifiers' table and be done with it
PHUNBASE:registerRecognizedStat("DamageMult", "Decreases damage", "Increases damage")
PHUNBASE:registerRecognizedStat("RecoilMult", "Decreases recoil", "Increases recoil")
PHUNBASE:registerRecognizedStat("FireDelayMult", "Increases firerate", "Decreases firerate")
PHUNBASE:registerRecognizedStat("HipSpreadMult", "Decreases hip spread", "Increases hip spread")
PHUNBASE:registerRecognizedStat("AimSpreadMult", "Decreases aim spread", "Increases aim spread")
PHUNBASE:registerRecognizedStat("ClumpSpreadMult", "Decreases clump spread", "Increases clump spread")
PHUNBASE:registerRecognizedStat("DrawSpeedMult", "Decreases deploy speed", "Increases deploy speed")
PHUNBASE:registerRecognizedStat("ReloadSpeedMult", "Decreases reload speed", "Increases reload speed")
PHUNBASE:registerRecognizedStat("OverallMouseSensMult", "Decreases handling", "Increases handling")
PHUNBASE:registerRecognizedStat("VelocitySensitivityMult", "Increases mobility", "Decreases mobility")
PHUNBASE:registerRecognizedStat("SpreadPerShotMult", "Decreases spread per shot", "Increases spread per shot")
PHUNBASE:registerRecognizedStat("MaxSpreadIncMult", "Decreases accumulative spread", "Increases accumulative spread")

PHUNBASE:registerRecognizedVariable("SpeedDec", "Increases movement speed by ", "Decreases movement speed by ", 
	function(weapon, attachmentData)
		weapon.SpeedDec = weapon.SpeedDec + attachmentData.SpeedDec
	end,
	
	function(weapon, attachmentData)
		weapon.SpeedDec = weapon.SpeedDec - attachmentData.SpeedDec
	end
)

-- load attachment files from default folder, you can add your own anywhere, just make sure to run the file
for k, v in pairs(file.Find("phunbase/attachments/*", "LUA")) do
	PHUNBASE.LoadLua("phunbase/attachments/"..v)
end
