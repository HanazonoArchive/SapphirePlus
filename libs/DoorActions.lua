Sapphire.Doors = Sapphire.Doors or {}

function Sapphire.Doors:Notify(text)
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
-- UNLOCK ALL DOORS & GATES (Tactical Action 15)
-- ============================================================
-- Sweeps all interactive door units, keycard readers, security
-- stations, and barred gates across the map and unlocks them instantly.
--
-- Neutralized in Safe Mode when joining as a client.
-- ============================================================
function Sapphire.Doors:UnlockAllDoors()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        self:Notify("Sapphire+: Unlock All Doors is disabled in Safe Mode.")
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then
        self:Notify("Sapphire+: Player unit not available.")
        return
    end

    local unlocked_count = 0
    pcall(function()
        local interactables = managers.interaction and managers.interaction._interactive_units or {}
        for _, unit in pairs(interactables) do
            if alive(unit) and unit:interaction() then
                local interaction = unit:interaction()
                local is_active = (not interaction.active or interaction:active()) and not interaction._disabled
                if is_active then
                    local tweak = tostring(interaction.tweak_data or ""):lower()
                    if tweak:find("^pick_lock") or tweak:find("^door_") or tweak == "open_door" or
                       tweak:find("^keycard") or tweak == "numpad_keycard" or
                       tweak:find("^security_station") or tweak:find("^c4") or
                       tweak == "hold_open_door" or tweak == "hold_open_vault" or
                       tweak == "open_slash_close_act" or tweak == "open_slash_close_sec_box" then
                        pcall(function()
                            interaction:interact(player)
                            unlocked_count = unlocked_count + 1
                        end)
                    end
                end
            end
        end
    end)

    if unlocked_count > 0 then
        self:Notify("Sapphire+: Unlocked " .. tostring(unlocked_count) .. " doors, gates, and security readers!")
    else
        self:Notify("Sapphire+: No locked doors or security gates found.")
    end

    Sapphire:Log("UnlockAllDoors unlocked: " .. tostring(unlocked_count))
end
