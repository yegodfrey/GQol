local GQol = _G.GQol

local Utils = GQol.Utils
local Timer = GQol.Timer
local Constants = GQol.Constants

GQol.RangeCheck = GQol.RangeCheck or {}
local RangeCheck = GQol.RangeCheck
RangeCheck.frame = nil
RangeCheck.text = nil
RangeCheck.ticker = nil
RangeCheck.LRC = nil

local function GetClassAttackRange()
	local _, class = UnitClass("player")
	local baseRange = Constants.CLASS_RANGE[class] or 5

	if not UnitExists("target") or not UnitIsFriend("player", "target") then
		return baseRange
	end

	local spec = GetSpecialization()
	if not spec then return baseRange end

	local specID = GetSpecializationInfo(spec)
	local healerRange = Constants.HEALER_SPEC_RANGE[specID]
	return healerRange or baseRange
end

local function GetRangeDB()
	return GQol.db.global.rangeCheck
end

local function GetRangeColor(minRange)
	local db = GetRangeDB()
	if not minRange then
		return db.inRangeColor.r, db.inRangeColor.g, db.inRangeColor.b
	end
	local attackRange = GetClassAttackRange()
	if minRange <= attackRange then
		return db.inRangeColor.r, db.inRangeColor.g, db.inRangeColor.b
	else
		return db.outOfRangeColor.r, db.outOfRangeColor.g, db.outOfRangeColor.b
	end
end

local function FormatRangeText(minRange, maxRange)
	if not minRange then
		return ""
	elseif not maxRange then
		return string.format("%d+", minRange)
	else
		return string.format("%d - %d", minRange, maxRange)
	end
end

local function UpdateRange()
	if not RangeCheck.frame or not RangeCheck.text then return end
	local db = GetRangeDB()

	if not db.enabled or Utils:IsInPetBattle() then
		RangeCheck.text:SetText("")
		return
	end

	if not UnitExists("target") then
		RangeCheck.text:SetText("")
		return
	end

	local minRange, maxRange
	if RangeCheck.LRC then
		minRange, maxRange = RangeCheck.LRC:GetRange("target")
	end

	local hideThreshold = db.hideThreshold
	if hideThreshold < 100 and minRange and minRange > hideThreshold then
		RangeCheck.text:SetText("")
		return
	end

	local r, g, b = GetRangeColor(minRange)
	RangeCheck.text:SetText(FormatRangeText(minRange, maxRange))
	RangeCheck.text:SetTextColor(r, g, b)
end

local function ApplyFontSize()
	if not RangeCheck.text then return end
	local db = GetRangeDB()
	local fontPath = GameFontNormalLarge:GetFont()
	local fontSize = db.fontSize
	RangeCheck.text:SetFont(fontPath, fontSize, "OUTLINE")
	RangeCheck.text:SetShadowOffset(0, 0)
end

local function SavePosition()
	if not RangeCheck.frame then return end
	Utils:SaveFramePosition(RangeCheck.frame, GetRangeDB())
end

local function RestorePosition()
	if not RangeCheck.frame then return end
	local db = GetRangeDB()
	Utils:RestoreFramePosition(RangeCheck.frame, db)
	if db.frameScale then
		RangeCheck.frame:SetScale(db.frameScale)
	end
end

local function UpdateLockState()
	if not RangeCheck.frame then return end
	local db = GetRangeDB()
	if db.locked then
		RangeCheck.frame:EnableMouse(false)
		RangeCheck.frame:SetMovable(false)
	else
		RangeCheck.frame:EnableMouse(true)
		RangeCheck.frame:SetMovable(true)
	end
end

local function UpdateVisibility()
	if not RangeCheck.frame then return end
	local db = GetRangeDB()
	if db.enabled and not Utils:IsInPetBattle() then
		RangeCheck.frame:Show()
	else
		RangeCheck.frame:Hide()
	end
end

function RangeCheck:RefreshAll()
	RestorePosition()
	ApplyFontSize()
	UpdateLockState()
	UpdateVisibility()
	UpdateRange()
end

function RangeCheck:ResetPosition()
	local defaults = GQol.Config.Defaults.global.rangeCheck
	local db = GetRangeDB()
	Utils:ResetPositionDefaults(db, defaults)
	self:RefreshAll()
	Utils:SendApplyMessage("RANGECHECK_POSITION_RESET")
