local GQol = _G.GQol

local Utils = GQol.Utils
local Constants = GQol.Constants
local L = GQol.L

local ROLE_TANK   = 1
local ROLE_HEALER = 2
local ROLE_DAMAGE = 4

local ROLE_TEX = {
	[ROLE_TANK]   = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0, 19/64, 22/64, 41/64 },
	[ROLE_HEALER] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 20/64, 39/64, 1/64, 20/64 },
	[ROLE_DAMAGE] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 20/64, 39/64, 22/64, 41/64 },
}

local BACKDROP_ROW = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
}

GQol.PremadeGroupHelper = GQol.PremadeGroupHelper or {}
local PGHelper = GQol.PremadeGroupHelper
PGHelper.frame = nil
PGHelper.ticker = nil
PGHelper.title = nil
PGHelper.appliedRoles = {}
PGHelper.state = {
	dungeon = { mapID = nil, name = nil, spellID = nil, isPvP = false, isDungeon = false },
	stats = { applyCount = 0, firstApplyTime = nil, joinedTime = nil, lastPendingCount = 0 },
	flags = { forceShow = false, autoHidden = false },
	lastAnnounceTime = nil,
	lastCooldownText = nil,
}

local LAYOUT = {}
LAYOUT.w = 6
LAYOUT.d = 10
LAYOUT.col1Width = 50
LAYOUT.col2Width = 90
LAYOUT.cancelBtnPadding = 10

LAYOUT.row1left = LAYOUT.w + LAYOUT.d
LAYOUT.row1right = LAYOUT.row1left + LAYOUT.col1Width
LAYOUT.row2left = LAYOUT.row1right + LAYOUT.d
LAYOUT.row2right = LAYOUT.row2left + LAYOUT.col2Width
LAYOUT.roleGroupX = LAYOUT.row2right + LAYOUT.d

LAYOUT.headerY = -28
LAYOUT.rowStartY = -54
LAYOUT.rowSpacing = 24
LAYOUT.rowCount = 5

-- === HELPERS ==============================================================

local function GetPGHDB()
	return GQol.db.global.premadeGroupHelper
end

local function GetFontInfo()
	local fontPath, _ = GameFontNormal:GetFont()
	return fontPath, GetPGHDB().fontSize
end

local function SetFont(widget, sizeOverride)
	if not widget then return end
	local fontPath, fontSize = GetFontInfo()
	widget:SetFont(fontPath, sizeOverride or fontSize, "")
end

local function GetSpellStatus(spellID)
	if not spellID then return "unknown", nil end
	if not C_SpellBook.IsSpellKnown(spellID) then return "notKnown", nil end
	local cd = C_Spell.GetSpellCooldown(spellID)
	if cd and cd.duration and cd.duration > 0 then
		local remaining = cd.startTime + cd.duration - GetTime()
		if remaining > 3 then return "onCooldown", remaining end
	end
	return "available", nil
end

local function EnsureTicker()
	if PGHelper.ticker then return end
	PGHelper.ticker = GQol.Timer:NewTicker(0.5, function()
		PGHelper.RefreshFrame()
	end)
end

local function ClearRowWidgets(rowData)
	if rowData.col1 then rowData.col1:SetText("") end
	if rowData.col2 then rowData.col2:SetText("") end
	if rowData.roleGroup then rowData.roleGroup:Hide() end
	if rowData.cancelBtn then rowData.cancelBtn:Hide() end
	rowData.frame:Hide()
end

local function ResetAllState()
	PGHelper.state.dungeon.mapID = nil
	PGHelper.state.dungeon.name = nil
	PGHelper.state.dungeon.spellID = nil
	PGHelper.state.dungeon.isDungeon = false
	PGHelper.state.dungeon.isPvP = false
	PGHelper.state.stats.applyCount = 0
	PGHelper.state.stats.firstApplyTime = nil
	PGHelper.state.stats.joinedTime = nil
	PGHelper.state.stats.lastPendingCount = 0
	PGHelper.state.flags.forceShow = false
	PGHelper.state.flags.autoHidden = false
	PGHelper.state.lastAnnounceTime = nil
	PGHelper.state.lastCooldownText = nil
	PGHelper.appliedRoles = {}
end

local function ResetStats()
	PGHelper.state.stats.applyCount = 0
	PGHelper.state.stats.firstApplyTime = nil
	PGHelper.state.stats.joinedTime = nil
	PGHelper.state.stats.lastPendingCount = 0
end

local function ResetDungeonState()
	PGHelper.state.dungeon.mapID = nil
	PGHelper.state.dungeon.name = nil
	PGHelper.state.dungeon.spellID = nil
	PGHelper.state.dungeon.isDungeon = false
	PGHelper.state.dungeon.isPvP = false
	PGHelper.state.lastCooldownText = nil
	PGHelper.state.lastAnnounceTime = nil
