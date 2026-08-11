if not rawget(_G, "Sapphire") then
    dofile(ModPath .. "core.lua")
end

-- Reset AutoCooker toggle to OFF every new heist/level load
if Sapphire and Sapphire.Settings then
    Sapphire.Settings.AutoCooker = false
end

if MissionManager then
    Hooks:PostHook(MissionManager, "init", "Sapphire_AutoCooker_MissionReset", function()
        if Sapphire and Sapphire.Settings then
            Sapphire.Settings.AutoCooker = false
        end
    end)
end

-- Comprehensive dialogue mapping covering both primary and confirmation cues
local dialog_to_chemical = {
    -- Cook Off, Rats, Border Crystals (Bain)
    pln_rt1_20 = "methlab_bubbling",        -- Muriatic Acid (Mu - Primary)
    pln_rt1_21 = "methlab_bubbling",        -- Muriatic Acid (Mu - Confirmation)
    pln_rt1_22 = "methlab_caustic_cooler",  -- Caustic Soda (Cs - Primary)
    pln_rt1_23 = "methlab_caustic_cooler",  -- Caustic Soda (Cs - Confirmation)
    pln_rt1_24 = "methlab_gas_to_salt",     -- Hydrogen Chloride (HCl - Primary)
    pln_rt1_25 = "methlab_gas_to_salt",     -- Hydrogen Chloride (HCl - Confirmation)

    -- Lab Rats (Bain)
    pln_rat_stage1_20 = "methlab_bubbling",        -- Muriatic Acid (Mu - Primary)
    pln_rat_stage1_21 = "methlab_bubbling",        -- Muriatic Acid (Mu - Confirmation)
    pln_rat_stage1_22 = "methlab_caustic_cooler",  -- Caustic Soda (Cs - Primary)
    pln_rat_stage1_23 = "methlab_caustic_cooler",  -- Caustic Soda (Cs - Confirmation)
    pln_rat_stage1_24 = "methlab_gas_to_salt",     -- Hydrogen Chloride (HCl - Primary)
    pln_rat_stage1_25 = "methlab_gas_to_salt",     -- Hydrogen Chloride (HCl - Confirmation)

    -- Border Crossing, San Martin, Breakfast in Tijuana (Locke)
    Play_loc_mex_cook_03 = "methlab_bubbling",        -- Muriatic Acid (Mu)
    Play_loc_mex_cook_04 = "methlab_caustic_cooler",  -- Caustic Soda (Cs)
    Play_loc_mex_cook_05 = "methlab_gas_to_salt",     -- Hydrogen Chloride (HCl)
    loc_mex_cook_01 = "methlab_bubbling",
    loc_mex_cook_02 = "methlab_caustic_cooler",
    loc_mex_cook_03 = "methlab_bubbling",
    loc_mex_cook_04 = "methlab_caustic_cooler",
    loc_mex_cook_05 = "methlab_gas_to_salt",
    loc_mex_cook_06 = "methlab_gas_to_salt"
}

local last_chemical_injected_t = 0
local last_power_flip_t = 0

-- 1. AUTO-INJECT INGREDIENTS
local function interact_with_chemical(chemical_tweak)
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local current_t = TimerManager and TimerManager:game() and TimerManager:game():time() or 0
    if (current_t - last_chemical_injected_t) < 3.0 then
        return
    end

    local function try_interact(unit)
        if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
            local tweak = unit:interaction().tweak_data
            if tweak == chemical_tweak then
                pcall(function()
                    local interaction = unit:interaction()
                    local orig_can_interact = interaction.can_interact
                    interaction.can_interact = function() return true end

                    interaction:interact(player)

                    interaction.can_interact = orig_can_interact
                    last_chemical_injected_t = current_t

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

    -- Check interactive units table
    local current_units = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(current_units) do
        if try_interact(unit) then return end
    end

    -- Sweep world units
    local world_units = World:find_units_quick("all", 1)
    for _, unit in pairs(world_units) do
        if try_interact(unit) then return end
    end
end

-- 2. POWER PROTECTION (Enemies Can't Cut Power)
local function restore_power(unit)
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local current_t = TimerManager and TimerManager:game() and TimerManager:game():time() or 0
    if (current_t - last_power_flip_t) < 1.0 then return end

    pcall(function()
        local interaction = unit:interaction()
        if interaction and interaction:active() then
            local orig_can_interact = interaction.can_interact
            interaction.can_interact = function() return true end

            interaction:interact(player)

            interaction.can_interact = orig_can_interact
            last_power_flip_t = current_t

            if managers and managers.hud and managers.hud.show_hint then
                managers.hud:show_hint({ text = "Sapphire+: Power Cut Blocked! Circuit breaker restored." })
            end
            Sapphire:Log("Auto-Cooker Power Protection: Restored circuit breaker.")
        end
    end)
end

-- Hook ObjectInteractionManager to protect circuit breaker / fuse box power
if ObjectInteractionManager then
    local orig_add_unit = ObjectInteractionManager.add_unit
    function ObjectInteractionManager:add_unit(unit, ...)
        orig_add_unit(self, unit, ...)

        local current_effective = Sapphire:GetEffectiveSettings()
        if current_effective.Enabled and current_effective.AutoCooker then
            if alive(unit) and unit.interaction and unit:interaction() then
                local tweak = tostring(unit:interaction().tweak_data):lower()
                if tweak == "circuit_breaker" or tweak == "transformer_box" or tweak:find("fuse_box") or tweak:find("power") then
                    DelayedCalls:Add("Sapphire_RestorePower_" .. tostring(unit:key()), 0.1, function()
                        if alive(unit) and unit:interaction() and unit:interaction():active() then
                            restore_power(unit)
                        end
                    end)
                end
            end
        end
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
                DelayedCalls:Add("Sapphire_AutoCook_" .. tostring(id), 0.2, function()
                    interact_with_chemical(target_chem)
                end)
            end
        end
        return orig_queue_dialog(self, id, ...)
    end
end
