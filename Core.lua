local ADDON_NAME = "GQol"
local GQol = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
_G[ADDON_NAME] = GQol

-- ====================== 完整双语本地化（中文 + 英文） ======================
local locale = GetLocale()
GQol.L = {}

-- 英文
if locale == "enUS" then
    GQol.L = {
        -- System
        SYSTEM_CVARS_SAVED = "System settings saved",
        SYSTEM_CVARS_APPLIED_WITH_CHANGES = "System settings applied, %d changes made",
        CANNOT_APPLY_SYSTEM_CVARS = "No saved system settings",
        KEYBINDINGS_SAVED = "Keybindings saved",
        KEYBINDINGS_APPLIED = "Keybindings applied",
        CANNOT_APPLY_KEYBINDINGS = "No saved keybindings",
        
        -- Action Bars
        ACTION_BAR_SAVED = "Saved action bar profile: %s",
        ACTIVATED_ACTION_BAR_SET = "Applied action bar profile: %s",
        NO_ACTION_BAR_SET_TO_APPLY = "No saved action bar profiles",
        SWITCHING_SPECIALIZATION_FOR_SET = "Switching specialization for profile: %s",
        NEW_SET = "New Profile",

        -- Macros
        ERROR_DATABASE_NOT_INITIALIZED = "Error: Database not initialized",
        ACCOUNT_MACROS_SAVED = "Account macros saved",
        ACCOUNT_MACROS_APPLIED_DETAILED = "Account macros applied: Created %d, Updated %d, Deleted %d",
        ACCOUNT_MACROS_NO_CHANGES_NEEDED = "Account macros: No changes needed",
        NO_ACCOUNT_MACROS_TO_APPLY = "No saved account macros",
        CLASS_MACROS_SAVED = "Class macros saved",
        CLASS_MACROS_APPLIED_DETAILED = "Class macros applied: Created %d, Updated %d, Deleted %d",
        CLASS_MACROS_NO_CHANGES_NEEDED = "Class macros: No changes needed",
        PLAYER_CLASS_UNAVAILABLE = "Could not retrieve player class",
	NO_CLASS_MACROS_TO_APPLY = "No saved class macros",

        -- Edit Mode
        EDIT_MODE_LAYOUT_SAVED = "Edit Mode layout saved",
        EDIT_MODE_LAYOUT_APPLIED = "Edit Mode layout applied successfully!",
        CANNOT_APPLY_EDIT_MODE_LAYOUT = "No saved Edit Mode layout",
        EDIT_MODE_NOT_AVAILABLE = "Edit Mode API is unavailable",
        EDIT_MODE_LAYOUT_ALREADY_CURRENT = "Edit Mode layout is already up to date",
        
        -- General
        HIDE_APPLY_NOTICE = "Hide apply notifications",
        APPLY_NOTICE_HIDDEN = "Apply notifications hidden",
        UNKNOWN_MESSAGE = "Unknown message",
        LOADED = "Loaded - Type /gqol to open settings",

        -- UI
        UI_SETTINGS_TITLE = "GQol Settings",
        UI_ACTION_BARS = "1. Action Bar Profiles (Per Class/Spec)",
        UI_SAVE_CURRENT_SPEC_ACTION_BAR = "Save Current Spec Action Bar",
        UI_APPLY_CURRENT_SPEC_ACTION_BAR = "Apply Current Spec Action Bar",
        UI_AUTO_APPLY_ACTION_BAR = "Auto-apply on login/spec change",

        UI_EDIT_MODE = "2. Edit Mode Layout",
        UI_SAVE_EDIT_MODE = "Save Current Layout",
        UI_APPLY_EDIT_MODE = "Apply Saved Layout",
        UI_AUTO_APPLY_EDIT_MODE = "Auto-apply layout on login",

        UI_MACRO = "3. Macro Management",
        UI_SAVE_ACCOUNT_MACRO = "Save Account Macros",
        UI_APPLY_ACCOUNT_MACRO = "Apply Account Macros",
        UI_SAVE_CHAR_MACRO = "Save Class Macros",
        UI_APPLY_CHAR_MACRO = "Apply Class Macros",
        UI_AUTO_APPLY_MACRO = "Auto-apply macros on login",

        UI_SYSTEM = "4. System Settings",
        UI_SAVE_SYSTEM = "Save System Settings",
        UI_APPLY_SYSTEM = "Apply System Settings",
        UI_AUTO_APPLY_SYSTEM = "Auto-apply settings on login",

        UI_KEYBINDING = "5. Key Bindings",
        UI_SAVE_KEYBINDING = "Save Key Bindings",
        UI_APPLY_KEYBINDING = "Apply Key Bindings",
        UI_AUTO_APPLY_KEYBINDING = "Auto-apply bindings on login",

        -- Space Btn
        SPACE_BTN_TITLE = "6. Quick Quest/Gossip/Confirm Helper (Spacebar)",
        SPACE_BTN_ENABLED = "Enable Space Btn Helper",
        SPACE_BTN_DISABLED = "Space Btn Helper disabled",

        -- Compass
        COMPASS_TITLE = "7. Compass Module",
        COMPASS_ENABLED = "Enable Compass",
        COMPASS_MINIMAP_THICKNESS = "Minimap Line Thickness",
        COMPASS_MINIMAP_LENGTH = "Minimap Line Length",
        COMPASS_LINE_COLOR = "Line Color",
        COMPASS_WORLDMAP_THICKNESS = "World Map Line Thickness",
        COMPASS_WORLDMAP_LENGTH = "World Map Line Length",
    }
