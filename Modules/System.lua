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
		"cameraDistanceMaxZoomFactor", "cameraYawMoveSpeed",
		"nameplateMaxDistance", "nameplateMinScale", "nameplateMaxScale",
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

function System:SaveKeybindings()
	local bindings = {}
	for i = 1, GetNumBindings() do
		local command, _, key1, key2 = GetBinding(i)
		if command then
			bindings[command] = {key1, key2}
		end
	end

	GQol.db.global.keybindings = bindings
	Utils:SendMessage("KEYBINDINGS_SAVED")
end

function System:ApplyKeybindings()
	local saved = GQol.db.global.keybindings
	if Utils:IsEmpty(saved) then
		return Utils:SendApplyMessage("KEYBINDINGS_NO_SETTINGS")
	end

	for i = 1, GetNumBindings() do
		local _, _, key1, key2 = GetBinding(i)
		if key1 then SetBinding(key1) end
		if key2 then SetBinding(key2) end
	end

	for command, keys in pairs(saved) do
		local k1, k2 = keys[1], keys[2]
		if k1 then SetBinding(k1, command) end
		if k2 then SetBinding(k2, command) end
	end

	SaveBindings(GetCurrentBindingSet())
	Utils:SendApplyMessage("KEYBINDINGS_APPLIED")
end

function System:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		systemSave = CH.Execute(41, "SYSTEM_SAVE_BTN", Utils:ModuleExecute("System", "SaveSystemCVars")),
		systemApply = CH.Execute(42, "SYSTEM_APPLY_BTN", Utils:ModuleExecute("System", "ApplySystemCVars")),
		systemAutoApply = CH.ProfileToggle(43, "SYSTEM_AUTO_APPLY_CBOX", "autoApplySystemOnLogin"),
		keybindingsSave = CH.Execute(51, "KEYBINDINGS_SAVE_BTN", Utils:ModuleExecute("System", "SaveKeybindings")),
		keybindingsApply = CH.Execute(52, "KEYBINDINGS_APPLY_BTN", Utils:ModuleExecute("System", "ApplyKeybindings")),
		keybindingsAutoApply = CH.ProfileToggle(53, "KEYBINDINGS_AUTO_APPLY_CBOX", "autoApplyKeybindingsOnLogin"),
	}
end
