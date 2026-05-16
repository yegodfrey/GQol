local GQol = _G.GQol

local Utils = GQol.Utils

GQol.System = GQol.System or {}
local System = GQol.System

function System:SaveSystemCVars()
	local savedCVars = {}

	local importantCVars = {
		-- 控制
		"deselectOnClick", "autoDismount", "autoClearAFK",
		"autoLootDefault", "autoLootKey", "lootUnderMouse",
		"combinedBags", "enableInteractKey", "interactOnLeftClick",
		"Sound_EnableInteractSound",
		-- 鼠标
		"mouseInvertPitch", "mouseLookSpeed", "clickToMove",
		-- 镜头
		"cameraWaterCollision", "cameraSmoothFollowStrength",
		"cameraSmoothTrackingStyle",
		-- 显示
		"showTutorials", "outlineMode", "statusTextDisplay",
		"chatBubbles", "chatBubblesParty", "chatBubblesRaid",
		-- 任务
		"showWarbandCompletedQuests", "lowLevelQuestFilter",
		-- 团队框体
		"raidFramesDisplayIncomingHeals", "raidFramesDisplayPowerBars",
		"raidFramesDisplayAggroHighlight", "raidFramesDisplayClassColor",
		"raidFramesBackground", "raidFramesDisplayPets",
		"raidFramesDisplayMainTankAndAssist", "raidFramesDisplayDebuffs",
		"raidFramesDisplayOnlyDispellableDebuffs", "raidFramesDisplayDispelHighlight",
		"raidFramesDisplayDispelColor", "raidFramesDisplayHealthText",
		-- 竞技场对手框体
		"arenaFramesDisplayPowerBars", "arenaFramesDisplayPets",
		"arenaFramesDisplayHealthText",
		-- 动作条
		"lockActionBars", "lockActionBarKeys",
		"showActionBarCooldownNumbers",
		-- 战斗
		"showPersonalResource", "showSelfHighlight",
		"showOutlineWhenOccluded", "showTargetTarget",
		"noFlashOnLowHealth", "lossOfControl",
		"enableMouseoverCast", "autoSelfCast",
		"focusCastKey", "enableEmpoweredCastInput",
		"spellAlertOpacity", "enableHoldToCast",
		"enableActionCam",
		-- 社交
		"chatProfanityFilter", "showGuildMemberAlert",
		"blockTrades", "blockGuildInvites",
		"blockChatChannelInvites", "restrictCalendarInvites",
		"showFriendOnlineAlert", "showFriendOfflineAlert",
		"showLocationInChat", "realIDFriendRequests",
		"autoAcceptQuickJoin", "chatStyle",
		"showChatTimestamps",
		-- 信号系统
		"enablePingSystem", "pingSound", "showPingsInChat",
		-- 游戏增强
		"enableBossAlerts", "enableBossEmotes",
		"enableCooldownManager", "enableExternalDefensives",
		"enableDamageMeter", "autoResetDamageMeter",
		"diminishingReturnsTracking",
		-- 姓名板
		"nameplateShowSelf", "nameplateShowEnemies",
		"nameplateShowFriendly", "nameplateShowFriendlyNPCs",
		"nameplateShowFriendlyMinions", "nameplateShowEnemyMinions",
		"nameplateShowEnemyMinus", "nameplateShowAll",
		"nameplateShowOffScreen", "nameplateMotion",
		"nameplateGlobalScale", "nameplateShowHealth",
		"nameplateShowCastBar", "nameplateShowThreat",
		"nameplateShowDebuffsOnEnemy", "nameplateShowDebuffsOnFriendly",
		-- 界面
		"uiScale", "questTextContrast",
		-- 综合
		"showMovePad", "enablePhotosensitivityMode",
		"minCharacterNameSize", "cameraShake",
		"cursorSize", "arachnophobiaMode",
		-- 系统 图形
		"useUIScale", "Gamma", "Brightness", "Contrast",
		"vsync", "lowLatencyMode",
		"antiAliasing", "multiSampleTechnique",
		"cameraFOV", "shadowQuality", "liquidDetail",
		"particleDensity", "ssao",
		"depthOfField", "computeEffects",
		"textureResolution", "spellDensity",
		"textureProjection", "viewDistance",
		"environmentDetail", "groundClutter",
		"tripleBuffering", "textureFiltering",
		"rayTracingShadows", "resampleQuality",
		"vrsMode", "graphicsAPI",
		"physicsInteractions", "maxFPS", "maxFPSBk",
		"targetFPS", "resampleSharpness",
	}

	for _, cvarName in ipairs(importantCVars) do
		local value = GetCVar(cvarName)
		if value ~= nil then
			savedCVars[cvarName] = value
		end
	end

	GQol.db.global.systemCVars = savedCVars
	Utils:SendMessage("SYSTEM_SAVED")
end

function System:ApplySystemCVars()
	if Utils:IsEmpty(GQol.db.global.systemCVars) then
		return Utils:SendApplyMessage("SYSTEM_NO_SETTINGS")
	end

	local changed = 0
	for cvar, value in pairs(GQol.db.global.systemCVars) do
		if GetCVar(cvar) ~= value then
			SetCVar(cvar, value)
			changed = changed + 1
		end
	end

	Utils:SendApplyMessage("SYSTEM_APPLIED", changed)
end