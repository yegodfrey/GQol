-- ====================== EditMode 模块 ======================
GQol.EditMode = {}

local function IsEditModeAPIAvailable()
    if not C_EditMode or type(C_EditMode.GetLayouts) ~= "function" or
       type(C_EditMode.ConvertLayoutInfoToString) ~= "function" or
       type(C_EditMode.ConvertStringToLayoutInfo) ~= "function" or
       type(C_EditMode.SaveLayouts) ~= "function" or 
       type(C_EditMode.SetActiveLayout) ~= "function" then
        GQol.Utils.SendApplyMessage("EDIT_MODE_NOT_AVAILABLE")
        return false
    end
    return true
end

local function GetActiveLayoutDetails()
    if not IsEditModeAPIAvailable() then return nil end

    local successCall, layoutsData = pcall(C_EditMode.GetLayouts)
    if not successCall or not layoutsData then return nil end

    local activeLayoutApiID = tonumber(layoutsData.activeLayout)
    if not activeLayoutApiID or activeLayoutApiID < GQol.Constants.EDIT_MODE_MIN_CUSTOM_UID then
        return nil
    end

    local targetIndex = activeLayoutApiID - (GQol.Constants.EDIT_MODE_MIN_CUSTOM_UID - 1)
    local layoutsArray = layoutsData.layouts
    if targetIndex < 1 or targetIndex > #layoutsArray then return nil end

    local activeLayoutInfo = layoutsArray[targetIndex]
    if not activeLayoutInfo or not activeLayoutInfo.systems then return nil end

    local successConvert, layoutString = pcall(C_EditMode.ConvertLayoutInfoToString, activeLayoutInfo)
    if not successConvert or not layoutString then return nil end

    return layoutString, activeLayoutInfo.layoutName
end

function GQol.EditMode.SaveCurrentLayout()
    local layoutString, layoutName = GetActiveLayoutDetails()
    if layoutString and layoutName then
        GQol.db.profile.editModeLayout = {
            name = layoutName,
            string = layoutString
        }
        GQol.Utils.SendMessage("EDIT_MODE_LAYOUT_SAVED")
    end
end

function GQol.EditMode.ApplyCurrentLayout()
    local saved = GQol.db.profile.editModeLayout
    if not saved or not saved.string then
        return GQol.Utils.SendApplyMessage("CANNOT_APPLY_EDIT_MODE_LAYOUT")
    end

    if not IsEditModeAPIAvailable() then
        return GQol.Utils.SendApplyMessage("CANNOT_APPLY_EDIT_MODE_LAYOUT")
    end

    local currentLayoutString = GetActiveLayoutDetails()
    if currentLayoutString == saved.string then
        return GQol.Utils.SendApplyMessage("EDIT_MODE_LAYOUT_ALREADY_CURRENT")
    end

    local successConvert, parsedLayout = pcall(C_EditMode.ConvertStringToLayoutInfo, saved.string)
    if not successConvert or not parsedLayout or not parsedLayout.systems then
        return GQol.Utils.SendApplyMessage("CANNOT_APPLY_EDIT_MODE_LAYOUT")
    end

    local layoutData = {
        layoutName = saved.name,
        layoutType = GQol.Constants.EDIT_MODE_LAYOUT_TYPE_CUSTOM,
        systems = parsedLayout.systems
    }

    local saveData = {
        layouts = {layoutData},
        activeLayout = GQol.Constants.EDIT_MODE_TARGET_UID,
        hasActiveLayoutBeenModifiedSinceLastSave = true
    }

    local successSave = pcall(C_EditMode.SaveLayouts, saveData)
    if not successSave then
        return GQol.Utils.SendApplyMessage("CANNOT_APPLY_EDIT_MODE_LAYOUT")
    end

    C_Timer.After(GQol.Constants.EDIT_MODE_APPLY_DELAY_1, function()
        C_Timer.After(GQol.Constants.EDIT_MODE_APPLY_DELAY_2, function()
            local successActivate = pcall(C_EditMode.SetActiveLayout, tostring(GQol.Constants.EDIT_MODE_TARGET_UID))
            if successActivate then
                GQol.Utils.SendApplyMessage("EDIT_MODE_LAYOUT_APPLIED")
            end
        end)
    end)
