local GQol = _G.GQol

local AceEvent = LibStub("AceEvent-3.0")
local L = GQol.L

local Timer = {}
GQol.Timer = Timer
Timer.activeTickers = {}
Timer.tickerCounter = 0

function Timer:NewTicker(interval, func, iterations)
	local id = self.tickerCounter + 1
	self.tickerCounter = id
	local ticker = C_Timer.NewTicker(interval, function()
		if self.activeTickers[id] then
			func()
		end
	end, iterations)
	self.activeTickers[id] = ticker
	return id
end

function Timer:Cancel(tickerId)
	local ticker = self.activeTickers[tickerId]
	if ticker then
		self.activeTickers[tickerId] = nil
		ticker:Cancel()
	end
end

function Timer:CancelAll()
	for id, ticker in pairs(self.activeTickers) do
		ticker:Cancel()
	end
	self.activeTickers = {}
end

local Combat = GQol.Combat
Combat.pendingFunctions = {}
AceEvent:Embed(Combat)

function Combat:RunWhenOut(func)
	if not InCombatLockdown() then
		func()
		return
	end

	table.insert(self.pendingFunctions, func)
	if self.combatEndRegistered then
		return
	end

	self.combatEndRegistered = true
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnded")
end

function Combat:OnCombatEnded()
	local pending = self.pendingFunctions
	self.pendingFunctions = {}
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self.combatEndRegistered = nil
	for i, func in ipairs(pending) do
		func()
	end
end

local Utils = GQol.Utils
Utils.addonPrefix = "|cFF33FF99GQol:|r "

function Utils:IsEmpty(t)
	return not t or not next(t)
end

function Utils:SafeTrim(s)
	return s and strtrim(s) or ""
end

function Utils:GetPlayerClassToken()
	return select(2, UnitClass("player"))
end

function Utils:SendMessage(key, ...)
	local L = GQol.L or {}
	local msg = L[key] or key
	local args = { ... }

	local formatted = string.format(msg, unpack(args))
	print(self.addonPrefix .. formatted)
end

function Utils:SendApplyMessage(key, ...)
	if GQol.db.global.general.hideApplyNotice then
		return
	end
	self:SendMessage(key, ...)
end

function Utils:SaveFramePosition(frame, posTable)
	if not frame or not posTable then return end
	local point, _, relativePoint, xOffset, yOffset = frame:GetPoint()
	if point and relativePoint then
		posTable.point = point
		posTable.relativePoint = relativePoint
		posTable.xOffset = xOffset or 0
		posTable.yOffset = yOffset or 0
	end
end

function Utils:RestoreFramePosition(frame, posTable, extraDefaults)
	if not frame or not posTable then return end
	local defaults = extraDefaults or {}
	frame:ClearAllPoints()
	frame:SetScale(posTable.frameScale or defaults.frameScale or 1.0)
	frame:SetPoint(
		posTable.point or defaults.point or "CENTER",
		UIParent,
		posTable.relativePoint or defaults.relativePoint or "CENTER",
		posTable.xOffset or defaults.xOffset or 0,
		posTable.yOffset or defaults.yOffset or 0
	)
end

function Utils:GetNestedValue(root, path)
	if not path then return nil end
	local parts = { strsplit(".", path) }
	local current = root
	for _, part in ipairs(parts) do
		if current == nil then return nil end
		current = current[part]
	end
	return current
end

