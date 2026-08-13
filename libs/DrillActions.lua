Sapphire.Drills = Sapphire.Drills or {}

-- ============================================================
-- FIX & FINISH ALL ACTIVE DRILLS (Tactical Action 13)
-- ============================================================
-- Sweeps all placed and active drills, thermal saws, timelocks,
-- and hacking devices across the heist map. Unjams any broken
-- equipment and sets the remaining timer to 0.01 seconds.
--
-- Gated by Safe Mode for multiplayer clients.
-- ============================================================

function Sapphire.Drills:FixAndSpeedAll()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Drill Actions are disabled in Safe Mode." })
        end
        return
    end

    local count = 0

    pcall(function()
        local units = World:find_units_quick("all")
        for _, unit in ipairs(units) do
            if alive(unit) then
                local modified = false

                -- 1. Check TimerGui (Drills, Saws, Hacking Panels)
                if unit.timer_gui and unit:timer_gui() then
                    local gui = unit:timer_gui()
                    if gui._jammed or (gui._current_timer and gui._current_timer > 0.05) then
                        gui._jammed = false
                        if gui.set_jammed then
                            pcall(function() gui:set_jammed(false) end)
                        end
                        gui._current_timer = 0.01
                        if gui.done then
                            pcall(function() gui:done() end)
                        end
                        modified = true
                    end
                end

                -- 2. Check DigitalGui (Keypads, Timelocks, Hack Screens)
                if unit.digital_gui and unit:digital_gui() then
                    local dgui = unit:digital_gui()
                    if dgui._timer and dgui._timer > 0.05 then
                        dgui._timer = 0.01
                        modified = true
                    end
                end

                -- 3. Check Drill / Saw Base Units
                if unit.base and unit:base() then
                    local base = unit:base()
                    if base.set_jammed then
                        pcall(function() base:set_jammed(false) end)
                        modified = true
                    end
                    if base._timer and base._timer > 0.05 then
                        base._timer = 0.01
                        modified = true
                    end
                end

                if modified then
                    count = count + 1
                end
            end
        end
    end)

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Fixed & fast-forwarded " .. tostring(count) .. " active drill/timer device(s)!" })
    end

    Sapphire:Log("Drills: Fixed and speeded " .. tostring(count) .. " active devices.")
end
