dofile(ModPath .. "core.lua")

Sapphire:Log("PlayerDamage hook loaded.")

-- ISSUE-03 fix: Use detour pattern instead of PreHook so attack_data mutations are guaranteed.

local orig_damage_bullet = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.BagDamageReduction then
        if managers.player and managers.player:is_carrying() and effective.BagDamageReduction > 0 then
            if attack_data and attack_data.damage then
                local multiplier = 1.0 - (effective.BagDamageReduction / 100.0)
                attack_data.damage = attack_data.damage * multiplier
            end
        end
    end
    if orig_damage_bullet then
        return orig_damage_bullet(self, attack_data)
    end
end

local orig_damage_melee = PlayerDamage.damage_melee
function PlayerDamage:damage_melee(attack_data)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.BagDamageReduction then
        if managers.player and managers.player:is_carrying() and effective.BagDamageReduction > 0 then
            if attack_data and attack_data.damage then
                local multiplier = 1.0 - (effective.BagDamageReduction / 100.0)
                attack_data.damage = attack_data.damage * multiplier
            end
        end
    end
    if orig_damage_melee then
        return orig_damage_melee(self, attack_data)
    end
end

local orig_damage_fall = PlayerDamage.damage_fall
function PlayerDamage:damage_fall(data)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.NoFallDamage then
        if managers.player and managers.player:is_carrying() then
            return false
        end
    end
    if orig_damage_fall then
        return orig_damage_fall(self, data)
    end
end
