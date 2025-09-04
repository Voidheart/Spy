----------------------------------------------------------------
-- Spy.lua
-- Optimizations By: Plagueheart
-- Server: Project Epoch
----------------------------------------------------------------
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local Astrolabe = DongleStub("Astrolabe-0.4")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("Spy")

-- region Plagueheart
local bit_band = bit.band
local strsplit = strsplit
local strlen = strlen
local strsub = strsub
local strreplace = strreplace
local strfind = strfind
local strupper = strupper
local time = time
local tonumber = tonumber
local math_floor = math.floor
-- endregion Plagueheart

Spy = LibStub("AceAddon-3.0"):NewAddon("Spy", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
Spy.Version = "1.3"
Spy.DatabaseVersion = "1.1"
Spy.Signature = "[Spy]"
Spy.ButtonLimit = 10
Spy.MaximumPlayerLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]
Spy.MapNoteLimit = 20
Spy.MapProximityThreshold = 0.02
Spy.CurrentMapNote = 1
Spy.ZoneID = {}
Spy.KOSGuild = {}
Spy.CurrentList = {}
Spy.NearbyList = {}
Spy.LastHourList = {}
Spy.WorldList = {}
Spy.ActiveList = {}
Spy.InactiveList = {}
Spy.PlayerCommList = {}
Spy.ListAmountDisplayed = 0
Spy.ButtonName = {}
Spy.EnabledInZone = false
Spy.InInstance = false
Spy.AlertType = nil
Spy.UpgradeMessageSent = false

-- region Plagueheart
--- Timeout settings for different options.
local TIMEOUTS = {
	Nearby = {
		OneMinute = { active = 30, inactive = 60 },
		TwoMinutes = { active = 60, inactive = 120 },
		FiveMinutes = { active = 150, inactive = 300 },
		TenMinutes = { active = 300, inactive = 600 },
		FifteenMinutes = { active = 450, inactive = 900 },
		Never = { active = 30, inactive = -1 },
		default = { active = 150, inactive = 300 },
	},
	World = {
		ThirtyMinutes = 1800,
		OneHour = 3600,
		TwoHours = 7200,
		FourHours = 14400,
		Never = -1,
		default = 3600,
	},
}

--- Flag: track if the player is currently zoning or in a loading state.
Spy.IsCurrentlyZoning = false
--- Flag: throttle UI refreshes.
Spy.RefreshRequested = false
--- Delay between UI refreshes.
Spy.RefreshDelay = 0.2
--- Delay between map updates.
Spy.MapUpdateDelay = {
	-- If we're zoning, use a longer delay to ensure the UI is stable.
	Zoning = 2.5,
	-- Otherwise, a short delay is enough to break the synchronous loop.
	NotZoning = 0.5,
}
-- endregion Plagueheart

function Spy:CreateMockPlayerData(name, isKOS, guild, isKOSGuild)
	-- Create a temporary player data entry for testing alerts
	if not SpyPerCharDB.PlayerData[name] then
		SpyPerCharDB.PlayerData[name] = {}
	end
	if guild then
		SpyPerCharDB.PlayerData[name].guild = guild
	end
	SpyPerCharDB.PlayerData[name].isEnemy = true
	SpyPerCharDB.PlayerData[name].reason = {
		["Ganker"] = true,
		["Camper"] = true,
	}
	SpyPerCharDB.PlayerData[name].zone = "Stranglethorn Vale"
	SpyPerCharDB.PlayerData[name].mapX = 0.32
	SpyPerCharDB.PlayerData[name].mapY = 0.18

	-- Handle KOS status
	if isKOS then
		SpyPerCharDB.KOSData[name] = time()
	end

	-- Handle KOS Guild status
	if isKOSGuild and guild then
		Spy.KOSGuild[guild] = true
	end
end

function Spy:RemoveMockPlayerData(name)
	-- Clean up temporary player data after a test
	local playerData = SpyPerCharDB.PlayerData[name]
	if playerData and playerData.guild then
		Spy.KOSGuild[playerData.guild] = nil
	end
	SpyPerCharDB.PlayerData[name] = nil
	SpyPerCharDB.KOSData[name] = nil
end

SM:Register("statusbar", "blend", [[Interface\Addons\Spy\Textures\bar-blend.tga]])

