dofile(ModPath .. "core.lua")

Sapphire:Log("PlayerManager hook loaded.")

-- ============================================================
-- Weapon restriction bypass
-- ============================================================
local orig_set_carry = PlayerManager.set_carry
function PlayerManager:set_carry(carry_id, ...)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.NoWeaponRestrictions and carry_id then
        local ct = tweak_data and tweak_data.carry and tweak_data.carry.types and tweak_data.carry.types[carry_id]
        if ct then
            local was = ct.weapon_category_fallback
            ct.weapon_category_fallback = nil
            local result = orig_set_carry and orig_set_carry(self, carry_id, ...)
            ct.weapon_category_fallback = was
            return result
        end
    end
    return orig_set_carry and orig_set_carry(self, carry_id, ...)
end

-- ============================================================
-- Armor movement penalty bypass
-- ============================================================
local orig_mod_movement_penalty = PlayerManager.mod_movement_penalty
function PlayerManager:mod_movement_penalty(...)
    local penalty = orig_mod_movement_penalty and orig_mod_movement_penalty(self, ...) or 1.0
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.IgnoreArmorPenalty and self:is_carrying() then
        return 1.0
    end
    return penalty
end