end

-- === VISIBILITY COMMAND =====================================================

function PGHelper.HandleVisibilityCommand(cmd)
	if cmd == "show" then
		PGHelper.state.flags.forceShow = true
		PGHelper.state.flags.autoHidden = false
		EnsureTicker()
		if PGHelper.frame then
			PGHelper.frame:Show()
			PGHelper.RefreshFrame()
		end
	elseif cmd == "hide" then
		PGHelper.state.flags.forceShow = false
		PGHelper.state.flags.autoHidden = false
		if PGHelper.ticker then
			GQol.Timer:Cancel(PGHelper.ticker)
			PGHelper.ticker = nil
		end
		if PGHelper.frame then PGHelper.frame:Hide() end
	end
end

-- === ACTIVITY INFO ========================================================

local function GetActivityInfoForID(activityID)
	if not activityID then return nil end
	local info = C_LFGList.GetActivityInfoTable(activityID)
	if not info then return nil end
	info._fullName = C_LFGList.GetActivityFullName(activityID) or info.fullName or ""
	return info
end

local function UpdateInfoByActivityID(activityID)
	if not activityID then return false end

	local info = GetActivityInfoForID(activityID)
	if not info then return false end

	PGHelper.state.dungeon.isPvP = info.isPvP or false
	PGHelper.state.dungeon.isDungeon = false

	if PGHelper.state.dungeon.isPvP then return false end

	if info.mapID and Constants.INSTANCE_PORTAL_SPELLS[info.mapID] then
		local spellID = Constants.INSTANCE_PORTAL_SPELLS[info.mapID]
		if type(spellID) == "function" then
			spellID = spellID()
		end
		PGHelper.state.dungeon.isDungeon = true
		PGHelper.state.dungeon.mapID = info.mapID
		PGHelper.state.dungeon.name = info._fullName
		PGHelper.state.dungeon.spellID = spellID
		return true
	end

	return false
end

-- === TELEPORT VIEW ========================================================

local function BuildTeleportView()
	if PGHelper.teleportBtn then return end

	PGHelper.teleportBtn = CreateFrame("Button", nil, PGHelper.frame, "SecureActionButtonTemplate")
	PGHelper.teleportBtn:SetPoint("TOPLEFT", 6, LAYOUT.headerY)
	PGHelper.teleportBtn:SetPoint("TOPRIGHT", -6, LAYOUT.headerY)
	PGHelper.teleportBtn:SetHeight(24)
	PGHelper.teleportBtn:SetAttribute("type", "spell")
	PGHelper.teleportBtn:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
	PGHelper.teleportBtn:Hide()

	local bg = PGHelper.teleportBtn:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0.1, 0.2, 0.1, 0.8)

	PGHelper.teleportText = PGHelper.teleportBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	PGHelper.teleportText:SetPoint("CENTER")
	PGHelper.teleportText:SetJustifyH("CENTER")
	PGHelper.teleportText:SetJustifyV("MIDDLE")
	PGHelper.teleportText:SetTextColor(1, 1, 1, 1)
	SetFont(PGHelper.teleportText)
end

local function UpdateTeleportState()
	if not PGHelper.teleportText then return end
	local status, remaining = GetSpellStatus(PGHelper.state.dungeon.spellID)

	if status == "available" then
		PGHelper.teleportText:SetText(L["PGH_TELEPORT_TO"] .. (PGHelper.state.dungeon.name or ""))
		PGHelper.teleportBtn:Enable()
		PGHelper.state.lastCooldownText = nil
	elseif status == "onCooldown" then
		local text = string.format(L["PGH_COOLDOWN_REMAINING"], Utils:FormatTime(remaining, true))
		if text ~= PGHelper.state.lastCooldownText then
			PGHelper.teleportText:SetText(text)
			PGHelper.state.lastCooldownText = text
		end
		PGHelper.teleportBtn:Disable()
	elseif status == "notKnown" then
		PGHelper.teleportText:SetText(L["PGH_TELEPORT_NOT_LEARNED"])
		PGHelper.teleportBtn:Disable()
		PGHelper.state.lastCooldownText = nil
	else
		PGHelper.teleportText:SetText("")
		PGHelper.teleportBtn:Disable()
	end
end

