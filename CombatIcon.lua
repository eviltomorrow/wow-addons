local _, ns = ...

local MEDIA = "Interface\\AddOns\\AntiHarmony\\Media\\"

-- style:
--   "swell"    A类 光圈涨缩：层同步外扩 + 淡出（大图/全幅层）
--   "spark"    B类 粒子四散：层错开时机向外散开 + 淡出（分散小元素）
--   "converge" C类 聚拢：层由大收拢到小 + 淡出（几层相似居中）
--   "static"   D类 静态：无叠加层，仅主图
local SPEC_IMAGES = {
    [71]  = { style = "swell", main = "wuqizhan1", frames = { "wuqizhan2", "wuqizhan3" } },
    [72]  = { style = "swell", main = "kb4", frames = { "kbzd", "kbzd2", "kbzd3" } },
    [73]  = { style = "swell", main = "fz", frames = { "fzjz", "fzjz2" } },
    [65]  = { style = "swell", main = "nq", frames = { "nq2", "nq3", "nq4" } },
    [66]  = { style = "swell", main = "fq", frames = { "fq1", "fq2", "fq4" } },
    [70]  = { style = "converge", main = "cjq2", frames = { "cjq3", "cjq4" } },
    [250] = { style = "spark", main = "xuedk", frames = { "xuedkzd1", "xuedkzd2", "xuedkzd3", "xuedkzd4" } },
    [251] = { style = "spark", main = "bingDK", frames = { "bingDKzd1", "bingDKzd2", "bingDKzd3" } },
    [252] = { style = "spark", main = "xiedk", frames = { "xiedkzd1", "xiedkzd2", "xiedkzd3" } },
    [62]  = { style = "converge", main = "aofa", frames = { "aofazd1", "aofazd2", "aofazd3", "aofazd4" } },
    [63]  = { style = "converge", main = "huofa", frames = { "huofazd1", "huofazd2", "huofazd3" } },
    [64]  = { style = "converge", main = "bf", frames = { "bfzd1", "bfzd2" } },
    [256] = { style = "converge", main = "jielv", frames = { "jielvzd1", "jielvzd2", "jielvzd3" } },
    [257] = { style = "converge", main = "shensheng", frames = { "shenshengzd1", "shenshengzd2", "shenshengzd3" } },
    [258] = { style = "spark", main = "am", frames = { "amzd1", "amzd2", "amzd3" } },
    [259] = { style = "converge", main = "qixi", frames = { "qixizd1", "qixizd2" } },
    [260] = { style = "converge", main = "kt", frames = { "ktzd1", "ktzd2", "ktzd3" } },
    [261] = { style = "converge", main = "minrui", frames = { "minruizd1", "minruizd2" } },
    [253] = { style = "swell", main = "sw", frames = { "swzd1", "swzd2", "swzd3" } },
    [254] = { style = "static", main = "sheji" },
    [255] = { style = "converge", main = "sc", frames = { "sczd1", "sczd2", "sczd3" } },
    [262] = { style = "swell", main = "yuansu", frames = { "yuansuzd1", "yuansuzd2" } },
    [263] = { style = "swell", main = "zq", frames = { "zqzd1", "zqzd2" } },
    [264] = { style = "converge", main = "huifu", frames = { "huifuzd1", "huifuzd2", "huifuzd3" } },
    [268] = { style = "converge", main = "jiuxian", frames = { "jiuxianzd1", "jiuxianzd2", "jiuxianzd3" } },
    [270] = { style = "converge", main = "zhiwu", frames = { "zhiwuzd1", "zhiwuzd2", "zhiwuzd3" } },
    [269] = { style = "swell", main = "tafeng", frames = { "tafengzd1", "tafengzd2", "tafengzd3" } },
    [102] = { style = "spark", main = "gugu", frames = { "guguzd1", "guguzd2", "guguzd3", "guguzd4", "guguzd5", "guguzd6" } },
    [103] = { style = "converge", main = "liebao", frames = { "liebaozd1", "liebaozd2" } },
    [104] = { style = "converge", main = "xiong3", frames = { "xiongzd1", "xiongzd2" } },
    [105] = { style = "converge", main = "shuren2", frames = { "shurenzd1", "shurenzd2", "shurenzd3" } },
    [577] = { style = "swell", main = "haojie", frames = { "haojiezd1", "haojiezd2", "haojiezd3" } },
    [581] = { style = "static", main = "fuchouzhidun" },
    [265] = { style = "spark", main = "tongku", frames = { "tongkuzd1", "tongkuzd2", "tongkuzd3" } },
    [266] = { style = "spark", main = "emo", frames = { "emozd1", "emozd2", "emozd3" } },
    [267] = { style = "spark", main = "huimie", frames = { "huimiezd1", "huimiezd2", "huimiezd3", "huimiezd4" } },
}

local SIZE = 130
local BURST_TIME = 0.8
local FADE_TIME = 0.35

local frame
local mainTex
local layers = {}
local layerCount = 0
local style = "static"
local mode = "enter"
local burstTimer = 0
local fadeTimer = 0
local active = false

