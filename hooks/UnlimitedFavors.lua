dofile(ModPath .. "core.lua")

Sapphire:Log("UnlimitedFavors hook loaded.")

-- ============================================================
-- UNLIMITED FAVORS: Remove pre-planning budget restrictions
-- ============================================================
-- The pre-planning system uses favor points to limit how many
-- assets you can bring into a heist. This hook makes all
-- pre-planning assets cost 0 favors, allowing you to select
-- as many as you want.
--
-- Three functions are overridden:
--   1. get_type_budget_cost → return 0 (all assets are free)
--   2. can_reserve_mission_element → return true (bypass limits)
--   3. MoneyManager:get_preplanning_type_cost → return 0 (free $)
-- ============================================================

-- This file is registered on both the preplanningmanager and moneymanager
-- hook_ids, so it runs twice. Each class block is guarded for idempotency to
-- avoid double-wrapping the raw detours.
if PrePlanningManager and not PrePlanningManager._sapphire_favors_hooked then
    PrePlanningManager._sapphire_favors_hooked = true

    local orig_get_type_budget_cost = PrePlanningManager.get_type_budget_cost
    function PrePlanningManager:get_type_budget_cost(type, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.UnlimitedFavors then
            return 0
        end
        if orig_get_type_budget_cost then
            return orig_get_type_budget_cost(self, type, ...)
        end
        return 0
    end

    local orig_can_reserve = PrePlanningManager.can_reserve_mission_element
    function PrePlanningManager:can_reserve_mission_element(type, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.UnlimitedFavors then
            return true
        end
        if orig_can_reserve then
            return orig_can_reserve(self, type, ...)
        end
        return false
    end

    Sapphire:Log("UnlimitedFavors: PrePlanningManager overrides applied.")
end

if MoneyManager and not MoneyManager._sapphire_favors_hooked then
    MoneyManager._sapphire_favors_hooked = true

    local orig_preplanning_cost = MoneyManager.get_preplanning_type_cost
    function MoneyManager:get_preplanning_type_cost(type, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.UnlimitedFavors then
            return 0
        end
        if orig_preplanning_cost then
            return orig_preplanning_cost(self, type, ...)
        end
        return 0
    end

    local orig_can_afford = MoneyManager.can_afford_preplanning_type
    if orig_can_afford then
        function MoneyManager:can_afford_preplanning_type(type, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.UnlimitedFavors then
                return true
            end
            return orig_can_afford(self, type, ...)
        end
    end

    Sapphire:Log("UnlimitedFavors: MoneyManager overrides applied.")
end