local function BuildStatsFrame()
	if PGHelper.statsFrame then return end

	PGHelper.statsFrame = CreateFrame("Frame", nil, PGHelper.frame, "BackdropTemplate")
	PGHelper.statsFrame:SetPoint("TOPLEFT", 6, LAYOUT.rowStartY)
	PGHelper.statsFrame:SetPoint("TOPRIGHT", -6, LAYOUT.rowStartY)
	PGHelper.statsFrame:SetHeight(LAYOUT.rowSpacing * LAYOUT.rowCount)
	PGHelper.statsFrame:SetBackdrop(BACKDROP_ROW)
	PGHelper.statsFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.4)
	PGHelper.statsFrame:Hide()

	PGHelper.statsLines = {}
	for i = 1, 3 do
		local fs = PGHelper.statsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		fs:SetPoint("TOPLEFT", 6, -4 - ((i - 1) * 22))
		fs:SetPoint("TOPRIGHT", -6, -4 - ((i - 1) * 22))
		fs:SetHeight(20)
		SetFont(fs)
		fs:SetJustifyH("CENTER")
		fs:SetJustifyV("MIDDLE")
		PGHelper.statsLines[i] = fs
	end
end

local function ShowStats(pendingCount)
	if not PGHelper.statsFrame then return end
	if pendingCount and pendingCount > 0 then
		PGHelper.statsFrame:Hide()
		return
	end
	if not PGHelper.state.stats.firstApplyTime or not PGHelper.state.stats.joinedTime then
		PGHelper.statsFrame:Hide()
		return
	end
	local duration = PGHelper.state.stats.joinedTime - PGHelper.state.stats.firstApplyTime
	PGHelper.statsLines[1]:SetText(L["PGH_FIRST_APPLY"])
	PGHelper.statsLines[2]:SetText(string.format(L["PGH_TIME_SPENT"], Utils:FormatTime(duration, false)))
	PGHelper.statsLines[3]:SetText(string.format(L["PGH_APPLY_COUNT"], PGHelper.state.stats.applyCount))
	PGHelper.statsFrame:Show()
end

-- === APPLICATION VIEW =====================================================

local function GetMemberCounts(appID)
	local counts = C_LFGList.GetSearchResultMemberCounts(appID)
	if not counts then return 0, 0, 0 end
	return counts.TANK or 0, counts.HEALER or 0, counts.DAMAGER or 0
end

local function GetPlayerSpecializationRole()
	local specIndex = GetSpecialization()
	if not specIndex then return nil end
	local role = GetSpecializationRole(specIndex)
	if role == "TANK" then return ROLE_TANK end
	if role == "HEALER" then return ROLE_HEALER end
	if role == "DAMAGER" then return ROLE_DAMAGE end
	return nil
end

local function IsApplicationPending(appID)
	local _, status = C_LFGList.GetApplicationInfo(appID)
	return status == "applied"
end

local function GetAppRowLabels(searchInfo)
	local listingTitle = searchInfo and searchInfo.name or "???"
	if not searchInfo or not searchInfo.activityIDs or not searchInfo.activityIDs[1] then
		return listingTitle, "???"
	end
	local info = GetActivityInfoForID(searchInfo.activityIDs[1])
	if not info then return listingTitle, "???" end
	local fullName = info._fullName or listingTitle
	fullName = fullName:gsub("（史诗钥石）", "")
	fullName = fullName:gsub("史诗钥石", "")
	return listingTitle, Utils:TruncateName(fullName, 5)
end

