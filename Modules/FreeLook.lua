local GQol = _G.GQol

local Utils = GQol.Utils
local Timer = GQol.Timer

GQol.FreeLook = GQol.FreeLook or {}
local FreeLook = GQol.FreeLook
FreeLook.isFreelookActive = false
FreeLook.holdStartTime = nil
FreeLook.tickerId = nil
FreeLook.frame = nil

local KEY_DOWN_FUNCS = {
	LCTRL = IsLeftControlKeyDown,
	LEFTCTRL = IsLeftControlKeyDown,
	RCTRL = IsRightControlKeyDown,
	RIGHTCTRL = IsRightControlKeyDown,
	CTRL = IsControlKeyDown,
	CONTROL = IsControlKeyDown,
	LSHIFT = IsLeftShiftKeyDown,
	LEFTSHIFT = IsLeftShiftKeyDown,
	RSHIFT = IsRightShiftKeyDown,
	RIGHTSHIFT = IsRightShiftKeyDown,
	SHIFT = IsShiftKeyDown,
	LALT = IsLeftAltKeyDown,
	LEFTALT = IsLeftAltKeyDown,
	RALT = IsRightAltKeyDown,
	RIGHTALT = IsRightAltKeyDown,
	ALT = IsAltKeyDown,
}

local COMPOSITE_KEYS = {
	CTRL = { "LCTRL", "RCTRL" },
	SHIFT = { "LSHIFT", "RSHIFT" },
	ALT = { "LALT", "RALT" },
}

function FreeLook:IsKeyDown(keyName)
	if not keyName or type(keyName) ~= "string" then return false end
	local func = KEY_DOWN_FUNCS[keyName:upper()]
	return func and func() or false
end

function FreeLook:CheckKeyState(pressedKey, isDown)
	local db = GQol.db.global.freeLook
	if not db.freelookEnabled then return end

	local targetKey = db.freelookKey or "LCTRL"
	local composite = COMPOSITE_KEYS[targetKey]
	local isTargetKey
	if composite then
		isTargetKey = (pressedKey == composite[1] or pressedKey == composite[2])
	else
		isTargetKey = (pressedKey == targetKey)
	end

	if isTargetKey then
		if isDown then
			if not self.holdStartTime then
				self.holdStartTime = GetTime()
				local delay = db.freelookDelay or 1.0
				self.tickerId = Timer:NewTicker(delay, function()
					if self.holdStartTime and not self.isFreelookActive and self:IsKeyDown(targetKey) then
						self.isFreelookActive = true
						MouselookStart()
					end
					Timer:Cancel(self.tickerId)
				end, 1)
			end
		else
			if self.isFreelookActive then
				self.isFreelookActive = false
				MouselookStop()
			end
			if self.tickerId then
				Timer:Cancel(self.tickerId)
				self.tickerId = nil
			end
			self.holdStartTime = nil
		end
	end
end

function FreeLook:OnInitialize()
	if self.frame then return end

	self.frame = CreateFrame("Frame", "GQol_FreeLookFrame", UIParent)
	self.isFreelookActive = false
	self.holdStartTime = nil
	self.tickerId = nil
end

function FreeLook:OnEnable()
	if not self.frame then self:OnInitialize() end
	self.frame:RegisterEvent("MODIFIER_STATE_CHANGED")
	self.frame:SetScript("OnEvent", function(_, event, key, down)
		if event == "MODIFIER_STATE_CHANGED" then
			self:CheckKeyState(key, down == 1)
		end
	end)
end

local function StopFreelook()
	if FreeLook.isFreelookActive then
		FreeLook.isFreelookActive = false
		MouselookStop()
	end
	if FreeLook.tickerId then
		Timer:Cancel(FreeLook.tickerId)
		FreeLook.tickerId = nil
	end
	FreeLook.holdStartTime = nil
end

function FreeLook:OnDisable()
	if self.frame then self.frame:UnregisterAllEvents() end
	StopFreelook()
end

function FreeLook:SetFreelookEnabled(val)
	if val then
		if not self.frame then self:OnInitialize() end
		Utils:SendApplyMessage("FREELOOK_ENABLED")
	else
		StopFreelook()
		Utils:SendApplyMessage("FREELOOK_DISABLED")
	end
end

function FreeLook:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(84, "FREELOOK_ENABLE_CBOX", "freeLook.freelookEnabled", function(val)
			self:SetFreelookEnabled(val)
		end),
		delay = CH.GlobalRange(85, "FREELOOK_DELAY_SLIDER", "freeLook.freelookDelay", 0.1, 3.0, 0.1),
		key = CH.GlobalKeybind(86, "FREELOOK_KEY_BINDING", "freeLook.freelookKey"),
	}
end
