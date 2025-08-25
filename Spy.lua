----------------------------------------------------------------
-- Spy.lua - Fixed and Optimized
-- Optimizations By: Plagueheart
-- Server: Project Epoch
----------------------------------------------------------------
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local Astrolabe = DongleStub("Astrolabe-0.4")
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:GetLocale("Spy")

--region Plagueheart
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
--endregion Plagueheart

Spy = LibStub("AceAddon-3.0"):NewAddon("Spy", "AceConsole-3.0", "AceEvent-3.0",
                                       "AceComm-3.0", "AceTimer-3.0")
Spy.Version = "1.2"
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
Spy.ActiveList = {}
Spy.InactiveList = {}
Spy.PlayerCommList = {}
Spy.ListAmountDisplayed = 0
Spy.ButtonName = {}
Spy.EnabledInZone = false
Spy.InInstance = false
Spy.AlertType = nil
Spy.UpgradeMessageSent = false

--region Plagueheart
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
--endregion Plagueheart

Spy.options = {
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
                    order = 1
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
                    end
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
                    end
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
                    end
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
                    end
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
                    end
                },
                intro2 = {
                    name = L["SpyDescription2"],
                    type = "description",
                    order = 6
                }
            }
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
                    order = 1
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
                    end
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
                        if Spy.db.profile.HideSpy and Spy:GetNearbyListSize() ==
                            0 then Spy.MainWindow:Hide() end
                    end
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
                    end
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
                    end
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
                    end
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
                    end
                }
            }
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
                    order = 1
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
                            end
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
                            end
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
                            end
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
                            end
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
                            end
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
                            end
                        }
                    }
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
                    end
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
                    end
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
                    end
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
                    end
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
                    end
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
                    end
                }
            }
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
                    order = 1
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
                                return Spy.db.profile.RemoveUndetected ==
                                           "OneMinute"
                            end,
                            set = function(info, value)
                                Spy.db.profile.RemoveUndetected = "OneMinute"
                                Spy:UpdateTimeoutSettings()
                            end
                        },
                        TwoMinutes = {
                            name = L["2Min"],
                            desc = L["2MinDescription"],
                            type = "toggle",
                            order = 2,
                            get = function(info)
                                return Spy.db.profile.RemoveUndetected ==
                                           "TwoMinutes"
                            end,
                            set = function(info, value)
                                Spy.db.profile.RemoveUndetected = "TwoMinutes"
                                Spy:UpdateTimeoutSettings()
                            end
                        },
                        FiveMinutes = {
                            name = L["5Min"],
                            desc = L["5MinDescription"],
                            type = "toggle",
                            order = 3,
                            get = function(info)
                                return Spy.db.profile.RemoveUndetected ==
                                           "FiveMinutes"
                            end,
                            set = function(info, value)
                                Spy.db.profile.RemoveUndetected = "FiveMinutes"
                                Spy:UpdateTimeoutSettings()
                            end
                        },
                        TenMinutes = {
                            name = L["10Min"],
                            desc = L["10MinDescription"],
                            type = "toggle",
                            order = 4,
                            get = function(info)
                                return Spy.db.profile.RemoveUndetected ==
                                           "TenMinutes"
                            end,
                            set = function(info, value)
                                Spy.db.profile.RemoveUndetected = "TenMinutes"
                                Spy:UpdateTimeoutSettings()
                            end
                        },
                        FifteenMinutes = {
                            name = L["15Min"],
                            desc = L["15MinDescription"],
                            type = "toggle",
                            order = 5,
                            get = function(info)
                                return Spy.db.profile.RemoveUndetected ==
                                           "FifteenMinutes"
                            end,
                            set = function(info, value)
                                Spy.db.profile.RemoveUndetected =
                                    "FifteenMinutes"
                                Spy:UpdateTimeoutSettings()
                            end
                        },
                        Never = {
                            name = L["Never"],
                            desc = L["NeverDescription"],
                            type = "toggle",
                            order = 6,
                            get = function(info)
                                return Spy.db.profile.RemoveUndetected ==
                                           "Never"
                            end,
                            set = function(info, value)
                                Spy.db.profile.RemoveUndetected = "Never"
                                Spy:UpdateTimeoutSettings()
                            end
                        }
                    }
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
                    end
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
                    end
                }
            }
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
                    order = 1
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
                    end
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
                    end
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
                    end
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
                            end
                        },
                        SameZone = {
                            name = L["LimitSameZone"],
                            desc = L["LimitSameZoneDescription"],
                            type = "toggle",
                            order = 2,
                            width = "full",
                            get = function(info)
                                return Spy.db.profile.MapDisplayLimit ==
                                           "SameZone"
                            end,
                            set = function(info, value)
                                Spy.db.profile.MapDisplayLimit = "SameZone"
                            end
                        },
                        SameContinent = {
                            name = L["LimitSameContinent"],
                            desc = L["LimitSameContinentDescription"],
                            type = "toggle",
                            order = 3,
                            width = "full",
                            get = function(info)
                                return Spy.db.profile.MapDisplayLimit ==
                                           "SameContinent"
                            end,
                            set = function(info, value)
                                Spy.db.profile.MapDisplayLimit = "SameContinent"
                            end
                        }
                    }
                }
            }
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
                    order = 1
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
                            end
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
                            end
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
                            end
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
                            end
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
                            end
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
                            end
                        }
                    }
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
                    end
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
                    end
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
                    end
                }
            }
        }
    }
}

