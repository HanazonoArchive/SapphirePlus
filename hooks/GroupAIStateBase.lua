dofile(ModPath .. "core.lua")

Sapphire:Log("GroupAIStateBase hook loaded.")

-- ============================================================
-- AI Can't Alarm: suppress ORGANIC alarm calls during stealth
-- ============================================================
-- on_police_called(called_reason) is the central "go loud"
-- broadcast. Verified against the decompiled source:
--   * The engine NEVER passes a "script" reason string. A guard
--     against called_reason == "script" is dead code.
--   * Mission-scripted loud transitions flow through this SAME
--     method via ElementAiGlobalEvent:on_executed, with a reason
--     drawn from the ordinary blame vocabulary (or nil). There is
--     no reason string that distinguishes "a guard spotted you"
--     from "the heist script forced loud".
--
-- So we cannot key an exception off called_reason. Instead we tag
-- calls that originate from the mission script (ElementAiGlobalEvent)
-- and ALWAYS let those through -- blocking a scripted loud start
-- would soft-lock the heist. Only organic detections (guards,
-- cameras, civilians) during whisper_mode are suppressed.
--
-- This file is registered on BOTH the groupaistatebase and the
-- elementaiglobalevent hook_ids so the tag detour is installed
-- regardless of class load order. Both detours below are guarded
-- for idempotency so the double registration is safe.
-- ============================================================

Sapphire._scripted_police_call = Sapphire._scripted_police_call or false

-- Tag mission-script-originated AI events so on_police_called can
-- recognise (and never block) a scripted loud transition.
if ElementAiGlobalEvent and not ElementAiGlobalEvent._sapphire_scripted_tag then
    ElementAiGlobalEvent._sapphire_scripted_tag = true
    local orig_on_executed = ElementAiGlobalEvent.on_executed
    if orig_on_executed then
        function ElementAiGlobalEvent:on_executed(...)
            local prev = Sapphire._scripted_police_call
            Sapphire._scripted_police_call = true
            local results = { pcall(orig_on_executed, self, ...) }
            Sapphire._scripted_police_call = prev
            if not results[1] then
                error(results[2])
            end
            return unpack(results, 2)
        end
    end
end

if GroupAIStateBase and not GroupAIStateBase._sapphire_police_hooked then
    GroupAIStateBase._sapphire_police_hooked = true
    local orig_on_police_called = GroupAIStateBase.on_police_called
    function GroupAIStateBase:on_police_called(called_reason, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.AICantAlarm then
            -- Suppress only organic detections while in stealth. Mission-script
            -- loud transitions (tagged above) always pass through.
            if self:whisper_mode() and not Sapphire._scripted_police_call then
                return
            end
        end
        if orig_on_police_called then
            return orig_on_police_called(self, called_reason, ...)
        end
    end
end

if ElementLaserTrigger and not ElementLaserTrigger._sapphire_laser_hooked then
    ElementLaserTrigger._sapphire_laser_hooked = true
    local orig_laser_executed = ElementLaserTrigger.on_executed
    if orig_laser_executed then
        function ElementLaserTrigger:on_executed(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.AICantAlarm then
                return
            end
            return orig_laser_executed(self, ...)
        end
    end
end