-- 中文（默认）
else
    GQol.L = {
        -- 系统
        SYSTEM_CVARS_SAVED = "系统设置已保存",
        SYSTEM_CVARS_APPLIED_WITH_CHANGES = "系统设置已应用，共修改 %d 项",
        CANNOT_APPLY_SYSTEM_CVARS = "没有已保存的系统设置",
        KEYBINDINGS_SAVED = "按键绑定已保存",
        KEYBINDINGS_APPLIED = "按键绑定已应用",
        CANNOT_APPLY_KEYBINDINGS = "没有已保存的按键绑定",
        
        -- 动作条
        ACTION_BAR_SAVED = "已保存动作条方案：%s",
        ACTIVATED_ACTION_BAR_SET = "已应用动作条方案：%s",
        NO_ACTION_BAR_SET_TO_APPLY = "没有已保存的动作条方案",
        SWITCHING_SPECIALIZATION_FOR_SET = "正在为专精切换方案：%s",
        NEW_SET = "新方案",

        -- 宏
        ERROR_DATABASE_NOT_INITIALIZED = "错误：数据库未初始化",
        ACCOUNT_MACROS_SAVED = "通用宏已保存",
        ACCOUNT_MACROS_APPLIED_DETAILED = "通用宏应用完成：创建 %d 个，更新 %d 个，删除 %d 个",
        ACCOUNT_MACROS_NO_CHANGES_NEEDED = "通用宏：无需进行任何更改",
        NO_ACCOUNT_MACROS_TO_APPLY = "没有已保存的通用宏方案",
        CLASS_MACROS_SAVED = "角色宏已保存",
        CLASS_MACROS_APPLIED_DETAILED = "角色宏应用完成：创建 %d 个，更新 %d 个，删除 %d 个",
        CLASS_MACROS_NO_CHANGES_NEEDED = "角色宏：无需进行任何更改",
        PLAYER_CLASS_UNAVAILABLE = "无法获取玩家职业",
	NO_CLASS_MACROS_TO_APPLY = "没有已保存的角色宏方案",

        -- Edit Mode
        EDIT_MODE_LAYOUT_SAVED = "编辑模式布局已保存",
        EDIT_MODE_LAYOUT_APPLIED = "编辑模式布局已成功应用！",
        CANNOT_APPLY_EDIT_MODE_LAYOUT = "没有已保存的编辑模式布局",
        EDIT_MODE_NOT_AVAILABLE = "编辑模式API当前不可用",
        EDIT_MODE_LAYOUT_ALREADY_CURRENT = "编辑模式布局已是最新状态",
        
        -- 通用
        HIDE_APPLY_NOTICE = "屏蔽应用操作通报",
        APPLY_NOTICE_HIDDEN = "已屏蔽应用操作通报",
        UNKNOWN_MESSAGE = "未知消息",
        LOADED = "已加载 - 输入 /gqol 打开设置面板",

        -- 设置界面
        UI_SETTINGS_TITLE = "GQol 设置",
        UI_ACTION_BARS = "1. 动作条方案（按职业-专精）",
        UI_SAVE_CURRENT_SPEC_ACTION_BAR = "保存当前专精动作条方案",
        UI_APPLY_CURRENT_SPEC_ACTION_BAR = "应用当前专精动作条方案",
        UI_AUTO_APPLY_ACTION_BAR = "登录/切换专精时自动应用当前专精方案",

        UI_EDIT_MODE = "2. 编辑模式布局",
        UI_SAVE_EDIT_MODE = "捕捉当前布局并保存",
        UI_APPLY_EDIT_MODE = "应用保存的布局",
        UI_AUTO_APPLY_EDIT_MODE = "登录时自动应用布局",

        UI_MACRO = "3. 宏管理",
        UI_SAVE_ACCOUNT_MACRO = "保存通用宏",
        UI_APPLY_ACCOUNT_MACRO = "立即应用通用宏",
        UI_SAVE_CHAR_MACRO = "保存角色宏",
        UI_APPLY_CHAR_MACRO = "立即应用角色宏",
        UI_AUTO_APPLY_MACRO = "登录时自动应用宏（通用+角色）",

        UI_SYSTEM = "4. 系统设置",
        UI_SAVE_SYSTEM = "保存系统设置",
        UI_APPLY_SYSTEM = "立即应用系统设置",
        UI_AUTO_APPLY_SYSTEM = "登录时自动应用系统设置",

        UI_KEYBINDING = "5. 按键绑定",
        UI_SAVE_KEYBINDING = "保存按键绑定",
        UI_APPLY_KEYBINDING = "立即应用按键绑定",
        UI_AUTO_APPLY_KEYBINDING = "登录时自动应用按键绑定",

        -- 空格模块
        SPACE_BTN_TITLE = "6. 空格快捷任务/对话/确认",
        SPACE_BTN_ENABLED = "启用空格助手",
	SPACE_BTN_DISABLED = "禁用空格助手",

        -- 指南针模块
        COMPASS_TITLE = "7. 指南针模块",
        COMPASS_ENABLED = "启用指南针",
        COMPASS_MINIMAP_THICKNESS = "小地图线粗细",
        COMPASS_MINIMAP_LENGTH = "小地图线长度",
        COMPASS_LINE_COLOR = "地图线颜色",
        COMPASS_WORLDMAP_THICKNESS = "世界地图线粗细",
        COMPASS_WORLDMAP_LENGTH = "世界地图线长度",
    }
