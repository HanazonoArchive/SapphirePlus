if not rawget(_G, "Sapphire") then
    dofile(ModPath .. "core.lua")
end

-- Comprehensive, verified dialogue table matching TheCooker standard
local dialog_to_chemical = {
    -- Cook Off, Rats, Border Crystals (Bain)
    pln_rt1_20 = "methlab_bubbling",        -- Muriatic Acid
    pln_rt1_21 = "methlab_bubbling",        -- Muriatic Acid (Correction)
    pln_rt1_22 = "methlab_caustic_cooler",  -- Caustic Soda
    pln_rt1_23 = "methlab_caustic_cooler",  -- Caustic Soda (Correction)
    pln_rt1_24 = "methlab_gas_to_salt",     -- Hydrogen Chloride
    pln_rt1_25 = "methlab_gas_to_salt",     -- Hydrogen Chloride (Correction)

    -- Lab Rats (Bain)
    pln_rat_stage1_20 = "methlab_bubbling",        -- Muriatic Acid
    pln_rat_stage1_21 = "methlab_bubbling",        -- Muriatic Acid (Correction)
    pln_rat_stage1_22 = "methlab_caustic_cooler",  -- Caustic Soda
    pln_rat_stage1_23 = "methlab_caustic_cooler",  -- Caustic Soda (Correction)
    pln_rat_stage1_24 = "methlab_gas_to_salt",     -- Hydrogen Chloride
    pln_rat_stage1_25 = "methlab_gas_to_salt",     -- Hydrogen Chloride (Correction)

    -- Border Crossing, San Martin, Breakfast in Tijuana (Locke)
    Play_loc_mex_cook_03 = "methlab_bubbling",        -- Muriatic Acid
    Play_loc_mex_cook_04 = "methlab_caustic_cooler",  -- Caustic Soda
    Play_loc_mex_cook_05 = "methlab_gas_to_salt",     -- Hydrogen Chloride
    loc_mex_cook_01 = "methlab_bubbling",
    loc_mex_cook_02 = "methlab_caustic_cooler",
    loc_mex_cook_03 = "methlab_bubbling",
    loc_mex_cook_04 = "methlab_caustic_cooler",
    loc_mex_cook_05 = "methlab_gas_to_salt",
    loc_mex_cook_06 = "methlab_gas_to_salt"
}

local function interact_with_chemical(chemical_tweak)
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local function try_interact(unit)
        if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
            local tweak = unit:interaction().tweak_data
            if tweak == chemical_tweak then
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

                    local chem_name = "Chemical"
                    if tweak == "methlab_caustic_cooler" then chem_name = "Caustic Soda (Cs)"
                    elseif tweak == "methlab_bubbling" then chem_name = "Muriatic Acid (Mu)"
                    elseif tweak == "methlab_gas_to_salt" then chem_name = "Hydrogen Chloride (HCl)" end

                    if managers and managers.hud and managers.hud.show_hint then
                        managers.hud:show_hint({ text = "Sapphire+ Auto-Cooker: Injected " .. chem_name .. "!" })
                    end
                    Sapphire:Log("Auto-Cooker injected " .. chem_name)
                end)
                return true
            end
        end
        return false
    end

    -- 1. Check interactive units table
    local current_units = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(current_units) do
        if try_interact(unit) then return end
    end

    -- 2. Sweep world units
    local world_units = World:find_units_quick("all", 1)
    for _, unit in pairs(world_units) do
        if try_interact(unit) then return end
    end
end

-- Hook DialogManager to intercept cooking cues instantly
if DialogManager then
    local orig_queue_dialog = DialogManager.queue_dialog
    function DialogManager:queue_dialog(id, ...)
        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.AutoCooker then
            local target_chem = dialog_to_chemical[id]
            if target_chem then
                DelayedCalls:Add("Sapphire_AutoCook_" .. tostring(id), 0.3, function()
                    interact_with_chemical(target_chem)
                end)
            end
        end
        return orig_queue_dialog(self, id, ...)
    end
end
