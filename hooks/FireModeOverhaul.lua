dofile(ModPath .. "core.lua")

Sapphire:Log("FireModeOverhaul hook loaded.")

-- ============================================================
-- ALL WEAPONS FULL AUTO OVERHAUL
-- ============================================================
-- Unlocks the ability to toggle full-automatic fire mode on semi-automatic
-- pistols, DMRs, and shotguns across all weapons in tweak_data.weapon.
--
-- Integrated with the Live-Apply Registry (RegisterLiveApply) so turning the
-- feature off mid-heist cleanly restores true vanilla fire mode toggles.
-- ============================================================

Sapphire.VanillaFiremodeToggles = Sapphire.VanillaFiremodeToggles or nil

local function apply_firemode_tweaks()
    if not tweak_data or not tweak_data.weapon then
        return
    end

    -- 1. Capture vanilla firemode permissions once
    if Sapphire.VanillaFiremodeToggles == nil then
        Sapphire.VanillaFiremodeToggles = {}
        for id, wep in pairs(tweak_data.weapon) do
            if type(wep) == "table" then
                Sapphire.VanillaFiremodeToggles[id] = wep.CAN_TOGGLE_FIREMODE
            end
        end
        Sapphire:Log("FireModeOverhaul: Vanilla firemode permissions captured.")
    end

    local effective = Sapphire:GetEffectiveSettings()

    -- 2. Apply or restore based on effective setting
    if effective.Enabled and effective.AllWeaponsFullAuto then
        for id, wep in pairs(tweak_data.weapon) do
            if type(wep) == "table" and id ~= "saw" and id ~= "saw_secondary" and
               not (wep.categories and (table.contains(wep.categories, "bow") or table.contains(wep.categories, "crossbow"))) then
                wep.CAN_TOGGLE_FIREMODE = true
            end
        end
    elseif Sapphire.VanillaFiremodeToggles then
        for id, orig_val in pairs(Sapphire.VanillaFiremodeToggles) do
            local wep = tweak_data.weapon[id]
            if wep then
                wep.CAN_TOGGLE_FIREMODE = orig_val
            end
        end
    end
end

-- Apply tweaks on initial file load
apply_firemode_tweaks()

-- Register with live-apply registry for mid-heist setting changes
if Sapphire.RegisterLiveApply then
    Sapphire:RegisterLiveApply(apply_firemode_tweaks)
end

-- Hook WeaponTweakData initialization for engine bootstrap safety
if WeaponTweakData and not WeaponTweakData._sapphire_firemode_hooked then
    WeaponTweakData._sapphire_firemode_hooked = true

    Hooks:PostHook(WeaponTweakData, "init", "Sapphire_FireModeOverhaul_Init", function(self)
        apply_firemode_tweaks()
    end)
end
