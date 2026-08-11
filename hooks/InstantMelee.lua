dofile(ModPath .. "core.lua")

Sapphire:Log("InstantMelee hook loaded.")

if PlayerStandard then
    local orig_get_melee_charge_lerp_value = PlayerStandard._get_melee_charge_lerp_value
    if orig_get_melee_charge_lerp_value then
        function PlayerStandard:_get_melee_charge_lerp_value(t, offset, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.InstantMeleeCharge then
                return 1.0
            end
            return orig_get_melee_charge_lerp_value(self, t, offset, ...)
        end
    end

    Sapphire:Log("InstantMelee: PlayerStandard overrides applied.")
end
