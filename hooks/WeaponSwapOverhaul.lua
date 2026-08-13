dofile(ModPath .. "core.lua")

Sapphire:Log("WeaponSwapOverhaul hook loaded.")

-- ============================================================
-- FAST WEAPON SWAP OVERHAUL (3x Speed)
-- ============================================================
-- Triples primary and secondary weapon switching animation speed
-- for instantaneous weapon swaps in combat and stealth.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================

if PlayerStandard and not PlayerStandard._sapphire_weapon_swap_hooked then
    PlayerStandard._sapphire_weapon_swap_hooked = true

    local orig_swap_speed = PlayerStandard._get_swap_speed_multiplier
    function PlayerStandard:_get_swap_speed_multiplier(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.FastWeaponSwitch then
            local base = orig_swap_speed and orig_swap_speed(self, ...) or 1
            return base * 3.0
        end
        if orig_swap_speed then
            return orig_swap_speed(self, ...)
        end
        return 1
    end
end
