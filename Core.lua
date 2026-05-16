local ADDON_NAME = "GQol"
local GQol = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
_G[ADDON_NAME] = GQol

GQol.L = {}
GQol.Modules = {}
GQol.Constants = {}
GQol.Utils = {}
GQol.Combat = {}
GQol.Config = {}

-- ============================================================
-- Module Management
-- ============================================================
GQol.ModuleHelpers = {}
local ModuleHelpers = GQol.ModuleHelpers

function GQol:RegisterModule(name, module)
	self.Modules[name] = module
end

function ModuleHelpers:InitializeModule(moduleName)
	local module = GQol.Modules[moduleName]
	if not module then return end
	LibStub("AceEvent-3.0"):Embed(module)
	if module.OnInitialize then
		if InCombatLockdown() then
			GQol.Combat:RunWhenOut(function()
				module.OnInitialize(module)
			end)
		else
			module.OnInitialize(module)
		end
	end
end

function ModuleHelpers:EnableModule(moduleName)
	local module = GQol.Modules[moduleName]
	if module and module.OnEnable then
		if InCombatLockdown() then
			GQol.Combat:RunWhenOut(function()
				module.OnEnable(module)
			end)
		else
			module.OnEnable(module)
		end
	end
end

function ModuleHelpers:DisableModule(moduleName)
	local module = GQol.Modules[moduleName]
	if module and module.OnDisable then
		module.OnDisable(module)
	end
end

-- ============================================================
-- Centralized Module Registration
-- ============================================================
local function RegisterAllModules()
	GQol:RegisterModule("System", GQol.System)
	GQol:RegisterModule("Macros", GQol.Macros)
	GQol:RegisterModule("ActionBars", GQol.ActionBars)
	GQol:RegisterModule("EditMode", GQol.EditMode)
	GQol:RegisterModule("Sound", GQol.Sound)
	GQol:RegisterModule("Compass", GQol.Compass)
	GQol:RegisterModule("MooseLight", GQol.MooseLight)
	GQol:RegisterModule("SpaceBtn", GQol.SpaceBtn)
	GQol:RegisterModule("FreeLook", GQol.FreeLook)
	GQol:RegisterModule("BanTarget", GQol.BanTarget)
	GQol:RegisterModule("RangeCheck", GQol.RangeCheck)
	GQol:RegisterModule("PremadeGroupHelper", GQol.PremadeGroupHelper)
	GQol:RegisterModule("ProfessionTabs", GQol.ProfessionTabs)
	GQol:RegisterModule("AutoRoll", GQol.AutoRoll)
	GQol:RegisterModule("Mail", GQol.Mail)
end

-- ============================================================
-- Core
-- ============================================================
function GQol:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GQolDB", self.Config.Defaults, true)

	RegisterAllModules()

	local function HandleMooseLight(cmd)
		self.Modules.MooseLight:HandleCommand(cmd)
	end
	local function HandlePGHVisibility(cmd)
		self.Modules.PremadeGroupHelper:HandleVisibilityCommand(cmd)
	end

	self:RegisterChatCommand("gqol", function(input)
		local cmd = strtrim((input or ""):lower())
		if cmd == "sbt" then self:ToggleSpaceBtn(); return end
		if cmd == "add" or cmd == "del" or cmd == "remove" or cmd == "save" then HandleMooseLight(cmd); return end
		if cmd == "show" or cmd == "hide" then HandlePGHVisibility(cmd); return end
		Settings.OpenToCategory(self.settingsCategoryID)
	end)

	self:SetupOptionsPanel()
end

function GQol:SetupModules()
	for name in pairs(self.Modules) do
		self.ModuleHelpers:InitializeModule(name)
	end
end

GQol.enabledModules = {}

function GQol:OnEnable()
	local function FinishEnable()
		for name in pairs(self.Modules) do
			if not self.enabledModules[name] then
				self.ModuleHelpers:EnableModule(name)
				self.enabledModules[name] = true
			end
		end
		self:RegisterEvent("PLAYER_LOGIN")
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			if not self.modulesSetup then
				self:SetupModules()
				self.modulesSetup = true
			end
			FinishEnable()
		end)
	else
		self:SetupModules()
		self.modulesSetup = true
		FinishEnable()
	end
end

function GQol:OnDisable()
	for name in pairs(self.Modules) do
		self.ModuleHelpers:DisableModule(name)
	end
	self.enabledModules = {}
	self.Timer:CancelAll()
end

-- ============================================================
-- Event Handlers
-- ============================================================
function GQol:PLAYER_LOGIN()
	C_Timer.After(GQol.Constants.LOGIN_DELAY, function()
		GQol:OnLogin()
	end)
end

function GQol:PLAYER_SPECIALIZATION_CHANGED(unit)
	if unit ~= "player" then return end
	local TimedActions = {
		{ profile = "autoApplyActionBarsOnLogin", delay = GQol.Constants.SPEC_CHANGE_DELAY, handler = function()
			self.Modules.ActionBars:AutoSwitchForCurrentSpec()
		end },
		{ profile = "autoApplyEditModeOnLogin", delay = GQol.Constants.SPEC_CHANGE_DELAY + 0.3, condition = function() return GQol.db.global.editModeLayout end, handler = function()
			self.Modules.EditMode:ApplyOnSpecChange()
		end },
	}

	for _, action in ipairs(TimedActions) do
		if self.db.profile[action.profile] then
			if not action.condition or action.condition() then
				C_Timer.After(action.delay, action.handler)
			end
		end
	end
end

-- ============================================================
-- Auto-apply on Login
-- ============================================================
function GQol:OnLogin()
	local configs = {
		{ profile = "autoApplySystemOnLogin", module = "System", method = "ApplySystemCVars", condition = function() return GQol.db.global.systemCVars end },
		{ profile = "autoApplyKeybindingsOnLogin", module = "System", method = "ApplyKeybindings", condition = function() return GQol.db.global.keybindings end },
		{ profile = "autoApplyAccountMacrosOnLogin", module = "Macros", method = "ApplyAccountMacros", condition = function() return GQol.db.global.accountMacros and not GQol.Utils:IsEmpty(GQol.db.global.accountMacros) end },
		{ profile = "autoApplyClassMacrosOnLogin", module = "Macros", method = "ApplyClassMacros", condition = function() return GQol.db.global.classMacros and not GQol.Utils:IsEmpty(GQol.db.global.classMacros) end },
		{ profile = "autoApplyEditModeOnLogin", module = "EditMode", method = "ApplyOnLogin", condition = function() return GQol.db.global.editModeLayout end },
		{ profile = "autoApplyActionBarsOnLogin", module = "ActionBars", method = "ApplyCurrentSpecSet" },
		{ profile = "autoApplyMooseLightOnLogin", module = "MooseLight", method = "UpdateZoneLight" },
	}

	for _, cfg in ipairs(configs) do
		if self.db.profile[cfg.profile] then
			if not cfg.condition or cfg.condition() then
				local mod = self.Modules[cfg.module]
				mod[cfg.method](mod)
			end
		end
	end
end

-- ============================================================
-- SpaceBtn Toggle
-- ============================================================
function GQol:ToggleSpaceBtn()
	if InCombatLockdown() then return end
	local enabled = not self.db.global.spaceBtn.enabled
	self.Modules.SpaceBtn:SetEnabled(enabled)
end
