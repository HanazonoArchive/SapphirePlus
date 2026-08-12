dofile(ModPath .. "core.lua")

Sapphire:Log("CarryRestrictions hook loaded.")

-- ============================================================
-- NO WEAPON RESTRICTIONS (Keep body bags when the heist goes loud)
-- ============================================================
-- PAYDAY 2 has no "cannot fire while carrying" mechanic -- you can always shoot
-- while holding a bag. The one real carry restriction tied to going loud is that
-- certain carriables (body bags / corpses that set `remove_on_weapons_hot` on
-- their carry tweak) are automatically disposed 2 seconds after enemies go
-- weapons-hot.
--
-- The engine registers that disposal through the static, server-only function
-- CarryData._register_remove_on_weapons_hot(unit, carry_id), called from
-- CarryData:set_carry_id when carry_tweak.remove_on_weapons_hot is set
-- (verified against lib/units/props/carrydata.lua:18 and :709). Detouring it to a
-- no-op while the setting is on prevents those bags from vanishing on the loud
-- transition, letting you keep hauling them.
--
-- This is a raw detour of a STATIC function (dot syntax, no self). It runs on the
-- host only anyway -- the vanilla function early-returns for non-servers -- so it
-- is inert for multiplayer clients and doubly gated by Safe Mode.
-- ============================================================

if CarryData and not CarryData._sapphire_carryrestrict_hooked then
    CarryData._sapphire_carryrestrict_hooked = true

    local orig_register = CarryData._register_remove_on_weapons_hot
    if orig_register then
        CarryData._register_remove_on_weapons_hot = function(unit, carry_id)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.NoWeaponRestrictions then
                -- Skip disposal registration: the bag stays carriable when loud.
                return
            end
            return orig_register(unit, carry_id)
        end
        Sapphire:Log("CarryRestrictions: _register_remove_on_weapons_hot override applied.")
    end
end
