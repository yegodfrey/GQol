local GQol = _G.GQol
local Utils, L = GQol.Utils, GQol.L

GQol.Sound = GQol.Sound or {}
local Sound = GQol.Sound
local DEFAULT_FRAME = "ChatFrameChannelButton"

-- 工具函数
local function GetRelativeFrame()
    return _G[DEFAULT_FRAME]
end

local function SavePos(frame, key)
    local db = GQol.db.global
    local rel = GetRelativeFrame()
    local cx, cy = frame:GetCenter()

    db.sound[key] = rel and {
        point = "CENTER",
        relativeFrame = DEFAULT_FRAME,
        relativePoint = "CENTER",
        x = cx - rel:GetCenter(),
        y = cy - select(2, rel:GetCenter())
    } or {
        point = "CENTER",
        x = cx, y = cy
    }
end

local function MakeDraggable(frame, key)
    local dragging = false
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        if IsShiftKeyDown() then
            dragging = true
            frame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function()
        if dragging then
            frame:StopMovingOrSizing()
            dragging = false
            SavePos(frame, key)
        end
    end)
end

local function CreateIcon(name, posKey, sizeKey, default)
    local f = CreateFrame("Frame", name, UIParent)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("MEDIUM")

    local db = GQol.db.global

    local size = db.sound[sizeKey] or default or 34
    f:SetSize(size, size)
    f:ClearAllPoints()

    local pos = db.sound[posKey]
    if pos then
        local rel = pos.relativeFrame and _G[pos.relativeFrame]
        if rel then
            f:SetPoint(pos.point, rel, pos.relativePoint, pos.x, pos.y)
        else
            f:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 0, pos.y or 0)
        end
    else
        local rel = GetRelativeFrame()
        f:SetPoint("CENTER", rel or UIParent, "CENTER", 0, 0)
    end

    MakeDraggable(f, posKey)
    return f
end

-- 核心功能
function Sound:UpdateMuteIcon()
    if not self.icon then return end
    local enabled = GetCVar("Sound_EnableAllSound") == "1"
    self.icon:SetAtlas(enabled and "voicechat-icon-speaker" or "voicechat-icon-speaker-mute")
    self.icon:SetVertexColor(enabled and 0 or 1, enabled and 1 or 0, 0, 1)
end

function Sound:ToggleSound()
    if InCombatLockdown() then return end
    SetCVar("Sound_EnableAllSound", GetCVar("Sound_EnableAllSound") == "1" and "0" or "1")
    self:UpdateMuteIcon()
end