local function FillAppRow(rowData, appID, searchInfo, listingTitle, activityName)
	local partyGUID = searchInfo and searchInfo.partyGUID
	local roleData = partyGUID and PGHelper.appliedRoles[partyGUID]
	
	rowData.frame:Show()

	if not rowData.col1 then
		rowData.col1 = rowData.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		rowData.col1:SetPoint("LEFT", rowData.frame, "LEFT", LAYOUT.row1left, 0)
		rowData.col1:SetWidth(LAYOUT.col1Width)
		rowData.col1:SetJustifyH("CENTER")
		rowData.col1:SetJustifyV("MIDDLE")
		rowData.col1:SetHeight(22)
	end
	SetFont(rowData.col1)
	rowData.col1:SetText(activityName or "???")

	if not rowData.col2 then
		rowData.col2 = rowData.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		rowData.col2:SetPoint("LEFT", rowData.frame, "LEFT", LAYOUT.row2left, 0)
		rowData.col2:SetWidth(LAYOUT.col2Width)
		rowData.col2:SetJustifyH("CENTER")
		rowData.col2:SetJustifyV("MIDDLE")
		rowData.col2:SetHeight(22)
	end
	SetFont(rowData.col2)
	rowData.col2:SetText(listingTitle or "???")

	local tankCount, healerCount, damageCount = GetMemberCounts(appID)
	local rolesToShow = {}

	-- 【优先级1】有手动选择记录 → 100%用窗口勾选的职责
	if roleData and roleData.isManualSelect then
		if roleData[ROLE_TANK] then
			table.insert(rolesToShow, { ROLE_TANK, tankCount })
		end
		if roleData[ROLE_HEALER] then
			table.insert(rolesToShow, { ROLE_HEALER, healerCount })
		end
		if roleData[ROLE_DAMAGE] then
			table.insert(rolesToShow, { ROLE_DAMAGE, damageCount })
		end
	end

	-- 【优先级2】没有手动记录 → 判定为双击快速申请 → 用当前专精
	if #rolesToShow == 0 then
		local specRole = GetPlayerSpecializationRole()
		if specRole == ROLE_TANK then
			table.insert(rolesToShow, { ROLE_TANK, tankCount })
		elseif specRole == ROLE_HEALER then
			table.insert(rolesToShow, { ROLE_HEALER, healerCount })
		else
			table.insert(rolesToShow, { ROLE_DAMAGE, damageCount })
		end
	end

	if not rowData.roleGroup then
		rowData.roleGroup = CreateFrame("Frame", nil, rowData.frame)
		rowData.roleGroup:SetPoint("LEFT", rowData.frame, "LEFT", LAYOUT.roleGroupX, 0)
		rowData.roleGroup:SetPoint("CENTER", rowData.frame, "CENTER", 0, 0)
		rowData.roleGroup:SetHeight(18)
		rowData.roleIcons = {}
	end
	rowData.roleGroup:Show()

	for _, data in ipairs(rowData.roleIcons) do
		data.icon:Hide()
		data.text:Hide()
	end

	local xOffset = 0
	for idx, entry in ipairs(rolesToShow) do
		local roleEnum, count = entry[1], entry[2]
		local texData = ROLE_TEX[roleEnum]
		local iconData = rowData.roleIcons[idx]
		if not iconData then
			local icon = rowData.roleGroup:CreateTexture(nil, "OVERLAY")
			icon:SetSize(14, 14)
			local countText = rowData.roleGroup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			SetFont(countText)
			iconData = { icon = icon, text = countText }
			rowData.roleIcons[idx] = iconData
		end
		local icon = iconData.icon
		local countText = iconData.text
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", rowData.roleGroup, "LEFT", xOffset, 0)
		icon:SetTexture(texData[1])
		icon:SetTexCoord(texData[2], texData[3], texData[4], texData[5])
		icon:Show()
		countText:ClearAllPoints()
		countText:SetPoint("LEFT", icon, "RIGHT", 1, 0)
		countText:SetText(tostring(count))
		countText:Show()
		xOffset = xOffset + 14 + countText:GetStringWidth() + 4
	end

	if not rowData.cancelBtn then
		rowData.cancelBtn = CreateFrame("Button", nil, rowData.frame)
		rowData.cancelBtn:SetSize(30, 20)
		rowData.cancelBtn:SetPoint("RIGHT", rowData.frame, "RIGHT", -LAYOUT.cancelBtnPadding, 0)
		local cancelText = rowData.cancelBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		cancelText:SetAllPoints()
		SetFont(cancelText)
		cancelText:SetText(L["PGH_CANCEL"])
		cancelText:SetTextColor(1, 1, 1, 1)
		cancelText:SetJustifyH("CENTER")
		cancelText:SetJustifyV("MIDDLE")
		rowData.cancelBtn:SetScript("OnClick", function(self)
			C_LFGList.CancelApplication(self.appID)
		end)
	end
	rowData.cancelBtn.appID = appID
	rowData.cancelBtn:Show()
end

local function BuildAppRows()
	if PGHelper.appRows then return end

	PGHelper.appHeader = PGHelper.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	PGHelper.appHeader:SetPoint("TOPLEFT", 6, LAYOUT.headerY)
	PGHelper.appHeader:SetPoint("TOPRIGHT", -6, LAYOUT.headerY)
	PGHelper.appHeader:SetHeight(22)
	SetFont(PGHelper.appHeader)
	PGHelper.appHeader:SetJustifyH("CENTER")
	PGHelper.appHeader:SetTextColor(1, 0.82, 0, 1)
	PGHelper.appHeader:SetText("")

	PGHelper.appRows = {}
	for i = 1, LAYOUT.rowCount do
		local y = LAYOUT.rowStartY - ((i - 1) * LAYOUT.rowSpacing)
		local f = CreateFrame("Frame", nil, PGHelper.frame, "BackdropTemplate")
		f:SetPoint("TOPLEFT", 6, y)
		f:SetPoint("TOPRIGHT", -6, y)
		f:SetHeight(22)
		f:SetBackdrop(BACKDROP_ROW)
		if i % 2 == 0 then
			f:SetBackdropColor(0.12, 0.12, 0.12, 0.6)
		else
			f:SetBackdropColor(0.08, 0.08, 0.08, 0.4)
		end
		f:Hide()
		PGHelper.appRows[i] = { frame = f }
	end
end

