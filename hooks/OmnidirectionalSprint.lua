dofile(ModPath .. "core.lua")

Sapphire:Log("OmnidirectionalSprint hook loaded.")

-- ============================================================
-- OMNIDIRECTIONAL SPRINT
-- ============================================================
-- Vanilla PlayerStandard:_can_run_directional() gates sprinting to
-- a forward-facing cone (50 deg, or 92 with the strafe-run skill),
-- unless the player has the free-run upgrade. Overriding it to
-- always return true lets the player sprint in any movement
-- direction (back/strafe) without that skill.
--
-- Verified against decompiled source: the crouch and steelsight
-- restrictions live elsewhere (_start_action_running interrupts
-- both on run-start; the low-ceiling duck check is independent), so
-- forcing this to true does NOT allow running while aiming or under
-- a low ceiling. It only removes the directional angle limit.
-- ============================================================

if PlayerStandard and not PlayerStandard._sapphire_omnisprint_hooked then
    PlayerStandard._sapphire_omnisprint_hooked = true

    local orig_can_run_directional = PlayerStandard._can_run_directional
    if orig_can_run_directional then
        function PlayerStandard:_can_run_directional(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.OmnidirectionalSprint then
                return true
            end
            return orig_can_run_directional(self, ...)
        end

        Sapphire:Log("OmnidirectionalSprint: PlayerStandard override applied.")
    end
end
