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
    end

    return effective
end

-- Returns whether the current player is carrying a body bag.
function Sapphire:IsCarryingBodyBag()
    local carry_type = self:GetPlayerCarryTypeName()
    return carry_type == "person"
end

-- Returns the carry type name string (e.g. "loot_bag", "person").
-- Uses current_carry_id() confirmed live in FunctionsDump (line 122).
function Sapphire:GetPlayerCarryTypeName()
    if not managers or not managers.player then return nil end
    -- current_carry_id() confirmed in live FunctionsDump
    local carry_id = managers.player:current_carry_id()
    if carry_id then return carry_id end
    -- Fallback: scan carry_data by table reference
    local carry_data = managers.player:get_my_carry_data()
    if not carry_data then return nil end
    if tweak_data and tweak_data.carry and tweak_data.carry.types then
        for name, data in pairs(tweak_data.carry.types) do
            if data == carry_data then
                return name
            end
        end
    end
    return nil
end

-- Returns the RAW, unmodified vanilla carry modifiers for the player's current carry.
-- Reads from tweak_data but never modifies it.
function Sapphire:GetVanillaCarryModifiers()
    local carry_name = self:GetPlayerCarryTypeName()
    if not carry_name then
        return nil
    end
    if not tweak_data or not tweak_data.carry or not tweak_data.carry.types then
        return nil
    end
    local raw = tweak_data.carry.types[carry_name]
    if not raw then
        return nil
    end
    return {
        can_run = raw.can_run == true,
        move_speed_modifier = tonumber(raw.move_speed_modifier) or 1.0,
        sprint_speed_modifier = tonumber(raw.sprint_speed_modifier) or 1.0,
        jump_modifier = tonumber(raw.jump_modifier) or 1.0,
        throw_distance_multiplier = tonumber(raw.throw_distance_multiplier) or 1.0,
        weapon_category_fallback = raw.weapon_category_fallback
    }
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