end

-- ====================== 宏模块 ======================
GQol.Macros = GQol.Macros or {}
local Macros = GQol.Macros
local L = GQol.L -- 引入本地化表

-- 抽象的宏遍历函数
local function IterateMacros(startIndex, endIndex, callback)
    if not callback then return end
    
    for i = startIndex, endIndex do
        local name, iconTexture, body = GetMacroInfo(i)
        if name and name ~= "" then
            callback(i, name, iconTexture, body)
        end
    end
end

-- 获取当前角色职业
function Macros.GetCurrentCharacterClass()
    local classToken, localizedClassName = UnitClass("player")
    return classToken, localizedClassName
end

-- 按名称查找宏
function Macros.FindMacroByName(macroName)
    if not macroName or macroName == "" then return nil end
    
    -- 遍历所有宏槽位
    for i = 1, GQol.Constants.CHAR_MACRO_RANGE[2] do
        local name = GetMacroInfo(i)
        if name == macroName then
            return i
        end
    end
    return nil
end

-- 保存账号宏
function Macros.SaveAccountMacros()
    GQol.db.profile.accountMacros = {}
    local savedCount = 0
    local start, endIdx = unpack(GQol.Constants.ACC_MACRO_RANGE)

    IterateMacros(start, endIdx, function(_, name, _, body) -- 修正参数位（i, name, icon, body）
        table.insert(GQol.db.profile.accountMacros, { name = name, body = GQol.Utils.SafeTrim(body) })
        savedCount = savedCount + 1
    end)
    
    GQol.Utils.SendMessage("ACCOUNT_MACROS_SAVED", savedCount)
end

-- 应用账号宏
function Macros.ApplyAccountMacros()
    if not GQol.db or not GQol.db.profile.accountMacros or GQol.Utils.IsEmpty(GQol.db.profile.accountMacros) then
        GQol.Utils.SendMessage("NO_ACCOUNT_MACROS_TO_APPLY")
        return -- 无保存数据时直接返回，不执行后续删除逻辑
    end

    local savedMacrosData = GQol.db.profile.accountMacros
    local updatedCount = 0
    local createdCount = 0
    local deletedCount = 0
    local appliedMacroNames = {}
    local start, endIdx = unpack(GQol.Constants.ACC_MACRO_RANGE)

    -- 第一步：应用保存的宏（原有逻辑不变）
    for _, macroData in ipairs(savedMacrosData) do
        if macroData.name and macroData.name ~= "" and macroData.body then
            local existingIndex = Macros.FindMacroByName(macroData.name)
            
            if existingIndex then
                -- 存在则检查内容是否更新
                local _, currentIcon, currentBody = GetMacroInfo(existingIndex)
                if GQol.Utils.SafeTrim(currentBody or "") ~= GQol.Utils.SafeTrim(macroData.body) then
                    EditMacro(existingIndex, macroData.name, currentIcon, macroData.body)
                    updatedCount = updatedCount + 1
                end
            else
                -- 不存在则创建
                CreateMacro(macroData.name, "INV_Misc_QuestionMark", macroData.body, false)
                createdCount = createdCount + 1
            end
            
            appliedMacroNames[macroData.name] = true
        end
    end

    -- 第二步：仅当有保存数据时，才删除多余宏（原有逻辑不变）
    local macrosToDelete = {}
    IterateMacros(start, endIdx, function(index, name, icon, body)
        if name and name ~= "" and name ~= "placeholder" and not appliedMacroNames[name] then
            table.insert(macrosToDelete, {index = index})
        end
    end)
    
    -- 从后往前删除，避免索引错乱
    table.sort(macrosToDelete, function(a, b) return a.index > b.index end)
    for _, macroInfo in ipairs(macrosToDelete) do
        DeleteMacro(macroInfo.index)
        deletedCount = deletedCount + 1
    end

    -- 输出结果（原有逻辑不变）
    if updatedCount > 0 or createdCount > 0 or deletedCount > 0 then
        GQol.Utils.SendApplyMessage("ACCOUNT_MACROS_APPLIED_DETAILED", createdCount, updatedCount, deletedCount)
    else
        GQol.Utils.SendApplyMessage("ACCOUNT_MACROS_NO_CHANGES_NEEDED")
    end
