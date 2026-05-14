local GQol = _G.GQol

local Utils = GQol.Utils
local Timer = GQol.Timer
local L = GQol.L

GQol.AutoRoll = GQol.AutoRoll or {}
local AutoRoll = GQol.AutoRoll

local ROLL_NEED = 1
local ROLL_GREED = 2
local ROLL_TRANSMOG = 4

local pendingRolls = {}
local autoRollEnabled = false
local hideCheckTimer = nil

local function RemoveWaitingRoll(rollID)
	local waitingRolls = GroupLootContainer.waitingRolls
	if #waitingRolls > 0 then
		for i = #waitingRolls, 1, -1 do
			if waitingRolls[i].rollID == rollID then
				table.remove(waitingRolls, i)
			end
		end
	end
end

local function HandleLootRoll(rollID)
	if not autoRollEnabled then return end

	local canNeed, canGreed, canTransmog = select(6, GetLootRollItemInfo(rollID))

	if canNeed then
		RemoveWaitingRoll(rollID)
		RollOnLoot(rollID, ROLL_NEED)
	elseif canGreed then
		RemoveWaitingRoll(rollID)
		RollOnLoot(rollID, ROLL_GREED)
	elseif canTransmog then
		RemoveWaitingRoll(rollID)
		RollOnLoot(rollID, ROLL_TRANSMOG)
	end

	pendingRolls[rollID] = nil
	CheckHideButton()
end

local function CheckHideButton()
	if not next(pendingRolls) then
		autoRollEnabled = false
		if AutoRoll.button then
			AutoRoll.button:Hide()
		end
	end
end

local function GetAutoRollDB()
	return GQol.db.global.autoRoll
end

local function SavePosition()
	if not AutoRoll.button then return end
	Utils:SaveFramePosition(AutoRoll.button, GetAutoRollDB())
end

local function RestorePosition()
	if not AutoRoll.button then return end
	Utils:RestoreFramePosition(AutoRoll.button, GetAutoRollDB())
end

local function SetFrameScale(val)
	GetAutoRollDB().frameScale = val
	RestorePosition()
end

local function ShowButton()
	if not GQol.db.global.autoRoll.enabled then return end
	if not AutoRoll.button then return end
	
	autoRollEnabled = false
	AutoRoll.button:Show()

	if hideCheckTimer then
		Timer:Cancel(hideCheckTimer)
	end
	hideCheckTimer = Timer:NewTicker(0.5, function()
		local hasActiveRoll = false
		if GroupLootContainer and GroupLootContainer.waitingRolls then
			hasActiveRoll = #GroupLootContainer.waitingRolls > 0
		end
		if not hasActiveRoll and not next(pendingRolls) then
			autoRollEnabled = false
			if AutoRoll.button then
				AutoRoll.button:Hide()
			end
			if hideCheckTimer then
				Timer:Cancel(hideCheckTimer)
				hideCheckTimer = nil
			end
		end
	end)
end

local function CreateAutoRollButton()
	if AutoRoll.button then return end

	local btn = CreateFrame("Button", "GQol_AutoRollButton", UIParent)
	btn:SetSize(120, 40)
	btn:SetMovable(true)
	btn:EnableMouse(true)
	btn:SetClampedToScreen(true)
	btn:SetFrameStrata("HIGH")
	btn:SetNormalFontObject("GameFontNormal")
	btn:SetHighlightFontObject("GameFontHighlight")

	local tex = btn:CreateTexture(nil, "BACKGROUND")
	tex:SetAllPoints()
	tex:SetAtlas("QuestSharing-PartyDialog-Frame")
	tex:SetTexCoord(0.02, 0.98, 0.2, 0.8)

	btn:SetNormalTexture(tex)

	local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetColorTexture(1, 1, 1, 0.2)
	btn:SetHighlightTexture(highlight)

	btn:SetText(L["AUTOROLL_BUTTON_TEXT"])

	local isDragging = false
	btn:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then
			isDragging = true
			btn:StartMoving()
		end
	end)
	btn:SetScript("OnMouseUp", function(_, button)
		if button == "LeftButton" and isDragging then
			isDragging = false
			btn:StopMovingOrSizing()
			SavePosition()
		end
	end)

	btn:SetScript("OnClick", function()
		if not isDragging then
			autoRollEnabled = true
			for rollID in pairs(pendingRolls) do
				HandleLootRoll(rollID)
			end
		end
	end)

	btn:Hide()
	AutoRoll.button = btn
	
	RestorePosition()
end

function AutoRoll:OnInitialize()
	if self.frame then return end

	self.frame = CreateFrame("Frame", "GQol_AutoRollFrame", UIParent)

	CreateAutoRollButton()
end

function AutoRoll:OnEnable()
	if not self.frame then self:OnInitialize() end
	self.frame:RegisterEvent("START_LOOT_ROLL")
	self.frame:SetScript("OnEvent", function(_, event, rollID)
		if event == "START_LOOT_ROLL" then
			if GQol.db.global.autoRoll.enabled then
				pendingRolls[rollID] = true
				ShowButton()
			end
		end
	end)
end

function AutoRoll:OnDisable()
	if self.frame then self.frame:UnregisterAllEvents() end
	if self.button then self.button:Hide() end
	wipe(pendingRolls)
	autoRollEnabled = false
	if hideCheckTimer then
		Timer:Cancel(hideCheckTimer)
		hideCheckTimer = nil
	end
end

function AutoRoll:SetEnabled(val)
	if val then
		if not self.frame then self:OnInitialize() end
		Utils:SendApplyMessage("AUTOROLL_ENABLED")
	else
		if self.frame then self.frame:UnregisterAllEvents() end
		if self.button then self.button:Hide() end
		wipe(pendingRolls)
		autoRollEnabled = false
		if hideCheckTimer then
			Timer:Cancel(hideCheckTimer)
			hideCheckTimer = nil
		end
		Utils:SendApplyMessage("AUTOROLL_DISABLED")
	end
end

function AutoRoll:ResetPosition()
	local defaults = GQol.Config.Defaults.global.autoRoll
	local db = GetAutoRollDB()
	Utils:ResetPositionDefaults(db, defaults)
	if self.button then
		RestorePosition()
	end
	Utils:SendApplyMessage("AUTOROLL_POSITION_RESET")
end

function AutoRoll:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(141, "AUTOROLL_ENABLE_CBOX", "autoRoll.enabled", function(val)
			self:SetEnabled(val)
		end),
		frameScale = CH.GlobalRange(142, "AUTOROLL_FRAME_SCALE_SLIDER", "autoRoll.frameScale", 0.5, 3.0, 0.1, function(val)
			SetFrameScale(val)
		end),
		resetPosition = CH.Execute(143, "AUTOROLL_RESET_POSITION_BTN", Utils:ModuleExecute("AutoRoll", "ResetPosition")),
	}
end