-- #region Plagueheart
function Spy:MergeDefaults(target, defaults)
	if type(target) ~= "table" or type(defaults) ~= "table" then
		return
	end

	for key, defaultValue in pairs(defaults) do
		if target[key] == nil then
			target[key] = defaultValue
		elseif type(target[key]) == "table" and type(defaultValue) == "table" then
			self:MergeDefaults(target[key], defaultValue)
		end
	end
end

function Spy:CheckDatabase()
	if not SpyPerCharDB or not SpyPerCharDB.PlayerData then
		SpyPerCharDB = {}
	end
	SpyPerCharDB.version = Spy.DatabaseVersion
	if not SpyPerCharDB.PlayerData then
		SpyPerCharDB.PlayerData = {}
	end
	if not SpyPerCharDB.IgnoreData then
		SpyPerCharDB.IgnoreData = {}
	end
	if not SpyPerCharDB.KOSData then
		SpyPerCharDB.KOSData = {}
	end

	if SpyDB.kosData == nil then
		SpyDB.kosData = {}
	end
	if SpyDB.kosData[Spy.RealmName] == nil then
		SpyDB.kosData[Spy.RealmName] = {}
	end
	if SpyDB.kosData[Spy.RealmName][Spy.FactionName] == nil then
		SpyDB.kosData[Spy.RealmName][Spy.FactionName] = {}
	end
	if SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName] == nil then
		SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName] = {}
	end

	if SpyDB.removeKOSData == nil then
		SpyDB.removeKOSData = {}
	end
	if SpyDB.removeKOSData[Spy.RealmName] == nil then
		SpyDB.removeKOSData[Spy.RealmName] = {}
	end
	if SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName] == nil then
		SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName] = {}
	end

	if Spy.db.profile == nil then
		Spy.db.profile = {}
	end

	self:MergeDefaults(Spy.db.profile, Spy.Options:GetDefaultProfile())
end
-- #endregion Plagueheart

function Spy:ResetProfile()
	Spy.db.profile = Spy.Options:GetDefaultProfile()
end

function Spy:HandleProfileChanges()
	Spy:CreateMainWindow()
	Spy:UpdateTimeoutSettings()
	Spy:UpdateWorldListTimeoutSettings()
	Spy.NearbyThresholdYards = self.db.profile.NearbyThresholdYards
end

function Spy:SetupOptions()
	self.optionsFrames = {}

	local options = Spy.Options:GetOptions()
	local optionsSlash = Spy.Options:GetSlashOptions()

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Spy", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Spy Commands", optionsSlash, "spy")

	local ACD3 = LibStub("AceConfigDialog-3.0")
	self.optionsFrames.Spy = ACD3:AddToBlizOptions("Spy", nil, nil, "General")
	self.optionsFrames.DisplayOptions = ACD3:AddToBlizOptions("Spy", L["DisplayOptions"], "Spy", "DisplayOptions")
	self.optionsFrames.AlertOptions = ACD3:AddToBlizOptions("Spy", L["AlertOptions"], "Spy", "AlertOptions")
	self.optionsFrames.ListOptions = ACD3:AddToBlizOptions("Spy", L["ListOptions"], "Spy", "ListOptions")
	self.optionsFrames.WorldListOptions = ACD3:AddToBlizOptions("Spy", L["WorldListOptions"], "Spy", "WorldListOptions")
	self.optionsFrames.DataOptions = ACD3:AddToBlizOptions("Spy", L["MinimapOptions"], "Spy", "MinimapOptions")
	self.optionsFrames.DataOptions = ACD3:AddToBlizOptions("Spy", L["DataOptions"], "Spy", "DataOptions")

	options.args.Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.Profiles.order = -2
	self.optionsFrames.Profiles = ACD3:AddToBlizOptions("Spy", L["Profiles"], "Spy", "Profiles")
end

function Spy:UpdateTimeoutSettings()
	local removeSetting = Spy.db.profile.RemoveUndetected
	local timeout = TIMEOUTS.Nearby[removeSetting] or TIMEOUTS.Nearby.default

	Spy.ActiveTimeout = timeout.active
	Spy.InactiveTimeout = timeout.inactive
end

function Spy:UpdateWorldListTimeoutSettings()
	local setting = Spy.db.profile.RemoveFromWorldList
	Spy.WorldListTimeout = TIMEOUTS.World[setting] or TIMEOUTS.World.default
