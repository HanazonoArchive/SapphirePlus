function Sapphire:ClampNumber(value, min_value, max_value, default_value)
    local number = tonumber(value) or default_value

    if number < min_value then
        return min_value
    end

    if number > max_value then
        return max_value
    end

    return number
end

function Sapphire:NormalizeSettings()
    self.Settings = self.Settings or {}

    self.Settings.Debug = self.Settings.Debug == true
    self.Settings.Enabled = self.Settings.Enabled ~= false
    self.Settings.SafeMode = self.Settings.SafeMode ~= false
    self.Settings.ForceSafeModeHost = self.Settings.ForceSafeModeHost == true
    self.Settings.InteractionSpeedReduction = self:ClampNumber(self.Settings.InteractionSpeedReduction, 0, 100, 0)

    self.Settings.AlwaysSprint = self.Settings.AlwaysSprint ~= false
    self.Settings.JumpHeight = self:ClampNumber(self.Settings.JumpHeight, 0.1, 5, 1.0)
    self.Settings.ThrowDistance = self:ClampNumber(self.Settings.ThrowDistance, 0.1, 20, 1.0)
    self.Settings.AffectBodyBags = self.Settings.AffectBodyBags ~= false

    self.Settings.InfiniteStamina = self.Settings.InfiniteStamina == true
    self.Settings.GodMode = self.Settings.GodMode == true
    self.Settings.BagDamageReduction = self:ClampNumber(self.Settings.BagDamageReduction, 0, 100, 50)
    self.Settings.NoFallDamage = self.Settings.NoFallDamage == true
    self.Settings.ExtendedInteract = self:ClampNumber(self.Settings.ExtendedInteract, 1.0, 5.0, 1.0)
    self.Settings.IgnoreArmorPenalty = self.Settings.IgnoreArmorPenalty == true

    self.Settings.NoWeaponRestrictions = self.Settings.NoWeaponRestrictions == true

    self.Settings.RandomPagers = self.Settings.RandomPagers == true
    self.Settings.RandomPagerChance = self:ClampNumber(self.Settings.RandomPagerChance, 0, 100, 35)
    self.Settings.AutoAnswerPagers = self.Settings.AutoAnswerPagers == true

    self.Settings.AICantAlarm = self.Settings.AICantAlarm == true
    self.Settings.UnlockDLCHeists = self.Settings.UnlockDLCHeists == true
    self.Settings.MultiPickup = self.Settings.MultiPickup == true
    self.Settings.UnlimitedFavors = self.Settings.UnlimitedFavors == true
    self.Settings.InfiniteCameraLoop = self.Settings.InfiniteCameraLoop == true
    self.Settings.MinDetectionRisk = self.Settings.MinDetectionRisk == true
    self.Settings.DrillNoJams = self.Settings.DrillNoJams == true
    self.Settings.InstantDrills = self.Settings.InstantDrills == true
    self.Settings.AutoCooker = self.Settings.AutoCooker == true
    self.Settings.OmnidirectionalSprint = self.Settings.OmnidirectionalSprint == true
    self.Settings.AntiFlashbang = self.Settings.AntiFlashbang == true
    self.Settings.InstantMeleeCharge = self.Settings.InstantMeleeCharge == true
    self.Settings.NoWeaponSway = self.Settings.NoWeaponSway == true
    self.Settings.FastReload = self.Settings.FastReload == true
    self.Settings.InstantMaskUp = self.Settings.InstantMaskUp == true
    self.Settings.FastArmorRegen = self.Settings.FastArmorRegen == true
    self.Settings.SentryGodMode = self.Settings.SentryGodMode == true
    self.Settings.InfiniteAmmo = self.Settings.InfiniteAmmo == true
    self.Settings.NoWeaponRecoil = self.Settings.NoWeaponRecoil == true
    self.Settings.NoBulletSpread = self.Settings.NoBulletSpread == true
    self.Settings.AllWeaponsFullAuto = self.Settings.AllWeaponsFullAuto == true
    self.Settings.InfiniteCableTies = self.Settings.InfiniteCableTies == true
    self.Settings.InfiniteBodyBags = self.Settings.InfiniteBodyBags == true
    self.Settings.InfiniteThrowables = self.Settings.InfiniteThrowables == true
    self.Settings.FastWeaponSwitch = self.Settings.FastWeaponSwitch == true
    self.Settings.StealthGPS = self.Settings.StealthGPS == true
end

