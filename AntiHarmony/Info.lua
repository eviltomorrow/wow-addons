local _, ns = ...

local frame
local fpsText
local durText
local timer = 0

local UPDATE_INTERVAL = 0.5

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

local function Refresh()
    fpsText:SetText(string.format("FPS: |cffffffff%d|r", GetFramerate()))
    local pct = GetAverageDurability()
    local color = pct >= 50 and "|cff00ff00" or (pct >= 25 and "|cffffff00" or "|cffff0000")
    durText:SetText(string.format("耐久: %s%.0f%%|r", color, pct))
end

local function CreateStatusFrame()
    if frame then
        return
    end
    frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(130, 50)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        tile = true,
        tileSize = 12,
    })
    frame:SetBackdropColor(0, 0, 0, 0.6)
    frame:SetBackdropBorderColor(1, 1, 1, 0.4)
    frame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8, 0)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)
    frame:SetScript("OnUpdate", function(_, elapsed)
        timer = timer + elapsed
        if timer >= UPDATE_INTERVAL then
            timer = 0
            Refresh()
        end
    end)

    fpsText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fpsText:SetPoint("TOPLEFT", 6, -4)
    durText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    durText:SetPoint("TOPLEFT", 6, -22)
end

function ns.SetStatusVisible(show)
    ns.db.showStatus = show
    if not show then
        if frame then
            frame:Hide()
        end
        return
    end
    CreateStatusFrame()
    frame:Show()
    Refresh()
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    if ns.db.showStatus then
        ns.SetStatusVisible(true)
    end
end)