end

function Spy:ResetMainWindow()
	Spy:EnableSpy(true, true)
	Spy:CreateMainWindow()
	Spy:RestoreMainWindowPosition(
		Spy.Options:GetDefaultProfile().MainWindow.Position.x,
		Spy.Options:GetDefaultProfile().MainWindow.Position.y,
		Spy.Options:GetDefaultProfile().MainWindow.Position.w,
		44
	)
	Spy:RequestRefresh()
end

function Spy:ShowConfig()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Spy)
end

function Spy:OnEnable(first)
	Spy.timeid = Spy:ScheduleRepeatingTimer("ManageExpirations", 10, true)
	Spy:RegisterEvent("ZONE_CHANGED", "ZoneChangedEvent")
	Spy:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChangedEvent")
	Spy:RegisterEvent("PLAYER_ENTERING_WORLD", "ZoneChangedEvent")
	Spy:RegisterEvent("UNIT_FACTION", "ZoneChangedEvent")
	Spy:RegisterEvent("PLAYER_TARGET_CHANGED", "PlayerTargetEvent")
	Spy:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "PlayerMouseoverEvent")
	Spy:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLogEvent")
	Spy:RegisterEvent("WORLD_MAP_UPDATE", "WorldMapUpdateEvent")
	Spy:RegisterEvent("PLAYER_REGEN_ENABLED", "LeftCombatEvent")
	Spy:RegisterEvent("PLAYER_DEAD", "PlayerDeadEvent")
	Spy:RegisterComm(Spy.Signature, "CommReceived")
	Spy.IsEnabled = true
	Spy:RequestRefresh()
end

function Spy:OnDisable()
	if not Spy.IsEnabled then
		return
	end
	if Spy.timeid then
		Spy:CancelTimer(Spy.timeid)
		Spy.timeid = nil
	end
	Spy:UnregisterEvent("ZONE_CHANGED")
	Spy:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	Spy:UnregisterEvent("PLAYER_ENTERING_WORLD")
	Spy:UnregisterEvent("UNIT_FACTION")
	Spy:UnregisterEvent("PLAYER_TARGET_CHANGED")
	Spy:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
	Spy:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	Spy:UnregisterEvent("WORLD_MAP_UPDATE")
	Spy:UnregisterEvent("PLAYER_REGEN_ENABLED")
	Spy:UnregisterEvent("PLAYER_DEAD")
	Spy:UnregisterComm(Spy.Signature)
	Spy.IsEnabled = false
end

function Spy:EnableSpy(value, changeDisplay, hideEnabledMessage)
	Spy.db.profile.Enabled = value
	if value then
		if changeDisplay then
			Spy.MainWindow:Show()
		end
		Spy:OnEnable()
		if not hideEnabledMessage then
			DEFAULT_CHAT_FRAME:AddMessage(L["SpyEnabled"])
		end
	else
		if changeDisplay then
			Spy.MainWindow:Hide()
		end
		Spy:OnDisable()
		DEFAULT_CHAT_FRAME:AddMessage(L["SpyDisabled"])
	end
end

function Spy:BuildZoneIDTable_z(continentIndex, zoneIndex, zoneName, next, ...)
	zoneIndex = zoneIndex + 1
	Spy.ZoneID[zoneName] = {}
	Spy.ZoneID[zoneName].continentIndex = continentIndex
	Spy.ZoneID[zoneName].zoneIndex = zoneIndex
	if next then
		Spy:BuildZoneIDTable_z(continentIndex, zoneIndex, next, ...)
	end
end

function Spy:BuildZoneIDTable(zoneIndex, continentName, next, ...)
	zoneIndex = zoneIndex + 1
	Spy:BuildZoneIDTable_z(zoneIndex, 0, GetMapZones(zoneIndex))
	if next then
		Spy:BuildZoneIDTable(zoneIndex, next, ...)
	end
end

function Spy:GetZoneID(zoneName)
	if not Spy.ZoneID[zoneName] then
		return nil
	end
	return Spy.ZoneID[zoneName].continentIndex, Spy.ZoneID[zoneName].zoneIndex
end

