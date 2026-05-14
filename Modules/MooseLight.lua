local GQol = _G.GQol

local Timer = GQol.Timer
local Constants = GQol.Constants
local Combat = GQol.Combat
local L = GQol.L

GQol.MooseLight = GQol.MooseLight or {}
local MooseLight = GQol.MooseLight
MooseLight.lastUpdate = 0
MooseLight.currentStatus = "default"
MooseLight.selectedZone = nil

local Utils = GQol.Utils

local function GetZoneName(zoneKey)
	if not zoneKey then return "" end
	local mapID = tonumber(strsplit("_", zoneKey))
	local mapInfo = mapID and C_Map.GetMapInfo(mapID)
	return mapInfo and mapInfo.name or zoneKey
end

local function GetCurrentZoneKey()
	local mapID = C_Map.GetBestMapForUnit("player") or 0
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	return string.format("%d_%d", mapID, instanceID or 0)
end

function MooseLight:SaveCurrentAsDefault()
	local db = GQol.db.global.mooseLight
	db.userDefaults = {
		Gamma = Utils:GetNumericCVar("Gamma"),
		Brightness = Utils:GetNumericCVar("Brightness"),
		Contrast = Utils:GetNumericCVar("Contrast"),
	}
	Utils:SendApplyMessage("MOOSELIGHT_DEFAULT_SAVED")
end

function MooseLight:RestoreDefault()
	if self.currentStatus == "default" then return end
	local db = GQol.db.global.mooseLight
	local def = db.userDefaults
	if not def then return end

	SetCVar("Gamma", def.Gamma)
	SetCVar("Brightness", def.Brightness)
	SetCVar("Contrast", def.Contrast)
	self.currentStatus = "default"
end

function MooseLight:ApplyBright()
	local db = GQol.db.global.mooseLight

	SetCVar("Gamma", db.gamma)
	SetCVar("Brightness", db.brightness)
	SetCVar("Contrast", db.contrast)
	self.currentStatus = "bright"
end

function MooseLight:UpdateZoneLight()
	local db = GQol.db.global.mooseLight

	if not db.enabled then
		self:RestoreDefault()
		return
	end

	local key = GetCurrentZoneKey()
	if db.zones[key] then
		self:ApplyBright()
	else
		self:RestoreDefault()
	end
end

function MooseLight:TriggerUpdate()
	local now = GetTime()
	if now - self.lastUpdate < Constants.MOOSE_LIGHT_DEBOUNCE_DELAY then return end
	self.lastUpdate = now
	C_Timer.After(Constants.MOOSE_LIGHT_UPDATE_DELAY, function()
		Combat:RunWhenOut(function()
			self:UpdateZoneLight()
		end)
	end)
end

function MooseLight:HandleCommand(msg)
	msg = Utils:SafeTrim(msg or ""):lower()
	local db = GQol.db.global.mooseLight
	local key = GetCurrentZoneKey()

	if msg == "add" then
		db.zones[key] = true
		self:UpdateZoneLight()
		Utils:SendApplyMessage("MOOSELIGHT_ZONE_ADDED")
		Utils:NotifyConfigChange()
	elseif msg == "del" or msg == "remove" then
		db.zones[key] = nil
		self:UpdateZoneLight()
		Utils:SendApplyMessage("MOOSELIGHT_ZONE_REMOVED")
		Utils:NotifyConfigChange()
	elseif msg == "save" then
		self:SaveCurrentAsDefault()
	end
end

function MooseLight:OnInitialize()
	local db = GQol.db.global.mooseLight
	if not db.userDefaults then
		self:SaveCurrentAsDefault()
	end

	if db.enabled then
		C_Timer.After(Constants.LOGIN_DELAY, function()
			self:UpdateZoneLight()
		end)
	end
end

function MooseLight:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		self:TriggerUpdate()
	end)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
		self:TriggerUpdate()
	end)
	self:RegisterEvent("PLAYER_LOGOUT", function()
		self:RestoreDefault()
	end)
	self:UpdateZoneLight()
end

function MooseLight:OnDisable()
	self:UnregisterAllEvents()
	self:RestoreDefault()
end

function MooseLight:SetEnabled(val)
	if val then
		self:UpdateZoneLight()
		Utils:SendApplyMessage("MOOSELIGHT_ENABLED")
	else
		self:RestoreDefault()
		Utils:SendApplyMessage("MOOSELIGHT_DISABLED")
	end
end

function MooseLight:GetOptions()
	local CH = Utils.ConfigHelpers
	local db = GQol.db.global.mooseLight
	
	local function GetZoneDropdownValues()
		local values = {}
		local zones = db.zones or {}
		for zoneKey in pairs(zones) do
			values[zoneKey] = GetZoneName(zoneKey)
		end
		return values
	end

	return {
		enabled = CH.GlobalToggle(101, "MOOSELIGHT_ENABLE_CBOX", "mooseLight.enabled", function(val)
			self:SetEnabled(val)
		end),
		gamma = CH.GlobalRange(102, "MOOSELIGHT_GAMMA_SLIDER", "mooseLight.gamma", 0.5, 2.0, 0.05, function(val)
			self:UpdateZoneLight()
		end),
		brightness = CH.GlobalRange(103, "MOOSELIGHT_BRIGHTNESS_SLIDER", "mooseLight.brightness", 0, 100, 1, function(val)
			self:UpdateZoneLight()
		end),
		contrast = CH.GlobalRange(104, "MOOSELIGHT_CONTRAST_SLIDER", "mooseLight.contrast", 0, 100, 1, function(val)
			self:UpdateZoneLight()
		end),
		saveDefault = CH.Execute(105, "MOOSELIGHT_SAVE_DEFAULT_BTN", function()
			self:SaveCurrentAsDefault()
		end),
		addCurrentZone = CH.Execute(106, "MOOSELIGHT_ADD_ZONE_BTN", function()
			self:HandleCommand("add")
		end),
		removeCurrentZone = CH.Execute(107, "MOOSELIGHT_REMOVE_ZONE_BTN", function()
			self:HandleCommand("del")
		end),
		zonesHeader = CH.Header(108, "MOOSELIGHT_ZONES_HEADER"),
		zones = {
			type = "group",
			name = "",
			order = 109,
			inline = true,
			args = {
				zoneDropdown = {
					type = "select",
					order = 1,
					name = L["MOOSELIGHT_SELECT_ZONE"] or "MOOSELIGHT_SELECT_ZONE",
					values = GetZoneDropdownValues,
					get = function()
						return self.selectedZone
					end,
					set = function(_, val)
						self.selectedZone = val
					end,
				},
				deleteZone = CH.Execute(2, "MOOSELIGHT_DELETE_ZONE_BTN", function()
					if self.selectedZone then
						db.zones[self.selectedZone] = nil
						self.selectedZone = nil
						self:UpdateZoneLight()
						Utils:NotifyConfigChange()
					end
				end, function()
					return not self.selectedZone
				end),
			},
		},
	}
end
