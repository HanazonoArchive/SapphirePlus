Sapphire.Gage = Sapphire.Gage or {}

function Sapphire.Gage:CollectAll()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Gage Package Collector is disabled in Safe Mode." })
        end
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local collected_count = 0
    local interaction_mask = managers.slot and managers.slot:get_mask("player_interactions")

    if interaction_mask then
        local units = World:find_units_quick("all", interaction_mask)
        for _, unit in pairs(units) do
            if alive(unit) and unit:interaction() then
                local tweak = unit:interaction().tweak_data or unit:interaction()._tweak_data
                if tweak and type(tweak) == "string" and tweak:find("^gage_assignment") then
                    pcall(function()
                        unit:interaction():interact(player)
                        collected_count = collected_count + 1
                    end)
                end
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if collected_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Collected " .. tostring(collected_count) .. " Gage Courier packages!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: No uncollected Gage packages found on the map." })
        end
    end

    Sapphire:Log("Collected " .. tostring(collected_count) .. " Gage Courier packages.")
end