function Spy:OnInitialize()
	WorldMapFrame:Show()
	WorldMapFrame:Hide()

	Spy.RealmName = GetCVar("realmName")
	Spy.FactionName, _ = UnitFactionGroup("player")
	if Spy.FactionName == "Alliance" then
		Spy.EnemyFactionName = "Horde"
	else
		Spy.EnemyFactionName = "Alliance"
	end
	Spy.CharacterName = UnitName("player")

	Spy.ValidClasses = {}
	Spy.ValidClasses["DEATHKNIGHT"] = true
	Spy.ValidClasses["DRUID"] = true
	Spy.ValidClasses["HUNTER"] = true
	Spy.ValidClasses["MAGE"] = true
	Spy.ValidClasses["PALADIN"] = true
	Spy.ValidClasses["PRIEST"] = true
	Spy.ValidClasses["ROGUE"] = true
	Spy.ValidClasses["SHAMAN"] = true
	Spy.ValidClasses["WARLOCK"] = true
	Spy.ValidClasses["WARRIOR"] = true
	Spy.ValidRaces = {}
	Spy.ValidRaces["Blood Elf"] = true
	Spy.ValidRaces["Draenei"] = true
	Spy.ValidRaces["Dwarf"] = true
	Spy.ValidRaces["Gnome"] = true
	Spy.ValidRaces["Human"] = true
	Spy.ValidRaces["Night Elf"] = true
	Spy.ValidRaces["Orc"] = true
	Spy.ValidRaces["Tauren"] = true
	Spy.ValidRaces["Troll"] = true
	Spy.ValidRaces["Undead"] = true

	local acedb = LibStub:GetLibrary("AceDB-3.0")

	Spy.db = acedb:New("SpyDB")
	Spy:CheckDatabase()

	self.db.RegisterCallback(self, "OnNewProfile", "ResetProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "ResetProfile")
	self.db.RegisterCallback(self, "OnProfileChanged", "HandleProfileChanges")
	self.db.RegisterCallback(self, "OnProfileCopied", "HandleProfileChanges")
	self:SetupOptions()

	Spy:BuildZoneIDTable(0, GetMapContinents())

	SpyTempTooltip = CreateFrame("GameTooltip", "SpyTempTooltip", nil, "GameTooltipTemplate")
	SpyTempTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	Spy:RegenerateKOSGuildList()
	if Spy.db.profile.ShareKOSBetweenCharacters then
		Spy:RemoveLocalKOSPlayers()
		Spy:RegenerateKOSCentralList()
		Spy:RegenerateKOSListFromCentral()
	end
	Spy:PurgeUndetectedData()
	Spy:CreateMainWindow()
	Spy:UpdateTimeoutSettings()
	Spy:UpdateWorldListTimeoutSettings()
	Spy.NearbyThresholdYards = self.db.profile.NearbyThresholdYards

	SM.RegisterCallback(Spy, "LibSharedMedia_Registered", "UpdateBarTextures")
	SM.RegisterCallback(Spy, "LibSharedMedia_SetGlobal", "UpdateBarTextures")
	if Spy.db.profile.BarTexture then
		Spy:SetBarTextures(Spy.db.profile.BarTexture)
	end

	Spy:LockWindows(Spy.db.profile.Locked)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Spy.FilterNotInParty)
	DEFAULT_CHAT_FRAME:AddMessage(L["LoadDescription"])
end

-- #region Plagueheart
function Spy:ZoneChangedEvent(event)
	if event ~= "PLAYER_ENTERING_WORLD" then
		Spy.IsCurrentlyZoning = true
	end

	Spy.InInstance = false

	local pvpType = GetZonePVPInfo()
	if pvpType == "sanctuary" or GetZoneText() == "" then
		Spy.EnabledInZone = false
	else
		Spy.EnabledInZone = true

		local inInstance, instanceType = IsInInstance()
		if inInstance then
			Spy.InInstance = true
			if
				instanceType == "party"
				or instanceType == "raid"
				or (not Spy.db.profile.EnabledInBattlegrounds and instanceType == "pvp")
				or (not Spy.db.profile.EnabledInArenas and instanceType == "arena")
			then
				Spy.EnabledInZone = false
			end
		elseif pvpType == "combat" then
			if not Spy.db.profile.EnabledInWintergrasp then
				Spy.EnabledInZone = false
			end
		elseif pvpType == "friendly" or pvpType == nil then
			if UnitIsPVP("player") == nil and Spy.db.profile.DisableWhenPVPUnflagged then
				Spy.EnabledInZone = false
			end
		end
	end

	if Spy.EnabledInZone then
		if not Spy.db.profile.HideSpy then
			Spy.MainWindow:Show()
			Spy:RequestRefresh()
		end
	else
		Spy.MainWindow:Hide()
	end

	if event == "PLAYER_ENTERING_WORLD" then
		Spy:ScheduleTimer(function()
			Spy.IsCurrentlyZoning = false
			if Spy.db.profile.Enabled and Spy.EnabledInZone then
				Spy:WorldMapUpdateEvent()
			end
		end, 2)
	end
