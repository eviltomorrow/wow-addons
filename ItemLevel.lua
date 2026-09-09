local _, ns = ...

local enabled = true

local FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

local PAPERDOLL_SLOTS = {
    { "CharacterHeadSlot", "HeadSlot" },
    { "CharacterNeckSlot", "NeckSlot" },
    { "CharacterShoulderSlot", "ShoulderSlot" },
    { "CharacterBackSlot", "BackSlot" },
    { "CharacterChestSlot", "ChestSlot" },
    { "CharacterWristSlot", "WristSlot" },
    { "CharacterHandsSlot", "HandsSlot" },
    { "CharacterWaistSlot", "WaistSlot" },
    { "CharacterLegsSlot", "LegsSlot" },
    { "CharacterFeetSlot", "FeetSlot" },
    { "CharacterFinger0Slot", "Finger0Slot" },
    { "CharacterFinger1Slot", "Finger1Slot" },
    { "CharacterTrinket0Slot", "Trinket0Slot" },
    { "CharacterTrinket1Slot", "Trinket1Slot" },
    { "CharacterMainHandSlot", "MainHandSlot" },
    { "CharacterSecondaryHandSlot", "SecondaryHandSlot" },
}

local function GetIlvlFrame(button)
    if not button.ILvlFrame then
        local f = CreateFrame("Frame", nil, button)
        f:SetAllPoints(button)
        f:SetFrameLevel(110)
        f:SetFrameStrata("TOOLTIP")
        local fs = f:CreateFontString(nil, "OVERLAY")
        fs:SetFont(FONT, 14, "OUTLINE")
        fs:SetPoint("BOTTOMRIGHT", 1, 1)
        fs:SetJustifyH("RIGHT")
        fs:SetTextColor(1, 1, 1)
        button.ILvlFrame = f
        button.ILvlText = fs
    end
    return button.ILvlFrame, button.ILvlText
end

local function Apply(button, ilvl, quality)
    local f, fs = GetIlvlFrame(button)
    if ilvl and ilvl > 0 then
        local r, g, b = 1, 1, 1
        if quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
            r, g, b = ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b
        end
        fs:SetTextColor(r, g, b)
        fs:SetText(ilvl)
        f:Show()
    else
        fs:SetText("")
        f:Hide()
    end
end

local function DisplayItemLevel(button, link)
    if button.ILvlTicker then
        button.ILvlTicker:Cancel()
        button.ILvlTicker = nil
    end
    if not enabled or not link then
        Apply(button, nil)
        return
    end
    local _, _, quality, ilvl = GetItemInfo(link)
    if ilvl and ilvl > 0 then
        Apply(button, ilvl, quality)
        return
    end
    local attempts = 0
    button.ILvlTicker = C_Timer.NewTicker(0.4, function()
        attempts = attempts + 1
        local _, _, q, lv = GetItemInfo(link)
        if (lv and lv > 0) or attempts >= 5 then
            Apply(button, lv, q)
            if button.ILvlTicker then
                button.ILvlTicker:Cancel()
                button.ILvlTicker = nil
            end
        end
    end)
end

local IS_PAPERDOLL = {}
for _, e in ipairs(PAPERDOLL_SLOTS) do
    IS_PAPERDOLL[e[1]] = true
end

local function ResolveLink(itemIDOrLink)
    if type(itemIDOrLink) == "string" and itemIDOrLink:match("^item:") then
        return itemIDOrLink
    end
    if itemIDOrLink then
        return select(2, GetItemInfo(itemIDOrLink))
    end
end

hooksecurefunc("SetItemButtonQuality", function(self, quality, itemIDOrLink)
    if IS_PAPERDOLL[self:GetName()] then
        return
    end
    DisplayItemLevel(self, ResolveLink(itemIDOrLink))
end)

local function UpdatePaperdoll()
    for _, entry in ipairs(PAPERDOLL_SLOTS) do
        local btn = _G[entry[1]]
        if btn then
            local slot = select(1, GetInventorySlotInfo(entry[2]))
            if slot then
                DisplayItemLevel(btn, GetInventoryItemLink("player", slot))
            end
        end
    end
end

local eqFrame = CreateFrame("Frame")
eqFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eqFrame:SetScript("OnEvent", function()
    if CharacterFrame and CharacterFrame:IsShown() then
        UpdatePaperdoll()
    end
end)

function ns.SetItemLevelEnabled(on)
    enabled = on and true or false
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        enabled = ns.db.itemLevel
        if PaperDollFrame then
            PaperDollFrame:HookScript("OnShow", UpdatePaperdoll)
        end
        UpdatePaperdoll()
    end
end)