end

-- 保存职业宏
function Macros.SaveClassMacros()
    if not GQol.db then
        GQol.Utils.SendMessage("ERROR_DATABASE_NOT_INITIALIZED")
        return
    end
    
    local classToken = Macros.GetCurrentCharacterClass()
    if not classToken or classToken == "" then
        GQol.Utils.SendMessage("PLAYER_CLASS_UNAVAILABLE")
        return
    end

    GQol.db.profile.classMacros = GQol.db.profile.classMacros or {}
    GQol.db.profile.classMacros[classToken] = {}
    local savedCount = 0
    local start, endIdx = unpack(GQol.Constants.CHAR_MACRO_RANGE)

    IterateMacros(start, endIdx, function(index, name, icon, body) -- 修正参数位
        table.insert(GQol.db.profile.classMacros[classToken], { name = name, body = GQol.Utils.SafeTrim(body) })
        savedCount = savedCount + 1
    end)
    
    GQol.Utils.SendMessage("CLASS_MACROS_SAVED", savedCount)
end

-- 应用职业宏
function Macros.ApplyClassMacros()
    -- 修复1：定义缺失的 classToken 变量
    local classToken = Macros.GetCurrentCharacterClass()
    if not classToken or classToken == "" then
        GQol.Utils.SendApplyMessage("PLAYER_CLASS_UNAVAILABLE")
        return
    end

    -- 修复2：增加空值安全判断，避免 nil 传入 ipairs
    if not GQol.db.profile.classMacros or not GQol.db.profile.classMacros[classToken] or GQol.Utils.IsEmpty(GQol.db.profile.classMacros[classToken]) then
        GQol.Utils.SendApplyMessage("NO_CLASS_MACROS_TO_APPLY")
        return -- 无保存数据时直接返回，不执行删除
    end

    local savedMacrosData = GQol.db.profile.classMacros[classToken]
    local updatedCount = 0
    local createdCount = 0
    local deletedCount = 0
    local appliedMacroNames = {}
    local start, endIdx = unpack(GQol.Constants.CHAR_MACRO_RANGE)

    -- 第一步：应用保存的宏（原有逻辑不变）
    for _, macroData in ipairs(savedMacrosData) do
        if macroData.name and macroData.name ~= "" and macroData.body then
            local existingIndex = Macros.FindMacroByName(macroData.name)
            
            if existingIndex then
                -- 存在则检查内容是否更新
                local currentName, currentIcon, currentBody = GetMacroInfo(existingIndex)
                if GQol.Utils.SafeTrim(currentBody or "") ~= GQol.Utils.SafeTrim(macroData.body) then
                    EditMacro(existingIndex, macroData.name, currentIcon, macroData.body)
                    updatedCount = updatedCount + 1
                end
            else
                -- 不存在则创建
                CreateMacro(macroData.name, "INV_Misc_QuestionMark", macroData.body, true)
                createdCount = createdCount + 1
            end
            
            appliedMacroNames[macroData.name] = true
        end
    end

    -- 第二步：仅当有保存数据时，才删除多余宏（原有逻辑不变）
    local macrosToDelete = {}
    IterateMacros(start, endIdx, function(index, name)
        if name and name ~= "" and name ~= "placeholder" and not appliedMacroNames[name] then
            table.insert(macrosToDelete, {index = index})
        end
    end)
    
    -- 从后往前删除
    table.sort(macrosToDelete, function(a, b) return a.index > b.index end)
    for _, macroInfo in ipairs(macrosToDelete) do
        DeleteMacro(macroInfo.index)
        deletedCount = deletedCount + 1
    end

    -- 输出结果（原有逻辑不变）
    if updatedCount > 0 or createdCount > 0 or deletedCount > 0 then
        GQol.Utils.SendApplyMessage("CLASS_MACROS_APPLIED_DETAILED", createdCount, updatedCount, deletedCount)
    else
        GQol.Utils.SendApplyMessage("CLASS_MACROS_NO_CHANGES_NEEDED")
    end