Spy.optionsSlash = {
    name = L["SlashCommand"],
    order = -3,
    type = "group",
    args = {
        intro = {
            name = L["SpySlashDescription"],
            type = "description",
            order = 1,
            cmdHidden = true
        },
        show = {
            name = L["Show"],
            desc = L["ShowDescription"],
            type = 'execute',
            order = 2,
            func = function() Spy:EnableSpy(true, true) end,
            dialogHidden = true
        },
        reset = {
            name = L["Reset"],
            desc = L["ResetDescription"],
            type = 'execute',
            order = 3,
            func = function() Spy:ResetMainWindow() end,
            dialogHidden = true
        },
        config = {
            name = L["Config"],
            desc = L["ConfigDescription"],
            type = 'execute',
            order = 4,
            func = function() Spy:ShowConfig() end,
            dialogHidden = true
        },
        kos = {
            name = L["KOS"],
            desc = L["KOSDescription"],
            type = 'input',
            order = 5,
            pattern = "%a",
            set = function(info, value)
                Spy:ToggleKOSPlayer(not SpyPerCharDB.KOSData[value], value)
            end,
            dialogHidden = true
        },
        ignore = {
            name = L["Ignore"],
            desc = L["IgnoreDescription"],
            type = 'input',
            order = 6,
            pattern = "%a",
            set = function(info, value)
                Spy:ToggleIgnorePlayer(not SpyPerCharDB.IgnoreData[value], value)
            end,
            dialogHidden = true
        }
    }
}

