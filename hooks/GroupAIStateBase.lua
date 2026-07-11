dofile(ModPath .. "core.lua")

Sapphire:Log("GroupAIStateBase hook loaded.")

-- ============================================================
-- AI Can't Alarm: Block Global Alarm
-- on_police_called is the central broadcast that makes the
-- heist go loud. Every detection path (guard sees player,
-- guard finds body, camera trips) eventually calls this.
-- Blocking it means the alarm siren can NEVER sound.
-- ============================================================
local orig_on_police_called = GroupAIStateBase.on_police_called
function GroupAIStateBase:on_police_called(called_reason, ...)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.AICantAlarm then
        return
    end
    if orig_on_police_called then
        return orig_on_police_called(self, called_reason, ...)
    end
end
