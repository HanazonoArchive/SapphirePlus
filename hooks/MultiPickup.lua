dofile(ModPath .. "core.lua")

Sapphire:Log("MultiPickup hook loaded.")

-- ============================================================
-- MULTI-PICKUP: Allow stacking consumable special equipment
-- ============================================================
-- Consumable specials: keycards (bank_manager_key, etc.), planks,
-- c4, thermite, etc.
-- Excluded tools: cable_tie (has its own system), crowbar, glass_cutter.
-- ============================================================

local ignored_specials = {
    cable_tie = true,
    crowbar = true,
    glass_cutter = true
}

Sapphire.VanillaSpecialQuantities = nil
Sapphire.VanillaInteractionBlocks = nil

local function is_managed_special(name)
    if not name or ignored_specials[name] then
        return false
    end
    return true
end

local function restore_multi_pickup_tweaks()
    if not tweak_data then return end

    -- Put back the vanilla stacking caps / equipment blocks we overwrote. Without
    -- this, max_quantity = 999 and the stripped special_equipment_block leak into
    -- the vanilla pickup path after the feature is toggled off, so consumables stay
    -- infinitely stackable even with MultiPickup disabled.
    if Sapphire.VanillaSpecialQuantities and tweak_data.equipments and tweak_data.equipments.specials then
        for name, saved in pairs(Sapphire.VanillaSpecialQuantities) do
            local data = tweak_data.equipments.specials[name]
            if data then
                data.max_quantity = saved.max_quantity
                data.quantity = saved.quantity
            end
        end
    end

    if Sapphire.VanillaInteractionBlocks and tweak_data.interaction then
        for int_name, saved_block in pairs(Sapphire.VanillaInteractionBlocks) do
            local int_data = tweak_data.interaction[int_name]
            if int_data then
                int_data.special_equipment_block = saved_block
            end
        end
    end
end

local function apply_multi_pickup_tweaks()
    if not tweak_data then return end

    local effective = Sapphire:GetEffectiveSettings()
    -- When the feature is off (master disabled, per-feature off, or clamped by Safe
    -- Mode) undo our edits instead of leaving the buffed values behind.
    if not effective.Enabled or not effective.MultiPickup then
        restore_multi_pickup_tweaks()
        return
    end

    -- 1. Patch tweak_data.equipments.specials
    if tweak_data.equipments and tweak_data.equipments.specials then
        Sapphire.VanillaSpecialQuantities = Sapphire.VanillaSpecialQuantities or {}

        for name, data in pairs(tweak_data.equipments.specials) do
            if is_managed_special(name) then
                if not Sapphire.VanillaSpecialQuantities[name] then
                    Sapphire.VanillaSpecialQuantities[name] = {
                        max_quantity = data.max_quantity,
                        quantity = data.quantity
                    }
                    Sapphire:Log("MultiPickup: Managed consumable special registered: " .. tostring(name))
                end

                -- Ensure quantity and max_quantity exist for counting & HUD badges.
                -- max_quantity is the real hold-cap lever the engine reads in
                -- _can_pickup_special_equipment; tweak_data.amount is never read by
                -- the engine, so we do not touch it (the live per-player amount is
                -- tracked on self._equipment.specials[name].amount instead).
                data.quantity = data.quantity or 1
                data.max_quantity = 999
            end
        end
    end

    -- 2. Patch tweak_data.interaction to remove special_equipment_block
    if tweak_data.interaction then
        Sapphire.VanillaInteractionBlocks = Sapphire.VanillaInteractionBlocks or {}

        for int_name, int_data in pairs(tweak_data.interaction) do
            if int_data.special_equipment_block then
                local block = int_data.special_equipment_block
                local should_unblock = false

                if type(block) == "string" then
                    if is_managed_special(block) then
                        should_unblock = true
                    end
                elseif type(block) == "table" then
                    for _, b_name in pairs(block) do
                        if is_managed_special(b_name) then
                            should_unblock = true
                            break
                        end
                    end
                end

                if should_unblock then
                    if not Sapphire.VanillaInteractionBlocks[int_name] then
                        Sapphire.VanillaInteractionBlocks[int_name] = int_data.special_equipment_block
                        Sapphire:Log("MultiPickup: Removed special_equipment_block from interaction: " .. tostring(int_name))
                    end
                    int_data.special_equipment_block = nil
                end
            end
        end
    end
end

-- Apply tweaks on load and when PlayerManager initializes
apply_multi_pickup_tweaks()

-- Re-sync on any live settings change (menu toggle) so switching MultiPickup off
-- mid-heist restores the vanilla caps instead of leaving them buffed.
if Sapphire.RegisterLiveApply then
    Sapphire:RegisterLiveApply(apply_multi_pickup_tweaks)
end

Hooks:PostHook(PlayerManager, "_setup", "Sapphire_MultiPickup_PlayerManagerSetup", function(self)
    apply_multi_pickup_tweaks()
end)

-- ============================================================
-- OVERRIDE: can_pickup_equipment & _can_pickup_special_equipment
-- ============================================================

local orig_can_pickup_equipment = PlayerManager.can_pickup_equipment
function PlayerManager:can_pickup_equipment(name)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.MultiPickup and is_managed_special(name) then
        apply_multi_pickup_tweaks()
        local special = self._equipment.specials[name]
        if not special then
            return true
        end
        if special.amount then
            local current = Application:digest_value(special.amount, false)
            return current < 999
        end
        return true
    end
    return orig_can_pickup_equipment(self, name)
end

local orig_can_pickup_special = PlayerManager._can_pickup_special_equipment
if orig_can_pickup_special then
    function PlayerManager:_can_pickup_special_equipment(special_equipment, name)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.MultiPickup and is_managed_special(name) then
            if special_equipment.amount then
                local current = Application:digest_value(special_equipment.amount, false)
                return current < 999, true
            end
            return true, true
        end
        return orig_can_pickup_special(self, special_equipment, name)
    end
end

-- ============================================================
-- PRE-HOOK: add_special to guarantee amount initialization
-- ============================================================

Hooks:PreHook(PlayerManager, "add_special", "Sapphire_MultiPickup_AddSpecialPre", function(self, params)
    local effective = Sapphire:GetEffectiveSettings()
    if not effective.Enabled or not effective.MultiPickup then return end

    local name = params and (params.equipment or params.name)
    if not name or not is_managed_special(name) then return end

    apply_multi_pickup_tweaks()

    -- Ensure tweak_data has quantity and max_quantity
    if tweak_data and tweak_data.equipments and tweak_data.equipments.specials and tweak_data.equipments.specials[name] then
        local eq = tweak_data.equipments.specials[name]
        eq.quantity = eq.quantity or 1
        eq.max_quantity = 999
    end

    -- If the player already holds this item but amount was nil (uncounted), initialize it to 1
    local special = self._equipment and self._equipment.specials and self._equipment.specials[name]
    if special and special.amount == nil then
        special.amount = Application:digest_value(1, true)
    end
end)
