dofile(ModPath .. "core.lua")

Sapphire:Log("LifecycleManager hook loaded.")

-- ============================================================
-- ENGINE LIFECYCLE & ASYNC TASK CLEANUP
-- ============================================================
-- Ensures that whenever a heist begins, restarts, or loads:
-- 1. All pending Sapphire_* DelayedCalls are cleanly cancelled and flushed
--    so stale unit pointers from a previous run never trigger errors.
-- 2. AutoCooker is reset to false (safe per-heist arming).
-- 3. Transient script-call tags are reset.
-- ============================================================

local sapphire_delayed_call_prefixes = {
    "Sapphire_DoorPass2",
    "Sapphire_StartLootQueue",
    "Sapphire_ProcessLoose_",
    "Sapphire_ConvertCop_",
    "Sapphire_FlashReset",
    "Sapphire_RestorePower_",
    "Sapphire_AutoCook_",
    "Sapphire_SuppressCameraLoopClutter_",
    "Sapphire_SpoofEHI_Reapply"
}

local function flush_active_delayed_calls()
    if not DelayedCalls or not DelayedCalls.Remove then
        return
    end

    pcall(function()
        if type(DelayedCalls._calls) == "table" then
            local to_remove = {}
            for k, v in pairs(DelayedCalls._calls) do
                local call_id = (type(v) == "table" and type(v.id) == "string" and v.id) or (type(k) == "string" and k) or nil
                if call_id and call_id:find("^Sapphire_") then
                    table.insert(to_remove, call_id)
                end
            end
            for _, id in ipairs(to_remove) do
                DelayedCalls:Remove(id)
            end
        end
    end)
end

if MissionManager and not MissionManager._sapphire_lifecycle_hooked then
    MissionManager._sapphire_lifecycle_hooked = true

    local function on_lifecycle_reset()
        -- Flush any lingering async queues
        flush_active_delayed_calls()

        -- Reset transient runtime flags
        if Sapphire then
            if Sapphire.Settings then
                Sapphire.Settings.AutoCooker = false
            end
            Sapphire._scripted_police_call = false
        end

        Sapphire:Log("Lifecycle: Heist boundary reset - transient tasks flushed.")
    end

    Hooks:PostHook(MissionManager, "init", "Sapphire_MissionLifecycle_Init", function(self)
        on_lifecycle_reset()
    end)

    Hooks:Add("BaseNetworkHandlerOnLoadComplete", "Sapphire_BaseNetwork_LoadComplete", function()
        on_lifecycle_reset()
    end)
end
