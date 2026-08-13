dofile(ModPath .. "core.lua")

Sapphire:Log("PlayerDamage hook loaded.")

-- ============================================================
-- GOD MODE, BAG DAMAGE REDUCTION, NO FALL DAMAGE
-- ============================================================
--
-- GOD MODE uses the engine's native `_god_mode` invincibility flag rather than
-- zeroing attack_data.damage in individual methods. The native flag is honored at
-- the top of EVERY damage entry point (damage_bullet, damage_tase, damage_melee
-- via damage_bullet, damage_explosion, damage_fire, damage_killzone, damage_fall,
-- damage_simple -- verified against lib/units/beings/player/playerdamage.lua), so
-- one flag gives true, complete invincibility instead of the previous
-- bullet+melee-only coverage.
--
-- It is enforced every frame from PlayerDamage:update so it survives respawns and
-- live toggling. The value is recomputed as (game/mission god mode) OR (our
-- toggle): `_god_mode` has exactly two vanilla writers -- init (which seeds it
-- from Global.god_mode) and set_god_mode (which sets both Global.god_mode and
-- self._god_mode) -- so Global.god_mode is authoritative and layering our toggle
-- on top of it never clobbers scripted/console god mode when our toggle is off.
-- The separate _invulnerable / _mission_damage_blockers flags are untouched.
--
-- BAG DAMAGE REDUCTION (0-100%) runs as an attack_data.damage mutation on the
-- bullet/melee detours; it only matters when God Mode is off.
--
-- damage_melee internally calls self:damage_bullet(attack_data)
-- (playerdamage.lua:1189), so without a guard the reduction would be applied
-- twice on a single melee hit. We tag attack_data on the first pass and no-op on
-- re-entry. Detour (not PreHook) is used so the mutation lands before the vanilla
-- damage math reads attack_data.damage.
--
-- God Mode is a dedicated toggle, decoupled from AICantAlarm, and neutralized by
-- Safe Mode for multiplayer clients.
-- ============================================================

local function apply_bag_damage_reduction(attack_data)
    local effective = Sapphire:GetEffectiveSettings()
    if not effective.Enabled or not attack_data or not attack_data.damage then
        return
    end

    -- Re-entrancy guard: damage_melee re-enters through damage_bullet.
    if attack_data._sapphire_dmg_modded then
        return
    end
    attack_data._sapphire_dmg_modded = true

    if effective.BagDamageReduction and effective.BagDamageReduction > 0
            and managers.player and managers.player:is_carrying() then
        attack_data.damage = attack_data.damage * (1.0 - effective.BagDamageReduction / 100.0)
    end
end

local orig_damage_bullet = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data)
    apply_bag_damage_reduction(attack_data)
    if orig_damage_bullet then
        return orig_damage_bullet(self, attack_data)
    end
end

local orig_damage_melee = PlayerDamage.damage_melee
function PlayerDamage:damage_melee(attack_data)
    apply_bag_damage_reduction(attack_data)
    if orig_damage_melee then
        return orig_damage_melee(self, attack_data)
    end
end

local orig_damage_fall = PlayerDamage.damage_fall
function PlayerDamage:damage_fall(data)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.NoFallDamage then
        return false
    end
    if orig_damage_fall then
        return orig_damage_fall(self, data)
    end
end

-- Suppress flashbang visual whiteout and audio ringing when AntiFlashbang is active
local orig_on_flashbanged = PlayerDamage.on_flashbanged
function PlayerDamage:on_flashbanged(sound_eff_mul, ...)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.AntiFlashbang then
        return
    end
    if orig_on_flashbanged then
        return orig_on_flashbanged(self, sound_eff_mul, ...)
    end
end

-- Fast Armor Regeneration: Eliminates armor recovery delay
local orig_upd_armor_regen = PlayerDamage._upd_armor_regeneration
function PlayerDamage:_upd_armor_regeneration(t, dt, ...)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.FastArmorRegen and not self._dead and not self._bleed_out and self._regen_armor_queued then
        self._armor_regenerate_timer = 0
    end
    if orig_upd_armor_regen then
        return orig_upd_armor_regen(self, t, dt, ...)
    end
end

-- Enforce God Mode via the native invincibility flag every frame. Layered on top
-- of the game's own Global.god_mode so turning our toggle off restores the game's
-- baseline instead of forcing false.
Hooks:PostHook(PlayerDamage, "update", "Sapphire_GodMode_Enforce", function(self)
    local effective = Sapphire:GetEffectiveSettings()
    local want = effective.Enabled and effective.GodMode and true or false
    local base = Global.god_mode and true or false
    self._god_mode = base or want
end)
