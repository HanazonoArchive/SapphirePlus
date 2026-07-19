if not Sapphire then return end

if not TimerGui then return end

-- Prevent the drill from randomly breaking down over time
local TimerGui_set_jamming_values = TimerGui._set_jamming_values
function TimerGui:_set_jamming_values(...)
    local effective = Sapphire:GetEffectiveSettings()
    
    if effective.Enabled and effective.ReliableDrills then
        -- Return instantly so the game never assigns a jam timer
        return
    end
    
    return TimerGui_set_jamming_values(self, ...)
end

-- Prevent cops from manually sabotaging or breaking the drill
local TimerGui_set_jammed = TimerGui.set_jammed
function TimerGui:set_jammed(jammed, ...)
    local effective = Sapphire:GetEffectiveSettings()
    
    if effective.Enabled and effective.ReliableDrills and jammed then
        -- If the game tries to jam the drill, we intercept and block it
        return
    end
    
    return TimerGui_set_jammed(self, jammed, ...)
end
