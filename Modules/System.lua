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
		"mouseInvertPitch", "mouseLookSpeed", "mouseLookSpeedPitch",
		"enableMouseSpeed", "enableWoWMouse",
		-- 镜头
		"cameraDistanceMaxZoomFactor", "cameraYawMoveSpeed",
		"cameraPitchMoveSpeed", "cameraSmoothStyle",
		"cameraSmoothFollows", "cameraSmoothFollowStrength",
		"cameraSmoothTrackingStyle", "cameraFollowOnStick",
		"cameraWaterCollision", "cameraPivotLock",
		"cameraPivotLockCharacter", "cameraFOV",
		-- 显示
		"showTutorials", "showNewPlayerExperience",
		"outlineMode", "statusTextDisplay",
		"lockChatBubble", "chatBubbles", "chatBubblesParty",
		-- 任务
		"showWarbandCompletedQuests", "lowLevelQuestFilter",
		-- 团队框体
		"raidFramesDisplayIncomingHeals", "raidFramesDisplayPowerBars",
		"raidFramesDisplayAggroHighlight", "raidFramesDisplayClassColor",
		"raidFramesDisplayPets", "raidFramesDisplayMainTankAndAssist",
		"raidFramesDisplayDebuffs", "raidFramesDisplayOnlyDispellableDebuffs",
		"raidFramesDisplayDispelHighlight", "raidFramesDisplayHealthText",
		-- 竞技场对手框体
		"arenaFramesDisplayPowerBars", "arenaFramesDisplayPets",
		"arenaFramesDisplayHealthText",
		-- 动作条
		"lockActionBars", "lockActionBarKeys",
		"showActionBarCooldownNumbers",
		-- 战斗
		"showPersonalResource", "showSelfHighlight",
		"showOutlineWhenOccluded", "showTargetTarget",
		"showClampedTargetTarget", "showTargetCastbar",
		"showPartyCastbar", "showArenaCastbar", "showRaidCastbar",
		"showCastOnTarget", "showSpellQueueWindow",
		"showComboPoints", "showReputationBar",
		"showBuffDuration", "showMinimap",
		"noFlashOnLowHealth", "lossOfControl",
		"lossOfControlAlerts", "lossOfControlFull",
		"lossOfControlIcons", "lossOfControlInterrupt",
		"lossOfControlSilence", "lossOfControlStopAttacks",
		"lossOfControlStopCasting", "lossOfControlStopMoving",
		"lossOfControlStopSpellTargeting",
		"enableMouseoverCast", "autoSelfCast",
		"autoPushSpells", "autoUnshift",
		"focusCastKey", "enableEmpoweredCastInput",
		"spellAlertOpacity", "enableHoldToCast",
		"enableActionCam", "actionCam",
		-- 社交
		"chatProfanityFilter", "showGuildMemberAlert",
		"blockTrades", "blockGuildInvites",
		"blockChatChannelInvites", "restrictCalendarInvites",
		"showFriendOnlineAlert", "showFriendOfflineAlert",
		"showLocationInChat", "realIDFriendRequests",
		"autoAcceptQuickJoin", "chatStyle",
		"showChatTimestamps", "wholeChatWindowClickable",
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
		"nameplateShowOnlyNames", "nameplateShowOffScreen",
		"nameplateShowDebuffsOnFriendly", "nameplateShowDishonorableTargets",
		"nameplateClassColors", "nameplateMotion",
		"nameplateOverlapH", "nameplateOverlapV",
		"nameplateMaxDistance", "nameplateMinScale", "nameplateMaxScale",
		"nameplateGlobalScale", "nameplateSelectedScale",
		"nameplateNotSelectedAlpha", "nameplateTargetAtMinScale",
		"nameplateOccludedAlphaMult", "nameplatePlayerMinAlpha",
		"nameplateShowHealth", "nameplateShowCastBar",
		"nameplateShowThreat", "nameplateShowDebuffsOnEnemy",
		-- 界面
		"uiScale", "useUIScale",
		"questTextContrast", "worldTextScale",
		-- 综合
		"showMovePad", "enablePhotosensitivityMode",
		"minCharacterNameSize", "cameraShake",
		"cursorSize", "arachnophobiaMode",
		-- 系统 图形
		"Gamma", "Brightness", "Contrast",
		"vsync", "lowLatencyMode",
		"antiAliasing", "multiSampleTechnique",
		"shadowQuality", "liquidDetail",
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
		"graphicsQuality", "raidGraphicsQuality",
		"farclip", "ffx", "ffxDeath",
		"ffxGlow", "ffxLodBias", "ffxMode",
		"ffxPostProcess", "ffxShadowLoD", "ffxWeather",
		"gxAPI", "gxMaximize", "gxMultisample", "gxMultisampleQuality",
		"gxResolution", "gxWindow", "gxWindowedMaximized",
		"enableFullscreenGlow", "enableModechange",
		"enableLiquidDetail", "enableMipmap",
		"enableParticleNames", "enablePhysics",
		"enableProjectedTextures", "enablePvpAlert",
		"enableSmoothLighting", "enableSpecialEffects",
		"enableHardwareCursor", "enableSpellQueuing",
		"multiSampleAntiAlias", "multiSampleAlphaToCoverage",
		"multiMonitorCursorLock", "multiMonitorSetup",
		-- 声音
		"Sound_EnableAllSound", "Sound_EnableMusic", "Sound_EnableSFX",
		"Sound_OutputDriverIndex", "Sound_OutputSampleRate",
		"Sound_MasterVolume", "Sound_MusicVolume", "Sound_SFXVolume",
		"Sound_AmbienceVolume", "Sound_DialogVolume",
		"Sound_EnableAmbience", "Sound_EnableDialog",
		"Sound_EnableErrorSpeech", "Sound_EnableEmoteSounds",
		"Sound_EnableLoopMusic", "Sound_EnablePetSounds",
		"Sound_EnableSoundWhenGameIsInBG",
		"Sound_MusicFadeSpeed", "Sound_NumChannels",
		"Sound_SoundOutputQuality",
		"Sound_VoiceChatInputVolume", "Sound_VoiceChatOutputVolume",
		-- 浮动战斗文本
		"enableFloatingCombatText", "floatingCombatTextAllSpellMechanics",
		"floatingCombatTextAuras", "floatingCombatTextCombatDamage",
		"floatingCombatTextCombatDamageDirectional",
		"floatingCombatTextCombatHealing", "floatingCombatTextCombatLogPeriodicSpells",
		"floatingCombatTextCombatState", "floatingCombatTextDamageReduction",
		"floatingCombatTextDodgeParryMiss", "floatingCombatTextEnergyGains",
		"floatingCombatTextFloatMode", "floatingCombatTextHonorGains",
		"floatingCombatTextLowManaHealth", "floatingCombatTextPetMeleeDamage",
		"floatingCombatTextPetSpellDamage", "floatingCombatTextRepChanges",
		"floatingCombatTextSpellMechanics", "floatingCombatTextSpellMechanicsOther",
		-- 其他
		"scriptErrors", "scriptWarnings",
		"factionNameplateColors", "threatPlaySound",
		"threatFlashFrames", "threatShowNumeric",
		"autoDeclineDuels", "autoOpenLootHistory",
		"checkCursorPosition", "colorBlindMode",
		"colorBlindWeaknessFilter",
		"GameTooltipActive", "GameTooltipFollow",
		"GameTooltipFollowOff", "GameTooltipHideCombat",
		"GameTooltipShowSpellID", "GameTooltipShowSpellInfo",
		"GameTooltipShowItemID",
		"lockChatWindows", "secureAbilityToggle",
		"showQuestTrackingTooltips",
		"healthBarType", "hideChatButtons", "hidePartyUI",
		"inboxNotify", "instantText",
		"keepChatHistory", "legacyControlGroups",
		"locale", "logChatToFile", "logCombatToFile",
		"macroFontSize", "mainFrameShown", "mapOpacity",
		"massLootConfirmation", "maxChatLines",
		"merchantItemsPerRow", "messageDuration",
		"messageFadeDuration", "microBarShown",
		"minimapInsideZoom", "minimapMotionSickness",
		"minimapOutsideZoom", "minimapPing",
		"minimapShowMinimapEdgeIcons", "minimapTrackingHide",
		"missingTalentAlert", "mouseMoveStop",
		"movementStrafesToTurns", "movementStrafesToTurnsTime",
		"movieSubtitle", "movieSubtitleFadeIn",
		"movieSubtitleFadeOut", "movieSubtitleTime",
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