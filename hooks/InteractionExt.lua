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
        local effective = Sapphire:GetEffectiveSettings()
        for id, data in pairs(tweak_data.carry.types) do
            if not effective.Enabled or (id == "person" and not effective.AffectBodyBags) then
                if Sapphire.VanillaCarryTypes and Sapphire.VanillaCarryTypes[id] then
                    local vanilla = Sapphire.VanillaCarryTypes[id]
                    data.move_speed_modifier = vanilla.move_speed_modifier
                    data.sprint_speed_modifier = vanilla.sprint_speed_modifier
                    data.jump_modifier = vanilla.jump_modifier
                    data.throw_distance_multiplier = vanilla.throw_distance_multiplier
                    data.can_run = vanilla.can_run
                end
            else
                data.move_speed_modifier = 1.0
                data.sprint_speed_modifier = 1.0
                data.jump_modifier = effective.JumpHeight
                data.throw_distance_multiplier = effective.ThrowDistance
                
                if effective.AlwaysSprint then
                    data.can_run = true
                else
                    if Sapphire.VanillaCarryTypes and Sapphire.VanillaCarryTypes[id] then
                        data.can_run = Sapphire.VanillaCarryTypes[id].can_run
                    end
                end
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
