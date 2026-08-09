dofile(ModPath .. "core.lua")

Sapphire:Log("MinDetectionRisk hook loaded.")

-- ============================================================
-- MINIMUM DETECTION RISK (Always 3 Detection)
-- ============================================================
-- Forces the player's detection risk and suspicion offset to
-- the absolute engine minimum (0.0 offset = Detection Risk 3).
--
-- Overrides:
--   1. BlackMarketManager:get_suspicion_offset_of_local -> returns 0
--   2. BlackMarketManager:get_suspicion_offset_from_custom_data -> returns 0
--   3. BlackMarketManager:_calculate_suspicion_offset -> returns 0
--   4. BlackMarketManager:get_real_armor_concealment -> returns 30 (suit)
--   5. BlackMarketManager:get_armor_concealment -> returns 30 (suit)
-- ============================================================

if BlackMarketManager then
    local orig_get_suspicion_offset_of_local = BlackMarketManager.get_suspicion_offset_of_local
    if orig_get_suspicion_offset_of_local then
        function BlackMarketManager:get_suspicion_offset_of_local(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                return 0
            end
            return orig_get_suspicion_offset_of_local(self, ...)
        end
    end

    local orig_get_suspicion_offset_from_custom_data = BlackMarketManager.get_suspicion_offset_from_custom_data
    if orig_get_suspicion_offset_from_custom_data then
        function BlackMarketManager:get_suspicion_offset_from_custom_data(custom_data, ...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                return 0
            end
            return orig_get_suspicion_offset_from_custom_data(self, custom_data, ...)
        end
    end

    local orig_calculate_suspicion_offset = BlackMarketManager._calculate_suspicion_offset
    if orig_calculate_suspicion_offset then
        function BlackMarketManager:_calculate_suspicion_offset(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                return 0
            end
            return orig_calculate_suspicion_offset(self, ...)
        end
    end

    local orig_get_real_armor_concealment = BlackMarketManager.get_real_armor_concealment
    if orig_get_real_armor_concealment then
        function BlackMarketManager:get_real_armor_concealment(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                return 30
            end
            return orig_get_real_armor_concealment(self, ...)
        end
    end

    local orig_get_armor_concealment = BlackMarketManager.get_armor_concealment
    if orig_get_armor_concealment then
        function BlackMarketManager:get_armor_concealment(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                return 30
            end
            return orig_get_armor_concealment(self, ...)
        end
    end

    Sapphire:Log("MinDetectionRisk: BlackMarketManager overrides applied.")
end
