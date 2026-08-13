dofile(ModPath .. "core.lua")

Sapphire:Log("WeaponSway hook loaded.")

-- ============================================================
-- NO WEAPON SWAY & BOBBING (Zero Stance Drift)
-- ============================================================
-- In vanilla PAYDAY 2, player stance breathing shakers cause continuous
-- weapon sway and sight bobbing during aiming (steelsight) and standing.
--
-- This module zeroes breathing amplitude across all stances in
-- tweak_data.player.stances, providing completely stable, laser-steady
-- weapon sights.
--
-- Integrated with the Live-Apply Registry (RegisterLiveApply) so turning the
-- feature off mid-heist cleanly restores true vanilla breathing amplitudes.
-- ============================================================

Sapphire.VanillaSwayAmplitudes = Sapphire.VanillaSwayAmplitudes or nil

local function apply_sway_tweaks()
    if not tweak_data or not tweak_data.player or not tweak_data.player.stances then
        return
    end

    -- 1. Capture vanilla breathing amplitudes once before any mutation
    if Sapphire.VanillaSwayAmplitudes == nil then
        Sapphire.VanillaSwayAmplitudes = {}
        for stance_name, stance_data in pairs(tweak_data.player.stances) do
            if type(stance_data) == "table" then
                Sapphire.VanillaSwayAmplitudes[stance_name] = {}
                for sub_name, sub_data in pairs(stance_data) do
                    if type(sub_data) == "table" and sub_data.shakers and sub_data.shakers.breathing then
                        Sapphire.VanillaSwayAmplitudes[stance_name][sub_name] = sub_data.shakers.breathing.amplitude
                    end
                end
            end
        end
        Sapphire:Log("WeaponSway: Vanilla stance shakers captured.")
    end

    local effective = Sapphire:GetEffectiveSettings()

    -- 2. Apply or restore based on effective setting
    if effective.Enabled and effective.NoWeaponSway then
        for _, stance_data in pairs(tweak_data.player.stances) do
            if type(stance_data) == "table" then
                for _, sub_data in pairs(stance_data) do
                    if type(sub_data) == "table" and sub_data.shakers and sub_data.shakers.breathing then
                        sub_data.shakers.breathing.amplitude = 0
                    end
                end
            end
        end
    elseif Sapphire.VanillaSwayAmplitudes then
        for stance_name, sub_map in pairs(Sapphire.VanillaSwayAmplitudes) do
            local stance_data = tweak_data.player.stances[stance_name]
            if stance_data then
                for sub_name, orig_amp in pairs(sub_map) do
                    if stance_data[sub_name] and stance_data[sub_name].shakers and stance_data[sub_name].shakers.breathing then
                        stance_data[sub_name].shakers.breathing.amplitude = orig_amp
                    end
                end
            end
        end
    end
end

-- Apply tweaks on initial file load
apply_sway_tweaks()

-- Register with live-apply registry for mid-heist setting changes
if Sapphire.RegisterLiveApply then
    Sapphire:RegisterLiveApply(apply_sway_tweaks)
end

-- Hook PlayerTweakData initialization for engine bootstrap safety
if PlayerTweakData and not PlayerTweakData._sapphire_sway_hooked then
    PlayerTweakData._sapphire_sway_hooked = true

    Hooks:PostHook(PlayerTweakData, "init", "Sapphire_WeaponSway_Init", function(self)
        apply_sway_tweaks()
    end)
end
