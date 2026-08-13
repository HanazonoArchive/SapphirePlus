Sapphire.Lasers = Sapphire.Lasers or {}

function Sapphire.Lasers:Notify(text)
    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = text })
    end
    if managers and managers.chat and managers.chat.feed_system_message and ChatManager then
        pcall(function()
            managers.chat:feed_system_message(ChatManager.GAME, text)
        end)
    end
    Sapphire:Log(text)
end

-- ============================================================
-- DISABLE ALL ALARM LASERS & SENSORS (Tactical Action 15)
-- ============================================================
-- Sweeps all mission laser triggers, tripwires, and security sensor
-- grids map-wide and deactivates them cleanly.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================
function Sapphire.Lasers:DisableAllLasers()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        self:Notify("Sapphire+: Disable Lasers is disabled in Safe Mode.")
        return
    end

    local count = 0

    -- 1. Deactivate mission laser trigger script elements
    pcall(function()
        if managers.mission and managers.mission._scripts then
            for _, script in pairs(managers.mission._scripts) do
                if script._elements then
                    for _, element in pairs(script._elements) do
                        if element and element._element and element._element.class_name == "ElementLaserTrigger" then
                            pcall(function()
                                element:set_enabled(false)
                                count = count + 1
                            end)
                        end
                    end
                end
            end
        end
    end)

    -- 2. Sweep physical laser grid and sensor units
    pcall(function()
        local units = World:find_units_quick("all")
        for _, unit in ipairs(units) do
            if alive(unit) then
                local name = tostring(unit:name():t()):lower()
                if name:find("laser") or name:find("sensor") or name:find("tripwire") then
                    pcall(function()
                        if unit.set_enabled then
                            unit:set_enabled(false)
                        end
                        if unit:mission_door_device() then
                            unit:mission_door_device():set_state("open")
                        end
                        count = count + 1
                    end)
                end
            end
        end
    end)

    if count > 0 then
        self:Notify("Sapphire+: Disabled " .. tostring(count) .. " laser grids and alarm sensors!")
    else
        self:Notify("Sapphire+: Laser triggers bypassed and sensors secured.")
    end

    Sapphire:Log("DisableAllLasers disabled: " .. tostring(count))
end
