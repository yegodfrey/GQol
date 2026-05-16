local GQol = _G.GQol
local Utils, L, CH = GQol.Utils, GQol.L, GQol.Utils.ConfigHelpers

GQol.Mail = GQol.Mail or {}
local Mail = GQol.Mail

local MAX_ATTACHMENTS = 12
local ATTACH_DELAY = 0.35

local function GetMailDB()
    return GQol.db.global.mail
end

local function GetItemNameFromID(itemID)
    local db = GetMailDB()
    if db.itemNames and db.itemNames[itemID] then
        return db.itemNames[itemID]
    end
    local name = C_Item.GetItemInfo(itemID)
    if name then
        if not db.itemNames then db.itemNames = {} end
        db.itemNames[itemID] = name
        return name
    end
    return "ID:" .. itemID
end

local function FindItemsInBags(itemIDs)
    if not itemIDs or #itemIDs == 0 then return {} end
    local found = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and tContains(itemIDs, itemID) then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and not info.isLocked then
                    table.insert(found, { bag = bag, slot = slot, itemID = itemID })
                end
            end
        end
    end
    return found
end

local function AttachNextItem(bagItems, index, recipient, callback)
    if index > #bagItems then
        C_Timer.After(0.1, function() callback(true) end)
        return
    end

    local attachedCount = 0
    for i = 1, MAX_ATTACHMENTS do
        local _, itemID = GetSendMailItem(i)
        if itemID then attachedCount = attachedCount + 1 end
    end

    if attachedCount >= MAX_ATTACHMENTS then
        callback(true)
        return
    end

    local item = bagItems[index]

    C_Container.UseContainerItem(item.bag, item.slot)

    C_Timer.After(ATTACH_DELAY, function()
        local wasAttached = false
        for i = 1, MAX_ATTACHMENTS do
            local _, attachedID = GetSendMailItem(i)
            if attachedID == item.itemID then
                wasAttached = true
                break
            end
        end
        if not wasAttached then
            C_Container.UseContainerItem(item.bag, item.slot)
            C_Timer.After(ATTACH_DELAY, function()
                AttachNextItem(bagItems, index + 1, recipient, callback)
            end)
        else
            AttachNextItem(bagItems, index + 1, recipient, callback)
        end
    end)
end

