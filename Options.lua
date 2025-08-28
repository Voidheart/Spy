local L = LibStub("AceLocale-3.0"):GetLocale("Spy")

local SpyOptions = {}
Spy.Options = SpyOptions

local options = {
	name = L["Spy"],
	type = "group",
	args = {
		General = {
			name = L["GeneralSettings"],
			desc = L["GeneralSettings"],
			type = "group",
			order = 1,
			args = {
				intro1 = {
					name = L["SpyDescription1"],
					type = "description",
					order = 1,
				},
				Enabled = {
					name = L["EnableSpy"],
					desc = L["EnableSpyDescription"],
					type = "toggle",
					order = 2,
					width = "full",
					get = function(info)
						return Spy.db.profile.Enabled
					end,
					set = function(info, value)
						Spy:EnableSpy(value, true)
					end,
				},
				EnabledInBattlegrounds = {
					name = L["EnabledInBattlegrounds"],
					desc = L["EnabledInBattlegroundsDescription"],
					type = "toggle",
					order = 2,
					width = "full",
					get = function(info)
						return Spy.db.profile.EnabledInBattlegrounds
					end,
					set = function(info, value)
						Spy.db.profile.EnabledInBattlegrounds = value
						Spy:ZoneChangedEvent()
					end,
				},
				EnabledInArenas = {
					name = L["EnabledInArenas"],
					desc = L["EnabledInArenasDescription"],
					type = "toggle",
					order = 3,
					width = "full",
					get = function(info)
						return Spy.db.profile.EnabledInArenas
					end,
					set = function(info, value)
						Spy.db.profile.EnabledInArenas = value
						Spy:ZoneChangedEvent()
					end,
				},
				EnabledInWintergrasp = {
					name = L["EnabledInWintergrasp"],
					desc = L["EnabledInWintergraspDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info)
						return Spy.db.profile.EnabledInWintergrasp
					end,
					set = function(info, value)
						Spy.db.profile.EnabledInWintergrasp = value
						Spy:ZoneChangedEvent()
					end,
				},
				DisableWhenPVPUnflagged = {
					name = L["DisableWhenPVPUnflagged"],
					desc = L["DisableWhenPVPUnflaggedDescription"],
					type = "toggle",
					order = 5,
					width = "full",
					get = function(info)
						return Spy.db.profile.DisableWhenPVPUnflagged
					end,
					set = function(info, value)
						Spy.db.profile.DisableWhenPVPUnflagged = value
						Spy:ZoneChangedEvent()
					end,
				},
				intro2 = {
					name = L["SpyDescription2"],
					type = "description",
					order = 6,
				},
			},
		},
		DisplayOptions = {
			name = L["DisplayOptions"],
			desc = L["DisplayOptions"],
			type = "group",
			order = 2,
			args = {
				intro = {
					name = L["DisplayOptionsDescription"],
					type = "description",
					order = 1,
				},
				ShowOnDetection = {
					name = L["ShowOnDetection"],
					desc = L["ShowOnDetectionDescription"],
					type = "toggle",
					order = 2,
					width = "full",
					get = function(info)
						return Spy.db.profile.ShowOnDetection
					end,
					set = function(info, value)
						Spy.db.profile.ShowOnDetection = value
					end,
				},
				HideSpy = {
					name = L["HideSpy"],
					desc = L["HideSpyDescription"],
					type = "toggle",
					order = 3,
					width = "full",
					get = function(info)
						return Spy.db.profile.HideSpy
					end,
					set = function(info, value)
						Spy.db.profile.HideSpy = value
						if Spy.db.profile.HideSpy and Spy:GetNearbyListSize() == 0 then
							Spy.MainWindow:Hide()
						end
					end,
				},
				ResizeSpy = {
					name = L["ResizeSpy"],
					desc = L["ResizeSpyDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info)
						return Spy.db.profile.ResizeSpy
					end,
					set = function(info, value)
						Spy.db.profile.ResizeSpy = value
						if value then
							Spy:RequestRefresh()
						end
					end,
				},
				DisplayWinLossStatistics = {
					name = L["TooltipDisplayWinLoss"],
					desc = L["TooltipDisplayWinLossDescription"],
					type = "toggle",
					order = 5,
					width = "full",
					get = function(info)
						return Spy.db.profile.DisplayWinLossStatistics
					end,
					set = function(info, value)
						Spy.db.profile.DisplayWinLossStatistics = value
					end,
				},
				DisplayKOSReason = {
					name = L["TooltipDisplayKOSReason"],
					desc = L["TooltipDisplayKOSReasonDescription"],
					type = "toggle",
					order = 6,
					width = "full",
					get = function(info)
						return Spy.db.profile.DisplayKOSReason
					end,
					set = function(info, value)
						Spy.db.profile.DisplayKOSReason = value
					end,
				},
				DisplayLastSeen = {
					name = L["TooltipDisplayLastSeen"],
					desc = L["TooltipDisplayLastSeenDescription"],
					type = "toggle",
					order = 7,
					width = "full",
					get = function(info)
						return Spy.db.profile.DisplayLastSeen
					end,
					set = function(info, value)
						Spy.db.profile.DisplayLastSeen = value
					end,
				},
			},
		},
		AlertOptions = {
			name = L["AlertOptions"],
			desc = L["AlertOptions"],
			type = "group",
			order = 3,
			args = {
				intro = {
					name = L["AlertOptionsDescription"],
					type = "description",
					order = 1,
				},
				Announce = {
					name = L["Announce"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						None = {
							name = L["None"],
							desc = L["NoneDescription"],
							type = "toggle",
							order = 1,
							get = function(info)
								return Spy.db.profile.Announce == "None"
							end,
							set = function(info, value)
								Spy.db.profile.Announce = "None"
							end,
						},
						Self = {
							name = L["Self"],
							desc = L["SelfDescription"],
							type = "toggle",
							order = 2,
							get = function(info)
								return Spy.db.profile.Announce == "Self"
							end,
							set = function(info, value)
								Spy.db.profile.Announce = "Self"
							end,
						},
						Party = {
							name = L["Party"],
							desc = L["PartyDescription"],
							type = "toggle",
							order = 3,
							get = function(info)
								return Spy.db.profile.Announce == "Party"
							end,
							set = function(info, value)
								Spy.db.profile.Announce = "Party"
							end,
						},
						Guild = {
							name = L["Guild"],
							desc = L["GuildDescription"],
							type = "toggle",
							order = 4,
							get = function(info)
								return Spy.db.profile.Announce == "Guild"
							end,
							set = function(info, value)
								Spy.db.profile.Announce = "Guild"
							end,
						},
						Raid = {
							name = L["Raid"],
							desc = L["RaidDescription"],
							type = "toggle",
							order = 5,
							get = function(info)
								return Spy.db.profile.Announce == "Raid"
							end,
							set = function(info, value)
								Spy.db.profile.Announce = "Raid"
							end,
						},
						LocalDefense = {
							name = L["LocalDefense"],
							desc = L["LocalDefenseDescription"],
							type = "toggle",
							order = 6,
							get = function(info)
								return Spy.db.profile.Announce == "LocalDefense"
							end,
							set = function(info, value)
								Spy.db.profile.Announce = "LocalDefense"
							end,
						},
					},
				},
				OnlyAnnounceKoS = {
					name = L["OnlyAnnounceKoS"],
					desc = L["OnlyAnnounceKoSDescription"],
					type = "toggle",
					order = 3,
					width = "full",
					get = function(info)
						return Spy.db.profile.OnlyAnnounceKoS
					end,
					set = function(info, value)
						Spy.db.profile.OnlyAnnounceKoS = value
					end,
				},
				WarnOnStealth = {
					name = L["WarnOnStealth"],
					desc = L["WarnOnStealthDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info)
						return Spy.db.profile.WarnOnStealth
					end,
					set = function(info, value)
						Spy.db.profile.WarnOnStealth = value
					end,
				},
				WarnOnKOS = {
					name = L["WarnOnKOS"],
					desc = L["WarnOnKOSDescription"],
					type = "toggle",
					order = 5,
					width = "full",
					get = function(info)
						return Spy.db.profile.WarnOnKOS
					end,
					set = function(info, value)
						Spy.db.profile.WarnOnKOS = value
					end,
				},
				WarnOnKOSGuild = {
					name = L["WarnOnKOSGuild"],
					desc = L["WarnOnKOSGuildDescription"],
					type = "toggle",
					order = 6,
					width = "full",
					get = function(info)
						return Spy.db.profile.WarnOnKOSGuild
					end,
					set = function(info, value)
						Spy.db.profile.WarnOnKOSGuild = value
					end,
				},
				DisplayWarningsInErrorsFrame = {
					name = L["DisplayWarningsInErrorsFrame"],
					desc = L["DisplayWarningsInErrorsFrameDescription"],
					type = "toggle",
					order = 7,
					width = "full",
					get = function(info)
						return Spy.db.profile.DisplayWarningsInErrorsFrame
					end,
					set = function(info, value)
						Spy.db.profile.DisplayWarningsInErrorsFrame = value
					end,
				},
				EnableSound = {
					name = L["EnableSound"],
					desc = L["EnableSoundDescription"],
					type = "toggle",
					order = 8,
					width = "full",
					get = function(info)
						return Spy.db.profile.EnableSound
					end,
					set = function(info, value)
						Spy.db.profile.EnableSound = value
					end,
				},
			},
		},
		ListOptions = {
			name = L["ListOptions"],
			desc = L["ListOptions"],
			type = "group",
			order = 4,
			args = {
				intro = {
					name = L["ListOptionsDescription"],
					type = "description",
					order = 1,
				},
				RemoveUndetected = {
					name = L["RemoveUndetected"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						OneMinute = {
							name = L["1Min"],
							desc = L["1MinDescription"],
							type = "toggle",
							order = 1,
							get = function(info)
								return Spy.db.profile.RemoveUndetected == "OneMinute"
							end,
							set = function(info, value)
								Spy.db.profile.RemoveUndetected = "OneMinute"
								Spy:UpdateTimeoutSettings()
							end,
						},
						TwoMinutes = {
							name = L["2Min"],
							desc = L["2MinDescription"],
							type = "toggle",
							order = 2,
							get = function(info)
								return Spy.db.profile.RemoveUndetected == "TwoMinutes"
							end,
							set = function(info, value)
								Spy.db.profile.RemoveUndetected = "TwoMinutes"
								Spy:UpdateTimeoutSettings()
							end,
						},
						FiveMinutes = {
							name = L["5Min"],
							desc = L["5MinDescription"],
							type = "toggle",
							order = 3,
							get = function(info)
								return Spy.db.profile.RemoveUndetected == "FiveMinutes"
							end,
							set = function(info, value)
								Spy.db.profile.RemoveUndetected = "FiveMinutes"
								Spy:UpdateTimeoutSettings()
							end,
						},
						TenMinutes = {
							name = L["10Min"],
							desc = L["10MinDescription"],
							type = "toggle",
							order = 4,
							get = function(info)
								return Spy.db.profile.RemoveUndetected == "TenMinutes"
							end,
							set = function(info, value)
								Spy.db.profile.RemoveUndetected = "TenMinutes"
								Spy:UpdateTimeoutSettings()
							end,
						},
						FifteenMinutes = {
							name = L["15Min"],
							desc = L["15MinDescription"],
							type = "toggle",
							order = 5,
							get = function(info)
								return Spy.db.profile.RemoveUndetected == "FifteenMinutes"
							end,
							set = function(info, value)
								Spy.db.profile.RemoveUndetected = "FifteenMinutes"
								Spy:UpdateTimeoutSettings()
							end,
						},
						Never = {
							name = L["Never"],
							desc = L["NeverDescription"],
							type = "toggle",
							order = 6,
							get = function(info)
								return Spy.db.profile.RemoveUndetected == "Never"
							end,
							set = function(info, value)
								Spy.db.profile.RemoveUndetected = "Never"
								Spy:UpdateTimeoutSettings()
							end,
						},
					},
				},
				ShowNearbyList = {
					name = L["ShowNearbyList"],
					desc = L["ShowNearbyListDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info)
						return Spy.db.profile.ShowNearbyList
					end,
					set = function(info, value)
						Spy.db.profile.ShowNearbyList = value
					end,
				},
				PrioritiseKoS = {
					name = L["PrioritiseKoS"],
					desc = L["PrioritiseKoSDescription"],
					type = "toggle",
					order = 5,
					width = "full",
					get = function(info)
						return Spy.db.profile.PrioritiseKoS
					end,
					set = function(info, value)
						Spy.db.profile.PrioritiseKoS = value
					end,
				},
			},
		},
		MinimapOptions = {
			name = L["MinimapOptions"],
			desc = L["MinimapOptions"],
			type = "group",
			order = 5,
			args = {
				intro = {
					name = L["MinimapOptionsDescription"],
					type = "description",
					order = 1,
				},
				MinimapTracking = {
					name = L["MinimapTracking"],
					desc = L["MinimapTrackingDescription"],
					type = "toggle",
					order = 2,
					width = "full",
					get = function(info)
						return Spy.db.profile.MinimapTracking
					end,
					set = function(info, value)
						Spy.db.profile.MinimapTracking = value
					end,
				},
				MinimapDetails = {
					name = L["MinimapDetails"],
					desc = L["MinimapDetailsDescription"],
					type = "toggle",
					order = 3,
					width = "full",
					get = function(info)
						return Spy.db.profile.MinimapDetails
					end,
					set = function(info, value)
						Spy.db.profile.MinimapDetails = value
					end,
				},
				DisplayOnMap = {
					name = L["DisplayOnMap"],
					desc = L["DisplayOnMapDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info)
						return Spy.db.profile.DisplayOnMap
					end,
					set = function(info, value)
						Spy.db.profile.DisplayOnMap = value
					end,
				},
				MapDisplayLimit = {
					name = L["MapDisplayLimit"],
					type = "group",
					order = 5,
					inline = true,
					args = {
						None = {
							name = L["LimitNone"],
							desc = L["LimitNoneDescription"],
							type = "toggle",
							order = 1,
							width = "full",
							get = function(info)
								return Spy.db.profile.MapDisplayLimit == "None"
							end,
							set = function(info, value)
								Spy.db.profile.MapDisplayLimit = "None"
							end,
						},
						SameZone = {
							name = L["LimitSameZone"],
							desc = L["LimitSameZoneDescription"],
							type = "toggle",
							order = 2,
							width = "full",
							get = function(info)
								return Spy.db.profile.MapDisplayLimit == "SameZone"
							end,
							set = function(info, value)
								Spy.db.profile.MapDisplayLimit = "SameZone"
							end,
						},
						SameContinent = {
							name = L["LimitSameContinent"],
							desc = L["LimitSameContinentDescription"],
							type = "toggle",
							order = 3,
							width = "full",
							get = function(info)
								return Spy.db.profile.MapDisplayLimit == "SameContinent"
							end,
							set = function(info, value)
								Spy.db.profile.MapDisplayLimit = "SameContinent"
							end,
						},
					},
				},
			},
		},
		DataOptions = {
			name = L["DataOptions"],
			desc = L["DataOptions"],
			type = "group",
			order = 6,
			args = {
				intro = {
					name = L["DataOptionsDescription"],
					type = "description",
					order = 1,
				},
				PurgeData = {
					name = L["PurgeData"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						OneDay = {
							name = L["OneDay"],
							desc = L["OneDayDescription"],
							type = "toggle",
							order = 1,
							get = function(info)
								return Spy.db.profile.PurgeData == "OneDay"
							end,
							set = function(info, value)
								Spy.db.profile.PurgeData = "OneDay"
							end,
						},
						FiveDays = {
							name = L["FiveDays"],
							desc = L["FiveDaysDescription"],
							type = "toggle",
							order = 2,
							get = function(info)
								return Spy.db.profile.PurgeData == "FiveDays"
							end,
							set = function(info, value)
								Spy.db.profile.PurgeData = "FiveDays"
							end,
						},
						TenDays = {
							name = L["TenDays"],
							desc = L["TenDaysDescription"],
							type = "toggle",
							order = 3,
							get = function(info)
								return Spy.db.profile.PurgeData == "TenDays"
							end,
							set = function(info, value)
								Spy.db.profile.PurgeData = "TenDays"
							end,
						},
						ThirtyDays = {
							name = L["ThirtyDays"],
							desc = L["ThirtyDaysDescription"],
							type = "toggle",
							order = 4,
							get = function(info)
								return Spy.db.profile.PurgeData == "ThirtyDays"
							end,
							set = function(info, value)
								Spy.db.profile.PurgeData = "ThirtyDays"
							end,
						},
						SixtyDays = {
							name = L["SixtyDays"],
							desc = L["SixtyDaysDescription"],
							type = "toggle",
							order = 5,
							get = function(info)
								return Spy.db.profile.PurgeData == "SixtyDays"
							end,
							set = function(info, value)
								Spy.db.profile.PurgeData = "SixtyDays"
							end,
						},
						NinetyDays = {
							name = L["NinetyDays"],
							desc = L["NinetyDaysDescription"],
							type = "toggle",
							order = 6,
							get = function(info)
								return Spy.db.profile.PurgeData == "NinetyDays"
							end,
							set = function(info, value)
								Spy.db.profile.PurgeData = "NinetyDays"
							end,
						},
					},
				},
				ShareData = {
					name = L["ShareData"],
					desc = L["ShareDataDescription"],
					type = "toggle",
					order = 3,
					width = "full",
					get = function(info)
						return Spy.db.profile.ShareData
					end,
					set = function(info, value)
						Spy.db.profile.ShareData = value
					end,
				},
				UseData = {
					name = L["UseData"],
					desc = L["UseDataDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info)
						return Spy.db.profile.UseData
					end,
					set = function(info, value)
						Spy.db.profile.UseData = value
					end,
				},
				ShareKOSBetweenCharacters = {
					name = L["ShareKOSBetweenCharacters"],
					desc = L["ShareKOSBetweenCharactersDescription"],
					type = "toggle",
					order = 5,
					width = "full",
					get = function(info)
						return Spy.db.profile.ShareKOSBetweenCharacters
					end,
					set = function(info, value)
						Spy.db.profile.ShareKOSBetweenCharacters = value
						if value then
							Spy:RegenerateKOSCentralList()
						end
					end,
				},
			},
		},
	},
}

local optionsSlash = {
	name = L["SlashCommand"],
	order = -3,
	type = "group",
	args = {
		intro = {
			name = L["SpySlashDescription"],
			type = "description",
			order = 1,
			cmdHidden = true,
		},
		show = {
			name = L["Show"],
			desc = L["ShowDescription"],
			type = "execute",
			order = 2,
			func = function()
				Spy:EnableSpy(true, true)
			end,
			dialogHidden = true,
		},
		reset = {
			name = L["Reset"],
			desc = L["ResetDescription"],
			type = "execute",
			order = 3,
			func = function()
				Spy:ResetMainWindow()
			end,
			dialogHidden = true,
		},
		config = {
			name = L["Config"],
			desc = L["ConfigDescription"],
			type = "execute",
			order = 4,
			func = function()
				Spy:ShowConfig()
			end,
			dialogHidden = true,
		},
		kos = {
			name = L["KOS"],
			desc = L["KOSDescription"],
			type = "input",
			order = 5,
			pattern = "%a",
			set = function(info, value)
				Spy:ToggleKOSPlayer(not SpyPerCharDB.KOSData[value], value)
			end,
			dialogHidden = true,
		},
		ignore = {
			name = L["Ignore"],
			desc = L["IgnoreDescription"],
			type = "input",
			order = 6,
			pattern = "%a",
			set = function(info, value)
				Spy:ToggleIgnorePlayer(not SpyPerCharDB.IgnoreData[value], value)
			end,
			dialogHidden = true,
		},
		test = {
			name = "Test",
			desc = "Triggers a test alert for debugging. Usage: /spy test [kos|kosaway|kosguild|kosguildaway] [name] [source]",
			type = "input",
			order = 7,
			get = false,
			set = function(info, value)
				local command, name, source = strsplit(" ", value, 3)
				command = command and string.lower(command) or ""
				name = name or "TestPlayer"
				source = source or "TestSource"
				local guild = "<Test KOS Guild>"

				if command == "kos" then
					Spy:CreateMockPlayerData(name, true)
					Spy:AlertPlayer(name, nil) -- source is nil for local detection
					Spy:RemoveMockPlayerData(name)
				elseif command == "kosaway" then
					Spy:CreateMockPlayerData(name, true)
					Spy:AlertPlayer(name, source)
					Spy:RemoveMockPlayerData(name)
				elseif command == "kosguild" then
					Spy:CreateMockPlayerData(name, false, guild, true)
					Spy:AlertPlayer(name, nil)
					Spy:RemoveMockPlayerData(name)
				elseif command == "kosguildaway" then
					Spy:CreateMockPlayerData(name, false, guild, true)
					Spy:AlertPlayer(name, source)
					Spy:RemoveMockPlayerData(name)
				else
					Spy:Print("Usage: /spy test [kos|kosaway|kosguild|kosguildaway] [name] [source]")
				end
			end,
			dialogHidden = true,
		},
		enable = {
			name = "Enable",
			desc = "Enables the Spy addon.",
			type = "execute",
			order = 8,
			func = function()
				Spy:EnableSpy(false, false, false)
			end,
			dialogHidden = true,
		},
		disable = {
			name = "Disable",
			desc = "Disables the Spy addon.",
			type = "execute",
			order = 9,
			func = function()
				Spy:EnableSpy(false, false, false)
			end,
			dialogHidden = true,
		},
	},
}

local Default_Profile = {
	profile = {
		Colors = {
			["Window"] = {
				["Title"] = { r = 1, g = 1, b = 1, a = 1 },
				["Background"] = {
					r = 24 / 255,
					g = 24 / 255,
					b = 24 / 255,
					a = 1,
				},
				["Title Text"] = { r = 1, g = 1, b = 1, a = 1 },
			},
			["Other Windows"] = {
				["Title"] = { r = 1, g = 0, b = 0, a = 1 },
				["Background"] = {
					r = 24 / 255,
					g = 24 / 255,
					b = 24 / 255,
					a = 1,
				},
				["Title Text"] = { r = 1, g = 1, b = 1, a = 1 },
			},
			["Bar"] = { ["Bar Text"] = { r = 1, g = 1, b = 1 } },
			["Warning"] = { ["Warning Text"] = { r = 1, g = 1, b = 1 } },
			["Tooltip"] = {
				["Title Text"] = { r = 0.8, g = 0.3, b = 0.22 },
				["Details Text"] = { r = 1, g = 1, b = 1 },
				["Location Text"] = { r = 1, g = 0.82, b = 0 },
				["Reason Text"] = { r = 1, g = 0, b = 0 },
			},
			["Alert"] = {
				["Background"] = { r = 0, g = 0, b = 0, a = 0.4 },
				["Icon"] = { r = 1, g = 1, b = 1, a = 0.5 },
				["KOS Border"] = { r = 1, g = 0, b = 0, a = 0.4 },
				["KOS Text"] = { r = 1, g = 0, b = 0 },
				["KOS Guild Border"] = { r = 1, g = 0.82, b = 0, a = 0.4 },
				["KOS Guild Text"] = { r = 1, g = 0.82, b = 0 },
				["Stealth Border"] = { r = 0.6, g = 0.2, b = 1, a = 0.4 },
				["Stealth Text"] = { r = 0.6, g = 0.2, b = 1 },
				["Away Border"] = { r = 0, g = 1, b = 0, a = 0.4 },
				["Away Text"] = { r = 0, g = 1, b = 0 },
				["Location Text"] = { r = 1, g = 0.82, b = 0 },
				["Name Text"] = { r = 1, g = 1, b = 1 },
			},
			["Class"] = {
				["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, a = 0.6 },
				["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, a = 0.6 },
				["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, a = 0.6 },
				["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, a = 0.6 },
				["MAGE"] = { r = 0.41, g = 0.8, b = 0.94, a = 0.6 },
				["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, a = 0.6 },
				["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, a = 0.6 },
				["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.0, a = 0.6 },
				["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, a = 0.6 },
				["DEATHKNIGHT"] = { r = 0.77, g = 0.12, b = 0.23, a = 0.6 },
				["PET"] = { r = 0.09, g = 0.61, b = 0.55, a = 0.6 },
				["MOB"] = { r = 0.58, g = 0.24, b = 0.63, a = 0.6 },
				["UNKNOWN"] = { r = 0.1, g = 0.1, b = 0.1, a = 0.6 },
				["HOSTILE"] = { r = 0.7, g = 0.1, b = 0.1, a = 0.6 },
				["UNGROUPED"] = { r = 0.63, g = 0.58, b = 0.24, a = 0.6 },
			},
		},
		MainWindow = {
			Buttons = {
				ClearButton = true,
				LeftButton = true,
				RightButton = true,
			},
			RowHeight = 20,
			RowSpacing = 2,
			TextHeight = 12,
			AutoHide = false,
			BarText = {
				RankNum = true,
				PerSec = true,
				Percent = true,
				NumFormat = 1,
			},
			Position = { x = 10, y = 760, w = 130, h = 44 },
		},
		AlertWindowNameSize = 14,
		AlertWindowLocationSize = 10,
		BarTexture = "blend",
		MainWindowVis = true,
		CurrentList = 1,
		Locked = false,
		Font = "Friz Quadrata TT",
		Scaling = 1,
		Enabled = true,
		EnabledInBattlegrounds = true,
		EnabledInArenas = true,
		EnabledInWintergrasp = true,
		DisableWhenPVPUnflagged = false,
		MinimapTracking = true,
		MinimapDetails = true,
		DisplayOnMap = true,
		MapDisplayLimit = "None",
		DisplayWinLossStatistics = true,
		DisplayKOSReason = true,
		DisplayLastSeen = true,
		ShowOnDetection = true,
		HideSpy = false,
		ResizeSpy = true,
		Announce = "Self",
		OnlyAnnounceKoS = false,
		WarnOnStealth = true,
		WarnOnKOS = true,
		WarnOnKOSGuild = true,
		DisplayWarningsInErrorsFrame = false,
		EnableSound = true,
		RemoveUndetected = "OneMinute",
		ShowNearbyList = true,
		PrioritiseKoS = true,
		PurgeData = "NinetyDays",
		ShareData = true,
		UseData = true,
		ShareKOSBetweenCharacters = true,
	},
}

function SpyOptions:GetDefaultDB()
	return Default_Profile
end

function SpyOptions:GetDefaultProfile()
	return Default_Profile.profile
end

function SpyOptions:GetOptions()
	return options
end

function SpyOptions:GetSlashOptions()
	return optionsSlash
end