local function GetAppliedRoleCount(appID)
	local searchInfo = C_LFGList.GetSearchResultInfo(appID)
	local partyGUID = searchInfo and searchInfo.partyGUID
	local roleData = partyGUID and PGHelper.appliedRoles[partyGUID]
	local tankCount, healerCount, damageCount = GetMemberCounts(appID)
	
	-- 有手动记录 → 用记录的职责排序
	if roleData and roleData.isManualSelect then
		if roleData[ROLE_DAMAGE] then return damageCount end
		if roleData[ROLE_HEALER] then return healerCount end
		if roleData[ROLE_TANK] then return tankCount end
	end
	
	-- 没有记录 → 用当前专精排序
	local specRole = GetPlayerSpecializationRole()
	if specRole == ROLE_TANK then return tankCount end
	if specRole == ROLE_HEALER then return healerCount end
	return damageCount
end

local function BuildPendingAppList()
	local pendingApps = {}
	local applications = C_LFGList.GetApplications()
	if not applications then return pendingApps end

	local activeGUIDs = {}
	for _, appID in ipairs(applications) do
		if IsApplicationPending(appID) then
			local searchInfo = C_LFGList.GetSearchResultInfo(appID)
			if searchInfo and not searchInfo.isDelisted then
				local listingTitle, activityName = GetAppRowLabels(searchInfo)
				local partyGUID = searchInfo.partyGUID
				local roleData = partyGUID and PGHelper.appliedRoles[partyGUID]
				if partyGUID then activeGUIDs[partyGUID] = true end
				table.insert(pendingApps, {
					id = appID,
					info = searchInfo,
					listingTitle = listingTitle,
					activityName = activityName,
					roleCount = GetAppliedRoleCount(appID),
					applyTime = roleData and roleData.applyTime or math.huge,
				})
			end
		end
	end

	for guid in pairs(PGHelper.appliedRoles) do
		if not activeGUIDs[guid] then
			PGHelper.appliedRoles[guid] = nil
		end
	end

	table.sort(pendingApps, function(a, b)
		if a.roleCount ~= b.roleCount then
			return a.roleCount > b.roleCount
		end
		return a.applyTime < b.applyTime
	end)

	return pendingApps
end

-- === MAIN REFRESH =========================================================

function PGHelper.RefreshFrame()
	if InCombatLockdown() then return end

	EnsureTicker()

	local db = GetPGHDB()
	if not db.enabled then
		if PGHelper.frame then PGHelper.frame:Hide() end
		return
	end

	local activeEntry = C_LFGList.GetActiveEntryInfo()
	if activeEntry and activeEntry.activityIDs and activeEntry.activityIDs[1] then
		UpdateInfoByActivityID(activeEntry.activityIDs[1])
	end

	local isInGroup = IsInGroup()
	local hasTeleport = not PGHelper.state.dungeon.isPvP and PGHelper.state.dungeon.isDungeon and PGHelper.state.dungeon.spellID
	local showTeleport = (isInGroup or activeEntry) and hasTeleport

	local pendingApps = BuildPendingAppList()
	local pendingCount = #pendingApps

	if showTeleport then
		PGHelper.appHeader:Hide()
		PGHelper.teleportBtn:Show()
		PGHelper.teleportBtn:SetAttribute("spell", PGHelper.state.dungeon.spellID)
		UpdateTeleportState()
	else
		PGHelper.teleportBtn:Hide()
		PGHelper.appHeader:Show()
		PGHelper.appHeader:SetText(string.format(L["PGH_APP_COUNT"], pendingCount))
	end

	for i = 1, LAYOUT.rowCount do
		local row = PGHelper.appRows[i]
		if i <= pendingCount then
			local app = pendingApps[i]
			FillAppRow(row, app.id, app.info, app.listingTitle, app.activityName)
		else
			ClearRowWidgets(row)
		end
	end

	ShowStats(pendingCount)

	local hasStats = PGHelper.statsFrame and PGHelper.statsFrame:IsShown()
	if pendingCount > 0 or showTeleport then
		if pendingCount > 0 or hasStats then
			PGHelper.frame:SetHeight(db.height)
		else
			PGHelper.frame:SetHeight(70)
		end
		PGHelper.frame:Show()
	else
		PGHelper.frame:Hide()
	end
end

-- === POSITION / FONT / SCALE ==============================================

local function ApplyFontSize()
	local fontPath, fontSize = GetFontInfo()

	SetFont(PGHelper.teleportText)
	SetFont(PGHelper.appHeader)
	SetFont(PGHelper.title, 14)

	if PGHelper.statsLines then
		for _, fs in ipairs(PGHelper.statsLines) do
			SetFont(fs)
		end
	end
	if PGHelper.appRows then
		for _, rowData in ipairs(PGHelper.appRows) do
			SetFont(rowData.col1)
			SetFont(rowData.col2)
			if rowData.roleIcons then
				for _, data in ipairs(rowData.roleIcons) do
					SetFont(data.text)
				end
			end
			if rowData.cancelBtn then
				local fs = rowData.cancelBtn:GetFontString()
				SetFont(fs)
			end
		end
	end
