local _, ns = ...

local COMMANDS = {
    help = function()
        ns.Print("/ah help 帮助 /ah panel 设置面板 /ah check 反和谐检测 /ah tune CVar优化 /ah reset 恢复默认")
        ns.Print("/ah repair|sell|spellqueue|harmony|combat on|off 开关对应功能 | /ah fps 开关 FPS/耐久面板")
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