end

-- ====================== 工具函数 ======================
GQol.Utils = {
    addonPrefix = "|cFF33FF99GQol:|r ",
    IsEmpty = function(t) return not t or not next(t) end,
    SafeTrim = function(s) return s and strtrim(tostring(s)) or "" end,
    GetPlayerClassToken = function() return select(2, UnitClass("player")) end,
    
    SendMessage = function(key, ...)
        local L = GQol.L
        local msg = L[key] or L.UNKNOWN_MESSAGE
        local args = {...}
        
        for i = 1, #args do
            local t = type(args[i])
            if t == "boolean" then
                args[i] = args[i] and "true" or "false"
            elseif t ~= "string" and t ~= "number" then
                args[i] = tostring(args[i] or "nil")
            end
        end
        
        local success, formatted = pcall(string.format, msg, unpack(args))
        print(GQol.Utils.addonPrefix .. (success and formatted or msg))
    end,
    
    SendApplyMessage = function(key, ...)
        if GQol.db and GQol.db.profile and GQol.db.profile.hideApplyNotice then return end
        GQol.Utils.SendMessage(key, ...)
    end
}

-- ====================== 常量 ======================
GQol.Constants = {
    MAX_ACTION_SLOTS = 120,
    EDIT_MODE_MIN_CUSTOM_UID = 3,
    EDIT_MODE_TARGET_UID = 3,
    EDIT_MODE_LAYOUT_TYPE_CUSTOM = 1,
    EDIT_MODE_APPLY_DELAY_1 = 0.7,
    EDIT_MODE_APPLY_DELAY_2 = 0.2,
    ACC_MACRO_RANGE = {1, 120},
    CHAR_MACRO_RANGE = {121, 150}
}



-- ====================== 核心初始化 ======================
local defaults = {
    profile = {
        actionBarSets = {},
        systemCVars = {},
        keybindings = {},
        accountMacros = {},
        classMacros = {},
        editModeLayout = nil,
        
        autoApplySystemOnLogin = false,
        autoApplyKeybindingsOnLogin = false,
        autoApplyAccountMacrosOnLogin = false,
        autoApplyClassMacrosOnLogin = false,
        autoApplyEditModeOnLogin = false,
        autoApplyActionBarsOnLogin = false,
        
        hideApplyNotice = false,

        SpaceBtnEnabled = true,
        SpaceBtnToggleKey = "SPACE",

        compass = {
            enabled = true,
            minimapLineThickness = 2,
            worldMapLineThickness = 2,
            LineColor = { r = 1, g = 0, b = 0, a = 0.8 }
        }
    }
}

function GQol:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GQolDB", defaults, true)
    
    local compass = self.db.profile.compass
    if compass then
        if not compass.lineColor then
            compass.lineColor = { r = 1, g = 0, b = 0, a = 0.8 }
        end
    end

    -- 支持 /gqol sbt 切换空格快捷任务
    self:RegisterChatCommand("gqol", function(input)
        local cmd = strtrim((input or ""):lower())
        if cmd == "sbt" or cmd == "space" or cmd == "空格" or cmd == "SpaceBtn" then
            GQol:ToggleSpaceBtn()
            return
        end
        if self.settingsCategoryID then
            Settings.OpenToCategory(self.settingsCategoryID)
        end
    end)
    
    self:SetupOptionsPanel()