end

-- ====================== 动作条模块 ======================
GQol.ActionBars = {}
local ActionBarSet = {}
ActionBarSet.__index = ActionBarSet

function ActionBarSet:New(data)
    local self = data or {}
    setmetatable(self, ActionBarSet)
    self.actions = self.actions or {}
    self.autoSwitch = self.autoSwitch or true
    return self
end

function ActionBarSet:Activate(specName)
    local currentSpecID = select(1, GetSpecializationInfo(GetSpecialization()))
    if self.specID and currentSpecID ~= self.specID then
        for i = 1, GetNumSpecializations() do
            if select(1, GetSpecializationInfo(i)) == self.specID then
                GQol.Utils.SendApplyMessage("SWITCHING_SPECIALIZATION_FOR_SET", self.name)
                GQol.pendingActionBarSet = self
                C_SpecializationInfo.SetSpecialization(i)
                return
            end
        end
    end
    self:ActivateInternal(specName)
end

function ActionBarSet:ActivateInternal(specName)
    local changed = 0
    for slot = 1, GQol.Constants.MAX_ACTION_SLOTS do
        local saved = self.actions[slot]
        if not GQol.ActionBars.CompareSlot(slot, saved) then
            GQol.ActionBars.SetActionToSlot(slot, saved)
            changed = changed + 1
        end
    end
    GQol.Utils.SendApplyMessage("ACTIVATED_ACTION_BAR_SET", specName)
end

function GQol.ActionBars.GetActionInfoTable(slot)
    local actionType, id, subType = GetActionInfo(slot)
    if not actionType then return nil end

    local info = {
        type = actionType,
        id = id,
        subType = subType,
        icon = GetActionTexture(slot),
        name = GetActionText(slot)
    }

    -- 宏：保存宏名
    if actionType == "macro" then
        local macroName = GetActionText(slot)
        if macroName then
            local idx = GetMacroIndexByName(macroName)
            if idx > 0 then
                local _, _, body = GetMacroInfo(idx)
                info.macroName = macroName
                info.macroText = GQol.Utils.SafeTrim(body)
            end
        end
    -- 技能
    elseif actionType == "spell" and id then
        local spellInfo = C_Spell.GetSpellInfo(id)
        info.name = spellInfo and spellInfo.name or info.name
    -- 物品：关键！保存 itemID
    elseif actionType == "item" and id then
        info.itemID = id
    end

    return info
end

function GQol.ActionBars.CompareSlot(slot, saved)
    if not saved then
        return GetActionInfo(slot) == nil
    end

    local t, id, subType = GetActionInfo(slot)
    if saved.type ~= t then return false end

    -- 宏：按宏名匹配
    if t == "macro" then
        return saved.macroName == GetActionText(slot)
    -- 物品：按 itemID 匹配
    elseif t == "item" then
        return saved.itemID == id
    -- 技能：按 id 匹配
    else
        return saved.id == id
    end
end

function GQol.ActionBars.SetActionToSlot(slot, data)
    ClearCursor()
    if not data then return end

    -- 技能
    if data.type == "spell" and data.id then
        C_Spell.PickupSpell(data.id)
        PlaceAction(slot)

    -- 宏：按名称拾取
    elseif data.type == "macro" and data.macroName then
        local idx = GetMacroIndexByName(data.macroName)
        if idx and idx > 0 then
            PickupMacro(idx)
            PlaceAction(slot)
        end

    -- 物品：按 itemID 拾取（修复）
    elseif data.type == "item" and data.itemID then
        PickupItem(data.itemID)
        PlaceAction(slot)
    end

    ClearCursor()
