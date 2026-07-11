local effective = Sapphire:GetEffectiveSettings()
if not effective.Enabled then return end

-- ============================================================
-- EHI SPOOF
-- ============================================================
if tweak_data and tweak_data.carry and tweak_data.carry.types and Sapphire.VanillaCarryTypes then
    for id, data in pairs(tweak_data.carry.types) do
        local vanilla = Sapphire.VanillaCarryTypes[id]
        if vanilla then
            data.move_speed_modifier = vanilla.move_speed_modifier
        end
    end
    
    DelayedCalls:Add("Sapphire_SpoofEHI_Reapply", 0.0, function()
        local current_effective = Sapphire:GetEffectiveSettings()
        for id, data in pairs(tweak_data.carry.types) do
            if not (id == "person" and not current_effective.AffectBodyBags) then
                data.move_speed_modifier = 1.0
            end
        end
    end)
end

-- ============================================================
-- INTERACTION OVERRIDES
-- ============================================================
if BaseInteractionExt then
    local orig_interact_distance = BaseInteractionExt.interact_distance
    function BaseInteractionExt:interact_distance(...)
        local distance = orig_interact_distance(self, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.ExtendedInteract and current_effective.ExtendedInteract > 1.0 then
            return distance * current_effective.ExtendedInteract
        end
        return distance
    end

    local orig_timer = BaseInteractionExt._get_timer
    function BaseInteractionExt:_get_timer(...)
        local timer = orig_timer(self, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.NoInteractionCooldown then
            return 0
        end
        return timer
    end
end
