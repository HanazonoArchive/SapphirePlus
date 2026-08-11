dofile(ModPath .. "core.lua")

Sapphire:Log("OmnidirectionalSprint hook loaded.")

if PlayerStandard then
    local orig_can_run = PlayerStandard._can_run
    if orig_can_run then
        function PlayerStandard:_can_run(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.OmnidirectionalSprint then
                -- If the player has any directional movement input, permit sprinting
                if self._move_dir then
                    local is_ducking = self._state_data.ducking
                    local is_aiming = self._state_data.in_steelsight
                    if not is_ducking and not is_aiming then
                        return true
                    end
                end
            end
            return orig_can_run(self, ...)
        end
    end

    Sapphire:Log("OmnidirectionalSprint: PlayerStandard overrides applied.")
end
