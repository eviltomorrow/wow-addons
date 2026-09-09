local _, ns = ...

local panel
local widgets = {
    checks = {},
}

local WIDTH = 440
local y = 14

local function NextY(step)
    y = y + (step or 30)
    return y
end

local function NewSection(title)
    local bar = panel:CreateTexture(nil, "ARTWORK")
    bar:SetSize(3, 18)
    bar:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -y)
    bar:SetTexture("Interface\\Buttons\\WHITE8x8")
    bar:SetVertexColor(1, 0.82, 0, 0.95)

    local fs = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetPoint("LEFT", bar, "RIGHT", 8, 0)
    fs:SetText(title)
    fs:SetTextColor(1, 0.82, 0)

    local div = panel:CreateTexture(nil, "OVERLAY")
    div:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -(y + 22))
    div:SetSize(WIDTH - 32, 1)
    div:SetTexture("Interface\\Buttons\\WHITE8x8")
    div:SetVertexColor(0.32, 0.32, 0.32, 0.5)

    y = NextY(30)
end

local function NewCheck(desc, key)
    local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -y)
    text:SetPoint("RIGHT", panel, "RIGHT", -46, 0)
    text:SetJustifyH("LEFT")
    text:SetText(desc)

    local check = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check:SetSize(24, 24)
    check:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    check:SetPoint("TOP", text, "TOP", 0, 0)
    check:SetChecked(ns.db[key])
    check:SetScript("OnClick", function(self)
        ns.SetToggle(key, self:GetChecked())
    end)
    widgets.checks[key] = check

    y = NextY(24)
    return check
end

local function NewButton(text, onClick)
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetText(text)
    btn:SetSize(150, 26)
    btn:SetScript("OnClick", onClick)
    return btn
end

local function NewHint(text)
    local fs = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    fs:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -y)
    fs:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:SetText(text)
    y = y + fs:GetHeight() + 6
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
    panel:SetWidth(WIDTH)

    NewSection("反和谐")

    widgets.status = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    widgets.status:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -y)
    widgets.status:SetPoint("RIGHT", panel, "RIGHT", -120, 0)
    widgets.status:SetJustifyH("LEFT")
    widgets.status:SetWordWrap(true)

    local detect = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    detect:SetText("重新检测")
    detect:SetSize(96, 22)
    detect:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -y)
    detect:SetScript("OnClick", ns.RefreshPanel)
    y = NextY(36)

    NewCheck("模型/特效反和谐", "harmony")

    NewSection("基础功能")

    NewCheck("自动修理装备", "autoRepair")
    NewCheck("自动出售灰色物品", "autoSell")
    NewCheck("技能队列窗口（180ms）", "spellQueue")

    NewSection("显示")

    NewCheck("FPS/耐久面板", "showStatus")
    NewCheck("耐久度光环", "durabilityRing")
    NewCheck("战斗状态图标", "combatIcon")

    NewSection("工具")

    NewCheck("背包/装备显示装等", "itemLevel")
    NewCheck("团本画质优化", "raidMode")
    y = NextY(6)

    NewButton("应用 CVar 优化", ns.ApplyTune):SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -y)
    NewButton("恢复默认设置", function()
        ns.ResetDB()
        ns.Print("设置已恢复默认")
    end):SetPoint("TOPLEFT", panel, "TOPLEFT", 176, -y)
    y = NextY(36)

    NewHint("反和谐 overrideArchive=0 自动写入、重启生效；图标还原请自行放入 Interface/ICONS/。")
    NewHint("团本画质 /ah raid <0-9>  大秘境压帧 /ah mplus <0-2>  命令 /ah help  /rl  /fs  /qg")

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