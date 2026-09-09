local _, ns = ...

local enabled = true

local function SetEnabled(on)
    enabled = on and true or false
    pcall(C_CVar.SetCVar, "tooltipShowAuraSpellIDs", enabled and "1" or "0")
end

local function AppendItemInfo(tip)
    if not enabled then
        return
    end
    local link = tip:GetItem()
    if not link then
        return
    end
    local itemID = link:match("item:(%d+)")
    if not itemID then
        return
    end
    local _, _, quality, ilvl = C_Item.GetItemInfo(link)
    local color = "ff888888"
    if quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        color = ITEM_QUALITY_COLORS[quality].hex
    end
    local parts = {}
    if ilvl then
        tinsert(parts, ("|c%s%d级|r"):format(color, ilvl))
    end
    tinsert(parts, ("|cff888888ID:%s|r"):format(itemID))
    tip:AddLine(table.concat(parts, "  "))
    tip:Show()
end

local function AppendSpellInfo(tip)
    if not enabled then
        return
    end
    local spellID = tip:GetSpell()
    if not spellID then
        return
    end
    tip:AddLine(("|cff888888法术ID:%d|r"):format(spellID))
    tip:Show()
end

GameTooltip:HookScript("OnTooltipSetItem", AppendItemInfo)
GameTooltip:HookScript("OnTooltipSetSpell", AppendSpellInfo)

ns.SetTooltipInfoEnabled = SetEnabled

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        SetEnabled(ns.db.tooltipInfo)
    end
end)