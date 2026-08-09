dofile(ModPath .. "core.lua")

Sapphire:Log("DrillOverhaul hook loaded.")

-- ============================================================
-- DRILL OVERHAUL: No Breakdowns & Instant Drills
-- ============================================================
-- 1. Drills Never Jam (DrillNoJams):
--    - Blocks TimerGui:_set_jamming_values from scheduling breakdown checkpoints.
--    - Blocks TimerGui:set_jammed, TimerGui:_set_jammed, and Drill:set_jammed
--      from entering the broken state.
--    - Failsafe in TimerGui:update to instantly clear any forced script jams.
-- 2. Instant Drills (InstantDrills):
--    - Automatically implies Drills Never Jam.
--    - Sets timer to 0.01s in TimerGui:set_timer, TimerGui:_start, and TimerGui:start.
--    - Ensures zero jamming values so the drill finishes in a split second cleanly.
-- ============================================================

-- Hook TimerGui (lib/units/props/timergui)
if TimerGui then
    local orig_timergui_set_timer = TimerGui.set_timer
    if orig_timergui_set_timer then
        function TimerGui:set_timer(timer, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InstantDrills then
                timer = 0.01
            end

            local res = orig_timergui_set_timer(self, timer, ...)

            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                self._jamming_values = {}
            end

            return res
        end
    end

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
if Drill then
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

    local orig_drill_clbk_jam = Drill.clbk_jam
    if orig_drill_clbk_jam then
        function Drill:clbk_jam(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                return
            end
            return orig_drill_clbk_jam(self, ...)
        end
    end

    local orig_drill_clbk_power_cut = Drill.clbk_power_cut
    if orig_drill_clbk_power_cut then
        function Drill:clbk_power_cut(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and (effective.DrillNoJams or effective.InstantDrills) then
                return
            end
            return orig_drill_clbk_power_cut(self, ...)
        end
    end

    Sapphire:Log("DrillOverhaul: Drill overrides applied.")
end
