local _, ns = ...

local frame
local text
local lastStr
local lastFps
local lastDurability
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
    local fps = GetFramerate()
    if fps == lastFps and durability == lastDurability then
        return
    end
    lastFps = fps
    lastDurability = durability
    local color = durability >= 50 and "|cff00ff00" or (durability >= 25 and "|cffffff00" or "|cffff0000")
    local str = string.format("FPS: |cffffffff%d|r   耐久: %s%.0f%%|r", fps, color, durability)
    lastStr = str
    text:SetText(str)
    AutoSize()
end

local ringFrame
local ringFill
local RING_RIM = 12

local function GetRingColor(dur)
    if dur >= 50 then
        return 0, 1, 0
    elseif dur >= 25 then
        return 1, 1, 0
    end
    return 1, 0, 0
end

local function UpdateRing()
    if not ringFrame or not ringFill or not ns.db.durabilityRing then
        return
    end
    local p = math.max(0, math.min(1, durability / 100))
    if ringFill.SetRadialProgressBarPercent then
        ringFill:SetRadialProgressBarPercent(p)
    end
    ringFill:SetVertexColor(GetRingColor(durability))
end

function ns.SetDurabilityRingVisible(on)
    if not on then
        if ringFrame then
            ringFrame:Hide()
        end
        return
    end
    if not ringFrame then
        local minimapSize = Minimap and Minimap:GetWidth() or 130
        ringFrame = CreateFrame("Frame", nil, UIParent)
        ringFrame:SetSize(minimapSize + RING_RIM * 2, minimapSize + RING_RIM * 2)
        ringFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
        ringFrame:SetFrameStrata("BACKGROUND")

        ringFill = ringFrame:CreateTexture(nil, "ARTWORK")
        ringFill:SetAllPoints(ringFrame)
        ringFill:SetTexture("Interface\\Buttons\\WHITE8x8")
        if ringFill.SetRadialProgressBarStartOffset then
            ringFill:SetRadialProgressBarStartOffset(0)
            ringFill:SetRadialProgressBarEndOffset(1)
            ringFill:SetRadialProgressBarReverse(false)
            ringFill:SetRadialProgressBarFeather(0.1)
        end
    end
    ringFrame:Show()
    UpdateRing()
end

local function OnDurabilityChange()
    durability = GetAverageDurability()
    Refresh()
    UpdateRing()
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
        if ns.db.durabilityRing then
            ns.SetDurabilityRingVisible(true)
        end
    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        OnDurabilityChange()
    end
end)