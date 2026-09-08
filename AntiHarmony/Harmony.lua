local _, ns = ...

local HARMONY_CVAR = "overrideArchive"

function ns.IsCN()
    return GetLocale() == "zhCN"
end

function ns.GetHarmonyState()
    if not ns.IsCN() then
        return "notCN"
    end
    local ok, value = pcall(C_CVar.GetCVar, HARMONY_CVAR)
    if not ok or not value then
        return "unknown"
    end
    if value == "0" then
        return "applied"
    end
    return "missing"
end

function ns.GetHarmonyStateText(state)
    state = state or ns.GetHarmonyState()
    if state == "applied" then
        return "|cff00ff00已开启|r：overrideArchive=0（重启游戏后当前会话生效）"
    elseif state == "missing" then
        return "|cffffff00未开启|r：overrideArchive 未设置，可在设置面板开启，由插件自动写入"
    elseif state == "unknown" then
        return "|cff888888未知|r：客户端未暴露 overrideArchive（可能非国服客户端）"
    end
    return "|cff888888非国服|r：无需模型反和谐"
end

function ns.PrintHarmonyStatus()
    local state = ns.GetHarmonyState()
    ns.Print(ns.GetHarmonyStateText(state))
    if state == "missing" then
        ns.Print("输入 /ah harmony on 或打开设置面板勾选，重启游戏生效")
    end
end