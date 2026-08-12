dofile(ModPath .. "core.lua")

Sapphire:Log("PlayerManager hook loaded.")

-- NOTE: NoWeaponRestrictions is NOT implemented here. PAYDAY 2 has no
-- "can't fire while carrying" restriction on the carry tweak (`carry.types`
-- carries only move/jump/run/throw modifiers -- there is no
-- `weapon_category_fallback` field anywhere in the engine), so a set_carry
-- override was a pure no-op. The real, verifiable behavior the setting maps to --
-- carried body bags being auto-disposed the moment enemies go weapons-hot -- is
-- handled by hooks/CarryRestrictions.lua, which detours
-- CarryData._register_remove_on_weapons_hot.

-- ============================================================
-- Armor movement penalty bypass
-- ============================================================
local orig_mod_movement_penalty = PlayerManager.mod_movement_penalty
function PlayerManager:mod_movement_penalty(...)
    local penalty = orig_mod_movement_penalty and orig_mod_movement_penalty(self, ...) or 1.0
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.IgnoreArmorPenalty then
        return 1.0
    end
    return penalty
end
