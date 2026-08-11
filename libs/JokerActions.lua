Sapphire.Jokers = Sapphire.Jokers or {}

function Sapphire.Jokers:ConvertAll()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Army of Jokers is disabled in Safe Mode." })
        end
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    -- 1. Bypass max minion limits in tweak data
    if tweak_data and tweak_data.upgrades and tweak_data.upgrades.values and tweak_data.upgrades.values.player then
        tweak_data.upgrades.values.player.convert_enemies = { true }
        tweak_data.upgrades.values.player.convert_enemies_max_minions = { 999, 999 }
        tweak_data.upgrades.values.player.convert_enemies_health_multiplier = { 0.25, 0.25 }
        tweak_data.upgrades.values.player.convert_enemies_damage_multiplier = { 2.5, 2.5 }
    end

    local converted_count = 0
    local processed_units = {}

    -- Helper function to convert an enemy unit to a friendly criminal minion
    local function convert_unit(unit)
        if not alive(unit) or processed_units[unit:key()] then
            return
        end
        processed_units[unit:key()] = true

        if unit:character_damage() and unit:character_damage():dead() then
            return
        end

        local brain = unit:brain()
        if not brain then return end

        pcall(function()
            -- Force surrender state
            brain:set_logic("surrender")
            if brain._logic_data then
                brain._logic_data.is_tied = false
            end

            -- Convert to player's criminal team
            if managers.group_ai and managers.group_ai:state() then
                managers.group_ai:state():convert_hostage_to_criminal(unit, player)
            end

            -- Apply friendly contour outline
            if unit:contour() then
                unit:contour():add("friendly", true)
            end

            converted_count = converted_count + 1
        end)
    end

    -- 2. Convert all tracked enemies
    if managers.enemy and managers.enemy.all_enemies then
        for _, data in pairs(managers.enemy:all_enemies()) do
            convert_unit(data.unit)
        end
    end

    -- 3. Also sweep world for any untracked enemy units
    local enemy_mask = managers.slot and managers.slot:get_mask("enemies")
    if enemy_mask then
        local units = World:find_units_quick("all", enemy_mask)
        for _, unit in pairs(units) do
            convert_unit(unit)
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if converted_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Converted an army of " .. tostring(converted_count) .. " cops into Jokers!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: No active cops available to convert." })
        end
    end

    Sapphire:Log("Converted " .. tostring(converted_count) .. " cops into friendly Jokers.")
end
