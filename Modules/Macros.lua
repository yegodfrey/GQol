local GQol = _G.GQol
local Constants, Utils = GQol.Constants, GQol.Utils

GQol.Macros = GQol.Macros or {}
local Macros = GQol.Macros

-- 遍历宏
local function IterateMacros(start, endIdx, callback)
	if not callback then return end
	for i = start, endIdx do
		local name, icon, body = GetMacroInfo(i)
		if name and name ~= "" then
			callback(i, name, icon, body)
		end
	end
end

-- 保存宏
local function SaveMacros(typeKey, saved, start, endIdx)
	wipe(saved)
	local unique = {}
	local count = 0

	IterateMacros(start, endIdx, function(_, name, icon, body)
		local clean = Utils:SafeTrim(body)
		local key = name .. "|" .. clean
		if not unique[key] then
			unique[key] = true
			tinsert(saved, {
				name = name,
				body = clean,
				icon = (icon ~= Constants.QUESTION_ICON) and icon or nil
			})
			count = count + 1
		end
	end)

	Utils:SendMessage(typeKey == "ACCOUNT" and "MACRO_ACCOUNT_SAVED" or "MACRO_CLASS_SAVED", count)
end

-- 应用宏
local function ApplyMacros(typeKey, saved, start, endIdx, isChar)
	if not saved or Utils:IsEmpty(saved) then
		Utils:SendApplyMessage(typeKey == "ACCOUNT" and "MACRO_ACCOUNT_NO_SETTINGS" or "MACRO_CLASS_NO_SETTINGS")
		return
	end

	-- 去重待应用列表
	local uniqueSaved, list = {}, {}
	for _, m in ipairs(saved) do
		local name, body = m.name, Utils:SafeTrim(m.body or "")
		if name and body ~= "" then
			local key = name .. "|" .. body
			if not uniqueSaved[key] then
				uniqueSaved[key] = true
				tinsert(list, { name = name, body = body, icon = m.icon or Constants.QUESTION_ICON })
			end
		end
	end

	-- 统计当前重复宏
	local currentCount = {}
	IterateMacros(start, endIdx, function(_, name, _, body)
		local key = name .. "|" .. Utils:SafeTrim(body)
		currentCount[key] = (currentCount[key] or 0) + 1
	end)

	-- 删除多余宏
	local toDelete = {}
	IterateMacros(start, endIdx, function(idx, name, _, body)
		local key = name .. "|" .. Utils:SafeTrim(body)
		if not uniqueSaved[key] or currentCount[key] > 1 then
			tinsert(toDelete, idx)
			if currentCount[key] then currentCount[key] = currentCount[key] - 1 end
		end
	end)

	-- 倒序删除
	table.sort(toDelete, function(a,b) return a > b end)
	for _, idx in ipairs(toDelete) do DeleteMacro(idx) end

	-- 创建缺失宏
	local current = {}
	IterateMacros(start, endIdx, function(_, name, _, body)
		current[name .. "|" .. Utils:SafeTrim(body)] = true
	end)

	local created = 0
	for _, m in ipairs(list) do
		if not current[m.name .. "|" .. m.body] then
			CreateMacro(m.name, m.icon, m.body, isChar)
			created = created + 1
		end
	end

	Utils:SendApplyMessage(typeKey == "ACCOUNT" and "MACRO_ACCOUNT_APPLIED" or "MACRO_CLASS_APPLIED", created)
end

-- 公开接口
function Macros:SaveAccountMacros()
	local start, endIdx = unpack(Constants.ACC_MACRO_RANGE)
	SaveMacros("ACCOUNT", GQol.db.global.accountMacros, start, endIdx)
end

function Macros:ApplyAccountMacros()
	local start, endIdx = unpack(Constants.ACC_MACRO_RANGE)
	ApplyMacros("ACCOUNT", GQol.db.global.accountMacros, start, endIdx, false)
end

function Macros:SaveClassMacros()
	local class = Utils:GetPlayerClassToken()
	if not class then return end
	local db = GQol.db.global
	db.classMacros = db.classMacros or {}
	db.classMacros[class] = db.classMacros[class] or {}

	local start, endIdx = unpack(Constants.CHAR_MACRO_RANGE)
	SaveMacros("CLASS", db.classMacros[class], start, endIdx)
end

function Macros:ApplyClassMacros()
	local class = Utils:GetPlayerClassToken()
	if not class then
		Utils:SendApplyMessage("MACRO_CLASS_UNAVAILABLE")
		return
	end

	local saved = GQol.db.global.classMacros and GQol.db.global.classMacros[class]
	local start, endIdx = unpack(Constants.CHAR_MACRO_RANGE)
	ApplyMacros("CLASS", saved, start, endIdx, true)
end

-- 宏窗口放大
function Macros:SetupMacroFrameResize()
	if self.resized then return end
	self.resized = true

	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(_, _, name)
		if name ~= "Blizzard_MacroUI" then return end

		MacroFrame:SetSize(535, 600)
		MacroHorizontalBarLeft:SetSize(452, 16)
		MacroHorizontalBarLeft:ClearAllPoints()
		MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -340)
		MacroFrameSelectedMacroBackground:ClearAllPoints()
		MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 5, -348)
		MacroFrame.MacroSelector:SetSize(520, 276)

		hooksecurefunc(MacroFrame, "Update", function(self)
			if not self.updated then
				self.MacroSelector:SetCustomStride(10)
				self.MacroSelector:Init()
				self.updated = true
			end
		end)

		MacroFrameScrollFrame:SetSize(484, 130)
		MacroFrameText:SetSize(484, 85)
		MacroFrameTextBackground:SetSize(520, 140)
		MacroFrameTextBackground:ClearAllPoints()
		MacroFrameTextBackground:SetPoint("TOPLEFT", MacroFrame, 6, -419)

		f:UnregisterEvent("ADDON_LOADED")
	end)
end

function Macros:OnInitialize()
	self:SetupMacroFrameResize()
end

-- 配置面板
function Macros:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		saveAccount = CH.Execute(31, "MACRO_SAVE_ACCOUNT_BTN", Utils:ModuleExecute("Macros", "SaveAccountMacros")),
		applyAccount = CH.Execute(32, "MACRO_APPLY_ACCOUNT_BTN", Utils:ModuleExecute("Macros", "ApplyAccountMacros")),
		saveClass = CH.Execute(33, "MACRO_SAVE_CLASS_BTN", Utils:ModuleExecute("Macros", "SaveClassMacros")),
		applyClass = CH.Execute(34, "MACRO_APPLY_CLASS_BTN", Utils:ModuleExecute("Macros", "ApplyClassMacros")),
		autoApply = CH.ProfileToggle(35, "MACRO_AUTO_APPLY_CBOX", "autoApplyAccountMacrosOnLogin", function(v)
			GQol.db.profile.autoApplyAccountMacrosOnLogin = v
			GQol.db.profile.autoApplyClassMacrosOnLogin = v
		end),
	}
end