local Default_Profile = {
    profile = {
        Colors = {
            ["Window"] = {
                ["Title"] = {r = 1, g = 1, b = 1, a = 1},
                ["Background"] = {
                    r = 24 / 255,
                    g = 24 / 255,
                    b = 24 / 255,
                    a = 1
                },
                ["Title Text"] = {r = 1, g = 1, b = 1, a = 1}
            },
            ["Other Windows"] = {
                ["Title"] = {r = 1, g = 0, b = 0, a = 1},
                ["Background"] = {
                    r = 24 / 255,
                    g = 24 / 255,
                    b = 24 / 255,
                    a = 1
                },
                ["Title Text"] = {r = 1, g = 1, b = 1, a = 1}
            },
            ["Bar"] = {["Bar Text"] = {r = 1, g = 1, b = 1}},
            ["Warning"] = {["Warning Text"] = {r = 1, g = 1, b = 1}},
            ["Tooltip"] = {
                ["Title Text"] = {r = 0.8, g = 0.3, b = 0.22},
                ["Details Text"] = {r = 1, g = 1, b = 1},
                ["Location Text"] = {r = 1, g = 0.82, b = 0},
                ["Reason Text"] = {r = 1, g = 0, b = 0}
            },
            ["Alert"] = {
                ["Background"] = {r = 0, g = 0, b = 0, a = 0.4},
                ["Icon"] = {r = 1, g = 1, b = 1, a = 0.5},
                ["KOS Border"] = {r = 1, g = 0, b = 0, a = 0.4},
                ["KOS Text"] = {r = 1, g = 0, b = 0},
                ["KOS Guild Border"] = {r = 1, g = 0.82, b = 0, a = 0.4},
                ["KOS Guild Text"] = {r = 1, g = 0.82, b = 0},
                ["Stealth Border"] = {r = 0.6, g = 0.2, b = 1, a = 0.4},
                ["Stealth Text"] = {r = 0.6, g = 0.2, b = 1},
                ["Away Border"] = {r = 0, g = 1, b = 0, a = 0.4},
                ["Away Text"] = {r = 0, g = 1, b = 0},
                ["Location Text"] = {r = 1, g = 0.82, b = 0},
                ["Name Text"] = {r = 1, g = 1, b = 1}
            },
            ["Class"] = {
                ["HUNTER"] = {r = 0.67, g = 0.83, b = 0.45, a = 0.6},
                ["WARLOCK"] = {r = 0.58, g = 0.51, b = 0.79, a = 0.6},
                ["PRIEST"] = {r = 1.0, g = 1.0, b = 1.0, a = 0.6},
                ["PALADIN"] = {r = 0.96, g = 0.55, b = 0.73, a = 0.6},
                ["MAGE"] = {r = 0.41, g = 0.8, b = 0.94, a = 0.6},
                ["ROGUE"] = {r = 1.0, g = 0.96, b = 0.41, a = 0.6},
                ["DRUID"] = {r = 1.0, g = 0.49, b = 0.04, a = 0.6},
                ["SHAMAN"] = {r = 0.14, g = 0.35, b = 1.0, a = 0.6},
                ["WARRIOR"] = {r = 0.78, g = 0.61, b = 0.43, a = 0.6},
                ["DEATHKNIGHT"] = {r = 0.77, g = 0.12, b = 0.23, a = 0.6},
                ["PET"] = {r = 0.09, g = 0.61, b = 0.55, a = 0.6},
                ["MOB"] = {r = 0.58, g = 0.24, b = 0.63, a = 0.6},
                ["UNKNOWN"] = {r = 0.1, g = 0.1, b = 0.1, a = 0.6},
                ["HOSTILE"] = {r = 0.7, g = 0.1, b = 0.1, a = 0.6},
                ["UNGROUPED"] = {r = 0.63, g = 0.58, b = 0.24, a = 0.6}
            }
        },
        MainWindow = {
            Buttons = {
                ClearButton = true,
                LeftButton = true,
                RightButton = true
            },
            RowHeight = 20,
            RowSpacing = 2,
            TextHeight = 12,
            AutoHide = false,
            BarText = {
                RankNum = true,
                PerSec = true,
                Percent = true,
                NumFormat = 1
            },
            Position = {x = 10, y = 760, w = 130, h = 44}
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
        ShareKOSBetweenCharacters = true
    }
}

SM:Register("statusbar", "blend",
            [[Interface\Addons\Spy\Textures\bar-blend.tga]])

--#region Plagueheart
function Spy:MergeDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then return end

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
	if not SpyPerCharDB.PlayerData then SpyPerCharDB.PlayerData = {} end
	if not SpyPerCharDB.IgnoreData then SpyPerCharDB.IgnoreData = {} end
	if not SpyPerCharDB.KOSData then SpyPerCharDB.KOSData = {} end

	if SpyDB.kosData == nil then SpyDB.kosData = {} end
	if SpyDB.kosData[Spy.RealmName] == nil then SpyDB.kosData[Spy.RealmName] = {} end
	if SpyDB.kosData[Spy.RealmName][Spy.FactionName] == nil then SpyDB.kosData[Spy.RealmName][Spy.FactionName] = {} end
	if SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName] == nil then SpyDB.kosData[Spy.RealmName][Spy.FactionName][Spy.CharacterName] = {} end

	if SpyDB.removeKOSData == nil then SpyDB.removeKOSData = {} end
	if SpyDB.removeKOSData[Spy.RealmName] == nil then SpyDB.removeKOSData[Spy.RealmName] = {} end
	if SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName] == nil then SpyDB.removeKOSData[Spy.RealmName][Spy.FactionName] = {} end

	if Spy.db.profile == nil then
		Spy.db.profile = {}
	end

    self:MergeDefaults(Spy.db.profile, Default_Profile.profile)
