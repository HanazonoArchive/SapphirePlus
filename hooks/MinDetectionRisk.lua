dofile(ModPath .. "core.lua")

Sapphire:Log("MinDetectionRisk hook loaded.")

-- ============================================================
-- MINIMUM DETECTION RISK (Always Detection Risk 3 / 0 offset)
-- ============================================================
-- Forces the player's suspicion offset to the engine minimum
-- (0.0 = Detection Risk 3).
--
-- Signatures verified against decompiled source
-- (lib/managers/blackmarketmanager.lua):
--   get_suspicion_offset_of_local(lerp, ignore_armor_kit)
--       -> returns (val:number, max_reached:bool, min_reached:bool)
--       where max_reached = (index == 1)                       [lowest concealment / MAX suspicion]
--       and   min_reached = (index == #concealment - 1)        [near-highest concealment / MIN suspicion]
--   get_suspicion_offset_from_custom_data(data, lerp)
--       -> returns the same (val, max_reached, min_reached) tuple
--   _calculate_suspicion_offset(index, lerp) -> returns (val:number)
--
-- The two public getters MUST return the full 3-tuple; the concealment
-- UI reads the 2nd/3rd values to color/flag the readout. At full
-- concealment (0 suspicion) the correct flags are max_reached=false,
-- min_reached=true -- returning them inverted paints the "0" readout in
-- the max-detection warning color.
--
-- NOTE: get_real_armor_concealment / get_armor_concealment do NOT
-- exist in the engine (verified: zero hits tree-wide) and are not
-- needed -- concealment feeds suspicion through the index math
-- above, which we already zero out.
-- ============================================================

if BlackMarketManager and not BlackMarketManager._sapphire_mindetect_hooked then
    BlackMarketManager._sapphire_mindetect_hooked = true

    local orig_get_suspicion_offset_of_local = BlackMarketManager.get_suspicion_offset_of_local
    if orig_get_suspicion_offset_of_local then
        function BlackMarketManager:get_suspicion_offset_of_local(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                -- 0 suspicion; max_reached=false, min_reached=true (fully concealed)
                return 0, false, true
            end
            return orig_get_suspicion_offset_of_local(self, ...)
        end
    end

    local orig_get_suspicion_offset_from_custom_data = BlackMarketManager.get_suspicion_offset_from_custom_data
    if orig_get_suspicion_offset_from_custom_data then
        function BlackMarketManager:get_suspicion_offset_from_custom_data(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MinDetectionRisk then
                return 0, false, true
            end
            return orig_get_suspicion_offset_from_custom_data(self, ...)
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

    Sapphire:Log("MinDetectionRisk: BlackMarketManager overrides applied.")
end
