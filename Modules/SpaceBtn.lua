local GQol = _G.GQol
local Utils = GQol.Utils

GQol.SpaceBtn = GQol.SpaceBtn or {}
local SpaceBtn = GQol.SpaceBtn
SpaceBtn.frame = nil
SpaceBtn.gossipList = {}
SpaceBtn.inCombat = false

local function IsSpaceBtnEnabled()
    return GQol.db.global.spaceBtn.enabled
end

local function IsFrameShown(name)
    return _G[name] and _G[name]:IsVisible()
end

local function ClickButton(btn)
    if btn and btn:IsEnabled() and btn:IsVisible() then
        btn:Click()
        return true
    end
    return false
end

local function HasValidWindow()
    if IsFrameShown("QuestFrame") or IsFrameShown("GossipFrame") then return true end
    if IsFrameShown("InteractionFrame") then return true end
    if IsFrameShown("PVPMatchResults") then return true end
    if IsFrameShown("ProfessionsFrame") then return true end
    if IsFrameShown("LFGDungeonReadyDialog") or IsFrameShown("PVPReadyDialog")
        or IsFrameShown("LFGListInviteDialog") or IsFrameShown("ReadyCheckFrame")
        or IsFrameShown("LFDRoleCheckPopup") then
        return true
    end
    for i = 1, 8 do
        if IsFrameShown("StaticPopup" .. i) then return true end
    end
    return false
end

local function HandleDialogPopup()
    for i = 1, 8 do
        local frame = _G["StaticPopup"..i]
        if frame and frame:IsVisible() then
            if ClickButton(_G["StaticPopup"..i.."Button1"]) then
                return true
            end
        end
    end

    if LFGDungeonReadyDialog and ClickButton(LFGDungeonReadyDialog.EnterDungeonButton) then return true end
    if PVPReadyDialog and ClickButton(PVPReadyDialog.EnterBattleButton) then return true end
    if LFGListInviteDialog and ClickButton(LFGListInviteDialog.AcceptButton) then return true end
    if ReadyCheckFrame and ClickButton(ReadyCheckFrameYesButton) then return true end
    if LFDRoleCheckPopup and ClickButton(LFDRoleCheckPopup.AcceptButton) then return true end
    if PVPMatchResults and ClickButton(PVPMatchResults.leaveButton) then return true end

    return false
end

local function HandleQuestFrame()
    if not QuestFrame:IsVisible() then return false end
    
    if ClickButton(QuestFrameAcceptButton) then
        return true
    elseif ClickButton(QuestFrameCompleteButton) then
        return true
    elseif ClickButton(QuestFrameCompleteQuestButton) then
        return true
    end
    
    return false
end

local function HandleGossipFrame(index)
    -- 11.0 兼容：InteractionFrame 和 GossipFrame 逻辑通用
    if not IsFrameShown("GossipFrame") and not IsFrameShown("InteractionFrame") then return false end
    
    wipe(SpaceBtn.gossipList)

    -- 安全获取数据
    local available = C_GossipInfo.GetAvailableQuests()
    if available then
        for _, v in ipairs(available) do
            table.insert(SpaceBtn.gossipList, { type = "avail", id = v.questID })
        end
    end

    local active = C_GossipInfo.GetActiveQuests()
    if active then
        for _, v in ipairs(active) do
            table.insert(SpaceBtn.gossipList, { type = "active", id = v.questID })
        end
    end

    local options = C_GossipInfo.GetOptions()
    if options then
        for _, v in ipairs(options) do
            table.insert(SpaceBtn.gossipList, { type = "option", id = v.gossipOptionID })
        end
    end

    local item = SpaceBtn.gossipList[index]
    if item then
        if item.type == "avail" then
            C_GossipInfo.SelectAvailableQuest(item.id)
        elseif item.type == "active" then
            C_GossipInfo.SelectActiveQuest(item.id)
        else
            C_GossipInfo.SelectOption(item.id)
        end
        return true
    end
    return false
