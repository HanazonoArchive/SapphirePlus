dofile(ModPath .. "core.lua")

Sapphire:Log("MeleeOverhaul hook loaded.")

-- ============================================================
-- HARDENED INSTANT FULL-CHARGE MELEE (100% Max Damage on Instant Tap)
-- ============================================================
-- In vanilla PAYDAY 2, melee attacks require holding the melee key to charge
-- from min_damage to max_damage over charge_time (typically 1.0s to 4.0s).
--
-- This module applies dual-layer hardening:
-- 1. TweakData: sets charge_time to 0.05s (safe non-zero) and min_damage = max_damage.
-- 2. PlayerStandard: hooks _get_melee_charge_lerp_value to return 1.0 instantly.
--
-- Integrated with the Live-Apply Registry (RegisterLiveApply) so turning the
-- feature off mid-heist cleanly restores true vanilla charge and damage values.
-- ============================================================

Sapphire.VanillaMeleeStats = Sapphire.VanillaMeleeStats or nil

local function apply_melee_tweaks()
    if not tweak_data or not tweak_data.blackmarket or not tweak_data.blackmarket.melee_weapons then
        return
    end

    -- 1. Capture vanilla stats once before any mutation
    if Sapphire.VanillaMeleeStats == nil then
        Sapphire.VanillaMeleeStats = {}
        for id, wep in pairs(tweak_data.blackmarket.melee_weapons) do
            if type(wep) == "table" and type(wep.stats) == "table" then
                Sapphire.VanillaMeleeStats[id] = {
                    charge_time = wep.stats.charge_time,
                    min_damage = wep.stats.min_damage
                }
            end
        end
        Sapphire:Log("MeleeOverhaul: Vanilla melee stats captured (" .. tostring(table.size and table.size(Sapphire.VanillaMeleeStats) or "all") .. " weapons).")
    end

    local effective = Sapphire:GetEffectiveSettings()

    -- 2. Apply or restore based on effective setting
    if effective.Enabled and effective.InstantMeleeCharge then
        for id, wep in pairs(tweak_data.blackmarket.melee_weapons) do
            if type(wep) == "table" and type(wep.stats) == "table" then
                wep.stats.charge_time = 0.05
                if wep.stats.max_damage then
                    wep.stats.min_damage = wep.stats.max_damage
                end
            end
        end
    elseif Sapphire.VanillaMeleeStats then
        for id, saved in pairs(Sapphire.VanillaMeleeStats) do
            local wep = tweak_data.blackmarket.melee_weapons[id]
            if wep and wep.stats then
                wep.stats.charge_time = saved.charge_time
                wep.stats.min_damage = saved.min_damage
            end
        end
    end
end

-- Apply tweaks on initial file load
apply_melee_tweaks()

-- Register with live-apply registry for mid-heist setting changes
if Sapphire.RegisterLiveApply then
    Sapphire:RegisterLiveApply(apply_melee_tweaks)
end

-- Hook BlackMarketTweakData initialization for engine bootstrap safety
if BlackMarketTweakData and not BlackMarketTweakData._sapphire_melee_hooked then
    BlackMarketTweakData._sapphire_melee_hooked = true

    Hooks:PostHook(BlackMarketTweakData, "init", "Sapphire_MeleeOverhaul_Init", function(self)
        apply_melee_tweaks()
    end)
end

-- Hook PlayerStandard melee charge lerp function for guaranteed 100% full charge value
if PlayerStandard and not PlayerStandard._sapphire_melee_charge_hooked then
    PlayerStandard._sapphire_melee_charge_hooked = true

    local orig_get_melee_lerp = PlayerStandard._get_melee_charge_lerp_value
    function PlayerStandard:_get_melee_charge_lerp_value(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InstantMeleeCharge then
            return 1
        end
        if orig_get_melee_lerp then
            return orig_get_melee_lerp(self, ...)
        end
        return 1
    end
end