function Utils:SetNestedValue(root, path, value)
	if not path then return end
	local parts = { strsplit(".", path) }
	local current = root
	for i = 1, #parts - 1 do
		local part = parts[i]
		if current[part] == nil then
			current[part] = {}
		end
		current = current[part]
	end
	current[parts[#parts]] = value
end

function Utils:SetupTooltip(frame, getText, anchor)
	anchor = anchor or "ANCHOR_BOTTOM"
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, anchor)
		local text = type(getText) == "function" and getText(self) or getText
		if type(text) == "table" then
			for _, line in ipairs(text) do
				GameTooltip:AddLine(line[1], line[2], line[3], line[4])
			end
		else
			GameTooltip:SetText(text)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function Utils:IsInPetBattle()
	return C_PetBattles and C_PetBattles.IsInBattle()
end

function Utils:GetNumericCVar(name)
	return tonumber(GetCVar(name)) or 0
end

function Utils:FormatTime(seconds, compact)
	if not seconds or seconds <= 0 then return "0s" end
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	if compact then
		local parts = {}
		if h > 0 then table.insert(parts, h .. "h") end
		if m > 0 or h > 0 then table.insert(parts, m .. "m") end
		table.insert(parts, s .. "s")
		return table.concat(parts, " ")
	end
	local L = GQol.L or {}
	if seconds < 60 then return s .. (L["PGH_TIME_SEC"] or "s") end
	if s > 0 then return m .. (L["PGH_TIME_MIN"] or "m") .. s .. (L["PGH_TIME_SEC"] or "s") end
	return m .. (L["PGH_TIME_MINS"] or "m")
end

function Utils:TruncateName(name, n)
	if not name then return "" end
	local result = ""
	local count = 0
	for char in name:gmatch("[^\128-\191][\128-\191]*") do
		result = result .. char
		count = count + 1
		if count >= n then break end
	end
	return result
end

function Utils:ModuleExecute(moduleName, methodName)
	return function()
		local module = GQol.Modules[moduleName]
		if module and module[methodName] then
			module[methodName](module)
		end
	end
end

local ConfigHelpers = {}
Utils.ConfigHelpers = ConfigHelpers

function ConfigHelpers.Header(order, nameKey)
	return {
		type = "header",
		order = order,
		name = L[nameKey] or nameKey
	}
end

function ConfigHelpers.GlobalToggle(order, nameKey, dbKey, onSet, descKey)
	return {
		type = "toggle",
		order = order,
		width = "full",
		name = L[nameKey] or nameKey,
		get = function()
			return Utils:GetNestedValue(GQol.db.global, dbKey)
		end,
		set = function(_, val)
			Utils:SetNestedValue(GQol.db.global, dbKey, val)
			if onSet then onSet(val) end
		end,
		desc = descKey and (L[descKey] or descKey) or nil
	}
end

function ConfigHelpers.ProfileToggle(order, nameKey, dbKey, onSet, descKey)
	return {
		type = "toggle",
		order = order,
		width = "full",
		name = L[nameKey] or nameKey,
		get = function()
			return Utils:GetNestedValue(GQol.db.profile, dbKey)
		end,
		set = function(_, val)
			Utils:SetNestedValue(GQol.db.profile, dbKey, val)
			if onSet then onSet(val) end
		end,
		desc = descKey and (L[descKey] or descKey) or nil
	}
end

function ConfigHelpers.GlobalRange(order, nameKey, dbKey, min, max, step, onSet, descKey)
	return {
		type = "range",
		order = order,
		width = "full",
		name = L[nameKey] or nameKey,
		min = min,
		max = max,
		step = step,
		get = function()
			local val = Utils:GetNestedValue(GQol.db.global, dbKey)
			if val == nil then return min end
			return val
		end,
		set = function(_, val)
			Utils:SetNestedValue(GQol.db.global, dbKey, val)
			if onSet then onSet(val) end
		end,
		desc = descKey and (L[descKey] or descKey) or nil
	}
end

function ConfigHelpers.Execute(order, nameKey, func, descKey, disabled)
	return {
		type = "execute",
		order = order,
		width = "full",
		name = L[nameKey] or nameKey,
		func = func,
		desc = descKey and (L[descKey] or descKey) or nil,
		disabled = disabled
	}
end

function ConfigHelpers.Description(order, text)
	return {
		type = "description",
		order = order,
		width = "full",
		name = text
	}
end

function ConfigHelpers.Color(order, nameKey, dbKey, hasAlpha, defaultColor, onSet)
	return {
		type = "color",
		order = order,
		width = "full",
		name = L[nameKey] or nameKey,
		hasAlpha = hasAlpha or false,
		get = function()
			local c = Utils:GetNestedValue(GQol.db.global, dbKey)
			if not c then
				local src = defaultColor or { r = 1, g = 1, b = 1 }
				c = { r = src.r or 1, g = src.g or 1, b = src.b or 1 }
				if hasAlpha then
					c.a = src.a or 1
				end
				Utils:SetNestedValue(GQol.db.global, dbKey, c)
			end
			if hasAlpha then
				return c.r or 1, c.g or 1, c.b or 1, c.a or 1
			else
				return c.r or 1, c.g or 1, c.b or 1
			end
		end,
		set = function(_, r, g, b, a)
			local c = Utils:GetNestedValue(GQol.db.global, dbKey)
			if not c then
				c = {}
				Utils:SetNestedValue(GQol.db.global, dbKey, c)
			end
			c.r, c.g, c.b = r, g, b
			if hasAlpha and a ~= nil then
				c.a = a
			end
			if onSet then onSet(r, g, b, a) end
		end
	}
end

function ConfigHelpers.GlobalKeybind(order, nameKey, dbKey, onSet, descKey)
	return {
		type = "input",
		order = order,
		width = "full",
		name = L[nameKey] or nameKey,
		get = function()
			return Utils:GetNestedValue(GQol.db.global, dbKey)
		end,
		set = function(_, val)
			Utils:SetNestedValue(GQol.db.global, dbKey, val)
			if onSet then onSet(val) end
		end,
		desc = descKey and (L[descKey] or descKey) or nil
	}
end

function ConfigHelpers.IsHeaderKey(key)
	return key:lower():match("^header")
end

function Utils:NotifyConfigChange()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("GQol")
end

function Utils:ResetPositionDefaults(db, defaults)
	db.point = defaults.point
	db.relativePoint = defaults.relativePoint
	db.xOffset = defaults.xOffset
	db.yOffset = defaults.yOffset
	if defaults.frameScale then
		db.frameScale = defaults.frameScale
	end
end
