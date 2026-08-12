dofile(ModPath .. "core.lua")

Sapphire:Log("InfiniteCameraLoop hook loaded.")

-- ============================================================
-- INFINITE & CONCURRENT CAMERA LOOPS (Clean HUD)
-- ============================================================
-- 1. Sets loop duration to 99,999s (permanent loop).
-- 2. Resets SecurityCamera.active_tape_loop_unit to allow multiple
--    cameras to be looped concurrently without cancelling previous ones.
-- 3. Automatically suppresses on-screen countdown timer widgets and
--    waypoints from Extra Heist Info (EHI) to prevent HUD clutter/spam.
-- 4. Ensures the physical camera model maintains its friendly blue/green
--    contour glow in 3D world space.
-- ============================================================

local INFINITE_DURATION = 99999

local function player_upgrades()
    if tweak_data and tweak_data.upgrades and tweak_data.upgrades.values and tweak_data.upgrades.values.player then
        return tweak_data.upgrades.values.player
    end
    return nil
end

-- Apply or restore the tape-loop duration tweak. Restoring matters because the
-- vanilla SecurityCamera:_start_tape_loop_by_upgrade_level path reads this value
-- directly -- leaving it at 99999 after the feature is toggled off would keep
-- camera loops effectively permanent even with the mod's detour disabled.
local function apply_camera_tweak_data()
    local player_upg = player_upgrades()
    if not player_upg or player_upg.tape_loop_duration == nil then return end

    -- Capture the true vanilla duration once, before we ever overwrite it.
    if Sapphire.VanillaTapeLoopDuration == nil and type(player_upg.tape_loop_duration) == "table" then
        local copy = {}
        for i, n in ipairs(player_upg.tape_loop_duration) do copy[i] = n end
        Sapphire.VanillaTapeLoopDuration = copy
    end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.InfiniteCameraLoop then
        player_upg.tape_loop_duration = { INFINITE_DURATION, INFINITE_DURATION }
    elseif Sapphire.VanillaTapeLoopDuration then
        local restored = {}
        for i, n in ipairs(Sapphire.VanillaTapeLoopDuration) do restored[i] = n end
        player_upg.tape_loop_duration = restored
    end
end

apply_camera_tweak_data()

-- Re-sync on any live settings change so toggling InfiniteCameraLoop off mid-heist
-- restores the vanilla loop duration.
if Sapphire.RegisterLiveApply then
    Sapphire:RegisterLiveApply(apply_camera_tweak_data)
end

local function suppress_hud_clutter(unit)
    if not alive(unit) then return end
    local key = tostring(unit:key())

    -- Clean up Extra Heist Info (EHI) screen trackers & waypoints
    if managers.ehi_tracker and managers.ehi_tracker.RemoveTracker then
        pcall(function() managers.ehi_tracker:RemoveTracker(key) end)
    end
    if managers.ehi_waypoint and managers.ehi_waypoint.RemoveWaypoint then
        pcall(function() managers.ehi_waypoint:RemoveWaypoint(key) end)
    end
    if managers.ehi_tracking and managers.ehi_tracking.Remove then
        pcall(function() managers.ehi_tracking:Remove(key) end)
    end
    if managers.ehi_hudlist and managers.ehi_hudlist.CallLeftListItemFunction then
        pcall(function() managers.ehi_hudlist:CallLeftListItemFunction("Camera", "RemoveCameraLoop", key) end)
    end
end

if SecurityCamera then
    local orig_start_tape_loop = SecurityCamera._start_tape_loop
    if orig_start_tape_loop then
        function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InfiniteCameraLoop then
                tape_loop_t = INFINITE_DURATION
            end

            local res = orig_start_tape_loop(self, tape_loop_t, ...)

            if effective.Enabled and effective.InfiniteCameraLoop then
                -- Clear single-camera tracker so subsequent camera loops do not cancel this one
                SecurityCamera.active_tape_loop_unit = nil

                -- Keep physical in-world friendly blue contour
                if alive(self._unit) and self._unit:contour() then
                    self._unit:contour():add("mark_unit_friendly")
                end

                -- Immediately suppress EHI on-screen timer box and floating waypoints
                suppress_hud_clutter(self._unit)

                -- Delayed suppression in case EHI hooks executed post-call
                local unit_ref = self._unit
                if DelayedCalls and DelayedCalls.Add then
                    DelayedCalls:Add("Sapphire_SuppressCameraLoopClutter_" .. tostring(unit_ref:key()), 0.05, function()
                        suppress_hud_clutter(unit_ref)
                    end)
                end
            end

            return res
        end
    end

    local orig_start_by_level = SecurityCamera._start_tape_loop_by_upgrade_level
    if orig_start_by_level then
        function SecurityCamera:_start_tape_loop_by_upgrade_level(time_upgrade_level, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InfiniteCameraLoop then
                return self:_start_tape_loop(INFINITE_DURATION)
            end
            return orig_start_by_level(self, time_upgrade_level, ...)
        end
    end

    local orig_public_start = SecurityCamera.start_tape_loop
    if orig_public_start then
        function SecurityCamera:start_tape_loop(tape_loop_t, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InfiniteCameraLoop then
                tape_loop_t = INFINITE_DURATION
            end

            local res = orig_public_start(self, tape_loop_t, ...)

            if effective.Enabled and effective.InfiniteCameraLoop then
                SecurityCamera.active_tape_loop_unit = nil
                suppress_hud_clutter(self._unit)
            end

            return res
        end
    end

    Sapphire:Log("InfiniteCameraLoop: SecurityCamera overrides applied (clean HUD & multi-loop active).")
end