end
--#endregion Plagueheart

function Spy:ResetProfile() Spy.db.profile = Default_Profile.profile end

function Spy:HandleProfileChanges()
    Spy:CreateMainWindow()
    Spy:UpdateTimeoutSettings()
end

function Spy:RegisterModuleOptions(name, optionTbl, displayName)
    Spy.options.args[name] = (type(optionTbl) == "function") and optionTbl() or
                                 optionTbl
    self.optionsFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
                                   "Spy", displayName, "Spy", name)
end

function Spy:SetupOptions()
    self.optionsFrames = {}

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Spy", Spy.options)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Spy Commands",
                                                  Spy.optionsSlash, "spy")

    local ACD3 = LibStub("AceConfigDialog-3.0")
    self.optionsFrames.Spy = ACD3:AddToBlizOptions("Spy", nil, nil, "General")
    self.optionsFrames.DisplayOptions = ACD3:AddToBlizOptions("Spy",
                                                              L["DisplayOptions"],
                                                              "Spy",
                                                              "DisplayOptions")
    self.optionsFrames.AlertOptions = ACD3:AddToBlizOptions("Spy",
                                                            L["AlertOptions"],
                                                            "Spy",
                                                            "AlertOptions")
    self.optionsFrames.ListOptions = ACD3:AddToBlizOptions("Spy",
                                                           L["ListOptions"],
                                                           "Spy", "ListOptions")
    self.optionsFrames.DataOptions = ACD3:AddToBlizOptions("Spy",
                                                           L["MinimapOptions"],
                                                           "Spy",
                                                           "MinimapOptions")
    self.optionsFrames.DataOptions = ACD3:AddToBlizOptions("Spy",
                                                           L["DataOptions"],
                                                           "Spy", "DataOptions")

    self:RegisterModuleOptions("Profiles",
                               LibStub("AceDBOptions-3.0"):GetOptionsTable(
                                   self.db), L["Profiles"])
    Spy.options.args.Profiles.order = -2
end

function Spy:UpdateTimeoutSettings()
    if not Spy.db.profile.RemoveUndetected or Spy.db.profile.RemoveUndetected ==
        "OneMinute" then
        Spy.ActiveTimeout = 30
        Spy.InactiveTimeout = 60
    elseif Spy.db.profile.RemoveUndetected == "TwoMinutes" then
        Spy.ActiveTimeout = 60
        Spy.InactiveTimeout = 120
    elseif Spy.db.profile.RemoveUndetected == "FiveMinutes" then
        Spy.ActiveTimeout = 150
        Spy.InactiveTimeout = 300
    elseif Spy.db.profile.RemoveUndetected == "TenMinutes" then
        Spy.ActiveTimeout = 300
        Spy.InactiveTimeout = 600
    elseif Spy.db.profile.RemoveUndetected == "FifteenMinutes" then
        Spy.ActiveTimeout = 450
        Spy.InactiveTimeout = 900
    elseif Spy.db.profile.RemoveUndetected == "Never" then
        Spy.ActiveTimeout = 30
        Spy.InactiveTimeout = -1
    else
        Spy.ActiveTimeout = 150
        Spy.InactiveTimeout = 300
    end
end

