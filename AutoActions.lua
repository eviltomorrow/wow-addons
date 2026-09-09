local _, ns = ...

local function SellGreyItems()
    for bag = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.quality == Enum.ItemQuality.Poor and not info.isLocked then
                C_Container.UseContainerItem(bag, slot)
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        if ns.db.autoRepair and CanMerchantRepair() then
            RepairAllItems(CanGuildBankRepair())
        end
        if ns.db.autoSell then
            SellGreyItems()
        end
    end
end)
