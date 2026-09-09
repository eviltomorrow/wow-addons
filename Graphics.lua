local _, ns = ...

local RAID_ENABLED_CVAR = "RAIDsettingsEnabled"
local RAID_QUALITY_CVAR = "raidGraphicsQuality"

ns.RAID_QUALITY_DEFAULT = 3

local MPLUS_PRESETS = {
    [0] = { label = "极限", RenderScale = "0.5", graphicsShadowQuality = "0", graphicsParticleDensity = "1", graphicsSpellDensity = "1", graphicsSSAO = "0", graphicsComputeEffects = "0", graphicsProjectedTextures = "0", graphicsViewDistance = "4" },
    [1] = { label = "标准", RenderScale = "0.65", graphicsShadowQuality = "1", graphicsParticleDensity = "2", graphicsSpellDensity = "2", graphicsSSAO = "1", graphicsComputeEffects = "0", graphicsProjectedTextures = "0", graphicsViewDistance = "6" },
    [2] = { label = "保守", RenderScale = "0.75", graphicsShadowQuality = "2", graphicsParticleDensity = "3", graphicsSpellDensity = "3", graphicsSSAO = "2", graphicsComputeEffects = "1", graphicsProjectedTextures = "1", graphicsViewDistance = "7" },
}
ns.MPLUS_PRESETS = MPLUS_PRESETS
ns.MPLUS_DEFAULT_LEVEL = 1

function ns.SetMplusMode(on, level)
    ns.db.mplusMode = on and true or false
    if level ~= nil then
        level = math.max(0, math.min(2, math.floor(level)))
        ns.db.mplusLevel = level
    end
    local preset = MPLUS_PRESETS[ns.db.mplusLevel or ns.MPLUS_DEFAULT_LEVEL]
    if ns.db.mplusMode then
        if not ns.db.mplusBackup then
            ns.db.mplusBackup = {}
            for cvar in pairs(preset) do
                if cvar ~= "label" then
                    local ok, value = pcall(C_CVar.GetCVar, cvar)
                    if ok then
                        ns.db.mplusBackup[cvar] = value
                    end
                end
            end
        end
        for cvar, value in pairs(preset) do
            if cvar ~= "label" then
                pcall(C_CVar.SetCVar, cvar, value)
            end
        end
    elseif ns.db.mplusBackup then
        for cvar, value in pairs(ns.db.mplusBackup) do
            pcall(C_CVar.SetCVar, cvar, value)
        end
        ns.db.mplusBackup = nil
    end
end

function ns.SetRaidMode(on, quality)
    ns.db.raidMode = on and true or false
    if quality ~= nil then
        quality = math.max(0, math.min(9, math.floor(quality)))
        ns.db.raidQuality = quality
    end
    local q = ns.db.raidQuality or ns.RAID_QUALITY_DEFAULT
    if ns.db.raidMode then
        pcall(C_CVar.SetCVar, RAID_ENABLED_CVAR, "1")
        pcall(C_CVar.SetCVar, RAID_QUALITY_CVAR, tostring(q))
    else
        pcall(C_CVar.SetCVar, RAID_ENABLED_CVAR, "0")
    end
end

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if ns.db.raidMode then
            ns.SetRaidMode(true)
        end
        if ns.db.mplusMode then
            ns.SetMplusMode(true)
        end
    end
end)