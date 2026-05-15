local GQol = _G.GQol

local Utils = GQol.Utils

GQol.System = GQol.System or {}
local System = GQol.System

function System:SaveSystemCVars()
	local savedCVars = {}

	local importantCVars = {
		"Gamma", "Brightness", "Contrast",
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
		"cameraDistanceMaxZoomFactor", "cameraYawMoveSpeed",
		"cameraPitchMoveSpeed", "cameraSmoothStyle",
		"cameraSmoothFollows", "cameraSmoothFollowStrength",
		"cameraSmoothTrackingStyle", "cameraFollowOnStick",
		"cameraWaterCollision", "cameraPivotLock",
		"cameraPivotLockCharacter",
		"nameplateMaxDistance", "nameplateMinScale", "nameplateMaxScale",
		"nameplateShowEnemies", "nameplateShowFriendly",
		"nameplateShowFriendlyNPCs", "nameplateShowFriendlyMinions",
		"nameplateShowEnemyMinions", "nameplateShowEnemyMinus",
		"nameplateShowAll", "nameplateShowOnlyNames",
		"nameplateShowDebuffsOnFriendly", "nameplateShowDishonorableTargets",
		"nameplateClassColors", "nameplatePlayerMinAlpha",
		"nameplateOccludedAlphaMult", "nameplateSelectedScale",
		"nameplateNotSelectedAlpha", "nameplateTargetAtMinScale",
		"nameplateMotion", "nameplateOverlapH", "nameplateOverlapV",
		"graphicsQuality", "raidGraphicsQuality",
		"worldTextScale", "maxFPS", "maxFPSBk",
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
		"scriptErrors", "scriptWarnings",
		"showBuffDuration", "showMinimap",
		"showTargetCastbar", "showPartyCastbar",
		"showCastOnTarget", "showArenaCastbar",
		"showRaidCastbar", "showSpellQueueWindow",
		"showClampedTargetTarget", "showTargetTarget",
		"showComboPoints", "showReputationBar",
		"factionNameplateColors", "threatPlaySound",
		"threatFlashFrames", "threatShowNumeric",
		"autoDeclineDuels", "autoDismount",
		"autoLootDefault", "autoOpenLootHistory",
		"autoPushSpells", "autoSelfCast",
		"autoUnshift", "checkCursorPosition",
		"colorBlindMode", "colorBlindWeaknessFilter",
		"deselectOnClick", "enableMouseSpeed",
		"enableWoWMouse", "GameTooltipActive",
		"GameTooltipFollow", "GameTooltipFollowOff",
		"GameTooltipHideCombat", "GameTooltipShowSpellID",
		"GameTooltipShowSpellInfo", "GameTooltipShowItemID",
		"lockActionBars", "lockChatWindows",
		"secureAbilityToggle", "showNewPlayerExperience",
		"showQuestTrackingTooltips", "showTutorials",
		"enableHardwareCursor", "enableSpellQueuing",
		"enableFullscreenGlow", "enableModechange",
		"enableLiquidDetail", "enableMipmap",
		"enableParticleNames", "enablePhysics",
		"enableProjectedTextures", "enablePvpAlert",
		"enableSmoothLighting", "enableSpecialEffects",
		"farclip", "ffx", "ffxDeath",
		"ffxGlow", "ffxLodBias", "ffxMode",
		"ffxPostProcess", "ffxShadowLoD", "ffxWeather",
		"gxAPI", "gxMaximize", "gxMultisample", "gxMultisampleQuality",
		"gxResolution", "gxWindow", "gxWindowedMaximized",
		"healthBarType", "hideChatButtons", "hidePartyUI",
		"inboxNotify", "instantText",
		"keepChatHistory", "legacyControlGroups",
		"locale", "lockChatBubble",
		"logChatToFile", "logCombatToFile",
		"lootUnderMouse", "lossOfControl",
		"lossOfControlAlerts", "lossOfControlFull",
		"lossOfControlIcons", "lossOfControlInterrupt",
		"lossOfControlSilence", "lossOfControlStopAttacks",
		"lossOfControlStopCasting", "lossOfControlStopMoving",
		"lossOfControlStopSpellTargeting", "lowLevelFilter",
		"lowLevelQuestFilter", "macroFontSize",
		"mainFrameShown", "mapOpacity",
		"massLootConfirmation", "maxChatLines",
		"merchantItemsPerRow", "messageDuration",
		"messageFadeDuration", "microBarShown",
		"minimapInsideZoom", "minimapMotionSickness",
		"minimapOutsideZoom", "minimapPing",
		"minimapShowMinimapEdgeIcons", "minimapTrackingHide",
		"missingTalentAlert", "mouseInvertPitch",
		"mouseLookInvert", "mouseLookSpeed",
		"mouseLookSpeedPitch", "mouseMoveStop",
		"movementStrafesToTurns", "movementStrafesToTurnsTime",
		"movieSubtitle", "movieSubtitleFadeIn",
		"movieSubtitleFadeOut", "movieSubtitleTime",
		"multiMonitorCursorLock", "multiMonitorSetup",
		"multiSampleAntiAlias", "multiSampleAlphaToCoverage",
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