dofile(ModPath .. "core.lua")

Sapphire:Log("WeaponCombat hook loaded.")

-- ============================================================
-- HARDENED WEAPON COMBAT OVERHAUL (Infinite Ammo, Zero Recoil, Zero Spread)
-- ============================================================
-- Enhances weapon handling and ballistic behavior:
-- 1. Infinite Ammo: Keeps clip full and prevents reserve ammo consumption.
-- 2. No Weapon Recoil: Zeroes weapon recoil multipliers and suppresses camera recoil kick.
-- 3. No Bullet Spread: Zeroes bullet deviation cone for laser precision.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================

-- 1. RAYCAST WEAPON BASE
if RaycastWeaponBase and not RaycastWeaponBase._sapphire_weapon_combat_hooked then
    RaycastWeaponBase._sapphire_weapon_combat_hooked = true

    -- Infinite Ammo (Clip)
    local orig_clip_empty = RaycastWeaponBase.clip_empty
    function RaycastWeaponBase:clip_empty(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteAmmo then
            if self.set_ammo_remaining_in_clip and self.get_ammo_max_per_clip then
                self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())
            end
            return false
        end
        if orig_clip_empty then
            return orig_clip_empty(self, ...)
        end
        return false
    end

    -- Infinite Ammo (Reserve Total)
    local orig_use_ammo = RaycastWeaponBase.use_ammo
    function RaycastWeaponBase:use_ammo(base, ammo_usage, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.InfiniteAmmo then
            return
        end
        if orig_use_ammo then
            return orig_use_ammo(self, base, ammo_usage, ...)
        end
    end

    -- Zero Recoil Multiplier
    local orig_recoil = RaycastWeaponBase.recoil_multiplier
    function RaycastWeaponBase:recoil_multiplier(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.NoWeaponRecoil then
            return 0
        end
        if orig_recoil then
            return orig_recoil(self, ...)
        end
        return 1
    end

    -- Zero Spread Multiplier
    local orig_spread = RaycastWeaponBase.spread_multiplier
    function RaycastWeaponBase:spread_multiplier(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.NoBulletSpread then
            return 0
        end
        if orig_spread then
            return orig_spread(self, ...)
        end
        return 1
    end
end

-- 2. NEW RAYCAST WEAPON BASE (Modern Weapons & Shotguns)
if NewRaycastWeaponBase and not NewRaycastWeaponBase._sapphire_weapon_combat_hooked then
    NewRaycastWeaponBase._sapphire_weapon_combat_hooked = true

    -- Zero Recoil Multiplier
    local orig_new_recoil = NewRaycastWeaponBase.recoil_multiplier
    function NewRaycastWeaponBase:recoil_multiplier(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.NoWeaponRecoil then
            return 0
        end
        if orig_new_recoil then
            return orig_new_recoil(self, ...)
        end
        return 1
    end

    -- Zero Spread Multiplier
    local orig_new_spread = NewRaycastWeaponBase.spread_multiplier
    function NewRaycastWeaponBase:spread_multiplier(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.NoBulletSpread then
            return 0
        end
        if orig_new_spread then
            return orig_new_spread(self, ...)
        end
        return 1
    end
end

-- 3. CAMERA RECOIL KICK SUPPRESSION
if FPCamController and not FPCamController._sapphire_recoil_hooked then
    FPCamController._sapphire_recoil_hooked = true

    local orig_recoil_kick = FPCamController.recoil_kick
    function FPCamController:recoil_kick(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.NoWeaponRecoil then
            return
        end
        if orig_recoil_kick then
            return orig_recoil_kick(self, ...)
        end
    end
end

if FPCameraPlayerBase and not FPCameraPlayerBase._sapphire_recoil_hooked then
    FPCameraPlayerBase._sapphire_recoil_hooked = true

    local orig_fp_recoil = FPCameraPlayerBase.recoil_kick
    function FPCameraPlayerBase:recoil_kick(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.NoWeaponRecoil then
            return
        end
        if orig_fp_recoil then
            return orig_fp_recoil(self, ...)
        end
    end
end
