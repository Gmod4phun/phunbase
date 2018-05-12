-- PHUNBASE VER FILE --
// You should not change anything here

if CLIENT then
	AddCSLuaFile()

	PHUNBASE.Version = 21

	local function VerCheckNeedUpdateMsg(your, latest)
		chat.AddText(Color(0, 180, 200, 255), "[PHUNBASE] ", Color(255,255,255,255), "Hey there, there is a new PHUNBASE version. Your version: "..your..", latest version: "..latest..". Updating is recommended.")
	end

	local function VerCheckFailMsg()
		chat.AddText(Color(0, 180, 200, 255), "[PHUNBASE] ", Color(250,10,10,255), "Version checking failed. Check the GitHub page to see if there is a new version.")
	end

	local function VerCheckOkayMsg()
		chat.AddText(Color(0, 180, 200, 255), "[PHUNBASE] ", Color(10,250,10,255), "Thank you for using the latest PHUNBASE version. If you encounter any errors, you can open a new Issue on the GitHub page.")
	end

	function PHUNBASE.CheckVersion()
		local pageTable = {}
		local verFile = "https://raw.githubusercontent.com/Gmod4phun/phunbase/master/lua/autorun/phunbase_version.lua"
		local verLine = {}
		local latestVer = 0

		http.Fetch(verFile,
			function(body, size, headers, code)
				pageTable = string.Split(body, "\n")
				if pageTable[1] == "-- PHUNBASE VER FILE --" then // top of this file
					verLine = string.Split(pageTable[7], " ")
					latestVer = tonumber(verLine[#verLine])
					if PHUNBASE.Version < latestVer then
						VerCheckNeedUpdateMsg(PHUNBASE.Version, latestVer)
					elseif PHUNBASE.Version == latestVer then
						VerCheckOkayMsg()
					end
				else
					VerCheckFailMsg()
				end
			end,
			function(error)
				VerCheckFailMsg()
			end
		)
	end

	local pbverchecked = false
	hook.Add("InitPostEntity", "PHUNBASE_Version_Check", function()
		if !pbverchecked then
			pbverchecked = true
			timer.Simple(3, function()
				PHUNBASE.CheckVersion()
			end)
		end
	end)
end
