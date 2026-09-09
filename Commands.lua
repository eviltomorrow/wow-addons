local _, ns = ...

local COMMANDS = {
    help = function()
        ns.Print("/ah help 帮助 /ah panel 设置面板 /ah check 反和谐检测 /ah tune CVar优化 /ah reset 恢复默认")
        ns.Print("/ah repair|sell|spellqueue|harmony|combat on|off 开关对应功能 | /ah fps 开关 FPS/耐久面板")
        ns.Print("/ah raid [0-9|on|off] 团本画质优化 | /ah mplus [0-2|on|off] 大米压帧 | /ah ilvl 开关背包/装备装等 | /ah ring 开关耐久光环")
    end,
    panel = function()
        ns.OpenSettings()
    end,
    check = function()
        ns.PrintHarmonyStatus()
    end,
    tune = function()
        ns.ApplyTune()
        ns.Print("CVar 优化已应用")
    end,
    reset = function()
        ns.ResetDB()
        ns.Print("设置已恢复默认")
    end,
    repair = function(arg)
        ns.SetToggle("autoRepair", arg == "on")
    end,
    sell = function(arg)
        ns.SetToggle("autoSell", arg == "on")
    end,
    spellqueue = function(arg)
        ns.SetToggle("spellQueue", arg == "on")
    end,
    harmony = function(arg)
        ns.SetToggle("harmony", arg == "on")
        ns.PrintHarmonyStatus()
    end,
    combat = function(arg)
        ns.SetToggle("combatIcon", arg == "on")
    end,
    fps = function(arg)
        if arg == "on" then
            ns.SetToggle("showStatus", true)
        elseif arg == "off" then
            ns.SetToggle("showStatus", false)
        else
            ns.SetToggle("showStatus", not ns.db.showStatus)
        end
    end,
    ring = function(arg)
        if arg == "on" then
            ns.SetToggle("durabilityRing", true)
        elseif arg == "off" then
            ns.SetToggle("durabilityRing", false)
        else
            ns.SetToggle("durabilityRing", not ns.db.durabilityRing)
        end
    end,
    ilvl = function(arg)
        if arg == "on" then
            ns.SetToggle("itemLevel", true)
        elseif arg == "off" then
            ns.SetToggle("itemLevel", false)
        else
            ns.SetToggle("itemLevel", not ns.db.itemLevel)
        end
    end,
    raid = function(arg)
        if arg == "off" then
            ns.SetRaidMode(false)
            ns.Print("团本画质优化已关闭，恢复原画质")
        elseif arg == "on" then
            ns.SetRaidMode(true)
            ns.Print(string.format("团本画质优化已开启（Raid 画质 %d/9，进团本自动生效）", ns.db.raidQuality))
        elseif tonumber(arg) then
            ns.SetRaidMode(true, tonumber(arg))
            ns.Print(string.format("团本画质优化已开启（Raid 画质 %d/9，进团本自动生效）", ns.db.raidQuality))
        else
            ns.SetRaidMode(not ns.db.raidMode)
            ns.Print(ns.db.raidMode and string.format("团本画质优化已开启（Raid 画质 %d/9）", ns.db.raidQuality) or "团本画质优化已关闭，恢复原画质")
        end
        if ns.RefreshPanel then
            ns.RefreshPanel()
        end
    end,
    mplus = function(arg)
        local labels = ns.MPLUS_PRESETS
        if arg == "off" then
            ns.SetMplusMode(false)
            ns.Print("大秘境压帧已关闭，恢复原画质")
        elseif arg == "on" then
            ns.SetMplusMode(true)
            ns.Print(string.format("大秘境压帧已开启（档位：%s）", labels[ns.db.mplusLevel].label))
        elseif tonumber(arg) then
            ns.SetMplusMode(true, tonumber(arg))
            ns.Print(string.format("大秘境压帧已开启（档位：%s）", labels[ns.db.mplusLevel].label))
        else
            ns.SetMplusMode(not ns.db.mplusMode)
            if ns.db.mplusMode then
                ns.Print(string.format("大秘境压帧已开启（档位：%s）", labels[ns.db.mplusLevel].label))
            else
                ns.Print("大秘境压帧已关闭，恢复原画质")
            end
        end
        if ns.RefreshPanel then
            ns.RefreshPanel()
        end
    end,
}

local function Handle(msg)
    local cmd, arg = strsplit(" ", msg, 2)
    cmd = strlower(cmd or "")
    arg = strlower(arg or "")
    local fn = COMMANDS[cmd]
    if fn then
        fn(arg)
    else
        COMMANDS.help()
    end
end

SLASH_ANTIHARMONY1 = "/ah"
SlashCmdList["ANTIHARMONY"] = Handle