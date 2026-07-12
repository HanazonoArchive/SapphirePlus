dofile(ModPath .. "core.lua")

Sapphire:Log("DLCManager hook loaded.")

local effective = Sapphire:GetEffectiveSettings()
if not effective.Enabled or not effective.UnlockDLCHeists then
    return
end

Sapphire:Log("DLC Heist Unlocker is enabled.")

local unlocked_dlcs_cache = nil
local unlock_all = false

local function initialize_unlocks()
    if unlocked_dlcs_cache then return end

    local filename = ModPath .. "dlcs-to-unlock.txt"
    local file, err = io.open(filename, "r")

    -- If file doesn't exist, create it with a wildcard and unlock everything
    if not file then
        file = io.open(filename, "a")
        if file then
            file:write("*")
            file:close()
        end
        unlock_all = true
        unlocked_dlcs_cache = {}
        return
    end

    local heist_keys = {}
    for line in file:lines() do
        local key = line:match("^%s*(.-)%s*$") -- trim whitespace
        if key == "*" then
            unlock_all = true
            file:close()
            unlocked_dlcs_cache = {}
            return
        elseif key ~= "" then
            heist_keys[key] = true
        end
    end
    file:close()

    -- Map string keys to actual dlc_data tables for O(1) lookups
    if Global and Global.dlc_manager and Global.dlc_manager.all_dlc_data then
        unlocked_dlcs_cache = {}
        for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
            if heist_keys[dlc_name] then
                unlocked_dlcs_cache[dlc_data] = true
            end
        end
    end
end

local function unlock_dlcs(dlc_data)
    if not unlocked_dlcs_cache then
        initialize_unlocks()
    end

    if unlock_all then
        return true
    end

    return unlocked_dlcs_cache and unlocked_dlcs_cache[dlc_data] or false
end

old_steam_check = old_steam_check or WinSteamDLCManager._check_dlc_data
old_epic_check = old_epic_check or WinEpicDLCManager._check_dlc_data
old_win_check = old_win_check or WINDLCManager._check_dlc_data

function WinSteamDLCManager:_check_dlc_data(dlc_data)
    return unlock_dlcs(dlc_data) or old_steam_check(self, dlc_data)
end

function WinEpicDLCManager:_check_dlc_data(dlc_data)
    return unlock_dlcs(dlc_data) or old_epic_check(self, dlc_data)
end

function WINDLCManager:_check_dlc_data(dlc_data)
    return unlock_dlcs(dlc_data) or old_win_check(self, dlc_data)
end
