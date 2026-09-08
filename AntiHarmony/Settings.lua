local _, ns = ...

local panel
local widgets = {
    checks = {},
}

local y = 20

local function NextY(step)
    y = y + (step or 30)
    return y
end

local function NewCheck(parent, desc, key)
    local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("TOPLEFT", 16, -y)
    text:SetPoint("RIGHT", parent, "RIGHT", -46, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetText(desc)

    local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    check:SetSize(24, 24)
    check:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    check:SetPoint("TOP", text, "TOP", 0, 0)
    check:SetChecked(ns.db[key])
    check:SetScript("OnClick", function(self)
        ns.SetToggle(key, self:GetChecked())
    end)
    widgets.checks[key] = check

    y = NextY(30)
    return check
end

local function NewButton(parent, text, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetText(text)
    btn:SetSize(150, 26)
    btn:SetScript("OnClick", onClick)
    return btn
end

local function NewTitle(parent, text)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetText(text)
    fs:SetTextColor(1, 0.82, 0)
    return fs
end

local function NewText(parent, text, font)
    local fs = parent:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
    fs:SetText(text)
    fs:SetJustifyH("LEFT")
    return fs
end

function ns.RefreshPanel()
    if not panel then
        return
    end
    if widgets.status then
        widgets.status:SetText(ns.GetHarmonyStateText())
    end
    for key, check in pairs(widgets.checks) do
        check:SetChecked(ns.db[key])
    end
end

function ns.OpenSettings()
    if Settings and Settings.OpenToCategory and ns.Category then
        Settings.OpenToCategory(ns.Category:GetID())
    end
end

local function BuildPanel()
    panel = CreateFrame("Frame")

    local title = NewTitle(panel, "反和谐")
    title:SetPoint("TOPLEFT", 16, -y)
    y = NextY(30)

    widgets.status = NewText(panel, "", "GameFontHighlight")
    widgets.status:SetPoint("TOPLEFT", 16, -y)
    widgets.status:SetWidth(400)
    y = NextY(34)

    NewButton(panel, "重新检测", ns.RefreshPanel):SetPoint("TOPLEFT", 16, -y)
    y = NextY(38)

    NewCheck(panel, "模型/特效反和谐（overrideArchive=0）", "harmony")

    local title2 = NewTitle(panel, "基础功能")
    title2:SetPoint("TOPLEFT", 16, -y)
    y = NextY(28)

    NewCheck(panel, "自动修理装备", "autoRepair")

    NewCheck(panel, "自动出售灰色物品", "autoSell")

    NewCheck(panel, "技能队列窗口（spellQueueWindow=180）", "spellQueue")

    NewCheck(panel, "显示 FPS/耐久度面板", "showStatus")

    NewCheck(panel, "战斗状态图标（进战斗动画）", "combatIcon")

    NewButton(panel, "应用 CVar 优化", ns.ApplyTune):SetPoint("TOPLEFT", 16, -y)
    NewButton(panel, "恢复默认设置", function()
        ns.ResetDB()
        ns.Print("设置已恢复默认")
    end):SetPoint("TOPLEFT", 186, -y)
    y = NextY(40)

    local hint = NewText(panel, "模型/特效反和谐由插件自动设置，重启游戏生效；图标还原需自行放置文件到 Interface/ICONS/。", "GameFontDisable")
    hint:SetPoint("TOPLEFT", 16, -y)
    hint:SetWidth(400)
    y = NextY(36)

    local note = NewText(panel, "命令：/ah help  |  /rl 重载  |  /fs 窗口/全屏  |  /qg 交接  |  /ah fps 开关面板", "GameFontDisable")
    note:SetPoint("TOPLEFT", 16, -y)
    note:SetWidth(400)

    panel:SetScript("OnShow", ns.RefreshPanel)
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    BuildPanel()
    local category = Settings.RegisterCanvasLayoutCategory(panel, "反和谐·基础工具")
    Settings.RegisterAddOnCategory(category)
    ns.Category = category
end)
