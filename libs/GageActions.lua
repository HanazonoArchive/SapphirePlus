Sapphire.Gage = Sapphire.Gage or {}

local function is_gage_package(unit)
    if not (alive(unit) and unit.interaction and unit:interaction()) then
        return false
    end
    local tweak = unit:interaction().tweak_data
    if tweak then
        local t = tostring(tweak):lower()
        if t:find("^gage") or t:find("assignment") or t:find("package") or
           t:find("snake") or t:find("eagle") or t:find("spider") or t:find("bull") or t:find("mantis") then
            return true
        end
    end
    local unit_name = unit:name()
    if unit_name then
        local name_str = tostring(unit_name):lower()
        if name_str:find("gage") or name_str:find("assignment") then
            return true
        end
    end
    return false
end

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
    local processed_keys = {}

    local function collect_unit(unit)
        if not alive(unit) or processed_keys[unit:key()] then return end
        processed_keys[unit:key()] = true

        if is_gage_package(unit) and unit:interaction():active() then
            pcall(function()
                local interaction = unit:interaction()
                local orig_can_interact = interaction.can_interact
                interaction.can_interact = function() return true end

                interaction:interact(player)

                interaction.can_interact = orig_can_interact
                collected_count = collected_count + 1
            end)
        end
    end

    -- 1. Scan active interactables table
    local interactables = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(interactables) do
        collect_unit(unit)
    end

    -- 2. Scan Gage Assignment Manager unit cache
    if managers.gage_assignment then
        local assignments = managers.gage_assignment._assignments or {}
        for _, assign_data in pairs(assignments) do
            if type(assign_data) == "table" and assign_data.units then
                for _, u in pairs(assign_data.units) do
                    collect_unit(u)
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