local function StopBurst()
    active = false
    frame:Hide()
    frame:SetAlpha(1)
    for i = 1, layerCount do
        layers[i]:SetAlpha(0)
    end
    mainTex:SetAlpha(1)
    mainTex:SetSize(SIZE, SIZE)
end

local function PlayBurst(m)
    if not ns.db or not ns.db.combatIcon then
        return
    end
    if active then
        return
    end
    local spec = GetSpecialization()
    if not spec or spec == 0 then
        return
    end
    local specID = select(1, GetSpecializationInfo(spec))
    local data = SPEC_IMAGES[specID]
    if not data then
        return
    end

    mainTex:SetTexture(MEDIA .. data.main .. ".tga")
    mainTex:SetSize(SIZE, SIZE)
    style = data.style or "static"
    mode = m or "enter"
    layerCount = 0
    for _, name in ipairs(data.frames or {}) do
        layerCount = layerCount + 1
        local tex = layers[layerCount]
        tex:SetTexture(MEDIA .. name .. ".tga")
        tex:SetSize(SIZE, SIZE)
        tex:SetAlpha(0)
    end

    burstTimer = 0
    fadeTimer = 0
    active = true
    frame:SetAlpha(1)
    mainTex:SetAlpha(1)
    frame:Show()
end

frame = CreateFrame("Frame", nil, UIParent)
frame:SetSize(SIZE, SIZE)
frame:SetPoint("CENTER", 0, 280)
frame:SetFrameStrata("DIALOG")
frame:Hide()
if frame.SetOnUpdateMode and Enum.OnUpdateMode then
    frame:SetOnUpdateMode(Enum.OnUpdateMode.RunWhenVisible)
end

mainTex = frame:CreateTexture(nil, "ARTWORK")
mainTex:SetAllPoints(frame)

for i = 1, 6 do
    local tex = frame:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("CENTER", frame, "CENTER", 0, 0)
    tex:SetSize(SIZE, SIZE)
    tex:SetAlpha(0)
    layers[i] = tex
end

-- eased in-out
local function Ease(t)
    return t * t * (3 - 2 * t)
end

local function UpdateSwell(p)
    -- A: 层同步外扩 + 淡出（贴近原生，减少放大模糊）
    local e = Ease(p)
    local s = SIZE * (0.95 + e * 0.15)
    local alpha = math.sin(p * math.pi)
    for i = 1, layerCount do
        layers[i]:SetSize(s, s)
        layers[i]:SetAlpha(alpha)
    end
    mainTex:SetSize(SIZE * (1 + e * 0.04), SIZE * (1 + e * 0.04))
end

local function UpdateSpark(p)
    -- B: 粒子错开散开 + 淡出（贴近原生，减少放大模糊）
    for i = 1, layerCount do
        local lp = p * layerCount - (i - 1)
        if lp > 0 and lp < 1 then
            local s = SIZE * (0.9 + Ease(lp) * 0.2)
            layers[i]:SetSize(s, s)
            layers[i]:SetAlpha(math.sin(lp * math.pi))
        else
            layers[i]:SetAlpha(0)
        end
    end
end

local function UpdateConverge(p)
    -- C: 层由大收拢到小 + 淡出（贴近原生，减少放大模糊）
    local s = SIZE * (1.12 - Ease(p) * 0.17)
    local alpha = math.sin(p * math.pi)
    for i = 1, layerCount do
        layers[i]:SetSize(s, s)
        layers[i]:SetAlpha(alpha)
    end
end

local function UpdateCollapse(p)
    -- 退出战斗：层由大收拢到小 + 淡出（贴近原生，减少放大模糊）
    local s = SIZE * (1.12 - Ease(p) * 0.22)
    local alpha = math.sin(p * math.pi)
    for i = 1, layerCount do
        layers[i]:SetSize(s, s)
        layers[i]:SetAlpha(alpha)
    end
end

local function UpdateBurst(p)
    if mode == "exit" then
        UpdateCollapse(p)
        return
    end
    if style == "spark" then
        UpdateSpark(p)
    elseif style == "swell" then
        UpdateSwell(p)
    elseif style == "converge" then
        UpdateConverge(p)
    end
end

frame:SetScript("OnUpdate", function(_, elapsed)
    if not active then
        return
    end
    if fadeTimer > 0 then
        fadeTimer = fadeTimer - elapsed
        local alpha = math.max(fadeTimer / FADE_TIME, 0)
        frame:SetAlpha(alpha)
        if fadeTimer <= 0 then
            StopBurst()
        end
        return
    end
    burstTimer = burstTimer + elapsed
    if burstTimer >= BURST_TIME then
        for i = 1, layerCount do
            layers[i]:SetAlpha(0)
        end
        mainTex:SetSize(SIZE, SIZE)
        fadeTimer = FADE_TIME
        return
    end
    UpdateBurst(burstTimer / BURST_TIME)
end)

function ns.SetCombatIconVisible(on)
    if not on then
        StopBurst()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        PlayBurst("enter")
    elseif event == "PLAYER_REGEN_ENABLED" then
        PlayBurst("exit")
    elseif event == "PLAYER_LOGIN" then
        if InCombatLockdown() then
            PlayBurst("enter")
        end
    end
end)
