dofile(ModPath .. "core.lua")

Sapphire:Log("FlashbangGasImmunity hook loaded.")

if PlayerDamage then
    local orig_on_flashbanged = PlayerDamage.on_flashbanged
    if orig_on_flashbanged then
        function PlayerDamage:on_flashbanged(sound_eff_mul, duration, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.FlashbangGasImmunity then
                return
            end
            return orig_on_flashbanged(self, sound_eff_mul, duration, ...)
        end
    end

    local orig_damage_tear_gas = PlayerDamage.damage_tear_gas
    if orig_damage_tear_gas then
        function PlayerDamage:damage_tear_gas(attack_data, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.FlashbangGasImmunity then
                return false
            end
            return orig_damage_tear_gas(self, attack_data, ...)
        end
    end

    Sapphire:Log("FlashbangGasImmunity: PlayerDamage overrides applied.")
end