end

function GQol:ToggleSpaceBtn()
    -- 战斗中直接拒绝，不缓存、不修改任何状态
    if InCombatLockdown() then
        GQol.Utils.SendMessage("ERROR_IN_COMBAT")
        return
    end

    local db = GQol.db.profile
    db.SpaceBtnEnabled = not db.SpaceBtnEnabled

    if db.SpaceBtnEnabled then
        GQol.Utils.SendMessage("SPACE_BTN_ENABLED")
    else
        GQol.Utils.SendMessage("SPACE_BTN_DISABLED")
    end

    -- 立即生效，无缓存
    if SpaceBtnFrame then
        SpaceBtnFrame:SetPropagateKeyboardInput(not db.SpaceBtnEnabled)
    end

    -- 同步UI
    if GQolSettingsPanel and GQolSettingsPanel.cbSpaceBtn then
        GQolSettingsPanel.cbSpaceBtn:SetChecked(db.SpaceBtnEnabled)
    end
end

function GQol:PLAYER_REGEN_ENABLED()
    -- 处理空格助手的战斗后同步
    if GQol.pendingSpaceBtnSync ~= nil and SpaceBtnFrame then
        SpaceBtnFrame:SetPropagateKeyboardInput(not GQol.pendingSpaceBtnSync)
        GQol.pendingSpaceBtnSync = nil
    end
end

function GQol:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED") -- 新增：监听战斗结束
end

function GQol:PLAYER_LOGIN()
    C_Timer.After(1.5, function()
        if GQol.db.profile.autoApplySystemOnLogin then
            GQol.System.ApplySystemCVars()
        end
        if GQol.db.profile.autoApplyKeybindingsOnLogin then
            GQol.System.ApplyKeybindings()
        end
        if GQol.db.profile.autoApplyAccountMacrosOnLogin then
            GQol.Macros.ApplyAccountMacros()
        end
        if GQol.db.profile.autoApplyClassMacrosOnLogin then
            GQol.Macros.ApplyClassMacros()
        end
        if GQol.db.profile.autoApplyEditModeOnLogin and GQol.db.profile.editModeLayout then
            GQol.EditMode.ApplyCurrentLayout()
        end
        if GQol.db.profile.autoApplyActionBarsOnLogin then
            GQol.ActionBars.AutoSwitchForCurrentSpec()
        end
    end)
end

function GQol:PLAYER_SPECIALIZATION_CHANGED()
    if GQol.pendingActionBarSet then
        GQol.ActionBars.RestoreMetatable(GQol.pendingActionBarSet)
        GQol.pendingActionBarSet:ActivateInternal()
        GQol.pendingActionBarSet = nil
    end
    if GQol.db.profile.autoApplyActionBarsOnLogin then
        C_Timer.After(0.5, function()
            GQol.ActionBars.AutoSwitchForCurrentSpec()
        end)
    end
end

function GQol:ToggleUI()
    if self.settingsCategoryID then
        Settings.OpenToCategory(self.settingsCategoryID)
    end
end

local resizeMacroFrame = CreateFrame("FRAME", nil)
resizeMacroFrame:RegisterEvent("ADDON_LOADED")
resizeMacroFrame:SetScript("OnEvent", function (self, event, a1, ...)
    if event == "ADDON_LOADED" and a1 == "Blizzard_MacroUI" then
        MacroFrame:SetSize(535,600)
        MacroHorizontalBarLeft:SetSize(452,16)
        MacroHorizontalBarLeft:ClearAllPoints()
        MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -340)
        MacroFrameSelectedMacroBackground:ClearAllPoints()
        MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 5, -348)
        MacroFrame.MacroSelector:SetSize(520,276)
        local MacroSelectorUpdated = false
        hooksecurefunc(MacroFrame, "Update", function(self, ...)
            if not MacroSelectorUpdated then
                self.MacroSelector:SetCustomStride(10);
                self.MacroSelector:Init();
                MacroSelectorUpdated = true
            end
        end)
        MacroFrameScrollFrame:SetSize(484,130)
        MacroFrameText:SetSize(484,85)
        MacroFrameTextBackground:SetSize(520,140)
        MacroFrameTextBackground:ClearAllPoints()
        MacroFrameTextBackground:SetPoint("TOPLEFT", MacroFrame, 6, -419)
        self:UnregisterEvent("ADDON_LOADED")
    end
end)