end

local function SavePosition()
	if not PGHelper.frame then return end
	Utils:SaveFramePosition(PGHelper.frame, GetPGHDB())
end

local function RestorePosition()
	if not PGHelper.frame then return end
	Utils:RestoreFramePosition(PGHelper.frame, GetPGHDB())
end

function PGHelper:RefreshAll()
	RestorePosition()
	ApplyFontSize()
	PGHelper.RefreshFrame()
end

function PGHelper:ResetPosition()
	local defaults = GQol.Config.Defaults.global.premadeGroupHelper
	local db = GetPGHDB()
	Utils:ResetPositionDefaults(db, defaults)
	self:RefreshAll()
	Utils:SendApplyMessage("PGH_POSITION_RESET")
end

function PGHelper:SetFontSize(val)
	GetPGHDB().fontSize = val
	ApplyFontSize()
end

function PGHelper:SetFrameScale(val)
	GetPGHDB().frameScale = val
	RestorePosition()
end

-- === EVENTS ===============================================================

function PGHelper:RegisterEvents()
	if self.eventsRegistered then return end
	self.eventsRegistered = true

	self:RegisterEvent("LFG_LIST_JOINED_GROUP", function(_, searchResultID)
		PGHelper.state.stats.joinedTime = GetTime()
		if searchResultID then
			local data = C_LFGList.GetSearchResultInfo(searchResultID)
			if data and data.activityIDs and data.activityIDs[1] then
				UpdateInfoByActivityID(data.activityIDs[1])
			end
		end
		PGHelper.RefreshFrame()
	end)

	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE", function()
		PGHelper.RefreshFrame()
	end)

	self:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED", function()
		local apps = C_LFGList.GetApplications()
		local pendingCount = 0
		if apps then
			for _, appID in ipairs(apps) do
				if IsApplicationPending(appID) then
					pendingCount = pendingCount + 1
				end
			end
		end
		local prev = PGHelper.state.stats.lastPendingCount
		if pendingCount > prev then
			PGHelper.state.stats.applyCount = PGHelper.state.stats.applyCount + (pendingCount - prev)
			if not PGHelper.state.stats.firstApplyTime then
				PGHelper.state.stats.firstApplyTime = GetTime()
			end
		end
		PGHelper.state.stats.lastPendingCount = pendingCount
		PGHelper.RefreshFrame()
	end)

	self:RegisterEvent("GROUP_LEFT", function()
		if PGHelper.state.stats.joinedTime and not IsInGroup() then
			ResetStats()
		end
		PGHelper.RefreshFrame()
	end)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		PGHelper.RefreshFrame()
	end)

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
		PGHelper.RefreshFrame()
	end)

	self:RegisterEvent("CHALLENGE_MODE_START", function()
		ResetDungeonState()
		ResetStats()
		PGHelper.frame:Hide()
	end)

	self:RegisterEvent("UNIT_SPELLCAST_START", function(_, unit, _, spellID)
		if unit == "player" and PGHelper.state.dungeon.mapID and spellID == PGHelper.state.dungeon.spellID and IsInGroup() then
			local now = GetTime()
			if not PGHelper.state.lastAnnounceTime or (now - PGHelper.state.lastAnnounceTime) > 2 then
				PGHelper.state.lastAnnounceTime = now
				local announce = string.format(L["PGH_TELEPORT_ANNOUNCE"], PGHelper.state.dungeon.name or "")
				SendChatMessage(announce, IsInRaid() and "RAID" or "PARTY")
			end
		end
	end)

	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
		if unit == "player" and PGHelper.state.dungeon.mapID and spellID == PGHelper.state.dungeon.spellID then
			ResetDungeonState()
			ResetStats()
			PGHelper.RefreshFrame()
		end
	end)

	self:RegisterEvent("CHAT_MSG_SYSTEM", function(_, text)
        if text:find("已被替换为") and text:find("史诗钥石") then
            local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
            local level = C_MythicPlus.GetOwnedKeystoneLevel()
            if mapID and level then
                local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
                if mapName then
                    UpdateKeystoneText(string.format("%s层：%s", level, mapName))
                end
            end
        end
    end)

end

-- === KEYSTONE DISPLAY =====================================================

local function ScanBagForKeystone()
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local level = C_MythicPlus.GetOwnedKeystoneLevel()
    if mapID and level then
        local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
        if mapName then
            return string.format("%s层：%s", level, mapName)
        end
    end
    return nil
end

