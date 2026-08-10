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

    -- 1. Revive local player if downed / bleedout
    if alive(player) and player:character_damage() and player:character_damage():need_revive() then
        pcall(function()
            player:character_damage():revive(true)
            revived_count = revived_count + 1
        end)
    end

    -- 2. Revive all player teammates and AI bots
    if managers.group_ai and managers.group_ai:state() then
        local all_criminals = {}
        for _, c in pairs(managers.group_ai:state():all_player_criminals() or {}) do
            table.insert(all_criminals, c.unit)
        end
        for _, c in pairs(managers.group_ai:state():all_AI_criminals() or {}) do
            table.insert(all_criminals, c.unit)
        end

        for _, unit in pairs(all_criminals) do
            if alive(unit) and unit:character_damage() and unit:character_damage():need_revive() then
                pcall(function()
                    unit:character_damage():revive(player)
                    revived_count = revived_count + 1
                end)
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if revived_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Revived " .. tostring(revived_count) .. " downed teammates!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: All team members are already standing & healthy." })
        end
    end
end