function Spy:ResetMainWindow()
    Spy:EnableSpy(true, true)
    Spy:CreateMainWindow()
    Spy:RestoreMainWindowPosition(Default_Profile.profile.MainWindow.Position.x,
                                  Default_Profile.profile.MainWindow.Position.y,
                                  Default_Profile.profile.MainWindow.Position.w,
                                  44)
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
    if not Spy.IsEnabled then return end
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
        if changeDisplay then Spy.MainWindow:Show() end
        Spy:OnEnable()
        if not hideEnabledMessage then
            DEFAULT_CHAT_FRAME:AddMessage(L["SpyEnabled"])
        end
    else
        if changeDisplay then Spy.MainWindow:Hide() end
        Spy:OnDisable()
        DEFAULT_CHAT_FRAME:AddMessage(L["SpyDisabled"])
    end
end

function Spy:BuildZoneIDTable_z(continentIndex, zoneIndex, zoneName, next, ...)
    zoneIndex = zoneIndex + 1
    Spy.ZoneID[zoneName] = {}
    Spy.ZoneID[zoneName].continentIndex = continentIndex
    Spy.ZoneID[zoneName].zoneIndex = zoneIndex
    if next then Spy:BuildZoneIDTable_z(continentIndex, zoneIndex, next, ...) end
end

function Spy:BuildZoneIDTable(zoneIndex, continentName, next, ...)
    zoneIndex = zoneIndex + 1
    Spy:BuildZoneIDTable_z(zoneIndex, 0, GetMapZones(zoneIndex))
    if next then Spy:BuildZoneIDTable(zoneIndex, next, ...) end
end

function Spy:GetZoneID(zoneName)
    if not Spy.ZoneID[zoneName] then return nil end
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

    Spy.db = acedb:New("SpyDB", Default_Profile)
    Spy:CheckDatabase()

    self.db.RegisterCallback(self, "OnNewProfile", "ResetProfile")
    self.db.RegisterCallback(self, "OnProfileReset", "ResetProfile")
    self.db.RegisterCallback(self, "OnProfileChanged", "HandleProfileChanges")
    self.db.RegisterCallback(self, "OnProfileCopied", "HandleProfileChanges")
    self:SetupOptions()

    Spy:BuildZoneIDTable(0, GetMapContinents())

    SpyTempTooltip = CreateFrame("GameTooltip", "SpyTempTooltip", nil,
                                 "GameTooltipTemplate")
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

    SM.RegisterCallback(Spy, "LibSharedMedia_Registered", "UpdateBarTextures")
    SM.RegisterCallback(Spy, "LibSharedMedia_SetGlobal", "UpdateBarTextures")
    if Spy.db.profile.BarTexture then
        Spy:SetBarTextures(Spy.db.profile.BarTexture)
    end

    Spy:LockWindows(Spy.db.profile.Locked)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Spy.FilterNotInParty)
    DEFAULT_CHAT_FRAME:AddMessage(L["LoadDescription"])
end

--#region Plagueheart
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
            if instanceType == "party" or instanceType == "raid" or
                (not Spy.db.profile.EnabledInBattlegrounds and instanceType ==
                    "pvp") or
                (not Spy.db.profile.EnabledInArenas and instanceType == "arena") then
                Spy.EnabledInZone = false
            end
        elseif pvpType == "combat" then
            if not Spy.db.profile.EnabledInWintergrasp then
                Spy.EnabledInZone = false
            end
        elseif (pvpType == "friendly" or pvpType == nil) then
            if UnitIsPVP("player") == nil and
                Spy.db.profile.DisableWhenPVPUnflagged then
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
        if playerData and playerData.isGuess == false then learnt = false end

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
        if Spy.EnabledInZone then Spy:AddDetected(name, time(), learnt) end
    elseif playerData then
        Spy:RemovePlayerData(name)
    end
end

function Spy:PlayerTargetEvent() self:ProcessUnitDetails("target") end

function Spy:PlayerMouseoverEvent() self:ProcessUnitDetails("mouseover") end
--#endregion Plagueheart

