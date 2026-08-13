dofile(ModPath .. "core.lua")

Sapphire:Log("PlayerInventoryHooks hook loaded.")

-- ============================================================
-- HARDENED PLAYER INVENTORY & CONSUMABLES OVERHAUL
-- ============================================================
-- Provides granular infinite supply controls for tactical stealth & combat:
-- 1. Infinite Cable Ties: Prevents tie depletion in special equipment and player manager.
-- 2. Infinite Body Bags: Prevents bag depletion and reports non-depleted status.
-- 3. Infinite Throwables: Prevents grenade/throwable reduction and guarantees throw permissions.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================

if PlayerManager and not PlayerManager._sapphire_inventory_hooks_done then
    PlayerManager._sapphire_inventory_hooks_done = true

    -- 1. INFINITE CABLE TIES
    local orig_has_cable_ties = PlayerManager.has_cable_ties
    function PlayerManager:has_cable_ties(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteCableTies then
            return true
        end
        if orig_has_cable_ties then
            return orig_has_cable_ties(self, ...)
        end
        return true
    end

    local orig_remove_cable_ties = PlayerManager.remove_cable_ties
    function PlayerManager:remove_cable_ties(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteCableTies then
            return
        end
        if orig_remove_cable_ties then
            return orig_remove_cable_ties(self, ...)
        end
    end

    local orig_remove_special = PlayerManager.remove_special
    function PlayerManager:remove_special(name, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteCableTies and name == "cable_tie" then
            return
        end
        if orig_remove_special then
            return orig_remove_special(self, name, ...)
        end
    end

    local orig_has_special = PlayerManager.has_special_equipment
    function PlayerManager:has_special_equipment(name, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteCableTies and name == "cable_tie" then
            return true
        end
        if orig_has_special then
            return orig_has_special(self, name, ...)
        end
        return false
    end

    -- 2. INFINITE BODY BAGS
    local orig_has_total_body_bags = PlayerManager.has_total_body_bags
    function PlayerManager:has_total_body_bags(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteBodyBags then
            return true
        end
        if orig_has_total_body_bags then
            return orig_has_total_body_bags(self, ...)
        end
        return true
    end

    local orig_remove_body_bags = PlayerManager.remove_body_bags_amount
    function PlayerManager:remove_body_bags_amount(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteBodyBags then
            return
        end
        if orig_remove_body_bags then
            return orig_remove_body_bags(self, ...)
        end
    end

    local orig_chk_body_bags_depleted = PlayerManager.chk_body_bags_depleted
    function PlayerManager:chk_body_bags_depleted(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteBodyBags then
            return false
        end
        if orig_chk_body_bags_depleted then
            return orig_chk_body_bags_depleted(self, ...)
        end
        return false
    end

    local orig_get_body_bags = PlayerManager.get_body_bags_amount
    function PlayerManager:get_body_bags_amount(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteBodyBags then
            local count = orig_get_body_bags and orig_get_body_bags(self, ...) or (self._local_player_body_bags or 0)
            return math.max(count, 1)
        end
        if orig_get_body_bags then
            return orig_get_body_bags(self, ...)
        end
        return self._local_player_body_bags or 0
    end

    -- 3. INFINITE THROWABLES / GRENADES
    local orig_has_grenades = PlayerManager.has_grenades
    function PlayerManager:has_grenades(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteThrowables then
            return true
        end
        if orig_has_grenades then
            return orig_has_grenades(self, ...)
        end
        return true
    end

    local orig_can_throw_grenade = PlayerManager.can_throw_grenade
    function PlayerManager:can_throw_grenade(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteThrowables then
            return true
        end
        if orig_can_throw_grenade then
            return orig_can_throw_grenade(self, ...)
        end
        return true
    end

    local orig_on_throw_grenade = PlayerManager.on_throw_grenade
    function PlayerManager:on_throw_grenade(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteThrowables then
            return
        end
        if orig_on_throw_grenade then
            return orig_on_throw_grenade(self, ...)
        end
    end
end
