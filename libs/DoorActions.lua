Sapphire.Doors = Sapphire.Doors or {}

local function is_unlockable_door(tweak)
    if not tweak then return false end
    local t = tostring(tweak):lower()
    return t:find("^pick_lock") or t:find("^keycard") or t:find("^security_station") or
           t:find("^suburbia_iron_gate") or t:find("^cage_door") or t:find("^open_door") or
           t:find("^open_train_door") or t:find("^timelock_panel") or t:find("^cut_fence") or
           t:find("^lockpick") or t:find("^hack_suburbia") or t:find("^hold_open_vent") or
           t:find("^open_slash_close_act")
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
    local all_interactables = managers.interaction and managers.interaction._interactive_units or {}

    for _, unit in pairs(all_interactables) do
        if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
            local tweak = unit:interaction().tweak_data
            if is_unlockable_door(tweak) then
                pcall(function()
                    local t_data = unit:interaction()._tweak_data
                    local orig_equip = t_data and t_data.special_equipment
                    local orig_block = t_data and t_data.special_equipment_block
                    if t_data then
                        t_data.special_equipment = nil
                        t_data.special_equipment_block = nil
                    end

                    unit:interaction():interact(player)

                    if t_data then
                        t_data.special_equipment = orig_equip
                        t_data.special_equipment_block = orig_block
                    end
                    count = count + 1
                end)
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Unlocked " .. tostring(count) .. " doors & security gates!" })
    end
    Sapphire:Log("Unlocked " .. tostring(count) .. " doors.")
end
