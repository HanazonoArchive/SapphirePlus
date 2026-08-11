Sapphire.Custody = Sapphire.Custody or {}

function Sapphire.Custody:Breakout()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Custody Breakout is disabled in Safe Mode." })
        end
        return
    end

    local respawned_count = 0

    if managers.trade then
        -- 1. Respawn all queued trade candidates immediately
        if managers.trade._criminals_to_respawn and #managers.trade._criminals_to_respawn > 0 then
            for i = #managers.trade._criminals_to_respawn, 1, -1 do
                local crim = managers.trade._criminals_to_respawn[i]
                if crim and crim.id then
                    pcall(function()
                        managers.trade:clbk_respawn_criminal(crim.id)
                        respawned_count = respawned_count + 1
                    end)
                end
            end
        end

        -- 2. Check all player criminals for custody status
        if managers.group_ai and managers.group_ai:state() then
            for name, crim_data in pairs(managers.group_ai:state():all_player_criminals() or {}) do
                if crim_data and managers.trade:is_criminal_in_custody(name) then
                    pcall(function()
                        managers.trade:clbk_respawn_criminal(name)
                        respawned_count = respawned_count + 1
                    end)
                end
            end

            -- 3. Check AI companions for custody status
            for name, crim_data in pairs(managers.group_ai:state():all_AI_criminals() or {}) do
                if crim_data and managers.trade:is_criminal_in_custody(name) then
                    pcall(function()
                        managers.trade:clbk_respawn_criminal(name)
                        respawned_count = respawned_count + 1
                    end)
                end
            end
        end

        -- 4. Also trigger immediate hostage trade cycle if trade was pending
        pcall(function()
            if managers.trade:get_best_hostage() then
                managers.trade:begin_hostage_trade()
            end
        end)
    end

    if managers and managers.hud and managers.hud.show_hint then
        if respawned_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Released " .. tostring(respawned_count) .. " teammates from custody!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: No teammates currently in custody." })
        end
    end

    Sapphire:Log("Custody breakout executed. Respawned: " .. tostring(respawned_count))
end
