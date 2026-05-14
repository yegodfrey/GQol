local GQol = _G.GQol

local Constants = GQol.Constants
local Utils = GQol.Utils
local Timer = GQol.Timer

GQol.EditMode = GQol.EditMode or {}
local EditMode = GQol.EditMode

EditMode.lastApplyTime = 0
EditMode.LAYOUT_COOLDOWN = 5

local function GetActiveLayoutDetails()
	local layoutsData = C_EditMode.GetLayouts()
	if not layoutsData then return nil end

	local activeLayoutApiID = tonumber(layoutsData.activeLayout)
	if not activeLayoutApiID or activeLayoutApiID < Constants.EDIT_MODE_MIN_CUSTOM_UID then
		return nil
	end

	local targetIndex = activeLayoutApiID - (Constants.EDIT_MODE_MIN_CUSTOM_UID - 1)
	local layoutsArray = layoutsData.layouts
	if targetIndex < 1 or targetIndex > #layoutsArray then return nil end

	local activeLayoutInfo = layoutsArray[targetIndex]
	if not activeLayoutInfo or not activeLayoutInfo.systems then return nil end

	local layoutString = C_EditMode.ConvertLayoutInfoToString(activeLayoutInfo)
	if not layoutString then return nil end

	return layoutString, activeLayoutInfo.layoutName
end

function EditMode:SaveCurrentLayout()
	local layoutString, layoutName = GetActiveLayoutDetails()
	if layoutString and layoutName then
		GQol.db.global.editModeLayout = {
			name = layoutName,
			string = layoutString
		}
		Utils:SendMessage("EDITMODE_SAVED")
	end
end

function EditMode:ApplyCurrentLayout(silent)
	if InCombatLockdown() then return end

	local now = GetTime()

	if now - self.lastApplyTime < self.LAYOUT_COOLDOWN then
		return
	end

	self.lastApplyTime = now

	local saved = GQol.db.global.editModeLayout
	if not saved or not saved.string then
		if not silent then
			Utils:SendApplyMessage("EDITMODE_NO_LAYOUT")
		end
		return
	end

	local currentLayoutString = GetActiveLayoutDetails()
	if currentLayoutString == saved.string then
		if not silent then
			Utils:SendApplyMessage("EDITMODE_ALREADY_CURRENT")
		end
		return
	end

	local parsedLayout = C_EditMode.ConvertStringToLayoutInfo(saved.string)
	if not parsedLayout or not parsedLayout.systems then
		if not silent then
			Utils:SendApplyMessage("EDITMODE_NO_LAYOUT")
		end
		return
	end

	local layoutData = {
		layoutName = saved.name,
		layoutType = Constants.EDIT_MODE_LAYOUT_TYPE_CUSTOM,
		systems = parsedLayout.systems
	}

	local saveData = {
		layouts = {layoutData},
		activeLayout = tostring(Constants.EDIT_MODE_TARGET_UID),
		hasActiveLayoutBeenModifiedSinceLastSave = true
	}

	C_EditMode.SaveLayouts(saveData)

	C_Timer.After(Constants.EDIT_MODE_APPLY_DELAY_1 + Constants.EDIT_MODE_APPLY_DELAY_2, function()
		C_EditMode.SetActiveLayout(tostring(Constants.EDIT_MODE_TARGET_UID))
		if not silent then
			Utils:SendApplyMessage("EDITMODE_APPLIED")
		end
	end)
end

function EditMode:ApplyOnLogin()
	if self.loginApplied then return end
	self.loginApplied = true
	self:ApplyCurrentLayout(true)
end

function EditMode:ApplyOnSpecChange()
	self:ApplyCurrentLayout(true)
end

function EditMode:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		save = CH.Execute(21, "EDITMODE_SAVE_BTN", Utils:ModuleExecute("EditMode", "SaveCurrentLayout")),
		apply = CH.Execute(22, "EDITMODE_APPLY_BTN", Utils:ModuleExecute("EditMode", "ApplyCurrentLayout")),
		autoApply = CH.ProfileToggle(23, "EDITMODE_AUTO_APPLY_CBOX", "autoApplyEditModeOnLogin"),
	}
end
