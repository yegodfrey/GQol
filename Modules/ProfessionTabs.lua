local GQol = _G.GQol

local Utils = GQol.Utils
local L = GQol.L

GQol.ProfessionTabs = GQol.ProfessionTabs or {}
local PTabs = GQol.ProfessionTabs
PTabs.frame = nil
PTabs.activeTabs = {}

local EXTRA_SPELLS = {
	436854, -- 切换飞行模式
	460905, -- 战团银行
}

local BLACKLIST = {
	[392296] = true,--巨龙群岛捡布
	[20222] = true,--地精工程师
}

local function BuildSpellList()
	local p1, p2, arch, fishing, cooking = GetProfessions()
	local profs = { p1, p2, cooking }
	local tradeSpells = {}

	for _, prof in pairs(profs) do
		local _, _, _, _, abilities, offset = GetProfessionInfo(prof)

		for i = 1, abilities do
			local slot = i + offset
			local itemInfo = C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Player)

			if itemInfo and itemInfo.spellID then
				local spellID = itemInfo.spellID

				if not BLACKLIST[spellID] and not C_Spell.IsSpellPassive(spellID) then
					tinsert(tradeSpells, spellID)
				end
			end
		end
	end
	return tradeSpells
end

local function SetupTab(button, spellID)
	local spellInfo = C_Spell.GetSpellInfo(spellID)
	if not spellInfo then return end

	button:SetSize(36, 36)
	button:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spellID)
	button:SetNormalTexture(spellInfo.iconID)

	local bg = button:CreateTexture(nil, "BORDER")
	bg:SetAtlas("ProfessionTab-Background")
	bg:SetAllPoints()

	Utils:SetupTooltip(button, spellInfo.name, "ANCHOR_RIGHT")
end

function PTabs:BuildTabs()
	if InCombatLockdown() then return end

	local container = PlayerSpellsFrame
	if not container then return end

	-- 已经创建过了，不再重复创建
	if #self.activeTabs > 0 then return end

	local tradeSpells = BuildSpellList()
	local extraCount = 0

	for _, spellID in ipairs(EXTRA_SPELLS) do
		if C_SpellBook.IsSpellKnown(spellID) then
			extraCount = extraCount + 1
		end
	end

	local totalCount = #tradeSpells + extraCount
	if totalCount == 0 then return end

	local tabSize = 36
	local gap = 10
	local totalHeight = totalCount * tabSize + (totalCount - 1) * gap
	local offsetY = (totalHeight - tabSize) / 2

	local prev

	for _, spellID in ipairs(tradeSpells) do
		-- 直接创建按钮，不用 tabPool
		local tab = CreateFrame("Button", nil, container, "SecureActionButtonTemplate")
		SetupTab(tab, spellID)
		tab:ClearAllPoints()

		if not prev then
			tab:SetPoint("LEFT", container, "RIGHT", 0, offsetY)
		else
			tab:SetPoint("TOP", prev, "BOTTOM", 0, -gap)
		end
		tab:Show()
		prev = tab
		tinsert(self.activeTabs, tab)
	end

	for _, spellID in ipairs(EXTRA_SPELLS) do
		if C_SpellBook.IsSpellKnown(spellID) then
			local tab = CreateFrame("Button", nil, container, "SecureActionButtonTemplate")
			SetupTab(tab, spellID)
			tab:ClearAllPoints()
			tab:SetPoint("TOP", prev, "BOTTOM", 0, -gap)
			tab:Show()
			prev = tab
			tinsert(self.activeTabs, tab)
		end
	end
end

function PTabs:OnInitialize()
	if self.frame then return end
	self.frame = CreateFrame("Frame", "GQol_ProfessionTabsFrame", UIParent)
end

function PTabs:OnEnable()
	if not self.frame then self:OnInitialize() end

	self.frame:SetScript("OnEvent", function(_, event, ...)
		if event == "ADDON_LOADED" then
			local addon = ...
			if addon == "Blizzard_PlayerSpells" then
				if InCombatLockdown() then
					self.pendingBuild = true
				else
					self:BuildTabs()
				end
			end
		elseif event == "PLAYER_REGEN_ENABLED" then
			if self.pendingBuild then
				self.pendingBuild = false
				self:BuildTabs()
			end
		end
	end)
	self.frame:RegisterEvent("ADDON_LOADED")
	self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")

	for _, tab in ipairs(self.activeTabs) do
		tab:Show()
	end
end

function PTabs:OnDisable()
	if self.frame then
		self.frame:UnregisterAllEvents()
		self.frame:SetScript("OnEvent", nil)
	end
	for _, tab in ipairs(self.activeTabs) do
		tab:Hide()
	end
end

function PTabs:SetEnabled(val)
	if val then
		self:OnEnable()
		Utils:SendApplyMessage("PROFTABS_ENABLED")
	else
		self:OnDisable()
		Utils:SendApplyMessage("PROFTABS_DISABLED")
	end
end

function PTabs:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(131, "PROFTABS_ENABLE_CBOX", "professionTabs.enabled", function(val)
			self:SetEnabled(val)
		end),
	}
end