end

function GQol.ActionBars.SaveCurrentSpecSet()
    local specIndex = GetSpecialization()
    local specID, specName = GetSpecializationInfo(specIndex)
    local classToken = GQol.Utils.GetPlayerClassToken()

    local sets = GQol.db.profile.actionBarSets or {}
    local existingID = nil
    
    for id, set in pairs(sets) do
        if set.class == classToken and set.specID == specID then
            existingID = id
            break
        end
    end

    local set
    if existingID then
        set = sets[existingID]
    else
        local newID = #sets + 1
        set = ActionBarSet:New({
            setID = newID, 
            name = specName, 
            class = classToken, 
            specID = specID
        })
        sets[newID] = set
    end

    for slot = 1, GQol.Constants.MAX_ACTION_SLOTS do
        set.actions[slot] = GQol.ActionBars.GetActionInfoTable(slot)
    end

    GQol.db.profile.actionBarSets = sets
    GQol.Utils.SendMessage("ACTION_BAR_SAVED", specName)
end

function GQol.ActionBars.HasSavedSet(classToken, specID)
    local sets = GQol.db.profile.actionBarSets or {}
    for _, set in pairs(sets) do
        if set.class == classToken and set.specID == specID then
            return true
        end
    end
    return false
end

function GQol.ActionBars.RestoreMetatable(set)
    if set and not getmetatable(set) then
        setmetatable(set, ActionBarSet)
    end
    return set
end

function GQol.ActionBars.ApplyCurrentSpecSet()
    local specIndex = GetSpecialization()
    local specID, specName = GetSpecializationInfo(specIndex)
    local classToken = GQol.Utils.GetPlayerClassToken()
    local sets = GQol.db.profile.actionBarSets or {}
    
    for _, set in pairs(sets) do
        if set.class == classToken and set.specID == specID then
            GQol.ActionBars.RestoreMetatable(set)
            set:Activate(specName)
            return
        end
    end
    
    GQol.Utils.SendApplyMessage("NO_ACTION_BAR_SET_TO_APPLY")
end

function GQol.ActionBars.AutoSwitchForCurrentSpec()
    local specIndex = GetSpecialization()
    local specID, specName = GetSpecializationInfo(specIndex)
    local sets = GQol.db.profile.actionBarSets or {}
    
    for _, set in pairs(sets) do
        if set.autoSwitch and set.specID == specID then
            GQol.ActionBars.RestoreMetatable(set)
            set:ActivateInternal(specName)
            return
        end
    end
end

-- ====================== 系统模块 ======================
GQol.System = {}

function GQol.System.SaveSystemCVars()
    local cvars = {
        "graphicsQuality", "textureFilteringMode", "shadowQuality", "particleDensity", "SSAO",
        "maxFPS", "maxFPSBk", "vsync", "gxWindow", "gxMaximize", "gxResolution", "gxRefresh",
        "nameplateMaxDistance", "nameplateShowAll", "nameplateShowEnemies",
        "enableFloatingCombatText", "SpellQueueWindow", "cameraDistanceMaxZoomFactor",
        "autoLootDefault", "showTargetOfTarget", "alwaysShowActionBars",
        "Sound_MasterVolume", "Sound_SFXVolume", "Sound_MusicVolume"
    }

    local savedCVars = {}
    for _, cvar in ipairs(cvars) do
        local value = GetCVar(cvar)
        if value ~= nil then
            savedCVars[cvar] = value
        end
    end

    GQol.db.profile.systemCVars = savedCVars
    GQol.Utils.SendMessage("SYSTEM_CVARS_SAVED")
end

