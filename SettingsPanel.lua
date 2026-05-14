local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local Utils = GQol.Utils
local CH = Utils.ConfigHelpers
local L = GQol.L

local MODULE_DESC_KEYS = {
	System = "SYSTEM_DESC",
	Macros = "MACRO_DESC",
	ActionBars = "ACTIONBARS_DESC",
	EditMode = "EDITMODE_DESC",
	Sound = "SOUND_DESC",
	Compass = "COMPASS_DESC",
	MooseLight = "MOOSELIGHT_DESC",
	SpaceBtn = "SPACEBTN_DESC",
	FreeLook = "FREELOOK_DESC",
	BanTarget = "BANTARGET_DESC",
	RangeCheck = "RANGECHECK_DESC",
	PremadeGroupHelper = "PGH_DESC",
	ProfessionTabs = "PROFTABS_DESC",
	AutoRoll = "AUTOROLL_DESC",
	Mail = "MAIL_DESC",
}

local MODULE_TAB_KEYS = {
	System = "SYSTEM_TAB",
	Macros = "MACRO_TAB",
	ActionBars = "ACTIONBARS_TAB",
	EditMode = "EDITMODE_TAB",
	Sound = "SOUND_TAB",
	Compass = "COMPASS_TAB",
	MooseLight = "MOOSELIGHT_TAB",
	SpaceBtn = "SPACEBTN_TAB",
	FreeLook = "FREELOOK_TAB",
	BanTarget = "BANTARGET_TAB",
	RangeCheck = "RANGECHECK_TAB",
	PremadeGroupHelper = "PGH_TAB",
	ProfessionTabs = "PROFTABS_TAB",
	AutoRoll = "AUTOROLL_TAB",
	Mail = "MAIL_TAB",
}

function GQol:SetupOptionsPanel()
	if self.optionsRegistered then return end
	self.optionsRegistered = true

	local options = {
		type = "group",
		name = "GQol",
		childGroups = "tree",
		args = {}
	}
	self.optionsTable = options

	options.args.general = {
		type = "group",
		name = L["GENERAL_TAB"],
		order = 0,
		args = {
			desc = CH.Description(0, L["GENERAL_DESC"] or ""),
			hideNotice = CH.GlobalToggle(1, "GENERAL_HIDE_NOTICE_CBOX", "general.hideApplyNotice"),
		}
	}

	local moduleOrder = 10
	for name, module in pairs(self.Modules) do
		if module.GetOptions then
			local opts = module:GetOptions()
			if opts and next(opts) then
				local cleanOpts = {}
				for key, opt in pairs(opts) do
					if not CH.IsHeaderKey(key) then
						cleanOpts[key] = opt
					end
				end

				local descKey = MODULE_DESC_KEYS[name]
				local descText = descKey and (L[descKey] or "") or ""
				if descText ~= "" then
					cleanOpts.desc = CH.Description(0, descText)
				end

				local tabKey = MODULE_TAB_KEYS[name]
				options.args[name:lower() .. "tab"] = {
					type = "group",
					name = tabKey and (L[tabKey] or name) or name,
					order = moduleOrder,
					args = cleanOpts,
				}
				moduleOrder = moduleOrder + 1
			end
		end
	end

	AceConfig:RegisterOptionsTable("GQol", options)

	local _, categoryID = AceConfigDialog:AddToBlizOptions("GQol", "GQol")
	self.settingsCategoryID = categoryID
end
