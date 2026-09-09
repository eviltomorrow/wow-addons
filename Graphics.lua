local _, ns = ...

local RAID_ENABLED_CVAR = "RAIDsettingsEnabled"
local RAID_QUALITY_CVAR = "raidGraphicsQuality"

ns.RAID_QUALITY_DEFAULT = 3

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
    if event == "PLAYER_LOGIN" and ns.db.raidMode then
        ns.SetRaidMode(true)
    end
end)