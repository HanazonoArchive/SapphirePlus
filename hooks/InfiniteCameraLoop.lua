dofile(ModPath .. "core.lua")

Sapphire:Log("InfiniteCameraLoop hook loaded.")

-- ============================================================
-- INFINITE CAMERA LOOP: Override tape loop duration
-- ============================================================
-- 1. Updates tweak_data upgrade values so HUD mods (like Extra Heist Info)
--    and the game engine read the loop duration as 99,999s.
-- 2. Hooks SecurityCamera:_start_tape_loop to force infinite duration.
-- ============================================================

local INFINITE_DURATION = 99999

local function apply_camera_tweak_data()
    local effective = Sapphire:GetEffectiveSettings()
    if not effective.Enabled or not effective.InfiniteCameraLoop then return end

    if tweak_data and tweak_data.upgrades and tweak_data.upgrades.values and tweak_data.upgrades.values.player then
        if tweak_data.upgrades.values.player.tape_loop_duration then
            tweak_data.upgrades.values.player.tape_loop_duration = { INFINITE_DURATION, INFINITE_DURATION }
        end
        if tweak_data.upgrades.values.player.tape_loop_duration_2 then
            tweak_data.upgrades.values.player.tape_loop_duration_2 = { INFINITE_DURATION, INFINITE_DURATION }
        end
    end
end

apply_camera_tweak_data()

if SecurityCamera then
    local orig_start_tape_loop = SecurityCamera._start_tape_loop
    if orig_start_tape_loop then
        function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InfiniteCameraLoop then
                tape_loop_t = INFINITE_DURATION
            end
            return orig_start_tape_loop(self, tape_loop_t, ...)
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
            return orig_public_start(self, tape_loop_t, ...)
        end
    end

    Sapphire:Log("InfiniteCameraLoop: SecurityCamera overrides applied.")
end
