-- ====================== 设置面板 ======================
function GQol:SetupOptionsPanel()
    local panel = CreateFrame("Frame", "GQolSettingsPanel", UIParent)
    panel.name = "GQol"

    local scroll = CreateFrame("ScrollFrame", "GQolMainScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -10)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(640, 1680)  -- 增加高度容纳新模块
    scroll:SetScrollChild(content)

    local y = -25

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, y)
    title:SetText(GQol.L.UI_SETTINGS_TITLE)
    
    local hideNoticeCB = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    hideNoticeCB:SetPoint("LEFT", title, "RIGHT", 20, 0)
    hideNoticeCB.text = hideNoticeCB:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    hideNoticeCB.text:SetPoint("LEFT", hideNoticeCB, "RIGHT", 4, 0)
    hideNoticeCB.text:SetText(GQol.L.HIDE_APPLY_NOTICE)
    hideNoticeCB:SetChecked(GQol.db.profile.hideApplyNotice)
    hideNoticeCB:SetScript("OnClick", function(self)
        GQol.db.profile.hideApplyNotice = self:GetChecked()
        if self:GetChecked() then
            GQol.Utils.SendMessage("APPLY_NOTICE_HIDDEN")
        end
    end)

    y = y - 45

    -- 1. 动作条
    local abTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    abTitle:SetPoint("TOPLEFT", 16, y)
    abTitle:SetText(GQol.L.UI_ACTION_BARS)
    y = y - 35

    local btnSaveAB = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnSaveAB:SetSize(240, 32)
    btnSaveAB:SetPoint("TOPLEFT", 20, y)
    btnSaveAB:SetText(GQol.L.UI_SAVE_CURRENT_SPEC_ACTION_BAR)
    btnSaveAB:SetScript("OnClick", function()
        GQol.ActionBars.SaveCurrentSpecSet()
    end)

    local btnApplyAB = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnApplyAB:SetSize(240, 32)
    btnApplyAB:SetPoint("LEFT", btnSaveAB, "RIGHT", 20, 0)
    btnApplyAB:SetText(GQol.L.UI_APPLY_CURRENT_SPEC_ACTION_BAR)
    btnApplyAB:SetScript("OnClick", function()
        GQol.ActionBars.ApplyCurrentSpecSet()
    end)

    y = y - 50

    local cbAutoAB = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cbAutoAB:SetPoint("TOPLEFT", 20, y)
    cbAutoAB.text = cbAutoAB:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbAutoAB.text:SetPoint("LEFT", cbAutoAB, "RIGHT", 4, 0)
    cbAutoAB.text:SetText(GQol.L.UI_AUTO_APPLY_ACTION_BAR)
    cbAutoAB:SetChecked(GQol.db.profile.autoApplyActionBarsOnLogin)
    cbAutoAB:SetScript("OnClick", function(self)
        GQol.db.profile.autoApplyActionBarsOnLogin = self:GetChecked()
    end)

    y = y - 80

    -- 2. Edit Mode
    local editTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    editTitle:SetPoint("TOPLEFT", 16, y)
    editTitle:SetText(GQol.L.UI_EDIT_MODE)
    y = y - 35

    local btnCaptureEdit = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnCaptureEdit:SetSize(260, 32)
    btnCaptureEdit:SetPoint("TOPLEFT", 20, y)
    btnCaptureEdit:SetText(GQol.L.UI_SAVE_EDIT_MODE)
    btnCaptureEdit:SetScript("OnClick", function() 
        GQol.EditMode.SaveCurrentLayout() 
    end)

    local btnApplyEdit = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnApplyEdit:SetSize(180, 32)
    btnApplyEdit:SetPoint("LEFT", btnCaptureEdit, "RIGHT", 20, 0)
    btnApplyEdit:SetText(GQol.L.UI_APPLY_EDIT_MODE)
    btnApplyEdit:SetScript("OnClick", function()
        GQol.EditMode.ApplyCurrentLayout()
    end)

    local cbEditAuto = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cbEditAuto:SetPoint("TOPLEFT", btnCaptureEdit, "BOTTOMLEFT", 0, -12)
    cbEditAuto.text = cbEditAuto:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbEditAuto.text:SetPoint("LEFT", cbEditAuto, "RIGHT", 4, 0)
    cbEditAuto.text:SetText(GQol.L.UI_AUTO_APPLY_EDIT_MODE)
    cbEditAuto:SetChecked(GQol.db.profile.autoApplyEditModeOnLogin)
    cbEditAuto:SetScript("OnClick", function(self)
        GQol.db.profile.autoApplyEditModeOnLogin = self:GetChecked()
    end)
    y = y - 110

    -- 3. 宏管理（原代码不变，省略）
    local macroTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    macroTitle:SetPoint("TOPLEFT", 16, y)
    macroTitle:SetText(GQol.L.UI_MACRO)
    y = y - 35

    local btnSaveAcc = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnSaveAcc:SetSize(150, 28)
    btnSaveAcc:SetPoint("TOPLEFT", 20, y)
    btnSaveAcc:SetText(GQol.L.UI_SAVE_ACCOUNT_MACRO)
    btnSaveAcc:SetScript("OnClick", function()
        GQol.Macros.SaveAccountMacros()
    end)

    local btnApplyAcc = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnApplyAcc:SetSize(150, 28)
    btnApplyAcc:SetPoint("LEFT", btnSaveAcc, "RIGHT", 12, 0)
    btnApplyAcc:SetText(GQol.L.UI_APPLY_ACCOUNT_MACRO)
    btnApplyAcc:SetScript("OnClick", function()
        GQol.Macros.ApplyAccountMacros()
    end)

    local btnSaveClass = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnSaveClass:SetSize(150, 28)
    btnSaveClass:SetPoint("TOPLEFT", btnSaveAcc, "BOTTOMLEFT", 0, -12)
    btnSaveClass:SetText(GQol.L.UI_SAVE_CHAR_MACRO)
    btnSaveClass:SetScript("OnClick", function()
        GQol.Macros.SaveClassMacros()
    end)

    local btnApplyClass = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnApplyClass:SetSize(150, 28)
    btnApplyClass:SetPoint("LEFT", btnSaveClass, "RIGHT", 12, 0)
    btnApplyClass:SetText(GQol.L.UI_APPLY_CHAR_MACRO)
    btnApplyClass:SetScript("OnClick", function()
        GQol.Macros.ApplyClassMacros()
    end)

    local cbMacroAuto = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cbMacroAuto:SetPoint("TOPLEFT", btnSaveClass, "BOTTOMLEFT", 0, -12)
    cbMacroAuto.text = cbMacroAuto:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbMacroAuto.text:SetPoint("LEFT", cbMacroAuto, "RIGHT", 4, 0)
    cbMacroAuto.text:SetText(GQol.L.UI_AUTO_APPLY_MACRO)
    cbMacroAuto:SetChecked(GQol.db.profile.autoApplyAccountMacrosOnLogin)
    cbMacroAuto:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        GQol.db.profile.autoApplyAccountMacrosOnLogin = checked
        GQol.db.profile.autoApplyClassMacrosOnLogin = checked
    end)
    y = y - 130

    -- 4. 系统设置（原代码不变，省略）
    local sysTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sysTitle:SetPoint("TOPLEFT", 16, y)
    sysTitle:SetText(GQol.L.UI_SYSTEM)
    y = y - 35

    local btnSaveCVars = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnSaveCVars:SetSize(160, 28)
    btnSaveCVars:SetPoint("TOPLEFT", 20, y)
    btnSaveCVars:SetText(GQol.L.UI_SAVE_SYSTEM)
    btnSaveCVars:SetScript("OnClick", function()
        GQol.System.SaveSystemCVars()
    end)

    local btnApplyCVars = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnApplyCVars:SetSize(160, 28)
    btnApplyCVars:SetPoint("LEFT", btnSaveCVars, "RIGHT", 15, 0)
    btnApplyCVars:SetText(GQol.L.UI_APPLY_SYSTEM)
    btnApplyCVars:SetScript("OnClick", function()
        GQol.System.ApplySystemCVars()
    end)

    local cbSysAuto = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cbSysAuto:SetPoint("TOPLEFT", btnSaveCVars, "BOTTOMLEFT", 0, -12)
    cbSysAuto.text = cbSysAuto:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbSysAuto.text:SetPoint("LEFT", cbSysAuto, "RIGHT", 4, 0)
    cbSysAuto.text:SetText(GQol.L.UI_AUTO_APPLY_SYSTEM)
    cbSysAuto:SetChecked(GQol.db.profile.autoApplySystemOnLogin)
    cbSysAuto:SetScript("OnClick", function(self)
        GQol.db.profile.autoApplySystemOnLogin = self:GetChecked()
    end)
    y = y - 85

    -- 5. 按键绑定（原代码不变，省略）
    local kbTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    kbTitle:SetPoint("TOPLEFT", 16, y)
    kbTitle:SetText(GQol.L.UI_KEYBINDING)
    y = y - 35

    local btnSaveKB = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnSaveKB:SetSize(160, 28)
    btnSaveKB:SetPoint("TOPLEFT", 20, y)
    btnSaveKB:SetText(GQol.L.UI_SAVE_KEYBINDING)
    btnSaveKB:SetScript("OnClick", function()
        GQol.System.SaveKeybindings()
    end)

    local btnApplyKB = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    btnApplyKB:SetSize(160, 28)
    btnApplyKB:SetPoint("LEFT", btnSaveKB, "RIGHT", 15, 0)
    btnApplyKB:SetText(GQol.L.UI_APPLY_KEYBINDING)
    btnApplyKB:SetScript("OnClick", function()
        GQol.System.ApplyKeybindings()
    end)

    local cbKBAuto = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cbKBAuto:SetPoint("TOPLEFT", btnSaveKB, "BOTTOMLEFT", 0, -12)
    cbKBAuto.text = cbKBAuto:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbKBAuto.text:SetPoint("LEFT", cbKBAuto, "RIGHT", 4, 0)
    cbKBAuto.text:SetText(GQol.L.UI_AUTO_APPLY_KEYBINDING)
    cbKBAuto:SetChecked(GQol.db.profile.autoApplyKeybindingsOnLogin)
    cbKBAuto:SetScript("OnClick", function(self)
        GQol.db.profile.autoApplyKeybindingsOnLogin = self:GetChecked()
    end)

    y = y - 80

    -- ====================== 6. 空格模块 ======================
local sbTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sbTitle:SetPoint("TOPLEFT", 16, y)
    sbTitle:SetText(GQol.L.SPACE_BTN_TITLE)
    y = y - 35

local cbSpaceBtn = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
cbSpaceBtn:SetPoint("TOPLEFT", 20, y)
cbSpaceBtn.text = cbSpaceBtn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
cbSpaceBtn.text:SetPoint("LEFT", cbSpaceBtn, "RIGHT", 4, 0)
cbSpaceBtn.text:SetText(GQol.L.SPACE_BTN_ENABLED)
cbSpaceBtn:SetChecked(GQol.db.profile.SpaceBtnEnabled)
GQolSettingsPanel.cbSpaceBtn = cbSpaceBtn

cbSpaceBtn:SetScript("OnClick", function(self)
    -- 战斗中直接禁止，不缓存、不修改
    if InCombatLockdown() then
        self:SetChecked(GQol.db.profile.SpaceBtnEnabled)
        GQol.Utils.SendMessage("ERROR_IN_COMBAT")
        return
    end

    local enable = self:GetChecked()
    GQol.db.profile.SpaceBtnEnabled = enable

    if enable then
        GQol.Utils.SendMessage("SPACE_BTN_ENABLED")
    else
        GQol.Utils.SendMessage("SPACE_BTN_DISABLED")
    end

    -- 立即生效
    if SpaceBtnFrame then
        SpaceBtnFrame:SetPropagateKeyboardInput(not enable)
    end
end)

    y = y - 50

    -- ====================== 7. 指南针模块 ======================
local compassTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    compassTitle:SetPoint("TOPLEFT", 16, y)
    compassTitle:SetText(GQol.L.COMPASS_TITLE)
    y = y - 35

    -- 统一启用开关
    local cbCompass = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cbCompass:SetPoint("TOPLEFT", 20, y)
    cbCompass.text = cbCompass:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbCompass.text:SetPoint("LEFT", cbCompass, "RIGHT", 4, 0)
    cbCompass.text:SetText(GQol.L.COMPASS_ENABLED)
    cbCompass:SetChecked(GQol.db.profile.compass and GQol.db.profile.compass.enabled or true)
    cbCompass:SetScript("OnClick", function(self)
        GQol.db.profile.compass.enabled = self:GetChecked()
    if GQol.Compass and GQol.Compass.Refresh then
        GQol.Compass.Refresh()
    end
end)
    y = y - 40

    -- ==================== 地图设置 ====================
    local mmThickSlider = CreateFrame("Slider", "GQolMinimapThickSlider", content, "OptionsSliderTemplate")
    mmThickSlider:SetPoint("TOPLEFT", 40, y)
    mmThickSlider:SetSize(220, 20)
    mmThickSlider.text = mmThickSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    mmThickSlider.text:SetPoint("BOTTOM", mmThickSlider, "TOP", 0, 3)
    mmThickSlider.text:SetText(GQol.L.COMPASS_MINIMAP_THICKNESS)
    mmThickSlider:SetMinMaxValues(1, 10)
    mmThickSlider:SetValueStep(0.5)
    mmThickSlider:SetValue(GQol.db.profile.compass.minimapLineThickness)
    mmThickSlider:SetScript("OnValueChanged", function(self, val)
        GQol.db.profile.compass.minimapLineThickness = math.floor(val * 2) / 2
        self:SetValue(GQol.db.profile.compass.minimapLineThickness)
    end)

    local wmThickSlider = CreateFrame("Slider", "GQolWorldThickSlider", content, "OptionsSliderTemplate")
    wmThickSlider:SetPoint("TOPLEFT", mmThickSlider, "TOPRIGHT", 40, 0)
    wmThickSlider:SetSize(220, 20)
    wmThickSlider.text = wmThickSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    wmThickSlider.text:SetPoint("BOTTOM", wmThickSlider, "TOP", 0, 3)
    wmThickSlider.text:SetText(GQol.L.COMPASS_WORLDMAP_THICKNESS)
    wmThickSlider:SetMinMaxValues(1, 10)
    wmThickSlider:SetValueStep(0.5)
    wmThickSlider:SetValue(GQol.db.profile.compass.worldMapLineThickness)
    wmThickSlider:SetScript("OnValueChanged", function(self, val)
        GQol.db.profile.compass.worldMapLineThickness = math.floor(val * 2) / 2
        self:SetValue(GQol.db.profile.compass.worldMapLineThickness)
    end)

    -- 统一颜色按钮
    local lineColorBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    lineColorBtn:SetSize(160, 24)
    lineColorBtn:SetPoint("TOPLEFT", mmLenSlider, "BOTTOMLEFT", 0, -25)
    lineColorBtn:SetText(GQol.L.COMPASS_LINE_COLOR)
    lineColorBtn:SetScript("OnClick", function()
        local db = GQol.db.profile.compass
        local color = db.lineColor
        ColorPickerFrame:SetupColorPickerAndShow({
            r = color.r or 1, g = color.g or 0, b = color.b or 0, a = color.a or 0.8,
            hasOpacity = true,
            swatchFunc = function() local r,g,b = ColorPickerFrame:GetColorRGB(); color.r,color.g,color.b = r,g,b end,
            opacityFunc = function() color.a = ColorPickerFrame:GetColorAlpha() end,
            cancelFunc = function(prev) color.r,color.g,color.b,color.a = prev.r,prev.g,prev.b,prev.a end,
            previousValues = {r=color.r or 1, g=color.g or 0, b=color.b or 0, a=color.a or 0.8}
        })
    end)

    y = y - 180   -- 调整后续模块的 Y 坐标

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    self.settingsCategoryID = category:GetID()
end

GQol.Utils.SendMessage("LOADED")