function Sapphire:IsMultiplayerSessionActive()
    -- Check if the user is playing "Play Offline"
    if type(Global) == "table" and type(Global.game_settings) == "table" then
        if Global.game_settings.single_player == true then
            return false
        end
    end

    -- If there's an active network session, it's a multiplayer lobby (even if solo)
    if type(managers) == "table" and type(managers.network) == "table" and type(managers.network.session) == "function" then
        local session = managers.network:session()
        if type(session) == "table" then
            return true
        end
    end

    return false
end

function Sapphire:IsHost()
    if type(managers) ~= "table" or type(managers.network) ~= "table" then
        return true
    end
    if type(managers.network.is_server) == "function" then
        return managers.network:is_server()
    end
    local session = managers.network:session()
    if type(session) == "table" and type(session.is_host) == "function" then
        return session:is_host()
    end
    return true
end

function Sapphire:GetEffectiveSettings()
    local effective = {
        Enabled = self.Settings.Enabled,
        InteractionSpeedReduction = self.Settings.InteractionSpeedReduction,
        AlwaysSprint = self.Settings.AlwaysSprint,
        JumpHeight = self.Settings.JumpHeight,
        ThrowDistance = self.Settings.ThrowDistance,
        AffectBodyBags = self.Settings.AffectBodyBags,
        InfiniteStamina = self.Settings.InfiniteStamina,
        GodMode = self.Settings.GodMode,
        BagDamageReduction = self.Settings.BagDamageReduction,
        NoFallDamage = self.Settings.NoFallDamage,
        ExtendedInteract = self.Settings.ExtendedInteract,
        IgnoreArmorPenalty = self.Settings.IgnoreArmorPenalty,
        NoWeaponRestrictions = self.Settings.NoWeaponRestrictions,
        RandomPagers = self.Settings.RandomPagers,
        RandomPagerChance = self.Settings.RandomPagerChance,
        AutoAnswerPagers = self.Settings.AutoAnswerPagers,
        AICantAlarm = self.Settings.AICantAlarm,
        UnlockDLCHeists = self.Settings.UnlockDLCHeists,
        MultiPickup = self.Settings.MultiPickup,
        UnlimitedFavors = self.Settings.UnlimitedFavors,
        InfiniteCameraLoop = self.Settings.InfiniteCameraLoop,
        MinDetectionRisk = self.Settings.MinDetectionRisk,
        DrillNoJams = self.Settings.DrillNoJams,
        InstantDrills = self.Settings.InstantDrills,
        AutoCooker = self.Settings.AutoCooker,
        OmnidirectionalSprint = self.Settings.OmnidirectionalSprint,
        AntiFlashbang = self.Settings.AntiFlashbang,
        InstantMeleeCharge = self.Settings.InstantMeleeCharge,
        NoWeaponSway = self.Settings.NoWeaponSway,
        FastReload = self.Settings.FastReload,
        InstantMaskUp = self.Settings.InstantMaskUp,
        FastArmorRegen = self.Settings.FastArmorRegen,
        SentryGodMode = self.Settings.SentryGodMode,
        InfiniteAmmo = self.Settings.InfiniteAmmo,
        NoWeaponRecoil = self.Settings.NoWeaponRecoil,
        NoBulletSpread = self.Settings.NoBulletSpread,
        AllWeaponsFullAuto = self.Settings.AllWeaponsFullAuto,
        InfiniteCableTies = self.Settings.InfiniteCableTies,
        InfiniteBodyBags = self.Settings.InfiniteBodyBags,
        InfiniteThrowables = self.Settings.InfiniteThrowables,
        FastWeaponSwitch = self.Settings.FastWeaponSwitch,
        StealthGPS = self.Settings.StealthGPS,
        SafeModeActive = false,
        ForceSafeModeHost = self.Settings.ForceSafeModeHost
    }

    local is_multiplayer = self:IsMultiplayerSessionActive()
    local is_host = self:IsHost()

    local safe_mode_active = false
    if self.Settings.SafeMode and is_multiplayer then
        if not is_host then
            safe_mode_active = true
        elseif self.Settings.ForceSafeModeHost then
            safe_mode_active = true
        end
    end

    if safe_mode_active then
        effective.SafeModeActive = true
        effective.InteractionSpeedReduction = math.min(effective.InteractionSpeedReduction, 25)
        effective.InfiniteStamina = false
        effective.GodMode = false
        effective.BagDamageReduction = math.min(effective.BagDamageReduction, 50)
        effective.NoFallDamage = false
        effective.ExtendedInteract = math.min(effective.ExtendedInteract, 1.25)
        effective.IgnoreArmorPenalty = false
        effective.NoWeaponRestrictions = false
        effective.AutoAnswerPagers = false
        effective.JumpHeight = math.min(effective.JumpHeight, 1.1)
        effective.ThrowDistance = math.min(effective.ThrowDistance, 1.25)
        effective.AffectBodyBags = false
        effective.AICantAlarm = false
        effective.MultiPickup = false
        effective.UnlimitedFavors = false
        effective.InfiniteCameraLoop = false
        effective.MinDetectionRisk = false
        effective.DrillNoJams = false
        effective.InstantDrills = false
        effective.AutoCooker = false
        effective.OmnidirectionalSprint = false
        effective.AntiFlashbang = false
        effective.InstantMeleeCharge = false
        effective.FastReload = false
        effective.InstantMaskUp = false
        effective.FastArmorRegen = false
        effective.SentryGodMode = false
        effective.InfiniteAmmo = false
        effective.NoWeaponRecoil = false
        effective.NoBulletSpread = false
        effective.AllWeaponsFullAuto = false
        effective.InfiniteCableTies = false
        effective.InfiniteBodyBags = false
        effective.InfiniteThrowables = false
        effective.FastWeaponSwitch = false
    end

    return effective
