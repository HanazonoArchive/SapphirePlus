Sapphire.Revive = Sapphire.Revive or {}

function Sapphire.Revive:ReviveTeam()
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Team Revive is disabled in Safe Mode." })
        end
        return
    end

    local revived_count = 0

    -- 1. Revive local player from all down states (Bleedout, Fatal, Tased, Incapacitated, Arrested)
    if alive(player) then
        local char_dmg = player:character_damage()
        local current_state = managers.player and managers.player:current_state()

        if char_dmg and char_dmg.need_revive and char_dmg:need_revive() then
            pcall(function()
                char_dmg:revive(true)
                revived_count = revived_count + 1
            end)
        elseif current_state == "incapacitated" or current_state == "tased" or current_state == "arrested" or current_state == "bleed_out" or current_state == "fatal" then
            pcall(function()
                managers.player:set_player_state("standard")
                if char_dmg and char_dmg.band_aid_health then
                    char_dmg:band_aid_health()
                end
                revived_count = revived_count + 1
            end)
        end
    end

    -- 2. Revive all player teammates and AI bots
    local group_ai = (managers.groupai or managers.group_ai) and (managers.groupai or managers.group_ai):state()
    if group_ai then
        local all_criminals = {}
        for _, c in pairs(group_ai:all_player_criminals() or {}) do
            if c and alive(c.unit) then table.insert(all_criminals, c.unit) end
        end
        for _, c in pairs(group_ai:all_AI_criminals() or {}) do
            if c and alive(c.unit) then table.insert(all_criminals, c.unit) end
        end

        for _, unit in pairs(all_criminals) do
            if alive(unit) and unit ~= player then
                local u_dmg = unit:character_damage()
                if u_dmg then
                    pcall(function()
                        if u_dmg.need_revive and u_dmg:need_revive() then
                            u_dmg:revive(player)
                            revived_count = revived_count + 1
                        elseif u_dmg._incapacitated or u_dmg._tased or (u_dmg.is_arrested and u_dmg:is_arrested()) then
                            if u_dmg.revive then u_dmg:revive(player) end
                            u_dmg._incapacitated = nil
                            u_dmg._tased = nil
                            revived_count = revived_count + 1
                        end
                    end)
                end
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if revived_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Revived & restored " .. tostring(revived_count) .. " downed teammates!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: All team members are already standing & healthy." })
        end
    end

    Sapphire:Log("Team revive executed. Revived: " .. tostring(revived_count))
end