function GQol.System.ApplySystemCVars()
    if GQol.Utils.IsEmpty(GQol.db.profile.systemCVars) then
        return GQol.Utils.SendApplyMessage("CANNOT_APPLY_SYSTEM_CVARS")
    end

    local changed = 0
    for cvar, value in pairs(GQol.db.profile.systemCVars) do
        if GetCVar(cvar) ~= value then
            SetCVar(cvar, value)
            changed = changed + 1
        end
    end

    GQol.Utils.SendApplyMessage("SYSTEM_CVARS_APPLIED_WITH_CHANGES", changed)
end

function GQol.System.SaveKeybindings()
    local bindings = {}
    for i = 1, GetNumBindings() do
        local command, _, key1, key2 = GetBinding(i)
        if command then
            bindings[command] = {key1, key2}
        end
    end

    GQol.db.profile.keybindings = bindings
    GQol.Utils.SendMessage("KEYBINDINGS_SAVED")
end

function GQol.System.ApplyKeybindings()
    local saved = GQol.db.profile.keybindings
    if GQol.Utils.IsEmpty(saved) then
        return GQol.Utils.SendApplyMessage("CANNOT_APPLY_KEYBINDINGS")
    end

    for i = 1, GetNumBindings() do
        local _, _, key1, key2 = GetBinding(i)
        if key1 then SetBinding(key1) end
        if key2 then SetBinding(key2) end
    end

    local applied = 0
    for command, keys in pairs(saved) do
        local k1, k2 = keys[1], keys[2]
        if k1 then SetBinding(k1, command); applied = applied + 1 end
        if k2 then SetBinding(k2, command); applied = applied + 1 end
    end

    SaveBindings(GetCurrentBindingSet())
    GQol.Utils.SendApplyMessage("KEYBINDINGS_APPLIED")
end

local function InitAllAutoLoad()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    
    eventFrame:SetScript("OnEvent", function(_, event, unit)
        -- 登录/重载界面：全模块自动加载（只执行1次）
        if event == "PLAYER_ENTERING_WORLD" then
            -- 延迟1.2秒 → 保证游戏UI/EditMode/宏系统完全加载完毕
            C_Timer.After(1.2, function()
                -- 1. 自动应用编辑模式布局（仅开启开关时）
                if GQol.db.profile.autoApplyEditModeOnLogin and GQol.EditMode and GQol.EditMode.ApplyCurrentLayout then
                    GQol.EditMode.ApplyCurrentLayout()
                end
                -- 2. 自动应用账号宏 + 职业宏（仅开启开关时）
                if GQol.Macros then
                    if GQol.db.profile.autoApplyAccountMacrosOnLogin and GQol.Macros.ApplyAccountMacros then
                        GQol.Macros.ApplyAccountMacros()
                    end
                    if GQol.db.profile.autoApplyClassMacrosOnLogin and GQol.Macros.ApplyClassMacros then
                        GQol.Macros.ApplyClassMacros()
                    end
                end
                -- 3. 自动应用系统CVars设置（仅开启开关时）
                if GQol.db.profile.autoApplySystemOnLogin and GQol.System and GQol.System.ApplySystemCVars then
                    GQol.System.ApplySystemCVars()
                end
                -- 4. 自动应用按键绑定（仅开启开关时）
                if GQol.db.profile.autoApplyKeybindingsOnLogin and GQol.System and GQol.System.ApplyKeybindings then
                    GQol.System.ApplyKeybindings()
                end
                -- 5. 最后自动切换动作条（仅开启开关时）
                if GQol.db.profile.autoApplyActionBarsOnLogin then
                    GQol.ActionBars.AutoSwitchForCurrentSpec()
                end
            end)

        -- 专精切换：仅自动切换动作条（不重复加载其他模块）
        elseif event == "PLAYER_SPECIALIZATION_CHANGED" and unit == "player" then
            C_Timer.After(0.5, function()
                if GQol.pendingActionBarSet then
                    GQol.pendingActionBarSet:ActivateInternal()
                    GQol.pendingActionBarSet = nil
                end
                if GQol.db.profile.autoApplyActionBarsOnLogin then
                    GQol.ActionBars.AutoSwitchForCurrentSpec()
                end
            end)
        end
    end)
end
InitAllAutoLoad()