dofile(ModPath .. "core.lua")

Sapphire:Log("PlayerMovement hook loaded.")

local orig_change_stamina = PlayerMovement._change_stamina
function PlayerMovement:_change_stamina(value)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.InfiniteStamina then
        -- If value is negative (stamina drain) and player is carrying a bag, cancel the drain
        if value and value < 0 and managers.player and managers.player:is_carrying() then
            return
        end
    end
    
    if orig_change_stamina then
        return orig_change_stamina(self, value)
    end
end

