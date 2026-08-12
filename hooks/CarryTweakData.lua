dofile(ModPath .. "core.lua")

Sapphire:Log("CarryTweakData hook loaded.")

local orig_carry_init = CarryTweakData.init
function CarryTweakData:init(tweak_data, ...)
    if orig_carry_init then
        orig_carry_init(self, tweak_data, ...)
    end
    
    local effective = Sapphire:GetEffectiveSettings()
    if not effective.Enabled then return end

    -- Capture vanilla carry values before the first apply. These are used both
    -- for EHI spoofing (InteractionExt) and for the restore branch inside
    -- Sapphire:ApplyCarryModifiers.
    Sapphire.VanillaCarryTypes = {}
    if self.types then
        for id, data in pairs(self.types) do
            Sapphire.VanillaCarryTypes[id] = {
                move_speed_modifier = data.move_speed_modifier,
                jump_modifier = data.jump_modifier,
                throw_distance_multiplier = data.throw_distance_multiplier,
                can_run = data.can_run
            }
        end

        -- Pass self.types explicitly: the global tweak_data is not yet wired up
        -- during CarryTweakData construction.
        Sapphire:ApplyCarryModifiers(self.types)
        Sapphire:Log("Carry++ physics modifiers applied.")
    end
end
