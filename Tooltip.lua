local _, ns = ...

local function AppendItemInfo(tip)
    if not ns.db or not ns.db.tooltipInfo then
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
    if not ns.db or not ns.db.tooltipInfo then
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

function ns.SetTooltipInfoEnabled(on)
    pcall(C_CVar.SetCVar, "tooltipShowAuraSpellIDs", on and "1" or "0")
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" and ns.db.tooltipInfo then
        ns.SetTooltipInfoEnabled(true)
    end
end)