local function CreateKeystoneFrame()
	if PGHelper.keystoneFrame then return end

	PGHelper.keystoneFrame = CreateFrame("Frame", "GQol_KeystoneDisplay", UIParent, "BackdropTemplate")
	PGHelper.keystoneFrame:SetSize(160, 60)
	PGHelper.keystoneFrame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	PGHelper.keystoneFrame:SetBackdropColor(0, 0, 0, 0.8)
	PGHelper.keystoneFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
	PGHelper.keystoneFrame:Hide()

	PGHelper.keystoneTitle = PGHelper.keystoneFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	PGHelper.keystoneTitle:SetPoint("TOP", 0, -8)
	PGHelper.keystoneTitle:SetText(L["PGH_KEYSTONE_TITLE"])

	PGHelper.keystoneText = PGHelper.keystoneFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	PGHelper.keystoneText:SetPoint("BOTTOM", 0, 10)
	PGHelper.keystoneText:SetText(L["PGH_KEYSTONE_READING"])
end

local KEYSTONE_ANCHOR_FRAMES = {
    "PVEFrame",
    "GroupFinderFrame",
}

local function GetVisibleAnchorFrame()
    for _, name in ipairs(KEYSTONE_ANCHOR_FRAMES) do
        local f = _G[name]
        if f and f:IsShown() then
            return f
        end
    end
    return nil
end

local function AnchorKeystoneFrame()
    if not PGHelper.keystoneFrame then return end

    local db = GetPGHDB()
    if not db.keystoneEnabled then
        PGHelper.keystoneFrame:Hide()
        return
    end

    local anchor = GetVisibleAnchorFrame()
    if anchor then
        PGHelper.keystoneFrame:SetParent(anchor)
        PGHelper.keystoneFrame:ClearAllPoints()
        PGHelper.keystoneFrame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 5, -20)
        PGHelper.keystoneFrame:Show()
    else
        PGHelper.keystoneFrame:Hide()
    end
end

local function UpdateKeystoneText(text)
	if not PGHelper.keystoneText then return end
	PGHelper.keystoneText:SetText(text or L["PGH_KEYSTONE_NONE"])
end

local function RefreshKeystoneDisplay()
    local text = ScanBagForKeystone()
    UpdateKeystoneText(text)
    AnchorKeystoneFrame()
end

local function HookKeystoneAnchors()
    if PGHelper.keystoneHooksInstalled then return end
    PGHelper.keystoneHooksInstalled = true

    for _, name in ipairs(KEYSTONE_ANCHOR_FRAMES) do
        local f = _G[name]
        if f then
            f:HookScript("OnShow", function()
                RefreshKeystoneDisplay()
            end)
            f:HookScript("OnHide", function()
                if PGHelper.keystoneFrame then PGHelper.keystoneFrame:Hide() end
            end)
        end
    end
end

-- === MODULE LIFECYCLE =====================================================

