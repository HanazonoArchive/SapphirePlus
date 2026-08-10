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

    local civ_mask = managers.slot and managers.slot:get_mask("civilians")
    if not civ_mask then return end

    local count = 0
    local civilians = World:find_units_quick("all", civ_mask)

    for _, civ in pairs(civilians) do
        if alive(civ) and civ:brain() and civ:character_damage() and not civ:character_damage():dead() then
            pcall(function()
                local brain = civ:brain()
                local logic_data = brain._logic_data

                -- 1. Switch logic brain directly into surrender mode
                if brain.set_logic then
                    brain:set_logic("surrender")
                end

                -- 2. Force submission state past 'alerted', 'hands_up', and 'kneeling' directly to 'tied'
                if logic_data then
                    logic_data.is_tied = true
                    if logic_data.internal_data then
                        logic_data.internal_data.submission_state = "tied"
                        logic_data.internal_data.submitting = nil
                    end
                end

                -- 3. Play immediate tied pose animation (stops standing/running instantly)
                if civ:movement() then
                    if civ:movement().play_redirect then
                        civ:movement():play_redirect(Idstring("tied"))
                    end
                    if civ:movement().action_request then
                        civ:movement():action_request({
                            type = "act",
                            body_part = 1,
                            variant = "tied",
                            clamp_to_graph = true
                        })
                    end
                end

                -- 4. Execute on_tied callback
                if brain.on_tied then
                    brain:on_tied(player, false)
                end

                -- 5. Register hostage state in GroupAI immediately
                if managers.group_ai and managers.group_ai:state() and managers.group_ai:state().on_hostage_state then
                    managers.group_ai:state():on_hostage_state(true, civ:key(), false)
                end

                -- 6. Configure interaction to 'hostage_move' (follow/stand up prompt)
                if civ:interaction() then
                    pcall(function()
                        civ:interaction():set_tweak_data("hostage_move")
                        civ:interaction():set_active(true, true)
                    end)
                end

                count = count + 1
            end)
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Instantly restrained & tied " .. tostring(count) .. " civilians!" })
    end
    Sapphire:Log("Instantly tied " .. tostring(count) .. " civilians (bypassed submission state machine).")
end