end

local function HandleProfessionsFrame()
    if not ProfessionsFrame or not ProfessionsFrame:IsVisible() then return false end
    
    local ordersPage = ProfessionsFrame.OrdersPage
    if not ordersPage or not ordersPage:IsVisible() then return false end
    
    local orderView = ordersPage.OrderView
    if not orderView or not orderView:IsVisible() then return false end

    -- 优先级 1: 开始订单 (StartOrderButton 位于 OrderInfo 下)
    local orderInfo = orderView.OrderInfo
    if orderInfo and orderInfo.StartOrderButton:IsShown() and orderInfo.StartOrderButton:IsEnabled() then
        orderInfo.StartOrderButton:Click()
        return true
    end

    -- 优先级 2: 制造物品 (CreateButton 位于 OrderView 下)
    -- 注意：制造时 CompleteOrderButton 可能已经 Shown，所以必须先判断制造
    if orderView.CreateButton:IsShown() and orderView.CreateButton:IsEnabled() then
        orderView.CreateButton:Click()
        return true
    end

    -- 优先级 3: 完成订单 (CompleteOrderButton 位于 OrderView 下)
    if orderView.CompleteOrderButton:IsShown() and orderView.CompleteOrderButton:IsEnabled() then
        orderView.CompleteOrderButton:Click()
        return true
    end
    
    return false
end

-- 安全调用SetPropagateKeyboardInput，战斗中绝对不调用
local function SafeSetPropagate(flag)
    if not SpaceBtn.inCombat and SpaceBtn.frame then
        pcall(function() SpaceBtn.frame:SetPropagateKeyboardInput(flag) end)
    end
end

function SpaceBtn:OnInitialize()
    if self.frame then return end

    self.frame = CreateFrame("Frame", "GQol_SpaceBtnFrame", UIParent)
    self.frame:SetPropagateKeyboardInput(true)
    self.frame:EnableKeyboard(true)
    self.frame:SetFrameStrata("TOOLTIP")

    self.frame:SetScript("OnKeyDown", function(f, key)
        if SpaceBtn.inCombat then return end

        f:SetPropagateKeyboardInput(true)

        if key ~= "SPACE" then return end

        if IsSpaceBtnEnabled() and HasValidWindow() then
            local handled = false
            if HandleDialogPopup() then handled = true
            elseif HandleQuestFrame() then handled = true
            elseif HandleGossipFrame(1) then handled = true
            elseif HandleProfessionsFrame() then handled = true
            end

            if handled then
                f:SetPropagateKeyboardInput(false)
            end
        end
    end)

    self.frame:SetScript("OnKeyUp", function() end)

    self.frame:SetShown(IsSpaceBtnEnabled())
end

function SpaceBtn:OnEnable()
    if not self.frame then self:OnInitialize() end
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.frame:SetScript("OnEvent", function(f, event)
        if event == "PLAYER_REGEN_DISABLED" then
            SpaceBtn.inCombat = true
        elseif event == "PLAYER_REGEN_ENABLED" then
            SpaceBtn.inCombat = false
            SafeSetPropagate(true)
        end
    end)
    self.frame:Show()
end

function SpaceBtn:OnDisable()
    if self.frame then
        self.frame:UnregisterAllEvents()
        self.frame:Hide()
    end
    SafeSetPropagate(true)
end

function SpaceBtn:SetEnabled(val)
    if not self.frame then self:OnInitialize() end
    self.frame:SetShown(val)
    SafeSetPropagate(true)
    Utils:SendApplyMessage(val and "SPACEBTN_ENABLED" or "SPACEBTN_DISABLED")
end

function SpaceBtn:GetOptions()
    local CH = Utils.ConfigHelpers
    return {
        enabled = CH.GlobalToggle(61, "SPACEBTN_ENABLE_CBOX", "spaceBtn.enabled", function(val)
            self:SetEnabled(val)
        end),
    }
end