end

function RangeCheck:SetHideThreshold(val)
	local db = GetRangeDB()
	db.hideThreshold = val
	UpdateRange()
end

function RangeCheck:OnInitialize()
	if self.frame then return end
	self.LRC = LibStub("LibRangeCheck-3.0")

	self.frame = CreateFrame("Frame", "GQol_RangeCheckFrame", UIParent)
	self.frame:SetSize(120, 40)
	self.frame:SetMovable(true)
	self.frame:SetClampedToScreen(true)

	self.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.text:SetPoint("CENTER")
	self.text:SetText("")

	local isDragging = false
	self.frame:SetScript("OnMouseDown", function(_, button)
		local db = GetRangeDB()
		if db.locked then return end
		if button == "LeftButton" then
			isDragging = true
			self.frame:StartMoving()
		end
	end)
	self.frame:SetScript("OnMouseUp", function()
		if isDragging then
			self.frame:StopMovingOrSizing()
			isDragging = false
			SavePosition()
		end
	end)

	self:RefreshAll()
end

function RangeCheck:OnEnable()
	if not self.frame then
		self:OnInitialize()
	end
	if not self.ticker then
		self.ticker = Timer:NewTicker(0.3, UpdateRange)
	end
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateRange)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		self:RefreshAll()
	end)
	self:RegisterEvent("PET_BATTLE_OPENING_START", UpdateVisibility)
	self:RegisterEvent("PET_BATTLE_OVER", UpdateVisibility)
	self:RefreshAll()
end

function RangeCheck:OnDisable()
	self:UnregisterAllEvents()
	if self.ticker then
		Timer:Cancel(self.ticker)
		self.ticker = nil
	end
	if self.frame then
		self.frame:Hide()
	end
end

function RangeCheck:SetEnabled(val)
	local db = GetRangeDB()
	db.enabled = val
	if val then
		if not self.ticker then
			self.ticker = Timer:NewTicker(0.3, UpdateRange)
		end
	else
		if self.ticker then
			Timer:Cancel(self.ticker)
			self.ticker = nil
		end
	end
	self:RefreshAll()
end

function RangeCheck:SetLocked(val)
	local db = GetRangeDB()
	db.locked = val
	UpdateLockState()
end

function RangeCheck:SetFontSize(val)
	local db = GetRangeDB()
	db.fontSize = val
	ApplyFontSize()
end

function RangeCheck:SetFrameScale(val)
	local db = GetRangeDB()
	db.frameScale = val
	RestorePosition()
end

function RangeCheck:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(111, "RANGECHECK_ENABLE_CBOX", "rangeCheck.enabled", function(val)
			self:SetEnabled(val)
		end),
		locked = CH.GlobalToggle(112, "RANGECHECK_LOCKED_CBOX", "rangeCheck.locked", function(val)
			self:SetLocked(val)
		end),
		fontSize = CH.GlobalRange(113, "RANGECHECK_FONT_SIZE_SLIDER", "rangeCheck.fontSize", 10, 48, 1, function(val)
			self:SetFontSize(val)
		end),
		frameScale = CH.GlobalRange(114, "RANGECHECK_FRAME_SCALE_SLIDER", "rangeCheck.frameScale", 0.5, 3.0, 0.1, function(val)
			self:SetFrameScale(val)
		end),
		hideThreshold = CH.GlobalRange(115, "RANGECHECK_HIDE_THRESHOLD_SLIDER", "rangeCheck.hideThreshold", 0, 100, 1, function(val)
			self:SetHideThreshold(val)
		end),
		resetPosition = CH.Execute(116, "RANGECHECK_RESET_POSITION_BTN", Utils:ModuleExecute("RangeCheck", "ResetPosition")),
		inRangeColor = CH.Color(117, "RANGECHECK_IN_RANGE_COLOR", "rangeCheck.inRangeColor", false, { r = 0, g = 1, b = 0 }),
		outOfRangeColor = CH.Color(118, "RANGECHECK_OUT_OF_RANGE_COLOR", "rangeCheck.outOfRangeColor", false, { r = 1, g = 0, b = 0 }),
	}
end