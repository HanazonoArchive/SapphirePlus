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
    local processed_names = {}

    local function respawn_name(name)
        if not name or processed_names[name] then return end
        processed_names[name] = true

        if managers.trade then
            pcall(function()
                -- Ensure candidate exists in respawn queue to prevent nil table errors
                managers.trade._criminals_to_respawn = managers.trade._criminals_to_respawn or {}
                local found = false
                for _, crim in pairs(managers.trade._criminals_to_respawn) do
                    if crim and crim.id == name then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(managers.trade._criminals_to_respawn, { id = name })
                end

                if managers.trade.clbk_respawn_criminal then
                    managers.trade:clbk_respawn_criminal(name)
                    respawned_count = respawned_count + 1
                elseif managers.trade.respawn_criminal then
                    managers.trade:respawn_criminal(name)
                    respawned_count = respawned_count + 1
                end
            end)
        end
    end

    if managers.trade then
        -- 1. Respawn all queued trade candidates immediately
        if managers.trade._criminals_to_respawn and #managers.trade._criminals_to_respawn > 0 then
            for i = #managers.trade._criminals_to_respawn, 1, -1 do
                local crim = managers.trade._criminals_to_respawn[i]
                if crim and crim.id then
                    respawn_name(crim.id)
                end
            end
        end

        -- 2. Check all player criminals for custody status
        local group_ai = (managers.groupai or managers.group_ai) and (managers.groupai or managers.group_ai):state()
        if group_ai then
            for name, crim_data in pairs(group_ai:all_player_criminals() or {}) do
                if crim_data and managers.trade:is_criminal_in_custody(name) then
                    respawn_name(name)
                end
            end

            -- 3. Check AI companions for custody status
            for name, crim_data in pairs(group_ai:all_AI_criminals() or {}) do
                if crim_data and managers.trade:is_criminal_in_custody(name) then
                    respawn_name(name)
                end
            end
        end

        -- 4. Also check internal trade criminals list
        if managers.trade._criminals then
            for _, c in pairs(managers.trade._criminals) do
                if c and c.id and c.in_custody then
                    respawn_name(c.id)
                end
            end
        end

        -- 5. Trigger immediate hostage trade cycle if trade was pending
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
