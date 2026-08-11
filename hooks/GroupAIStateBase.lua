dofile(ModPath .. "core.lua")

Sapphire:Log("GroupAIStateBase hook loaded.")

-- ============================================================
-- AI Can't Alarm: Block Enemy Calls in Stealth Only
-- on_police_called is the central broadcast that makes the
-- heist go loud. We only block guards and cameras from calling
-- during stealth. We NEVER block scripted loud heists (Hoxton
-- Breakout, Safehouse Defense, etc.) or ongoing loud assaults.
-- ============================================================
local orig_on_police_called = GroupAIStateBase.on_police_called
function GroupAIStateBase:on_police_called(called_reason, ...)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.AICantAlarm then
        -- Only block enemy calls if the heist is currently in stealth and not a scripted loud mission start
        if self:whisper_mode() and called_reason ~= "script" then
            return
        end
    end
    if orig_on_police_called then
        return orig_on_police_called(self, called_reason, ...)
    end
end