function Spy:CombatLogEvent(_, timestamp, event, srcGUID, srcName, srcFlags,
                            dstGUID, dstName, dstFlags, ...)
    if not Spy.EnabledInZone then return end

    local HOSTILE_FLAG = COMBATLOG_OBJECT_REACTION_HOSTILE

    if bit_band(srcFlags, HOSTILE_FLAG) == HOSTILE_FLAG and srcGUID and srcName and
        not SpyPerCharDB.IgnoreData[srcName] then
        local srcType = bit_band(tonumber("0x" .. strsub(srcGUID, 3, 5)), 0x00F)
        if srcType == 0 or srcType == 8 then -- Player or Pet
            local learnt = false
            local detected = true
            local playerData = SpyPerCharDB.PlayerData[srcName]
            if not playerData or playerData.isGuess then
                learnt, playerData = Spy:ParseUnitAbility(true, event, srcName,
                                                          srcFlags, arg9, arg10)
            end
            if not learnt then
                detected = Spy:UpdatePlayerData(srcName, nil, nil, nil, nil,
                                                true, nil)
            end

            if detected then
                Spy:AddDetected(srcName, timestamp, learnt)
                if event == "SPELL_AURA_APPLIED" and
                    (arg10 == L["Stealth"] or arg10 == L["Prowl"]) then
                    Spy:AlertStealthPlayer(srcName)
                end
            end

            if dstGUID == UnitGUID("player") then
                Spy.LastAttack = srcName
            end
        end
    end

    if bit_band(dstFlags, HOSTILE_FLAG) == HOSTILE_FLAG and dstGUID and dstName and
        not SpyPerCharDB.IgnoreData[dstName] then
        local dstType = bit_band(tonumber("0x" .. strsub(dstGUID, 3, 5)), 0x00F)
        if dstType == 0 or dstType == 8 then -- Player or Pet
            local learnt = false
            local detected = true
            local playerData = SpyPerCharDB.PlayerData[dstName]
            if not playerData or playerData.isGuess then
                learnt, playerData = Spy:ParseUnitAbility(false, event, dstName,
                                                          dstFlags, arg9, arg10)
            end
            if not learnt then
                detected = Spy:UpdatePlayerData(dstName, nil, nil, nil, nil,
                                                true, nil)
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
                if not playerData.wins then playerData.wins = 0 end
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
            if not playerData.loses then playerData.loses = 0 end
            playerData.loses = playerData.loses + 1
        end
    end
end

function Spy:WorldMapUpdateEvent()
    for i = 1, Spy.MapNoteLimit do
        local note = Spy.MapNoteList[i]
        if note.displayed then
            Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, note.worldIcon,
                                          note.continentIndex, note.zoneIndex,
                                          note.mapX, note.mapY)
            Astrolabe:PlaceIconOnMinimap(note.miniIcon, note.continentIndex,
                                         note.zoneIndex, note.mapX, note.mapY)
        end
    end
end


