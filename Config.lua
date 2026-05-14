local GQol = _G.GQol
local Config = GQol.Config

-- ============================================================
-- Constants
-- ============================================================
local Constants = GQol.Constants
Constants.MAX_ACTION_SLOTS = 120
Constants.EDIT_MODE_MIN_CUSTOM_UID = 3
Constants.EDIT_MODE_TARGET_UID = 3
Constants.EDIT_MODE_LAYOUT_TYPE_CUSTOM = 1
Constants.EDIT_MODE_APPLY_DELAY_1 = 0.7
Constants.EDIT_MODE_APPLY_DELAY_2 = 0.2
Constants.ACC_MACRO_RANGE = {1, 120}
Constants.CHAR_MACRO_RANGE = {121, 150}
Constants.QUESTION_ICON = 134400
Constants.LOGIN_DELAY = 0.5
Constants.SPEC_CHANGE_DELAY = 0.5
Constants.MOOSE_LIGHT_UPDATE_DELAY = 0.8
Constants.MOOSE_LIGHT_DEBOUNCE_DELAY = 0.5
Constants.PI = math.pi
Constants.CLASS_RANGE = {
	WARRIOR = 8,
	PALADIN = 5,
	HUNTER = 40,
	ROGUE = 5,
	PRIEST = 40,
	DEATHKNIGHT = 5,
	SHAMAN = 40,
	MAGE = 40,
	WARLOCK = 40,
	MONK = 5,
	DRUID = 5,
	EVOKER = 25,
}
Constants.HEALER_SPEC_RANGE = {
	[256] = 46,
	[257] = 40,
	[65] = 40,
	[264] = 40,
	[105] = 40,
	[270] = 40,
	[1468] = 25,
}
Constants.INSTANCE_PORTAL_SPELLS = {
	-- Midnight
	[2805] = 1254400,
	[2811] = 1254572,
	[2874] = 1254559,
	[2915] = 1254563,
	-- The War Within
	[2648] = 445443,
	[2649] = 445444,
	[2651] = 445441,
	[2652] = 445269,
	[2660] = 445417,
	[2661] = 445440,
	[2662] = 445414,
	[2669] = 445416,
	[2773] = 1216786,
	[2830] = 1237215,
	-- Dragonflight
	[2451] = 393222,
	[2515] = 393279,
	[2516] = 393262,
	[2519] = 393276,
	[2520] = 393267,
	[2521] = 393256,
	[2526] = 393273,
	[2527] = 393283,
	[2579] = 424197,
	-- Shadowlands
	[2284] = 354469,
	[2285] = 354466,
	[2286] = 354462,
	[2287] = 354465,
	[2289] = 354463,
	[2290] = 354464,
	[2291] = 354468,
	[2293] = 354467,
	[2441] = 367416,
	-- Battle for Azeroth
	[1763] = 424187,
	[1754] = 410071,
	[1822] = function() return UnitFactionGroup("player") == "Alliance" and 445418 or 464256 end,
	[1594] = function() return UnitFactionGroup("player") == "Alliance" and 467553 or 467555 end,
	[1841] = 410074,
	[1862] = 424167,
	[2097] = 373274,
	-- Legion
	[1571] = 393766,
	[1651] = 373262,
	[1501] = 424153,
	[1466] = 424163,
	[1458] = 410078,
	[1477] = 393764,
	[1753] = 1254551,
	-- Warlords of Draenor
	[1209] = 159898,
	[1176] = 159899,
	[1208] = 159900,
	[1279] = 159901,
	[1195] = 159896,
	[1182] = 159897,
	[1175] = 159895,
	[1358] = 159902,
	-- Mists of Pandaria
	[959] = 131206,
	[960] = 131204,
	[961] = 131205,
	[962] = 131225,
	[994] = 131222,
	[1001] = 131231,
	[1007] = 131232,
	[1011] = 131228,
	[1004] = 131229,
	-- Cataclysm
	[643] = 424142,
	[657] = 410080,
	[670] = 445424,
	-- Wrath of the Lich King
	[658] = 1254555,
}

-- ============================================================
-- Config Defaults
-- ============================================================
Config.Defaults = {
	global = {
		actionBarSets = {},
		systemCVars = {},
		keybindings = {},
		accountMacros = {},
		classMacros = {},
		editModeLayout = nil,
		general = {
			hideApplyNotice = false,
		},
		spaceBtn = {
			enabled = true,
		},
		freeLook = {
			freelookEnabled = true,
			freelookKey = "LCTRL",
			freelookDelay = 1.0,
		},
		banTarget = {
			enabled = true,
			clickTime = 0.2,
		},
		sound = {
			iconEnabled = true,
			ldbEnabled = true,
			iconSize = 34,
			position = {
				point = "CENTER",
				relativeFrame = "ChatFrameChannelButton",
				relativePoint = "CENTER",
				x = 0,
				y = 0,
			},
		},
		compass = {
			enabled = true,
			minimapLineThickness = 2,
			worldMapLineThickness = 2,
			minimapThrottle = 0.2,
			worldMapThrottle = 0.5,
			lineColor = { r = 1, g = 0, b = 0, a = 0.8 }
		},
		mooseLight = {
			enabled = true,
			zones = {},
			userDefaults = nil,
			gamma = 1.3,
			brightness = 60,
			contrast = 55,
		},
		rangeCheck = {
			enabled = true,
			locked = true,
			fontSize = 18,
			frameScale = 1.0,
			point = "CENTER",
			relativePoint = "CENTER",
			xOffset = 0,
			yOffset = 0,
			inRangeColor = { r = 0.0, g = 1.0, b = 0.0 },
			outOfRangeColor = { r = 1.0, g = 0.0, b = 0.0 },
			hideThreshold = 60,
		},
		premadeGroupHelper = {
			enabled = true,
			keystoneEnabled = true,
			fontSize = 14,
			frameScale = 1.0,
			point = "CENTER",
			relativePoint = "CENTER",
			xOffset = 0,
			yOffset = 0,
			width = 280,
			height = 210,
		},
		professionTabs = {
			enabled = true,
		},
		autoRoll = {
			enabled = true,
			frameScale = 1.0,
			point = "CENTER",
			relativePoint = "CENTER",
			xOffset = 0,
			yOffset = 150,
		},
		mail = {
			enabled = true,
			recipient = "",
			itemIDs = {},
		},
	},
	profile = {
		autoApplySystemOnLogin = false,
		autoApplyKeybindingsOnLogin = false,
		autoApplyAccountMacrosOnLogin = false,
		autoApplyClassMacrosOnLogin = false,
		autoApplyEditModeOnLogin = false,
		autoApplyActionBarsOnLogin = false,
		autoApplyMooseLightOnLogin = false,
	},
}
