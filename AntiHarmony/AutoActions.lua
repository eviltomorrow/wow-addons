local _, ns = ...

local function SellGreyItems()
    local num = GetMerchantNumItems()
    for i = 1, num do
        local link = GetMerchantItemLink(i)
        if link then
            local quality = select(3, GetItemInfo(link))
            if quality and quality == Enum.ItemQuality.Poor then
                local quantity = select(4, GetMerchantItemInfo(i))
                MerchantSellItem(i, quantity or 1)
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        if ns.db.autoRepair then
            MerchantRepairAllItems(CanGuildRepair())
        end
        if ns.db.autoSell then
            SellGreyItems()
        end
    end
end)