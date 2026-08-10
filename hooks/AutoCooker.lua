if not rawget(_G, "Sapphire") then
    dofile(ModPath .. "core.lua")
end

local required_chemical_by_dialog = {
    -- Rats / Cook Off (Bain)
    pln_rt1_20 = "methlab_gas_to_salt",     -- Muriatic Acid
    pln_rt1_22 = "methlab_caustic_cooler",   -- Caustic Soda
    pln_rt1_24 = "methlab_bubbling",         -- Hydrogen Chloride

    -- Corrections / Confirmations
    pln_rt1_21 = "methlab_gas_to_salt",
    pln_rt1_23 = "methlab_caustic_cooler",
    pln_rt1_25 = "methlab_bubbling",

    -- Border Crossing / Mexican Heists (Locke)
    loc_mex_cook_01 = "methlab_gas_to_salt",
    loc_mex_cook_02 = "methlab_caustic_cooler",
    loc_mex_cook_03 = "methlab_bubbling",
    loc_mex_cook_04 = "methlab_gas_to_salt",
    loc_mex_cook_05 = "methlab_caustic_cooler",
    loc_mex_cook_06 = "methlab_bubbling"
}

local function interact_with_chemical(chemical_tweak)
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local current_units = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(current_units) do
        if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
            local tweak = unit:interaction().tweak_data
            if tweak == chemical_tweak or (chemical_tweak == nil and (tweak == "methlab_caustic_cooler" or tweak == "methlab_gas_to_salt" or tweak == "methlab_bubbling")) then
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

                    local chem_name = "Chemical"
                    if tweak == "methlab_caustic_cooler" then chem_name = "Caustic Soda"
                    elseif tweak == "methlab_gas_to_salt" then chem_name = "Muriatic Acid"
                    elseif tweak == "methlab_bubbling" then chem_name = "Hydrogen Chloride" end

                    if managers and managers.hud and managers.hud.show_hint then
                        managers.hud:show_hint({ text = "Sapphire+ Auto-Cooker: Added " .. chem_name .. "!" })
                    end
                    Sapphire:Log("Auto-Cooker added " .. chem_name)
                end)
                return
            end
        end
    end
end

-- Hook DialogManager to intercept cooking lines immediately
if DialogManager then
    local orig_queue_dialog = DialogManager.queue_dialog
    function DialogManager:queue_dialog(id, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.AutoCooker then
            local target_chem = required_chemical_by_dialog[id]
            if target_chem then
                DelayedCalls:Add("Sapphire_AutoCook_" .. tostring(id), 0.2, function()
                    interact_with_chemical(target_chem)
                end)
            end
        end
        return orig_queue_dialog(self, id, ...)
    end
end