end

-- Applies (or restores) carry-type physics modifiers based on the current
-- effective settings. This is the single source of truth for carry modifiers,
-- called from three places: CarryTweakData:init (initial apply), the EHI-spoof
-- re-apply in InteractionExt, and the live-update path in the settings menu.
--
-- `types` is the carry-types table to operate on. It defaults to
-- tweak_data.carry.types, but CarryTweakData:init must pass self.types
-- explicitly because the global tweak_data is not yet wired up mid-construction.
--
-- The restore branch reads vanilla values from Sapphire.VanillaCarryTypes, which
-- CarryTweakData:init captures before the first apply, so this stays idempotent
-- and can be called repeatedly.
function Sapphire:ApplyCarryModifiers(types)
    types = types or (tweak_data and tweak_data.carry and tweak_data.carry.types)
    if not types then
        return
    end

    local effective = self:GetEffectiveSettings()

    -- The "being" weight-class is used by exactly two carry items -- `person` and
    -- `special_person` (body bags) -- and nothing else (verified against
    -- lib/tweak_data/carrytweakdata.lua). `types` is keyed by weight-class, NOT by
    -- item id, so gating on the item id "person" never matched and body bags were
    -- always buffed regardless of AffectBodyBags / Safe Mode. Gate on "being".
    for id, data in pairs(types) do
        if not effective.Enabled or (id == "being" and not effective.AffectBodyBags) then
            local vanilla = self.VanillaCarryTypes and self.VanillaCarryTypes[id]
            if vanilla then
                data.move_speed_modifier = vanilla.move_speed_modifier
                data.jump_modifier = vanilla.jump_modifier
                data.throw_distance_multiplier = vanilla.throw_distance_multiplier
                data.can_run = vanilla.can_run
            end
        else
            data.move_speed_modifier = 1.0
            data.jump_modifier = effective.JumpHeight
            data.throw_distance_multiplier = effective.ThrowDistance

            if effective.AlwaysSprint then
                data.can_run = true
            elseif self.VanillaCarryTypes and self.VanillaCarryTypes[id] then
                data.can_run = self.VanillaCarryTypes[id].can_run
            end
        end
    end
end

-- ============================================================
-- LIVE-APPLY REGISTRY
-- ============================================================
-- Hooks that mutate shared tweak_data at runtime (MultiPickup, InfiniteCameraLoop,
-- ...) register a sync callback here. ApplyLiveTweaks() runs them all -- alongside
-- ApplyCarryModifiers -- from the settings-menu change handler, so a mid-heist
-- toggle both APPLIES and RESTORES each tweak instead of leaking a buffed value
-- into vanilla code paths after the feature is switched off. Each callback must be
-- idempotent and decide apply-vs-restore from its own effective settings.
Sapphire.LiveApplyCallbacks = Sapphire.LiveApplyCallbacks or {}

function Sapphire:RegisterLiveApply(fn)
    if type(fn) ~= "function" then return end
    table.insert(self.LiveApplyCallbacks, fn)
end

function Sapphire:ApplyLiveTweaks()
    self:ApplyCarryModifiers()
    for _, fn in ipairs(self.LiveApplyCallbacks) do
        pcall(fn)
    end
end

function Sapphire:Dump(tbl)
    if type(tbl) ~= "table" then
        self:Log("Dump failed: value is not a table.")
        return
    end

    for k, v in pairs(tbl) do
        self:Log(tostring(k) .. " = " .. tostring(v))
    end
end