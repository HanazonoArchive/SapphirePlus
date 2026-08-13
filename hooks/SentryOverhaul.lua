dofile(ModPath .. "core.lua")

Sapphire:Log("SentryOverhaul hook loaded.")

-- ============================================================
-- SENTRY GUN OVERHAUL (Invulnerable & Infinite Ammo Sentry Guns)
-- ============================================================
-- Protects all player-placed sentry guns and suppressed sentries from
-- taking damage from bullets, melee attacks, fire, and explosions,
-- and prevents sentry ammunition depletion.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================

if SentryGunDamage and not SentryGunDamage._sapphire_sentry_hooked then
    SentryGunDamage._sapphire_sentry_hooked = true

    local orig_damage_bullet = SentryGunDamage.damage_bullet
    function SentryGunDamage:damage_bullet(attack_data, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.SentryGodMode then
            return
        end
        if orig_damage_bullet then
            return orig_damage_bullet(self, attack_data, ...)
        end
    end

    local orig_damage_fire = SentryGunDamage.damage_fire
    function SentryGunDamage:damage_fire(attack_data, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.SentryGodMode then
            return
        end
        if orig_damage_fire then
            return orig_damage_fire(self, attack_data, ...)
        end
    end

    local orig_damage_explosion = SentryGunDamage.damage_explosion
    function SentryGunDamage:damage_explosion(attack_data, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.SentryGodMode then
            return
        end
        if orig_damage_explosion then
            return orig_damage_explosion(self, attack_data, ...)
        end
    end

    local orig_damage_melee = SentryGunDamage.damage_melee
    function SentryGunDamage:damage_melee(attack_data, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.SentryGodMode then
            return
        end
        if orig_damage_melee then
            return orig_damage_melee(self, attack_data, ...)
        end
    end

    local orig_damage_concussion = SentryGunDamage.damage_concussion
    function SentryGunDamage:damage_concussion(attack_data, ...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.SentryGodMode then
            return
        end
        if orig_damage_concussion then
            return orig_damage_concussion(self, attack_data, ...)
        end
    end
end

if SentryGunWeapon and not SentryGunWeapon._sapphire_sentry_ammo_hooked then
    SentryGunWeapon._sapphire_sentry_ammo_hooked = true

    local orig_out_of_ammo = SentryGunWeapon.out_of_ammo
    function SentryGunWeapon:out_of_ammo(...)
        local effective = Sapphire:GetEffectiveSettings()
        if effective.Enabled and effective.SentryGodMode then
            return false
        end
        if orig_out_of_ammo then
            return orig_out_of_ammo(self, ...)
        end
        return false
    end
end
