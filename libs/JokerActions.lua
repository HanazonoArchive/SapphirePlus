Sapphire.Jokers = Sapphire.Jokers or {}

local is_processing_queue = false

function Sapphire.Jokers:ConvertAll()
    if is_processing_queue then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Joker conversion already in progress..." })
        end
        return
    end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Army of Jokers is disabled in Safe Mode." })
        end
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    -- Restrict to loud gameplay only (prevents stealth AI desyncs)
    if managers.group_ai and managers.group_ai:state() and managers.group_ai:state():whisper_mode() then
        if managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Army of Jokers is only available when the heist is loud." })
        end
        return
    end

    -- 1. Bypass max minion limits in tweak data and player manager
    if tweak_data and tweak_data.upgrades and tweak_data.upgrades.values and tweak_data.upgrades.values.player then
        tweak_data.upgrades.values.player.convert_enemies = { true }
        tweak_data.upgrades.values.player.convert_enemies_max_minions = { 999, 999 }
        tweak_data.upgrades.values.player.convert_enemies_health_multiplier = { 0.25, 0.25 }
        tweak_data.upgrades.values.player.convert_enemies_damage_multiplier = { 2.5, 2.5 }
    end

    local orig_upgrade_val = managers.player and managers.player.upgrade_value
    local orig_has_upgrade = managers.player and managers.player.has_category_upgrade
    if managers.player then
        managers.player.upgrade_value = function(self, cat, upg, def)
            if cat == "player" and (upg == "convert_enemies_max_minions" or upg == "convert_enemies") then
                return upg == "convert_enemies_max_minions" and 999 or true
            end
            if orig_upgrade_val then return orig_upgrade_val(self, cat, upg, def) end
            return def
        end
        managers.player.has_category_upgrade = function(self, cat, upg)
            if cat == "player" and upg == "convert_enemies" then return true end
            if orig_has_upgrade then return orig_has_upgrade(self, cat, upg) end
            return false
        end
    end

    -- 2. Scan and populate cops queue
    local cops_queue = {}
    local processed_keys = {}

    local function add_candidate(unit)
        if not alive(unit) or processed_keys[unit:key()] then return end
        if unit:character_damage() and unit:character_damage():dead() then return end
        
        local brain = unit:brain()
        if not brain then return end
        local logic_data = brain._logic_data
        if logic_data and logic_data.is_converted then return end

        processed_keys[unit:key()] = true
        table.insert(cops_queue, unit)
    end

    if managers.enemy and managers.enemy.all_enemies then
        for _, data in pairs(managers.enemy:all_enemies()) do
            add_candidate(data.unit)
        end
    end

    local enemy_mask = managers.slot and managers.slot:get_mask("enemies")
    if enemy_mask then
        local units = World:find_units_quick("all", enemy_mask)
        for _, unit in pairs(units) do
            add_candidate(unit)
        end
    end

    if #cops_queue == 0 then
        if managers.player then
            if orig_upgrade_val then managers.player.upgrade_value = orig_upgrade_val end
            if orig_has_upgrade then managers.player.has_category_upgrade = orig_has_upgrade end
        end
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: No active cops available to convert." })
        end
        return
    end

    is_processing_queue = true
    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Converting " .. tostring(#cops_queue) .. " cops into Jokers..." })
    end

    local current_idx = 1
    local total_converted = 0

    local function process_next_cop()
        if not alive(player) then
            is_processing_queue = false
            if managers.player then
                if orig_upgrade_val then managers.player.upgrade_value = orig_upgrade_val end
                if orig_has_upgrade then managers.player.has_category_upgrade = orig_has_upgrade end
            end
            return
        end

        if current_idx > #cops_queue then
            is_processing_queue = false
            if managers.player then
                if orig_upgrade_val then managers.player.upgrade_value = orig_upgrade_val end
                if orig_has_upgrade then managers.player.has_category_upgrade = orig_has_upgrade end
            end
            if managers and managers.hud and managers.hud.show_hint then
                managers.hud:show_hint({ text = "Sapphire+: Successfully converted " .. tostring(total_converted) .. " Jokers!" })
            end
            Sapphire:Log("Joker conversion complete. Total: " .. tostring(total_converted))
            return
        end

        local unit = cops_queue[current_idx]
        current_idx = current_idx + 1

        if alive(unit) and unit:brain() and not (unit:character_damage() and unit:character_damage():dead()) then
            pcall(function()
                local brain = unit:brain()
                local logic_data = brain._logic_data

                if logic_data and not logic_data.is_converted then
                    -- 1. Force hostage flags so conversion succeeds immediately
                    logic_data.is_tied = true
                    logic_data.is_hostage = true
                    if brain.on_intimidated then
                        brain:on_intimidated(100, player)
                    end
                    if brain.set_logic and brain._logics and brain._logics.intimidated then
                        brain:set_logic("intimidated")
                    end

                    -- 2. Convert to player's criminal team
                    if managers.group_ai and managers.group_ai:state() then
                        managers.group_ai:state():convert_hostage_to_criminal(unit, player)
                    end

                    -- 3. Apply friendly contour outline once converted
                    logic_data.is_converted = true
                    if unit:contour() then
                        unit:contour():add("friendly", true)
                    end

                    total_converted = total_converted + 1
                end
            end)
        end

        DelayedCalls:Add("Sapphire_ConvertCop_" .. tostring(current_idx), 0.05, process_next_cop)
    end

    process_next_cop()
end
