local _, ns = ...

local function MergeDefaults(defaults, target)
    target = target or {}
    for k, v in pairs(defaults) do
        if target[k] == nil then
            target[k] = v
        end
    end
    return target
end

ns.defaults = {
    char = {
        autoRepair = false,
        autoSell = false,
        showStatus = true,
        spellQueue = true,
        harmony = false,
        combatIcon = true,
        durabilityRing = true,
        itemLevel = true,
        raidMode = false,
        raidQuality = 3,
        mplusMode = false,
        mplusLevel = 1,
    },
}

ns.TOGGLES = {
    harmony = { label = "模型/特效反和谐", cvar = "overrideArchive", cvarValue = "0", onlyCN = true },
    autoRepair = { label = "自动修理" },
    autoSell = { label = "自动出售灰色物品" },
    showStatus = { label = "FPS/耐久面板", apply = function(on) ns.SetStatusVisible(on) end },
    spellQueue = { label = "技能队列窗口 180ms", cvar = "spellQueueWindow", cvarValue = "180" },
    combatIcon = { label = "战斗状态图标", apply = function(on) ns.SetCombatIconVisible(on) end },
    durabilityRing = { label = "耐久度光环", apply = function(on) ns.SetDurabilityRingVisible(on) end },
    itemLevel = { label = "背包/装备显示装等", apply = function(on) ns.SetItemLevelEnabled(on) end },
    raidMode = { label = "团本画质优化", apply = function(on) ns.SetRaidMode(on) end },
}

ns.TUNE_CVARS = {
    cameraDistanceMaxZoomFactor = "2.6",
    lootUnderMouse = "1",
    showLootSpam = "1",
}

function ns.ApplyToggle(key)
    local spec = ns.TOGGLES[key]
    if not spec then
        return
    end
    if spec.onlyCN and not ns.IsCN() then
        return
    end
    if spec.cvar and ns.db[key] then
        pcall(C_CVar.SetCVar, spec.cvar, spec.cvarValue)
    end
    if spec.apply then
        spec.apply(ns.db[key])
    end
end

function ns.ApplyEnabledToggles()
    for key, spec in pairs(ns.TOGGLES) do
        if spec.cvar then
            ns.ApplyToggle(key)
        end
    end
end

function ns.SetToggle(key, value)
    ns.db[key] = value
    ns.ApplyToggle(key)
    if ns.RefreshPanel then
        ns.RefreshPanel()
    end
    local label = ns.TOGGLES[key] and ns.TOGGLES[key].label or key
    ns.Print(string.format("%s：%s", label, value and "开启" or "关闭"))
end

function ns.ResetDB()
    for k, v in pairs(ns.defaults.char) do
        ns.db[k] = v
    end
    for key, spec in pairs(ns.TOGGLES) do
        if spec.cvar or spec.apply then
            ns.ApplyToggle(key)
        end
    end
    ns.SetMplusMode(false)
    if ns.RefreshPanel then
        ns.RefreshPanel()
    end
end

function ns.ApplyTune()
    for name, value in pairs(ns.TUNE_CVARS) do
        C_CVar.SetCVar(name, value)
    end
end

function ns.Print(...)
    local msg = strjoin(" ", ...)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[AH]|r " .. msg)
    else
        print("[AH] " .. msg)
    end
end

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(_, _, addonName)
    if addonName ~= "AntiHarmony" then
        return
    end
    if type(AntiHarmonyDB) ~= "table" then
        AntiHarmonyDB = {}
    end
    ns.db = AntiHarmonyDB
    MergeDefaults(ns.defaults.char, ns.db)
    ns.ApplyEnabledToggles()
end)