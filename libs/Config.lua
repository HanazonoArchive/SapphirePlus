Sapphire.DefaultSettings = {
    Debug = true,
    Enabled = true,
    SafeMode = true,
    ForceSafeModeHost = false,
    NoInteractionCooldown = false,
    AlwaysSprint = true,
    WalkSpeed = 1.2,
    SprintSpeed = 1.25,
    JumpHeight = 1.1,
    ThrowDistance = 1.25,
    AffectBodyBags = false,
    CrouchWithCarry = false,
    InfiniteStamina = false,
    BagDamageReduction = false,
    NoFallDamage = false,
    ExtendedInteract = 1.25,
    IgnoreArmorPenalty = false,
    NoWeaponRestrictions = false,
    RandomPagers = false,
    RandomPagerChance = 35,
    AutoAnswerPagers = false,
    AICantAlarm = false,
    UnlockDLCHeists = false,
    MultiPickup = false,
    UnlimitedFavors = false,
    InfiniteCameraLoop = false,
    MinDetectionRisk = false,
    DrillNoJams = false,
    InstantDrills = false
}

Sapphire.Settings = {}
Sapphire.SettingsPath = ModPath .. "settings.json"

function Sapphire:ApplyDefaultSettings()
    for key, value in pairs(self.DefaultSettings) do
        self.Settings[key] = value
    end
end

function Sapphire:LoadSettings()
    self:ApplyDefaultSettings()

    if type(json) ~= "table" or type(json.decode) ~= "function" or type(json.encode) ~= "function" then
        log("[Sapphire+] json encode/decode API is unavailable, using in-memory defaults.")
        self:NormalizeSettings()
        return
    end

    local file = io.open(self.SettingsPath, "r")
    if file then
        local raw = file:read("*all")
        file:close()

        if raw ~= nil and raw ~= "" then
            local ok, decoded = pcall(json.decode, raw)
            if ok and type(decoded) == "table" then
                for key, value in pairs(decoded) do
                    if self.DefaultSettings[key] ~= nil then
                        self.Settings[key] = value
                    end
                end
            else
                log("[Sapphire+] Failed to decode settings.json, restoring defaults.")
            end
        end
    end

    self:NormalizeSettings()
    self:SaveSettings()
end

function Sapphire:SaveSettings()
    if type(json) ~= "table" or type(json.encode) ~= "function" then
        log("[Sapphire+] json.encode API is unavailable, settings were not saved.")
        return false
    end

    local ok, encoded = pcall(json.encode, self.Settings)
    if not ok or type(encoded) ~= "string" then
        log("[Sapphire+] Failed to encode settings for saving.")
        return false
    end

    local file = io.open(self.SettingsPath, "w+")
    if not file then
        log("[Sapphire+] Failed to open settings.json for writing.")
        return false
    end

    file:write(encoded)
    file:close()
    return true
end

function Sapphire:SetSetting(key, value)
    if self.DefaultSettings[key] == nil then
        self:Log("Ignored unknown setting key: " .. tostring(key))
        return false
    end

    self.Settings[key] = value
    self:NormalizeSettings()
    self:SaveSettings()
    return true
end