--#region Plagueheart
--- IMPLEMENTATION: Deferred map updates and improved data validations.
function Spy:CommReceived(prefix, message, distribution, source)
    if not (Spy.EnabledInZone and Spy.db.profile.UseData) then return end
    if prefix ~= Spy.Signature or not message or source == Spy.CharacterName then
        return
    end

    local version, player, class, level, race, zone, subZone, mapX, mapY, guild =
        strsplit("|", message)
    if player and (not Spy.InInstance or zone == GetZoneText()) then
        if not Spy.PlayerCommList[player] then
            if tonumber(version) > tonumber(Spy.Version) and
                not Spy.UpgradeMessageSent then
                DEFAULT_CHAT_FRAME:AddMessage(L["UpgradeAvailable"])
                Spy.UpgradeMessageSent = true
            end

            if strlen(class) > 0 then
                if not Spy.ValidClasses[class] then return end
            else
                class = nil
            end

            if strlen(level) > 0 then
                level = tonumber(level)
                if not (type(level) == "number" and level >= 1 and level <=
                    Spy.MaximumPlayerLevel and math_floor(level) == level) then
                    return
                end
            else
                level = nil
            end

            if strlen(race) > 0 then
                if not Spy.ValidRaces[race] then return end
            else
                race = nil
            end

            if strlen(zone) > 0 then
                if not Spy:GetZoneID(zone) then return end
            else
                zone = nil
            end

            if strlen(subZone) == 0 then subZone = nil end

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

            if strlen(guild) > 24 then return end
            if strlen(guild) == 0 then guild = nil end

            local learnt, playerData = Spy:ParseUnitDetails(player, class,
                                                            level, race, zone,
                                                            subZone, mapX, mapY,
                                                            guild)
            if playerData and playerData.isEnemy and
                not SpyPerCharDB.IgnoreData[player] then
                Spy.PlayerCommList[player] = Spy.CurrentMapNote
                Spy:AddDetected(player, time(), learnt, source)

                if Spy.db.profile.DisplayOnMap then
                    if Spy.IsCurrentlyZoning then
                        Spy:ScheduleTimer("ShowMapNote", self.MapUpdateDelay.Zoning, player)
                    else
                        Spy:ScheduleTimer("ShowMapNote", self.MapUpdateDelay.NotZoning, player)
                    end
                end
            end
        end
    end
end
--#endregion Plagueheart

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
    if (event == ERR_NOT_IN_GROUP or event == ERR_NOT_IN_RAID) then
        return true
    end
    return false
end

function Spy:ShowMapNote(player)
    local playerData = SpyPerCharDB.PlayerData[player]
    if not playerData then return end

    local currentContinentIndex, currentZoneIndex = Spy:GetZoneID(GetZoneText())
    local continentIndex, zoneIndex = playerData.zone and
                                          Spy:GetZoneID(playerData.zone)
    local mapX, mapY = playerData.mapX, playerData.mapY

    if continentIndex and zoneIndex and type(mapX) == "number" and type(mapY) ==
        "number" and (Spy.db.profile.MapDisplayLimit == "None" or
        (Spy.db.profile.MapDisplayLimit == "SameZone" and zoneIndex ==
            currentZoneIndex) or
        (Spy.db.profile.MapDisplayLimit == "SameContinent" and continentIndex ==
            currentContinentIndex)) then

        local note = Spy.MapNoteList[Spy.CurrentMapNote]
        note.displayed = true
        note.continentIndex = continentIndex
        note.zoneIndex = zoneIndex
        note.mapX = mapX
        note.mapY = mapY

        Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, note.worldIcon,
                                      continentIndex, zoneIndex, mapX, mapY)
        Astrolabe:PlaceIconOnMinimap(note.miniIcon, continentIndex, zoneIndex,
                                     mapX, mapY)

        for i = 1, Spy.MapNoteLimit do
            if i ~= Spy.CurrentMapNote and Spy.MapNoteList[i].displayed then
                if continentIndex == Spy.MapNoteList[i].continentIndex and
                    zoneIndex == Spy.MapNoteList[i].zoneIndex and
                    abs(mapX - Spy.MapNoteList[i].mapX) <
                    Spy.MapProximityThreshold and
                    abs(mapY - Spy.MapNoteList[i].mapY) <
                    Spy.MapProximityThreshold then
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
    if location and playerData.subZone and playerData.subZone ~= "" and
        playerData.subZone ~= location then
        location = playerData.subZone .. ", " .. location
    end
    if mapX and mapX ~= 0 and mapY and mapY ~= 0 then
        location =
            location .. " (" .. math_floor(tonumber(mapX) * 100) .. "," ..
                math_floor(tonumber(mapY) * 100) .. ")"
    end
    return location
end

function Spy:RequestRefresh(...)
    if self.RefreshRequested then return end
    self.RefreshRequested = true
    self:ScheduleTimer(function(...)
        self.RefreshRequested = false
        self:RefreshCurrentList(...)
    end, self.RefreshDelay, ...)
end