function PGHelper:OnInitialize()
	if self.frame then return end

	-- ==============================================
	-- 核心Hook：100%准确抓取职责窗口勾选
	-- ==============================================
	local function HookApplicationDialog()
		if not LFGListApplicationDialog then return end
		if LFGListApplicationDialog.GQolHooked then return end

		local originalSignUpClick = LFGListApplicationDialog.SignUpButton:GetScript("OnClick")

		LFGListApplicationDialog.SignUpButton:SetScript("OnClick", function(self, button, ...)
			local dialog = LFGListApplicationDialog
			local resultID = dialog.resultID

			local tankChecked = dialog.TankButton:IsShown() and dialog.TankButton.CheckButton:GetChecked()
			local healerChecked = dialog.HealerButton:IsShown() and dialog.HealerButton.CheckButton:GetChecked()
			local damageChecked = dialog.DamagerButton:IsShown() and dialog.DamagerButton.CheckButton:GetChecked()

			local searchInfo = resultID and C_LFGList.GetSearchResultInfo(resultID)
			local partyGUID = searchInfo and searchInfo.partyGUID

			if partyGUID then
				PGHelper.appliedRoles[partyGUID] = {
					[ROLE_TANK] = tankChecked or false,
					[ROLE_HEALER] = healerChecked or false,
					[ROLE_DAMAGE] = damageChecked or false,
					applyTime = GetTime(),
					isManualSelect = true,
				}
			end

			if originalSignUpClick then
				originalSignUpClick(self, button, ...)
			end
		end)

		LFGListApplicationDialog.GQolHooked = true
	end

	-- ==============================================
	-- 自动Hook处理（适配UI延迟加载）
	-- ==============================================
	-- 立即尝试Hook（如果UI已经加载）
	HookApplicationDialog()
	
	-- 如果UI还没加载，等加载完成后再Hook
	if not LFGListApplicationDialog then
		local loadFrame = CreateFrame("Frame")
		loadFrame:RegisterEvent("ADDON_LOADED")
		loadFrame:SetScript("OnEvent", function(self, _, addonName)
			if addonName == "Blizzard_LookingForGroupUI" then
				HookApplicationDialog()
				self:UnregisterEvent("ADDON_LOADED")
			end
		end)
	end

	-- ==============================================
	-- 以下是你原有的UI创建代码，完全不动
	-- ==============================================
	local db = GetPGHDB()

	self.frame = CreateFrame("Frame", "GQol_PGH", UIParent, "BackdropTemplate")
	self.frame:SetSize(db.width, db.height)
	self.frame:SetMovable(true)
	self.frame:EnableMouse(true)
	self.frame:SetClampedToScreen(true)
	self.frame:SetFrameStrata("MEDIUM")
	self.frame:SetFrameLevel(100)
	self.frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	self.frame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
	self.frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

	self.title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.title:SetPoint("TOPLEFT", 4, -3)
	self.title:SetPoint("TOPRIGHT", -20, -3)
	self.title:SetHeight(18)
	SetFont(self.title, 14)
	self.title:SetJustifyH("CENTER")
	self.title:SetTextColor(1, 0.82, 0, 1)
	self.title:SetText(L["PGH_TITLE"])

	self.closeBtn = CreateFrame("Button", nil, self.frame)
	self.closeBtn:SetSize(20, 20)
	self.closeBtn:SetPoint("TOPRIGHT", -4, -4)
	local closeText = self.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	closeText:SetAllPoints()
	SetFont(closeText, 14)
	closeText:SetText("X")
	closeText:SetTextColor(1, 1, 1, 1)
	closeText:SetJustifyH("CENTER")
	closeText:SetJustifyV("MIDDLE")
	self.closeBtn:SetScript("OnClick", function()
		PGHelper.state.flags.forceShow = false
		PGHelper.state.flags.autoHidden = false
		if PGHelper.ticker then
			GQol.Timer:Cancel(PGHelper.ticker)
			PGHelper.ticker = nil
		end
		PGHelper.frame:Hide()
	end)

	self.frame:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then
			self.frame:StartMoving()
		end
	end)
	self.frame:SetScript("OnMouseUp", function()
		self.frame:StopMovingOrSizing()
		SavePosition()
	end)

	BuildAppRows()
	BuildTeleportView()
	BuildStatsFrame()
	CreateKeystoneFrame()
	HookKeystoneAnchors()

	EnsureTicker()
	self:RefreshAll()
end

local function _EnableSelf(self)
	if not self.frame then self:OnInitialize() end
	self:RegisterEvents()
	EnsureTicker()
	self:RefreshAll()
	RefreshKeystoneDisplay()
end

local function _DisableSelf(self)
	self:UnregisterAllEvents()
	self.eventsRegistered = nil
	if PGHelper.ticker then
		GQol.Timer:Cancel(PGHelper.ticker)
		PGHelper.ticker = nil
	end
	ResetAllState()
	if self.frame then self.frame:Hide() end
	if PGHelper.keystoneFrame then PGHelper.keystoneFrame:Hide() end
end

function PGHelper:OnEnable()
	_EnableSelf(self)
end

function PGHelper:OnDisable()
	_DisableSelf(self)
end

function PGHelper:SetEnabled(val)
	GetPGHDB().enabled = val
	if val then
		_EnableSelf(self)
	else
		_DisableSelf(self)
	end
end

function PGHelper:SetKeystoneEnabled(val)
	GetPGHDB().keystoneEnabled = val
	if val then
		RefreshKeystoneDisplay()
	elseif PGHelper.keystoneFrame then
		PGHelper.keystoneFrame:Hide()
	end
end

function PGHelper:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(121, "PGH_ENABLE_CBOX", "premadeGroupHelper.enabled", function(val)
			self:SetEnabled(val)
		end),
		keystoneEnabled = CH.GlobalToggle(121.5, "PGH_KEYSTONE_ENABLE_CBOX", "premadeGroupHelper.keystoneEnabled", function(val)
			self:SetKeystoneEnabled(val)
		end),
		fontSize = CH.GlobalRange(122, "PGH_FONT_SIZE_SLIDER", "premadeGroupHelper.fontSize", 10, 32, 1, function(val)
			self:SetFontSize(val)
		end),
		frameScale = CH.GlobalRange(123, "PGH_FRAME_SCALE_SLIDER", "premadeGroupHelper.frameScale", 0.5, 3.0, 0.1, function(val)
			self:SetFrameScale(val)
		end),
		resetPosition = CH.Execute(124, "PGH_RESET_POSITION_BTN", Utils:ModuleExecute("PremadeGroupHelper", "ResetPosition")),
	}
end
