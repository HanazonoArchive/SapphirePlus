Sapphire.Corpses = Sapphire.Corpses or {}

function Sapphire.Corpses:CleanAll()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Clean All Corpses is disabled in Safe Mode." })
        end
        return
    end

    local cleaned_count = 0
    local processed_keys = {}

    local function remove_corpse_unit(unit)
        if not alive(unit) or processed_keys[unit:key()] then return end
        processed_keys[unit:key()] = true

        pcall(function()
            if unit:slot() ~= 0 then
                unit:set_slot(0)
                cleaned_count = cleaned_count + 1
            end
        end)
    end

    -- 1. Remove tracked corpses from EnemyManager
    if managers.enemy and managers.enemy.all_corpses then
        for _, data in pairs(managers.enemy:all_corpses()) do
            if data and alive(data.unit) then
                remove_corpse_unit(data.unit)
            end
        end
    end

    -- 2. Sweep corpses collision slot mask
    local corpse_mask = managers.slot and managers.slot:get_mask("corpses")
    if corpse_mask then
        local units = World:find_units_quick("all", corpse_mask)
        for _, unit in pairs(units) do
            remove_corpse_unit(unit)
        end
    end

    -- 3. Also remove any bagged bodies lying on the ground
    local interaction_mask = managers.slot and managers.slot:get_mask("player_interactions")
    if interaction_mask then
        local units = World:find_units_quick("all", interaction_mask)
        for _, unit in pairs(units) do
            if alive(unit) and unit.interaction and unit:interaction() then
                local tweak = unit:interaction().tweak_data or unit:interaction()._tweak_data
                if tweak and type(tweak) == "string" and tweak == "corpse_dispose" then
                    remove_corpse_unit(unit)
                end
            end
        end
    end

    -- 4. Sweep all interactables for bagged corpses
    local all_interactables = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(all_interactables) do
        if alive(unit) and unit.interaction and unit:interaction() then
            local tweak = unit:interaction().tweak_data
            if tweak == "corpse_dispose" then
                remove_corpse_unit(unit)
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if cleaned_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Silently cleaned " .. tostring(cleaned_count) .. " corpses and body bags!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: No corpses or body bags found on the map." })
        end
    end

    Sapphire:Log("Cleaned " .. tostring(cleaned_count) .. " corpses/bags.")
end
