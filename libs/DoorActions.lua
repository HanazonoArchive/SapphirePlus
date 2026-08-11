Sapphire.Doors = Sapphire.Doors or {}

local function is_unlockable_door(tweak)
    if not tweak then return false end
    local t = tostring(tweak):lower()
    return t:find("^pick_lock") or t:find("^keycard") or t:find("^security_station") or
           t:find("^suburbia_iron_gate") or t:find("^cage_door") or t:find("^open_door") or
           t:find("^open_train_door") or t:find("^timelock_panel") or t:find("^cut_fence") or
           t:find("^lockpick") or t:find("^hack_suburbia") or t:find("^hold_open_vent") or
           t:find("^open_slash_close_act") or t:find("^door_double") or t:find("^press_open")
end

function Sapphire.Doors:UnlockAll()
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Unlock All Doors is disabled in Safe Mode." })
        end
        return
    end

    local count = 0
    local processed_keys = {}

    local function interact_unit(unit)
        if not alive(unit) or not unit.interaction or not unit:interaction() or not unit:interaction():active() then
            return
        end
        local tweak = unit:interaction().tweak_data
        if is_unlockable_door(tweak) then
            pcall(function()
                local interaction = unit:interaction()
                local orig_can_interact = interaction.can_interact
                local t_data = interaction._tweak_data
                local orig_equip = t_data and t_data.special_equipment
                local orig_block = t_data and t_data.special_equipment_block
                if t_data then
                    t_data.special_equipment = nil
                    t_data.special_equipment_block = nil
                end
                interaction.can_interact = function() return true end

                interaction:interact(player)

                if t_data then
                    t_data.special_equipment = orig_equip
                    t_data.special_equipment_block = orig_block
                end
                interaction.can_interact = orig_can_interact

                if not processed_keys[unit:key()] then
                    processed_keys[unit:key()] = true
                    count = count + 1
                end
            end)
        end
    end

    -- PASS 1: Unlock all security keypads, lockpicks, cut fences, and primary latches
    local all_interactables = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(all_interactables) do
        interact_unit(unit)
    end

    local world_units = World:find_units_quick("all", 1)
    for _, unit in pairs(world_units) do
        interact_unit(unit)
    end

    -- PASS 2: 0.12s later, open any door handles or second leaves that unlocked from Pass 1
    DelayedCalls:Add("Sapphire_DoorPass2", 0.12, function()
        if not alive(player) then return end
        local current_interactables = managers.interaction and managers.interaction._interactive_units or {}
        for _, unit in pairs(current_interactables) do
            interact_unit(unit)
        end
        local current_world = World:find_units_quick("all", 1)
        for _, unit in pairs(current_world) do
            interact_unit(unit)
        end
    end)

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Unlocked & opened " .. tostring(count) .. " doors, keycard readers & security gates!" })
    end
    Sapphire:Log("Unlocked " .. tostring(count) .. " doors (2-pass execution).")
end
