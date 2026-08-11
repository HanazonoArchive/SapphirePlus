Sapphire.Loot = Sapphire.Loot or {}

local is_processing_queue = false

local function is_loot_container(tweak)
    if not tweak then return false end
    local t = tostring(tweak):lower()
    return t == "crate_loot" or t == "crate_loot_crowbar" or t == "open_loot_crate" or
           t == "deposit_box" or t == "deposit_box_close" or t == "lockpick_locker" or
           t:find("^cut_glass") or t:find("^open_safe") or t:find("^pick_lock")
end

local function is_carry_bag(unit)
    if not (alive(unit) and unit:slot() ~= 0 and unit.carry_data and unit:carry_data()) then
        return false
    end
    if unit.interaction and unit:interaction() then
        local t = tostring(unit:interaction().tweak_data):lower()
        return t == "carry_drop" or t == "painting_carry_drop" or t == "corpse_dispose" or t == "safe_carry_drop"
    end
    return false
end

local function is_loose_loot(tweak)
    if not tweak then return false end
    local t = tostring(tweak):lower()
    return t:find("^hold_take_") or t:find("^gen_pku_") or
           t == "money_wrap" or t == "money_wrap_single_bundle" or t == "money_small" or
           t == "small_loot" or t == "diamond_pickup" or t == "safe_loot_pickup" or
           t == "coke_pure" or t == "pickup_armor" or t == "mus_artifact" or
           t == "samurai_armor" or t == "diamonds_dah" or t == "red_diamond" or
           t == "warhead" or t == "fusion_engine" or t == "toothbrush" or t == "sandwich"
end

function Sapphire.Loot:Notify(text)
    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = text })
    end
    if managers and managers.chat and managers.chat.feed_system_message and ChatManager then
        pcall(function()
            managers.chat:feed_system_message(ChatManager.GAME, text)
        end)
    end
    Sapphire:Log(text)
end

-- ============================================================
-- TELEPORT LOOT (Single-Pass Loose Loot Bagger & Opener)
-- ============================================================
function Sapphire.Loot:TeleportLoot()
    if is_processing_queue then
        self:Notify("Sapphire+: Loot gathering already in progress...")
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then
        self:Notify("Sapphire+: Player unit not available.")
        return
    end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        self:Notify("Sapphire+: Teleport Loot is disabled in Safe Mode.")
        return
    end

    is_processing_queue = true

    -- PHASE 1: Open all closed shipping crates, lockers & containers across map (No crowbar required)
    local opened_containers = 0
    local all_interactables = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(all_interactables) do
        if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
            local tweak = unit:interaction().tweak_data
            if is_loot_container(tweak) then
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
                    opened_containers = opened_containers + 1
                end)
            end
        end
    end

    -- PHASE 2: Wait 0.08s for crates to reveal their items, then scan for loose/unbagged loot
    DelayedCalls:Add("Sapphire_StartLootQueue", 0.08, function()
        if not alive(player) then
            is_processing_queue = false
            return
        end

        local loose_queue = {}
        local current_units = managers.interaction and managers.interaction._interactive_units or {}
        for _, unit in pairs(current_units) do
            if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
                -- Ignore all existing physical carry bags on the floor
                if not is_carry_bag(unit) then
                    local tweak = unit:interaction().tweak_data
                    if is_loose_loot(tweak) then
                        table.insert(loose_queue, unit)
                    end
                end
            end
        end

        -- If no loose loot remains on the map, exit cleanly
        if #loose_queue == 0 then
            is_processing_queue = false
            Sapphire.Loot:Notify("Sapphire+: No unbagged loot available.")
            return
        end

        Sapphire.Loot:Notify("Sapphire+: Bagging & gathering " .. tostring(#loose_queue) .. " loose loot items...")

        local loose_idx = 1
        local total_bagged = 0

        local function process_loose_item()
            if not alive(player) then
                is_processing_queue = false
                return
            end

            if loose_idx > #loose_queue then
                -- Finished bagging all loose items!
                if managers.player and managers.player.is_carrying and managers.player:is_carrying() then
                    pcall(function()
                        managers.player:drop_carry()
                    end)
                end

                is_processing_queue = false
                Sapphire.Loot:Notify("Sapphire+: Successfully gathered " .. tostring(total_bagged) .. " loot items!")
                return
            end

            local unit = loose_queue[loose_idx]
            loose_idx = loose_idx + 1

            -- Drop previous bag if still held
            if managers.player and managers.player.is_carrying and managers.player:is_carrying() then
                pcall(function()
                    managers.player:drop_carry()
                end)
            end

            -- Interact and bag current item
            if alive(unit) and unit.interaction and unit:interaction() and unit:interaction():active() then
                pcall(function()
                    local interaction = unit:interaction()
                    local orig_can_interact = interaction.can_interact
                    interaction.can_interact = function() return true end

                    interaction:interact(player)

                    interaction.can_interact = orig_can_interact
                end)
                total_bagged = total_bagged + 1

                -- Eject newly created bag forward in aim direction
                if managers.player and managers.player.is_carrying and managers.player:is_carrying() then
                    pcall(function()
                        managers.player:drop_carry()
                    end)
                end
            end

            DelayedCalls:Add("Sapphire_ProcessLoose_" .. tostring(loose_idx), 0.05, process_loose_item)
        end

        process_loose_item()
    end)
end
