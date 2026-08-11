Sapphire.Civilians = Sapphire.Civilians or {}

function Sapphire.Civilians:TieAll()
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Tie All Civilians is disabled in Safe Mode." })
        end
        return
    end

    local count = 0
    local all_civilians = managers.enemy and managers.enemy:all_civilians()

    if all_civilians then
        for _, u_data in pairs(all_civilians) do
            local civ = u_data.unit
            if alive(civ) and civ:brain() and civ:character_damage() and not civ:character_damage():dead() then
                pcall(function()
                    local brain = civ:brain()
                    if not (brain.is_tied and brain:is_tied()) then
                        -- 1. Instantly halt any running or fleeing movement
                        local halt_act = {
                            type = "act",
                            body_part = 1,
                            clamp_to_graph = true,
                            variant = "halt"
                        }
                        if brain.action_request then
                            brain:action_request(halt_act)
                        end

                        -- 2. Force maximum instant intimidation (math.huge bypasses progression stages)
                        if brain._current_logic and brain._current_logic.on_intimidated and brain._logic_data then
                            brain._current_logic.on_intimidated(brain._logic_data, math.huge, player, true)
                        elseif brain.on_intimidated then
                            brain:on_intimidated(100, player)
                        end

                        -- 3. Native on_tied execution (registers hostage with GroupAI and ties hands)
                        if brain.on_tied then
                            brain:on_tied(player)
                        end

                        -- 4. Enable follow/stay interaction prompt
                        if civ:interaction() and civ:interaction():active() then
                            civ:interaction():set_tweak_data("hostage_move")
                            civ:interaction():set_active(true, true)
                        end

                        count = count + 1
                    end
                end)
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Instantly restrained & tied " .. tostring(count) .. " civilians!" })
    end
    Sapphire:Log("Instantly tied " .. tostring(count) .. " civilians.")
end
