AddCSLuaFile()

PHUNBASE.firemodes = {}
PHUNBASE.firemodes.registered = {}
PHUNBASE.firemodes.registeredByID = {}

-- id - the ID of the firemode
-- display - the text to display when the firemode is active
-- automatic - whether it is a full-auto firemode
-- burstAmount - amount of rounds to fire, pass 0 to make it not have a burst system
-- bulletDisplay - amount of rounds to display on the HUD
function PHUNBASE.firemodes:registerFiremode(id, display, automatic, burstAmount, bulletDisplay)
	local fireModeData = {id = id, display = display, auto = automatic, burstamt = burstAmount, buldis = bulletDisplay}
	
	table.insert(self.registered, fireModeData)
	self.registeredByID[id] = fireModeData
end

PHUNBASE.firemodes:registerFiremode("auto", "FULL-AUTO", true, 0, 5)
PHUNBASE.firemodes:registerFiremode("semi", "SEMI-AUTO", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("single", "SINGLE-ACTION", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("double", "DOUBLE-ACTION", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("bolt", "BOLT-ACTION", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("pump", "PUMP-ACTION", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("break", "BREAK-ACTION", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("lever", "LEVER-ACTION", false, 0, 1)
PHUNBASE.firemodes:registerFiremode("2burst", "2-ROUND BURST", true, 2, 2)
PHUNBASE.firemodes:registerFiremode("3burst", "3-ROUND BURST", true, 3, 3)
PHUNBASE.firemodes:registerFiremode("safe", "SAFE", false, 0, 0)