function Mail:MailItems()
    local db = GetMailDB()
    local recipient = db.recipient or ""

    if recipient == "" then
        Utils:SendApplyMessage("MAIL_NO_RECIPIENT")
        return
    end

    if not MailFrame:IsShown() then
        Utils:SendApplyMessage("MAIL_OPEN_MAILBOX")
        return
    end

    local bagItems = FindItemsInBags(db.itemIDs)
    if #bagItems == 0 then
        Utils:SendApplyMessage("MAIL_NO_ITEMS")
        return
    end

    if self.isSending then return end
    self.isSending = true

    SetSendMailShowing(true)
    SendMailNameEditBox:SetText(recipient)

    AttachNextItem(bagItems, 1, recipient, function(success)
        if success and MailFrame:IsShown() then
            local subject = L["MAIL_DEFAULT_SUBJECT"] or "GQol Auto Mail"
            SendMail(recipient, subject, "")
            Utils:SendApplyMessage("MAIL_SENT", #bagItems, recipient)
        else
            ClearSendMail()
            Utils:SendApplyMessage("MAIL_ATTACH_FAILED")
        end
        self.isSending = false
    end)
end

function Mail:AddItemID(itemID)
    if not itemID then return end
    local db = GetMailDB()
    local id = tonumber(itemID)
    if not id then
        Utils:SendApplyMessage("MAIL_INVALID_ID")
        return
    end
    if tContains(db.itemIDs, id) then
        Utils:SendApplyMessage("MAIL_ITEM_EXISTS", GetItemNameFromID(id))
        return
    end
    table.insert(db.itemIDs, id)
    Utils:SendApplyMessage("MAIL_ITEM_ADDED", GetItemNameFromID(id))
    self:RefreshItemList()
end

function Mail:RemoveItemID(itemID)
    local db = GetMailDB()
    for i, id in ipairs(db.itemIDs) do
        if id == itemID then
            table.remove(db.itemIDs, i)
            Utils:SendApplyMessage("MAIL_ITEM_REMOVED", GetItemNameFromID(itemID))
            self:RefreshItemList()
            return
        end
    end
end

function Mail:SetRecipient(name)
    local db = GetMailDB()
    db.recipient = name or ""
    Utils:SendApplyMessage("MAIL_RECIPIENT_SET", db.recipient)
end

function Mail:RefreshItemList()
    local optionsTable = GQol.optionsTable
    if not optionsTable then return end

    local opts = self:GetOptions()
    local cleanOpts = {}
    for key, opt in pairs(opts) do
		if not CH.IsHeaderKey(key) then
            cleanOpts[key] = opt
        end
    end

    local descKey = "MAIL_DESC"
    local descText = L[descKey] or ""
    if descText ~= "" then
        cleanOpts.desc = Utils.ConfigHelpers.Description(0, descText)
    end

    optionsTable.args["mailtab"].args = cleanOpts
    LibStub("AceConfigRegistry-3.0"):NotifyChange("GQol")
end

function Mail:CreateMailButton()
    if self.mailButton then return end

    local btn = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
    btn:SetSize(120, 22)
    btn:SetPoint("BOTTOMRIGHT", MailFrame, "BOTTOMRIGHT", -10, 0)
    btn:SetText(L["MAIL_SEND_BTN"] or "Send Items")
    btn:SetScript("OnClick", function() self:MailItems() end)
    btn:Hide()

    MailFrame:HookScript("OnShow", function() btn:Show() end)
    MailFrame:HookScript("OnHide", function() btn:Hide() end)

    self.mailButton = btn
end

function Mail:OnInitialize()
    local db = GetMailDB()
    if not db.itemIDs then db.itemIDs = {} end
    if not db.recipient then db.recipient = "" end
    if not db.itemNames then db.itemNames = {} end

    self:CreateMailButton()
end

function Mail:OnEnable()
    if not self.mailButton then self:OnInitialize() end
    if self.mailButton and MailFrame:IsShown() then
        self.mailButton:Show()
    end
end

function Mail:OnDisable()
    if self.mailButton then self.mailButton:Hide() end
end

function Mail:GetOptions()
    local db = GetMailDB()

    local options = {
        enabled = CH.GlobalToggle(1, "MAIL_ENABLE_CBOX", "mail.enabled", function(val)
            if val then
                Utils:SendApplyMessage("MAIL_ENABLED")
            else
                Utils:SendApplyMessage("MAIL_DISABLED")
            end
        end),
        recipient = {
            type = "input",
            order = 2,
            width = "full",
            name = L["MAIL_RECIPIENT_INPUT"] or "Recipient",
            get = function() return db.recipient or "" end,
            set = function(_, val) self:SetRecipient(val) end,
        },
        addItemHeader = CH.Header(3, "MAIL_ADD_ITEM_HEADER"),
        addItemID = {
            type = "input",
            order = 4,
            width = "full",
            name = L["MAIL_ADD_ITEM_INPUT"] or "Add Item ID",
            get = function() return "" end,
            set = function(_, val) self:AddItemID(val) end,
            desc = L["MAIL_ADD_ITEM_DESC"] or "Enter an item ID to add to the auto-mail list",
        },
        itemListHeader = CH.Header(5, "MAIL_ITEM_LIST_HEADER"),
    }

    if db.itemIDs and #db.itemIDs > 0 then
        for i, itemID in ipairs(db.itemIDs) do
            local capturedID = itemID
            local name = GetItemNameFromID(capturedID)
            options["removeItem_" .. capturedID] = {
                type = "execute",
                order = 6 + i,
                width = "full",
                name = (L["MAIL_REMOVE_ITEM_BTN"] or "Remove") .. " " .. name .. " (" .. capturedID .. ")",
                func = function() self:RemoveItemID(capturedID) end,
            }
        end
    else
        options.noItems = CH.Description(6, L["MAIL_NO_ITEMS_LIST"] or "No items in the list")
    end

    return options
end