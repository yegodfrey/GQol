local GQol = _G.GQol

local Constants = GQol.Constants
local Utils = GQol.Utils

GQol.ActionBars = GQol.ActionBars or {}
local ActionBars = GQol.ActionBars

local function GetSpecKey()
	local specIndex = GetSpecialization()
	if not specIndex then return nil end

	local specID = select(1, GetSpecializationInfo(specIndex))
	local classToken = Utils:GetPlayerClassToken()

	if not specID or not classToken then return nil end
	return classToken .. "_" .. specID
end

function ActionBars:SaveCurrentSpecSet()
	local key = GetSpecKey()
	local specIndex = GetSpecialization()
	local specID, specName = GetSpecializationInfo(specIndex)

	local sets = GQol.db.global.actionBarSets or {}
	sets[key] = {
		name = specName,
		class = Utils:GetPlayerClassToken(),
		specID = specID,
		actions = {}
	}

	local set = sets[key]
	for slot = 1, Constants.MAX_ACTION_SLOTS do
		set.actions[slot] = self:GetActionInfoTable(slot)
	end

	GQol.db.global.actionBarSets = sets
	Utils:SendMessage("ACTIONBARS_SAVED", specName)
end

function ActionBars:ApplyCurrentSpecSet(silent)
	local key = GetSpecKey()
	if not key then
		if not silent then
			Utils:SendApplyMessage("ACTIONBARS_NO_PROFILE")
		end
		return
	end

	local sets = GQol.db.global.actionBarSets or {}
	local set = sets[key]

	if not set or not set.actions then
		if not silent then
			Utils:SendApplyMessage("ACTIONBARS_NO_PROFILE")
		end
		return
	end

	for slot = 1, Constants.MAX_ACTION_SLOTS do
		local saved = set.actions[slot]
		if not self:CompareSlot(slot, saved) then
			self:SetActionToSlot(slot, saved)
		end
	end
	if not silent then
		Utils:SendApplyMessage("ACTIONBARS_APPLIED", set.name)
	end
end

function ActionBars:AutoSwitchForCurrentSpec()
	self:ApplyCurrentSpecSet(true)
end

function ActionBars:GetActionInfoTable(slot)
	local actionType, id, subType = GetActionInfo(slot)
	if not actionType then return nil end

	local info = {
		type = actionType,
		id = id,
		subType = subType
	}

	if actionType == "macro" then
		local macroName = GetActionText(slot)
		if macroName then
			info.macroName = macroName
		end
	end

	return info
end

function ActionBars:CompareSlot(slot, saved)
	if not saved then
		return GetActionInfo(slot) == nil
	end

	local t, id = GetActionInfo(slot)
	if saved.type ~= t or saved.id ~= id then
		return false
	end

	if t == "macro" then
		return saved.macroName == GetActionText(slot)
	end

	return true
end

function ActionBars:SetActionToSlot(slot, data)
	if InCombatLockdown() then
		return
	end

	if not data then
		PickupAction(slot)
		ClearCursor()
		return
	end

	ClearCursor()
	if data.type == "spell" and data.id then
		C_Spell.PickupSpell(data.id)
		PlaceAction(slot)
	elseif data.type == "macro" and data.macroName then
		local idx = GetMacroIndexByName(data.macroName)
		if idx and idx > 0 then
			PickupMacro(idx)
			PlaceAction(slot)
		end
	elseif data.type == "item" and data.id then
		PickupItem(data.id)
		PlaceAction(slot)
	end
end

function ActionBars:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		save = CH.Execute(11, "ACTIONBARS_SAVE_BTN", Utils:ModuleExecute("ActionBars", "SaveCurrentSpecSet")),
		apply = CH.Execute(12, "ACTIONBARS_APPLY_BTN", Utils:ModuleExecute("ActionBars", "ApplyCurrentSpecSet")),
		autoApply = CH.ProfileToggle(13, "ACTIONBARS_AUTO_APPLY_CBOX", "autoApplyActionBarsOnLogin"),
	}
end