end

--- IMPLEMENTATION: DRY for target and mouseover events.
function Spy:ProcessUnitDetails(unit)
	local name = GetUnitName(unit, true)
	if not (name and UnitIsPlayer(unit) and not SpyPerCharDB.IgnoreData[name]) then
		return
	end

	local playerData = SpyPerCharDB.PlayerData[name]
	if UnitIsEnemy("player", unit) then
		name = strreplace(name, " - ", "-")

		local learnt = true
		if playerData and playerData.isGuess == false then
			learnt = false
		end

		local _, class = UnitClass(unit)
		local race, _ = UnitRace(unit)
		local level = tonumber(UnitLevel(unit))
		local guild = GetGuildInfo(unit)
		local guess = false
		if level and level <= 0 then
			guess = true
			level = nil
		end

		Spy:UpdatePlayerData(name, class, level, race, guild, true, guess)
		if Spy.EnabledInZone then
			Spy:AddDetected(name, time(), learnt)
		end
	elseif playerData then
		Spy:RemovePlayerData(name)
	end
end

function Spy:PlayerTargetEvent()
	self:ProcessUnitDetails("target")
end

function Spy:PlayerMouseoverEvent()
	self:ProcessUnitDetails("mouseover")
end
-- #endregion Plagueheart

function Spy:CombatLogEvent(_, timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if not Spy.EnabledInZone then
		return
	end

	local HOSTILE_FLAG = COMBATLOG_OBJECT_REACTION_HOSTILE

	if
		bit_band(srcFlags, HOSTILE_FLAG) == HOSTILE_FLAG
		and srcGUID
		and srcName
		and not SpyPerCharDB.IgnoreData[srcName]
	then
		local srcType = bit_band(tonumber("0x" .. strsub(srcGUID, 3, 5)), 0x00F)
		if srcType == 0 or srcType == 8 then -- Player or Pet
			local learnt = false
			local detected = true
			local playerData = SpyPerCharDB.PlayerData[srcName]
			if not playerData or playerData.isGuess then
				learnt, playerData = Spy:ParseUnitAbility(true, event, srcName, srcFlags, arg9, arg10)
			end
			if not learnt then
				detected = Spy:UpdatePlayerData(srcName, nil, nil, nil, nil, true, nil)
			end

			if detected then
				Spy:AddDetected(srcName, timestamp, learnt)
				if event == "SPELL_AURA_APPLIED" and (arg10 == L["Stealth"] or arg10 == L["Prowl"]) then
					Spy:AlertStealthPlayer(srcName)
				end
			end

			if dstGUID == UnitGUID("player") then
				Spy.LastAttack = srcName
			end
		end
	end

	if
		bit_band(dstFlags, HOSTILE_FLAG) == HOSTILE_FLAG
		and dstGUID
		and dstName
		and not SpyPerCharDB.IgnoreData[dstName]
	then
		local dstType = bit_band(tonumber("0x" .. strsub(dstGUID, 3, 5)), 0x00F)
		if dstType == 0 or dstType == 8 then -- Player or Pet
			local learnt = false
			local detected = true
			local playerData = SpyPerCharDB.PlayerData[dstName]
			if not playerData or playerData.isGuess then
				learnt, playerData = Spy:ParseUnitAbility(false, event, dstName, dstFlags, arg9, arg10)
			end
			if not learnt then
				detected = Spy:UpdatePlayerData(dstName, nil, nil, nil, nil, true, nil)
			end

			if detected then
				Spy:AddDetected(dstName, timestamp, learnt)
			end
		end
	end

	if event == "PARTY_KILL" then
		if srcGUID == UnitGUID("player") and dstName then
			local playerData = SpyPerCharDB.PlayerData[dstName]
			if playerData then
				if not playerData.wins then
					playerData.wins = 0
				end
				playerData.wins = playerData.wins + 1
			end
		end
	end
end

function Spy:LeftCombatEvent()
	Spy.LastAttack = nil
	Spy:RequestRefresh()
end

function Spy:PlayerDeadEvent()
	if Spy.LastAttack then
		local playerData = SpyPerCharDB.PlayerData[Spy.LastAttack]
		if playerData then
			if not playerData.loses then
				playerData.loses = 0
			end
			playerData.loses = playerData.loses + 1
		end
	end
end

function Spy:WorldMapUpdateEvent()
	for i = 1, Spy.MapNoteLimit do
		local note = Spy.MapNoteList[i]
		if note.displayed then
			Astrolabe:PlaceIconOnWorldMap(
				WorldMapDetailFrame,
				note.worldIcon,
				note.continentIndex,
				note.zoneIndex,
				note.mapX,
				note.mapY
			)
			Astrolabe:PlaceIconOnMinimap(note.miniIcon, note.continentIndex, note.zoneIndex, note.mapX, note.mapY)
		end
	end
end

-- #region Plagueheart
--- IMPLEMENTATION: Deferred map updates and improved data validations.
function Spy:CommReceived(prefix, message, distribution, source)
	if not (Spy.EnabledInZone and Spy.db.profile.UseData) then
		return
	end
	if prefix ~= Spy.Signature or not message or source == Spy.CharacterName then
		return
	end

	local version, player, class, level, race, zone, subZone, mapX, mapY, guild = strsplit("|", message)
	if player and (not Spy.InInstance or zone == GetZoneText()) then
		if not Spy.PlayerCommList[player] then
			if tonumber(version) > tonumber(Spy.Version) and not Spy.UpgradeMessageSent then
				DEFAULT_CHAT_FRAME:AddMessage(L["UpgradeAvailable"])
				Spy.UpgradeMessageSent = true
			end

			if strlen(class) > 0 then
				if not Spy.ValidClasses[class] then
					return
				end
			else
				class = nil
			end

			if strlen(level) > 0 then
				level = tonumber(level)
				if
					not (
						type(level) == "number"
						and level >= 1
						and level <= Spy.MaximumPlayerLevel
						and math_floor(level) == level
					)
				then
					return
				end
			else
				level = nil
			end

			if strlen(race) > 0 then
				if not Spy.ValidRaces[race] then
					return
				end
			else
				race = nil
			end

			if strlen(zone) > 0 then
				if not Spy:GetZoneID(zone) then
					return
				end
			else
				zone = nil
			end

			if strlen(subZone) == 0 then
				subZone = nil
			end

			if strlen(mapX) > 0 then
				mapX = tonumber(mapX)
				if not (type(mapX) == "number" and mapX >= 0 and mapX <= 1) then
					return
				end
			else
				mapX = nil
			end

			if strlen(mapY) > 0 then
				mapY = tonumber(mapY)
				if not (type(mapY) == "number" and mapY >= 0 and mapY <= 1) then
					return
				end
			else
				mapY = nil
			end

			if strlen(guild) > 24 then
				return
			end
			if strlen(guild) == 0 then
				guild = nil
			end

			local learnt, playerData =
				Spy:ParseUnitDetails(player, class, level, race, zone, subZone, mapX, mapY, guild)

			if playerData and playerData.isEnemy and not SpyPerCharDB.IgnoreData[player] then
				local currentTime = time()
				Spy.WorldList[player] = currentTime
				Spy.LastHourList[player] = currentTime

				local pC, pZ, pX, pY = Astrolabe:GetCurrentPlayerPosition()
				local remoteC, remoteZ = Spy:GetZoneID(zone)

				if pC and remoteC and mapX and mapY then
					local distance = Astrolabe:ComputeDistance(pC, pZ, pX, pY, remoteC, remoteZ, mapX, mapY)
					if distance and distance <= Spy.db.profile.NearbyThresholdYards then
						Spy:AddDetected(player, currentTime, learnt, source)
					end
				end

				if Spy.db.profile.DisplayOnMap and not Spy.PlayerCommList[player] then
					Spy.PlayerCommList[player] = Spy.CurrentMapNote
					if Spy.IsCurrentlyZoning then
						Spy:ScheduleTimer("ShowMapNote", self.MapUpdateDelay.Zoning, player)
					else
						Spy:ScheduleTimer("ShowMapNote", self.MapUpdateDelay.NotZoning, player)
					end
				end

				if Spy.db.profile.CurrentList == 5 then
					Spy:RequestRefresh()
				end
			end
		end
	end
end
-- #endregion Plagueheart

function Spy:TrackHumanoids()
	local tooltip = GameTooltipTextLeft1:GetText()
	if tooltip and tooltip ~= Spy.LastTooltip then
		tooltip = Spy:ParseMinimapTooltip(tooltip)
		if Spy.db.profile.MinimapDetails then
			GameTooltipTextLeft1:SetText(tooltip)
			Spy.LastTooltip = tooltip
		end
		GameTooltip:Show()
	end
end

function Spy:FilterNotInParty(frame, event, message)
	if event == ERR_NOT_IN_GROUP or event == ERR_NOT_IN_RAID then
		return true
	end
	return false
end

function Spy:ShowMapNote(player)
	local playerData = SpyPerCharDB.PlayerData[player]
	if not playerData then
		return
	end

	local currentContinentIndex, currentZoneIndex = Spy:GetZoneID(GetZoneText())
	local continentIndex, zoneIndex = playerData.zone and Spy:GetZoneID(playerData.zone)
	local mapX, mapY = playerData.mapX, playerData.mapY

	if
		continentIndex
		and zoneIndex
		and type(mapX) == "number"
		and type(mapY) == "number"
		and (
			Spy.db.profile.MapDisplayLimit == "None"
			or (Spy.db.profile.MapDisplayLimit == "SameZone" and zoneIndex == currentZoneIndex)
			or (Spy.db.profile.MapDisplayLimit == "SameContinent" and continentIndex == currentContinentIndex)
		)
	then
		local note = Spy.MapNoteList[Spy.CurrentMapNote]
		note.displayed = true
		note.continentIndex = continentIndex
		note.zoneIndex = zoneIndex
		note.mapX = mapX
		note.mapY = mapY

		Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, note.worldIcon, continentIndex, zoneIndex, mapX, mapY)
		Astrolabe:PlaceIconOnMinimap(note.miniIcon, continentIndex, zoneIndex, mapX, mapY)

		for i = 1, Spy.MapNoteLimit do
			if i ~= Spy.CurrentMapNote and Spy.MapNoteList[i].displayed then
				if
					continentIndex == Spy.MapNoteList[i].continentIndex
					and zoneIndex == Spy.MapNoteList[i].zoneIndex
					and abs(mapX - Spy.MapNoteList[i].mapX) < Spy.MapProximityThreshold
					and abs(mapY - Spy.MapNoteList[i].mapY) < Spy.MapProximityThreshold
				then
					Spy.MapNoteList[i].displayed = false
					Spy.MapNoteList[i].worldIcon:Hide()
					Astrolabe:RemoveIconFromMinimap(Spy.MapNoteList[i].miniIcon)
					for p in pairs(Spy.PlayerCommList) do
						if Spy.PlayerCommList[p] == i then
							Spy.PlayerCommList[p] = Spy.CurrentMapNote
						end
					end
				end
			end
		end

		Spy.CurrentMapNote = Spy.CurrentMapNote + 1
		if Spy.CurrentMapNote > Spy.MapNoteLimit then
			Spy.CurrentMapNote = 1
		end
	end
end

function Spy:GetPlayerLocation(playerData)
	local location = playerData.zone or ""
	local mapX = playerData.mapX
	local mapY = playerData.mapY
	if location and playerData.subZone and playerData.subZone ~= "" and playerData.subZone ~= location then
		location = playerData.subZone .. ", " .. location
	end
	if mapX and mapX ~= 0 and mapY and mapY ~= 0 then
		location = location
			.. " ("
			.. math_floor(tonumber(mapX) * 100)
			.. ","
			.. math_floor(tonumber(mapY) * 100)
			.. ")"
	end
	return location
end

function Spy:RequestRefresh(...)
	if self.RefreshRequested then
		return
	end
	self.RefreshRequested = true
	self:ScheduleTimer(function(...)
		self.RefreshRequested = false
		self:RefreshCurrentList(...)
	end, self.RefreshDelay, ...)
end
