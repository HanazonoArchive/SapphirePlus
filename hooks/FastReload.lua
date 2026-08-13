dofile(ModPath .. "core.lua")

Sapphire:Log("FastReload hook loaded.")

-- ============================================================
-- HARDENED FAST WEAPON RELOAD (2.5x Reload Speed Acceleration)
-- ============================================================
-- Speeds up magazine reloads and shotgun shell loading animations
-- across all primary, secondary, akimbo, and special weapons.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================

local function hook_reload_class(cls)
    if not cls or cls._sapphire_fast_reload_hooked then
        return
    end
    cls._sapphire_fast_reload_hooked = true

    local orig_reload_mult = cls.reload_speed_multiplier
    function cls:reload_speed_multiplier(...)
        local base = 1
        if orig_reload_mult then
            base = orig_reload_mult(self, ...) or 1
        end

        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.FastReload then
            return base * 2.5
        end

        return base
    end
end

-- Hook primary and secondary weapon base classes
hook_reload_class(RaycastWeaponBase)
hook_reload_class(NewRaycastWeaponBase)
hook_reload_class(ShotgunBase)
hook_reload_class(AkimboWeaponBase)
hook_reload_class(AkimboShotgunBase)
