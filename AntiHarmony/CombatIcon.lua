local _, ns = ...

local MEDIA = "Interface\\AddOns\\AntiHarmony\\Media\\"

local SPEC_IMAGES = {
    [71] = { main = "wuqizhan1", frames = { "wuqizhan2", "wuqizhan3" } },
    [72] = { main = "kb4", frames = { "kbzd", "kbzd2", "kbzd3" } },
    [73] = { main = "fz", frames = { "fzjz", "fzjz2" } },
    [65] = { main = "nq", frames = { "nq2", "nq3", "nq4" } },
    [66] = { main = "fq", frames = { "fq1", "fq2", "fq4" } },
    [70] = { main = "cjq2", frames = { "cjq3", "cjq4" } },
    [250] = { main = "xuedk", frames = { "xuedkzd1", "xuedkzd2", "xuedkzd3", "xuedkzd4" } },
    [251] = { main = "bingDK", frames = { "bingDKzd1", "bingDKzd2", "bingDKzd3" } },
    [252] = { main = "xiedk", frames = { "xiedkzd1", "xiedkzd2", "xiedkzd3" } },
    [62] = { main = "aofa", frames = { "aofazd1", "aofazd2", "aofazd3", "aofazd4" } },
    [63] = { main = "huofa", frames = { "huofazd1", "huofazd2", "huofazd3" } },
    [64] = { main = "bf", frames = { "bfzd1", "bfzd2" } },
    [256] = { main = "jielv", frames = { "jielvzd1", "jielvzd2", "jielvzd3" } },
    [257] = { main = "shensheng", frames = { "shenshengzd1", "shenshengzd2", "shenshengzd3" } },
    [258] = { main = "am", frames = { "amzd1", "amzd2", "amzd3" } },
    [259] = { main = "qixi", frames = { "qixizd1", "qixizd2" } },
    [260] = { main = "kt", frames = { "ktzd1", "ktzd2", "ktzd3" } },
    [261] = { main = "minrui", frames = { "minruizd1", "minruizd2" } },
    [253] = { main = "sw", frames = { "swzd1", "swzd2", "swzd3" } },
    [254] = { main = "sheji" },
    [255] = { main = "sc", frames = { "sczd1", "sczd2", "sczd3" } },
    [262] = { main = "yuansu", frames = { "yuansuzd1", "yuansuzd2" } },
    [263] = { main = "zq", frames = { "zqzd1", "zqzd2" } },
    [264] = { main = "huifu", frames = { "huifuzd1", "huifuzd2", "huifuzd3" } },
    [268] = { main = "jiuxian", frames = { "jiuxianzd1", "jiuxianzd2", "jiuxianzd3" } },
    [270] = { main = "zhiwu", frames = { "zhiwuzd1", "zhiwuzd2", "zhiwuzd3" } },
    [269] = { main = "tafeng", frames = { "tafengzd1", "tafengzd2", "tafengzd3" } },
    [102] = { main = "gugu", frames = { "guguzd1", "guguzd2", "guguzd3", "guguzd4", "guguzd5", "guguzd6" } },
    [103] = { main = "liebao", frames = { "liebaozd1", "liebaozd2" } },
    [104] = { main = "xiong3", frames = { "xiongzd1", "xiongzd2" } },
    [105] = { main = "shuren2", frames = { "shurenzd1", "shurenzd2", "shurenzd3" } },
    [577] = { main = "haojie", frames = { "haojiezd1", "haojiezd2", "haojiezd3" } },
    [581] = { main = "fuchouzhidun" },
    [265] = { main = "tongku", frames = { "tongkuzd1", "tongkuzd2", "tongkuzd3" } },
    [266] = { main = "emo", frames = { "emozd1", "emozd2", "emozd3" } },
    [267] = { main = "huimie", frames = { "huimiezd1", "huimiezd2", "huimiezd3", "huimiezd4" } },
}

local DURATION = 2.0
local FRAME_INTERVAL = 0.12

local frame
local icon
local seq = {}
local seqIndex = 1
local timer = 0
local frameTimer = 0
local active = false

local function StopBurst()
    active = false
    frame:Hide()
end

local function PlayBurst()
    if not ns.db or not ns.db.combatIcon then
        return
    end
    local spec = GetSpecialization()
    if not spec or spec == 0 then
        return
    end
    local _, specID = GetSpecializationInfo(spec)
    local data = SPEC_IMAGES[specID]
    if not data then
        return
    end
    wipe(seq)
    tinsert(seq, data.main)
    for _, name in ipairs(data.frames or {}) do
        tinsert(seq, name)
    end
    seqIndex = 1
    timer = 0
    frameTimer = 0
    active = true
    icon:SetTexture(MEDIA .. seq[1] .. ".tga")
    frame:Show()
end

frame = CreateFrame("Frame", nil, UIParent)
frame:SetSize(300, 300)
frame:SetPoint("CENTER", 0, 180)
frame:SetFrameStrata("DIALOG")
frame:Hide()

icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints(frame)

frame:SetScript("OnUpdate", function(_, elapsed)
    if not active then
        return
    end
    timer = timer + elapsed
    if timer >= DURATION then
        StopBurst()
        return
    end
    frameTimer = frameTimer + elapsed
    if frameTimer >= FRAME_INTERVAL then
        frameTimer = 0
        seqIndex = seqIndex % #seq + 1
        icon:SetTexture(MEDIA .. seq[seqIndex] .. ".tga")
    end
end)

function ns.SetCombatIconVisible(on)
    if not on then
        StopBurst()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        PlayBurst()
    elseif event == "PLAYER_LOGIN" then
        if InCombatLockdown() then
            PlayBurst()
        end
    end
end)