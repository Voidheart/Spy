--[[ 
TODO: Needs to be fully implemented

The goal is to replace the Spy's current list system with a more efficient and flexible system.

Needs to support the following:
 - Find a player with in a distance
 - Improve safety checks
 - .. more to come
]]

Spy.Query = {}

-- A utility to get the size of a table with string keys.
local function getTableSize(t)
	if not t or type(t) ~= "table" then
		return 0
	end
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

---
-- Checks if a player is in the specified list.
-- @param list The Spy list table to check (e.g., Spy.NearbyList).
-- @param playerName The name of the player.
-- @return boolean True if the player is in the list, false otherwise.
---
function Spy.Query:IsPlayerInList(list, playerName)
	if not list or type(list) ~= "table" or not playerName then
		return false
	end
	return list[playerName] ~= nil
end

---
-- Checks if a player is currently in the Nearby list.
-- @param playerName The name of the player.
-- @return boolean
---
function Spy.Query:IsPlayerNearby(playerName)
	return self:IsPlayerInList(Spy.NearbyList, playerName)
end

---
-- Checks if a player is currently in the Active list.
-- @param playerName The name of the player.
-- @return boolean
---
function Spy.Query:IsPlayerActive(playerName)
	return self:IsPlayerInList(Spy.ActiveList, playerName)
end

---
-- Checks if a player is currently in the Inactive list.
-- @param playerName The name of the player.
-- @return boolean
---
function Spy.Query:IsPlayerInactive(playerName)
	return self:IsPlayerInList(Spy.InactiveList, playerName)
end

---
-- Returns the number of players in a given list.
-- @param listName The name of the list (e.g., "NearbyList", "ActiveList").
-- @return number The count of players in the list.
---
function Spy.Query:GetPlayerCount(listName)
	local list = Spy[listName]
	if list and type(list) == "table" then
		return getTableSize(list)
	end
	return 0
end

---
-- Returns a array of player names from a given list.
-- @param list The Spy list table to query.
-- @return table An array of player names.
---
function Spy.Query:GetPlayerNamesFromList(list)
	local names = {}
	if list and type(list) == "table" then
		for playerName in pairs(list) do
			table.insert(names, playerName)
		end
	end
	return names
end

---
-- Retrieves all players currently in the Nearby list.
-- @return table An array of player names.
---
function Spy.Query:GetNearbyPlayers()
	return self:GetPlayerNamesFromList(Spy.NearbyList)
end

---
-- Retrieves all players currently in the Active list.
-- @return table An array of player names.
---
function Spy.Query:GetActivePlayers()
	return self:GetPlayerNamesFromList(Spy.ActiveList)
end

---
-- Retrieves all players currently in the Inactive list.
-- @return table An array of player names.
---
function Spy.Query:GetInactivePlayers()
	return self:GetPlayerNamesFromList(Spy.InactiveList)
end

---
-- Retrieves all players currently being displayed in the main window.
-- @return table An array of player names.
---
function Spy.Query:GetCurrentListPlayers()
	local names = {}
	if Spy.CurrentList and type(Spy.CurrentList) == "table" then
		for _, data in ipairs(Spy.CurrentList) do
			table.insert(names, data.player)
		end
	end
	return names
end

---
-- Finds a player's data across all tracked lists and the main player database.
-- @param playerName The name of the player to find.
-- @return table A consolidated information table, or nil if not found or if data is malformed.
---
function Spy.Query:FindPlayer(playerName)
	if not playerName or type(playerName) ~= "string" then
		return nil
	end

	if
		not SpyPerCharDB
		or type(SpyPerCharDB) ~= "table"
		or not SpyPerCharDB.PlayerData
		or type(SpyPerCharDB.PlayerData) ~= "table"
	then
		return nil
	end
	local playerData = SpyPerCharDB.PlayerData[playerName]
	if not playerData then
		return nil
	end

	local info = {
		name = playerName,
		data = playerData,
		isNearby = self:IsPlayerNearby(playerName),
		isActive = self:IsPlayerActive(playerName),
		isInactive = self:IsPlayerInactive(playerName),
		isKOS = SpyPerCharDB.KOSData and SpyPerCharDB.KOSData[playerName] ~= nil,
		isIgnored = SpyPerCharDB.IgnoreData and SpyPerCharDB.IgnoreData[playerName] ~= nil,
		lastSeen = Spy.LastHourList and Spy.LastHourList[playerName],
	}

	return info
end
