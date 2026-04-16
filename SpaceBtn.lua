local SpaceBtnFrame = CreateFrame("Frame", "SpaceBtnFrame", UIParent)
SpaceBtnFrame:EnableKeyboard(true)

-- 初始化严格按配置，不瞎写默认值
local function GetEnabled()
    return GQol and GQol.db and GQol.db.profile and GQol.db.profile.SpaceBtnEnabled
end
SpaceBtnFrame:SetPropagateKeyboardInput(not GetEnabled())

local function SpaceBtn_HandleKey(index, key)
    if not GetEnabled() then return end

    if QuestFrame and QuestFrame:IsVisible() then
        if index == 1 then
            if QuestFrameAcceptButton and QuestFrameAcceptButton:IsVisible() and QuestFrameAcceptButton:IsEnabled() then
                QuestFrameAcceptButton:Click()
            elseif QuestFrameCompleteButton and QuestFrameCompleteButton:IsVisible() and QuestFrameCompleteButton:IsEnabled() then
                QuestFrameCompleteButton:Click()
            elseif QuestFrameCompleteQuestButton and QuestFrameCompleteQuestButton:IsVisible() and QuestFrameCompleteQuestButton:IsEnabled() then
                if GetNumQuestChoices() == 0 then
                    QuestFrameCompleteQuestButton:Click()
                end
            end
        end
        return
    end

    if key == "SPACE" then
        for i = 1, 4 do
            local popup = _G["StaticPopup"..i]
            if popup and popup:IsVisible() then
                local btn = _G["StaticPopup"..i.."Button1"]
                if btn and btn:IsVisible() and btn:IsEnabled() then
                    btn:Click()
                    break
                end
            end
        end
    end

    if GossipFrame and GossipFrame:IsVisible() then
        local elements = {}
        local avail = C_GossipInfo.GetAvailableQuests()
        if avail then for _, v in ipairs(avail) do table.insert(elements, {t="avail", id=v.questID}) end end
        local active = C_GossipInfo.GetActiveQuests()
        if active then for _, v in ipairs(active) do table.insert(elements, {t="active", id=v.questID}) end end
        local opts = C_GossipInfo.GetOptions()
        if opts then for _, v in ipairs(opts) do table.insert(elements, {t="opt", id=v.gossipOptionID}) end end

        local t = elements[index]
        if t then
            if t.t == "avail" then C_GossipInfo.SelectAvailableQuest(t.id)
            elseif t.t == "active" then C_GossipInfo.SelectActiveQuest(t.id)
            elseif t.t == "opt" then C_GossipInfo.SelectOption(t.id)
            end
        end
    end
end

SpaceBtnFrame:SetScript("OnKeyDown", function(self, key)
    -- 禁用 = 直接放行，不处理任何逻辑
    if not GetEnabled() then
        self:SetPropagateKeyboardInput(true)
        return
    end

    -- 聊天框打开 = 放行
    if ChatEdit_GetActiveWindow() then
        self:SetPropagateKeyboardInput(true)
        return
    end

    local hasWindow = (QuestFrame and QuestFrame:IsVisible())
                   or (GossipFrame and GossipFrame:IsVisible())
    local hasPopup = false
    for i = 1, 4 do
        local f = _G["StaticPopup"..i]
        if f and f:IsVisible() then hasPopup = true break end
    end
    if not hasWindow and not hasPopup then
        self:SetPropagateKeyboardInput(true)
        return
    end

    local index
    if key == "SPACE" or key == "1" then index = 1
    elseif key == "2" then index = 2
    elseif key == "3" then index = 3
    elseif key == "4" then index = 4
    elseif key == "5" then index = 5 end

    if index then
        self:SetPropagateKeyboardInput(false)
        SpaceBtn_HandleKey(index, key)
    else
        self:SetPropagateKeyboardInput(true)
    end
end)