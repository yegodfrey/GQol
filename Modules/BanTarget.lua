local GQol = _G.GQol

local Utils = GQol.Utils

GQol.BanTarget = GQol.BanTarget or {}
local BanTarget = GQol.BanTarget
BanTarget.lastClick = 0
BanTarget.frame = nil

function BanTarget:OnInitialize()
	if self.frame then return end

	self.frame = CreateFrame("Frame", "GQol_BanTargetFrame", UIParent)

	WorldFrame:HookScript("OnMouseUp", function(_, button)
		if button ~= "RightButton" then return end
		local db = GQol.db.global.banTarget
		if not db.enabled then return end
		if not UnitAffectingCombat("player") then return end

		local now = GetTime()
		local doubleTime = db.clickTime or 0.2

		if now - self.lastClick < doubleTime then
			self.lastClick = 0
		else
			MouselookStop()
			self.lastClick = now
		end
	end)
end

function BanTarget:OnEnable()
	if not self.frame then self:OnInitialize() end
end

function BanTarget:OnDisable()
	self.lastClick = 0
end

function BanTarget:SetEnabled(val)
	if val then
		if not self.frame then self:OnInitialize() end
		Utils:SendApplyMessage("BANTARGET_ENABLED")
	else
		Utils:SendApplyMessage("BANTARGET_DISABLED")
	end
end

function BanTarget:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(81, "BANTARGET_ENABLE_CBOX", "banTarget.enabled", function(val)
			self:SetEnabled(val)
		end),
		clickTime = CH.GlobalRange(82, "BANTARGET_CLICK_TIME_SLIDER", "banTarget.clickTime", 0.1, 0.5, 0.01),
	}
end
