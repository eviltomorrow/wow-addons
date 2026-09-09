local _, ns = ...

SLASH_RELOADUI1 = "/rl"
SlashCmdList["RELOADUI"] = function()
    ReloadUI()
end

SLASH_FS1 = "/fs"
SlashCmdList["FS"] = function()
    local windowed = tonumber(C_CVar.GetCVar("gxWindowed")) or 1
    C_CVar.SetCVar("gxWindowed", tostring(1 - windowed))
    C_CVar.SetCVar("gxMaximize", "0")
    ns.Print(windowed == 1 and "已切换为全屏" or "已切换为窗口化")
end

SLASH_TURNIN1 = "/qg"
SlashCmdList["TURNIN"] = function()
    if InCombatLockdown() then
        ns.Print("战斗状态，无法交接")
        return
    end
    if QuestFrame and QuestFrame:IsShown() then
        local button = QuestFrameCompleteQuestButton
        if button and button:IsVisible() then
            button:Click()
            return
        end
    end
    if CanCompleteQuest() then
        CompleteQuest()
        return
    end
    if CanAcceptQuest() then
        AcceptQuest()
        return
    end
    ns.Print("当前没有可交接的任务")
end