local _, ns = ...

local frame
local text
local lastStr
local ticker
local durability = 100

local UPDATE_INTERVAL = 0.5
local PAD_X = 14
local PAD_Y = 6
local MIN_W = 40

local EQUIPMENT_SLOTS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }

local function GetAverageDurability()
    local total = 0
    local count = 0
    for _, slot in ipairs(EQUIPMENT_SLOTS) do
        local current, max = GetInventoryItemDurability(slot)
        if current and max then
            total = total + current / max
            count = count + 1
        end
    end
    if count == 0 then
        return 100
    end
    return total / count * 100
end

local function AutoSize()
    local w = math.max(text:GetStringWidth(), MIN_W) + PAD_X * 2
    local h = text:GetHeight() + PAD_Y * 2
    frame:SetSize(w, h)
end

local function Refresh()
    if not text then
        return
    end
    local color = durability >= 50 and "|cff00ff00" or (durability >= 25 and "|cffffff00" or "|cffff0000")
    local str = string.format("FPS: |cffffffff%d|r   耐久: %s%.0f%%|r", GetFramerate(), color, durability)
    if str ~= lastStr then
        lastStr = str
        text:SetText(str)
        AutoSize()
    end
end

local function OnDurabilityChange()
    durability = GetAverageDurability()
    Refresh()
end

local function GetAnchorName(anchor)
    if anchor == UIParent then
        return "UIParent"
    elseif type(anchor) == "string" then
        return anchor
    elseif anchor and anchor.GetName then
        return anchor:GetName() or "UIParent"
    end
    return "UIParent"
end

local function ApplySavedPos()
    local p = ns.db.statusPos
    if not p then
        frame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8, 0)
        return
    end
    local anchor = p[2] == "UIParent" and UIParent or _G[p[2]] or UIParent
    frame:SetPoint(p[1], anchor, p[3], p[4], p[5])
end

local function CreateStatusFrame()
    if frame then
        return
    end
    frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(MIN_W + PAD_X * 2, 24)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        tile = true,
        tileSize = 12,
    })
    frame:SetBackdropColor(0, 0, 0, 0.6)
    frame:SetBackdropBorderColor(1, 1, 1, 0.4)
    ApplySavedPos()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local point, relativeTo, relPoint, x, y = frame:GetPoint(1)
        ns.db.statusPos = { point, GetAnchorName(relativeTo), relPoint, x, y }
    end)

    text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("CENTER", 0, 0)
end

function ns.SetStatusVisible(show)
    ns.db.showStatus = show
    if not show then
        if ticker then
            C_Timer.CancelTimer(ticker)
            ticker = nil
        end
        if frame then
            frame:Hide()
        end
        return
    end
    CreateStatusFrame()
    frame:Show()
    OnDurabilityChange()
    if not ticker then
        ticker = C_Timer.NewTicker(UPDATE_INTERVAL, Refresh)
    end
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
init:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if ns.db.showStatus then
            ns.SetStatusVisible(true)
        end
    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        OnDurabilityChange()
    end
end)