function Sound:CycleOutputDevice()
    if InCombatLockdown() then return end
    local total = Sound_GameSystem_GetNumOutputDrivers()
    if total <= 1 then return end

    local current = tonumber(GetCVar("Sound_OutputDriverIndex")) or 0
    local list, curIdx = {}, nil

    for i = 1, total - 1 do
        local name = Sound_GameSystem_GetOutputDriverNameByIndex(i)
        if name and name ~= "" then
            tinsert(list, {i = i, n = name})
            if i == current then curIdx = #list end
        end
    end

    if #list == 0 then return end
    local next = list[curIdx and curIdx % #list + 1 or 1]
    SetCVar("Sound_OutputDriverIndex", next.i)
    Sound_GameSystem_RestartSoundSystem()
    Utils:SendApplyMessage("SOUND_DEVICE_SWITCHED", next.n)
end

-- 初始化
function Sound:OnInitialize()
    if self.frame then return end

    self.frame = CreateIcon("GQol_SoundFrame", "position", "iconSize", 34)
    self.icon = self.frame:CreateTexture(nil, "ARTWORK")
    self.icon:SetAllPoints()

    self.frame:SetScript("OnMouseUp", function(_, btn)
        if btn == "LeftButton" and not IsShiftKeyDown() then
            self:ToggleSound()
        elseif btn == "RightButton" then
            self:CycleOutputDevice()
        end
    end)

    Utils:SetupTooltip(self.frame, function()
        local dev = Sound_GameSystem_GetOutputDriverNameByIndex(GetCVar("Sound_OutputDriverIndex"))
        return {
            {L["SOUND_TOOLTIP_TITLE"], 0.3,0.7,1},
            {L["SOUND_DEVICE"].." |cFFFFFFFF"..(dev or "").."|r"},
            {" "},
            {L["SOUND_LEFT_BUTTON"], 0,1,0},
            {L["SOUND_RIGHT_BUTTON"], 0,1,0},
            {L["SOUND_DRAG_TOOLTIP"], 0.7,0.7,1},
        }
    end, "ANCHOR_BOTTOM")

    self:UpdateMuteIcon()
    if not GQol.db.global.sound.iconEnabled then
        self.frame:Hide()
    end

    self:InitLDB()
end

-- 开关/大小/重置
function Sound:SetIconSize(val)
    self.frame:SetSize(val or 34, val or 34)
end

function Sound:OnEnable()
    if not self.frame then self:OnInitialize() end
    self:RegisterEvent("CVAR_UPDATE", function(_, arg1)
        if arg1 == "Sound_EnableAllSound" then
            self:UpdateMuteIcon()
            self:UpdateLDBIcon()
        end
    end)
    if GQol.db.global.sound.iconEnabled then
        self.frame:Show()
    end
    self:UpdateLDBIcon()
end

function Sound:OnDisable()
    self:UnregisterEvent("CVAR_UPDATE")
    if self.frame then self.frame:Hide() end
    self:UpdateLDBIcon()
end

function Sound:SetIconEnabled(enable)
    if enable then
        if not self.frame then self:OnInitialize() end
        self.frame:Show()
        Utils:SendApplyMessage("SOUND_ENABLED")
    else
        if self.frame then self.frame:Hide() end
        Utils:SendApplyMessage("SOUND_DISABLED")
    end
end

function Sound:ResetPosition()
    local db = GQol.db.global
    local rel = GetRelativeFrame()
    db.sound.position = {
        point = "CENTER",
        relativeFrame = rel and DEFAULT_FRAME or nil,
        relativePoint = "CENTER",
        x = 0, y = 0
    }
    if self.frame then
        self.frame:ClearAllPoints()
        self.frame:SetPoint("CENTER", rel or UIParent, "CENTER", 0, 0)
    end
    Utils:SendApplyMessage("SOUND_POSITION_RESET")
end

-- 配置面板
function Sound:GetOptions()
    local CH = Utils.ConfigHelpers
    return {
        iconEnabled = CH.GlobalToggle(66, "SOUND_ENABLE_CBOX", "sound.iconEnabled", function(v)
            self:SetIconEnabled(v)
        end),
        ldbEnabled = CH.GlobalToggle(67, "SOUND_LDB_ENABLE_CBOX", "sound.ldbEnabled", function(v)
            self:SetLDBEnabled(v)
        end),
        iconSize = CH.GlobalRange(68, "SOUND_ICON_SIZE_SLIDER", "sound.iconSize", 15, 60, 1, function(v)
            self:SetIconSize(v)
        end),
        resetPosition = CH.Execute(69, "SOUND_RESET_POSITION_BTN", Utils:ModuleExecute("Sound", "ResetPosition")),
    }
end

-- ==============================================
-- LDB 模块（完全隔离，ElvUI不存在时不执行）
-- ==============================================
function Sound:InitLDB()
    -- 严格依赖检查：无LDB库 或 无ElvUI 或 已初始化 → 直接返回
    local LDB = LibStub and LibStub:GetLibrary('LibDataBroker-1.1', true)
    if not LDB or not ElvUI or self.LDBInitialized then return end

    local E, DT
    local function TryLoadElvUIDT()
        if E and DT then return end
        E = unpack(ElvUI)
        DT = E and E.GetModule and E:GetModule('DataTexts')
    end

    -- LDB 图标本体
    self.LDBIcon = LDB:NewDataObject('GQol_Sound', {
        type = 'data source',
        text = L["SOUND_TOOLTIP_TITLE"],
        iconAtlas = "voicechat-icon-speaker", -- 和主图标统一使用Atlas
        OnClick = function(_, btn)
            if InCombatLockdown() then return end
            if btn == 'LeftButton' then
                self:ToggleSound()
            elseif btn == 'RightButton' then
                self:CycleOutputDevice()
            end
        end,
        OnTooltipShow = function(tooltip)
            local enabled = GetCVar("Sound_EnableAllSound") == "1"
            local dev = Sound_GameSystem_GetOutputDriverNameByIndex(GetCVar("Sound_OutputDriverIndex"))

            tooltip:AddLine(L["SOUND_TOOLTIP_TITLE"], 0.3, 0.7, 1)
            tooltip:AddLine(L["SOUND_DEVICE"] .. ": |cFFFFFFFF" .. (dev or "") .. "|r")
            tooltip:AddLine(" ")
            tooltip:AddLine(L["SOUND_LEFT_BUTTON"], 0, 1, 0)
            tooltip:AddLine(L["SOUND_RIGHT_BUTTON"], 0, 1, 0)
        end,
    })

    -- LDB 图标状态更新
    function self:UpdateLDBIcon()
		if not self.LDBIcon then return end

		if not GQol.db.global.sound.ldbEnabled then
			self.LDBIcon.iconAtlas = "voicechat-icon-speaker-mute"
			return
		end

		local enabled = GetCVar("Sound_EnableAllSound") == "1"
		self.LDBIcon.iconAtlas = enabled and "voicechat-icon-speaker" or "voicechat-icon-speaker-mute"
	end

    -- LDB 开关控制
    function self:SetLDBEnabled(enable)
        GQol.db.global.sound.ldbEnabled = enable
        self:UpdateLDBIcon()
        
        -- 刷新ElvUI数据文本
        TryLoadElvUIDT()
        if DT then
            DT:RegisterLDB()
            DT:UpdateQuickDT()
            DT:LoadDataTexts()
        end
    end

    -- 刷新ElvUI LDB注册
    local function RefreshAllLDB()
        TryLoadElvUIDT()
        if not DT then return end

        DT:RegisterLDB()
        DT:UpdateQuickDT()
        DT:LoadDataTexts()

        for dtSlot, dtInfo in pairs(DT.AssignedDatatexts or {}) do
            if dtInfo.isLDB and dtInfo.eventFunc then
                dtInfo.eventFunc(dtSlot, 'ELVUI_FORCE_UPDATE')
            end
        end
    end

    self:RegisterEvent("PLAYER_LOGIN", function()
        C_Timer.After(0.5, function()
            self:UpdateLDBIcon()
            RefreshAllLDB()
        end)
    end)

    self.LDBInitialized = true
end