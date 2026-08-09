dofile(ModPath .. "core.lua")

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
    -- Interaction distance multiplier
    local orig_interact_distance = BaseInteractionExt.interact_distance
    function BaseInteractionExt:interact_distance(...)
        local distance = orig_interact_distance(self, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.ExtendedInteract and current_effective.ExtendedInteract > 1.0 then
            return distance * current_effective.ExtendedInteract
        end
        return distance
    end

    -- Instant / no interaction cooldown
    local orig_timer = BaseInteractionExt._get_timer
    function BaseInteractionExt:_get_timer(...)
        local timer = orig_timer(self, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.NoInteractionCooldown then
            return 0
        end
        return timer
    end

    -- Helper to check if special_equipment_block should be bypassed
    local function is_managed_block(blocker)
        if not blocker then return false end
        if blocker == "cable_tie" or blocker == "crowbar" or blocker == "glass_cutter" then
            return false
        end
        return true
    end

    -- Bypass special_equipment_block in can_select
    local orig_can_select = BaseInteractionExt.can_select
    function BaseInteractionExt:can_select(player, locator, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.MultiPickup then
            local orig_block = self._tweak_data and self._tweak_data.special_equipment_block
            if orig_block then
                local should_bypass = false
                if type(orig_block) == "string" and is_managed_block(orig_block) then
                    should_bypass = true
                elseif type(orig_block) == "table" then
                    for _, b in pairs(orig_block) do
                        if is_managed_block(b) then
                            should_bypass = true
                            break
                        end
                    end
                end

                if should_bypass then
                    self._tweak_data.special_equipment_block = nil
                    local res = orig_can_select(self, player, locator, ...)
                    self._tweak_data.special_equipment_block = orig_block
                    return res
                end
            end
        end
        return orig_can_select(self, player, locator, ...)
    end

    -- Bypass special_equipment_block in can_interact
    local orig_can_interact = BaseInteractionExt.can_interact
    function BaseInteractionExt:can_interact(player, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.MultiPickup then
            local orig_block = self._tweak_data and self._tweak_data.special_equipment_block
            if orig_block then
                local should_bypass = false
                if type(orig_block) == "string" and is_managed_block(orig_block) then
                    should_bypass = true
                elseif type(orig_block) == "table" then
                    for _, b in pairs(orig_block) do
                        if is_managed_block(b) then
                            should_bypass = true
                            break
                        end
                    end
                end

                if should_bypass then
                    self._tweak_data.special_equipment_block = nil
                    local res = orig_can_interact(self, player, ...)
                    self._tweak_data.special_equipment_block = orig_block
                    return res
                end
            end
        end
        return orig_can_interact(self, player, ...)
    end
end
