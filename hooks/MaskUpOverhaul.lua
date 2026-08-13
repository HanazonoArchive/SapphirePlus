dofile(ModPath .. "core.lua")

Sapphire:Log("MaskUpOverhaul hook loaded.")

-- ============================================================
-- INSTANT MASK ON (Zero Mask-Up Delay in Casing Mode)
-- ============================================================
-- In vanilla PAYDAY 2, equipping your mask during casing mode requires
-- holding the interact key for 2.0 seconds.
--
-- This module reduces put_on_mask_time to 0.05s, allowing instant mask-on
-- execution for stealth and speedrun efficiency.
--
-- Integrated with the Live-Apply Registry (RegisterLiveApply) so turning the
-- feature off mid-heist cleanly restores true vanilla delay (2.0s).
-- ============================================================

Sapphire.VanillaPutOnMaskTime = Sapphire.VanillaPutOnMaskTime or nil

local function apply_mask_tweaks()
    if not tweak_data or not tweak_data.player then
        return
    end

    -- 1. Capture vanilla mask time once
    if Sapphire.VanillaPutOnMaskTime == nil then
        Sapphire.VanillaPutOnMaskTime = tweak_data.player.put_on_mask_time or 2.0
        Sapphire:Log("MaskUpOverhaul: Vanilla put_on_mask_time captured (" .. tostring(Sapphire.VanillaPutOnMaskTime) .. "s).")
    end

    local effective = Sapphire:GetEffectiveSettings()

    -- 2. Apply or restore based on effective setting
    if effective.Enabled and effective.InstantMaskUp then
        tweak_data.player.put_on_mask_time = 0.05
    elseif Sapphire.VanillaPutOnMaskTime ~= nil then
        tweak_data.player.put_on_mask_time = Sapphire.VanillaPutOnMaskTime
    end
end

-- Apply tweaks on initial file load
apply_mask_tweaks()

-- Register with live-apply registry for mid-heist setting changes
if Sapphire.RegisterLiveApply then
    Sapphire:RegisterLiveApply(apply_mask_tweaks)
end

-- Hook PlayerTweakData initialization for engine bootstrap safety
if PlayerTweakData and not PlayerTweakData._sapphire_mask_up_hooked then
    PlayerTweakData._sapphire_mask_up_hooked = true

    Hooks:PostHook(PlayerTweakData, "init", "Sapphire_MaskUpOverhaul_Init", function(self)
        apply_mask_tweaks()
    end)
end
