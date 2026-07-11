dofile(ModPath .. "core.lua")

Sapphire:Log("CarryTweakData hook loaded.")

local orig_carry_init = CarryTweakData.init
function CarryTweakData:init(tweak_data, ...)
    if orig_carry_init then
        orig_carry_init(self, tweak_data, ...)
    end
    
    local effective = Sapphire:GetEffectiveSettings()
    if not effective.Enabled then return end
    
    -- Save vanilla types for EHI spoofing
    Sapphire.VanillaCarryTypes = {}
    if self.types then
        for id, data in pairs(self.types) do
            Sapphire.VanillaCarryTypes[id] = {
                move_speed_modifier = data.move_speed_modifier,
                sprint_speed_modifier = data.sprint_speed_modifier,
                jump_modifier = data.jump_modifier,
                throw_distance_multiplier = data.throw_distance_multiplier,
                can_run = data.can_run
            }
            
            if not (id == "person" and not effective.AffectBodyBags) then
                -- Set speed modifiers to 1.0 directly so that carrying a bag feels weightless.
                data.move_speed_modifier = 1.0
                data.sprint_speed_modifier = 1.0
                data.jump_modifier = effective.JumpHeight
                data.throw_distance_multiplier = effective.ThrowDistance
                
                if effective.AlwaysSprint then
                    data.can_run = true
                end
            end
        end
        Sapphire:Log("Carry++ physics modifiers applied.")
    end
end
