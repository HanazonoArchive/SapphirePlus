dofile(ModPath .. "core.lua")

Sapphire:Log("DrillOverhaul hook loaded.")

-- ============================================================
-- DRILL OVERHAUL: No Breakdowns & Instant Drills
-- ============================================================
-- 1. Drills Never Jam (DrillNoJams):
--    - Empties TimerGui._jamming_values so no breakdown checkpoints are scheduled.
--    - Blocks TimerGui:set_jammed / TimerGui:_set_jammed / Drill:set_jammed
--      from entering the jammed state.
--    - Failsafe in TimerGui:update to instantly clear any forced script jams.
-- 2. Instant Drills (InstantDrills):
--    - Implies Drills Never Jam.
--    - Forces the timer to 0.01s in TimerGui:_start and TimerGui:start
--      (verified: TimerGui:_start does `self._timer = timer or 5`, so a small
--      timer value takes effect). TimerGui:set_timer does NOT exist in the
--      engine and is intentionally not hooked.
--
-- This file is registered on both the timergui and drill hook_ids, so it runs
-- twice. Each class block is guarded for idempotency to avoid double-wrapping
-- the raw detours.
-- ============================================================

-- Hook TimerGui (lib/units/props/timergui)
if TimerGui and not TimerGui._sapphire_drill_hooked then
    TimerGui._sapphire_drill_hooked = true

    local orig_timergui_start = TimerGui._start
    if orig_timergui_start then
        function TimerGui:_start(timer, current_timer, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InstantDrills then
                timer = 0.01
                if current_timer then
                    current_timer = 0.01
                end
            end

            local res = orig_timergui_start(self, timer, current_timer, ...)

            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                self._jamming_values = {}
            end

            return res
        end
    end

    local orig_timergui_public_start = TimerGui.start
    if orig_timergui_public_start then
        function TimerGui:start(timer, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InstantDrills then
                timer = 0.01
            end

            local res = orig_timergui_public_start(self, timer, ...)

            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                self._jamming_values = {}
            end

            return res
        end
    end

    local orig_set_jamming_values = TimerGui._set_jamming_values
    if orig_set_jamming_values then
        function TimerGui:_set_jamming_values(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                self._jamming_values = {}
                return
            end
            return orig_set_jamming_values(self, ...)
        end
    end

    local orig_timergui_set_jammed = TimerGui.set_jammed
    if orig_timergui_set_jammed then
        function TimerGui:set_jammed(jammed, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) and jammed then
                return
            end
            return orig_timergui_set_jammed(self, jammed, ...)
        end
    end

    local orig_timergui_internal_set_jammed = TimerGui._set_jammed
    if orig_timergui_internal_set_jammed then
        function TimerGui:_set_jammed(jammed, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) and jammed then
                return
            end
            return orig_timergui_internal_set_jammed(self, jammed, ...)
        end
    end

    local orig_timergui_update = TimerGui.update
    if orig_timergui_update then
        function TimerGui:update(unit, t, dt, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                if self._jammed then
                    self._jammed = false
                    if orig_timergui_set_jammed then
                        orig_timergui_set_jammed(self, false)
                    end
                end
            end
            return orig_timergui_update(self, unit, t, dt, ...)
        end
    end

    Sapphire:Log("DrillOverhaul: TimerGui overrides applied.")
end

-- Hook Drill (lib/units/props/drill)
-- Only Drill:set_jammed exists on the Drill class; clbk_jam / clbk_power_cut
-- do NOT exist in the engine (verified) and are not hooked.
if Drill and not Drill._sapphire_drill_hooked then
    Drill._sapphire_drill_hooked = true

    local orig_drill_set_jammed = Drill.set_jammed
    if orig_drill_set_jammed then
        function Drill:set_jammed(jammed, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) and jammed then
                return
            end
            return orig_drill_set_jammed(self, jammed, ...)
        end
    end

    Sapphire:Log("DrillOverhaul: Drill overrides applied.")
end
