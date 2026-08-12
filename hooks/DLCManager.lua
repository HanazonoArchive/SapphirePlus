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

-- Detour _check_dlc_data on each platform DLC manager that actually exists on
-- this install. A Steam client has no WinEpicDLCManager (and vice versa), so we
-- must guard every class -- indexing a nil manager would crash the mod. Origins
-- are captured per-class and the detour is idempotent (safe if this file is ever
-- evaluated more than once), and nothing leaks into the global namespace.
local function install_check(manager)
    if not manager or not manager._check_dlc_data then return end
    if manager._sapphire_dlc_hooked then return end
    manager._sapphire_dlc_hooked = true

    local orig_check = manager._check_dlc_data
    function manager:_check_dlc_data(dlc_data)
        return unlock_dlcs(dlc_data) or orig_check(self, dlc_data)
    end
end

install_check(rawget(_G, "WinSteamDLCManager"))
install_check(rawget(_G, "WinEpicDLCManager"))
install_check(rawget(_G, "WINDLCManager"))

