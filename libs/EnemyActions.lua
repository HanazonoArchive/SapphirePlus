Sapphire.Enemies = Sapphire.Enemies or {}

function Sapphire.Enemies:WipeAll()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Wipe All Enemies is disabled in Safe Mode." })
        end
        return
    end

    local enemy_count = 0
    local camera_count = 0

    -- 1. Despawn all tracked enemies from enemy manager
    if managers.enemy and managers.enemy.all_enemies then
        for _, data in pairs(managers.enemy:all_enemies()) do
            local unit = data.unit
            if alive(unit) and unit:slot() ~= 0 then
                pcall(function()
                    if unit:brain() then
                        unit:brain():set_active(false)
                    end
                    unit:set_slot(0)
                    enemy_count = enemy_count + 1
                end)
            end
        end
    end

    -- 2. Sweep enemy collision slot mask for any unlinked guards / snipers
    local enemy_mask = managers.slot and managers.slot:get_mask("enemies")
    if enemy_mask then
        local units = World:find_units_quick("all", enemy_mask)
        for _, unit in pairs(units) do
            if alive(unit) and unit:slot() ~= 0 then
                pcall(function()
                    if unit:brain() then
                        unit:brain():set_active(false)
                    end
                    unit:set_slot(0)
                    enemy_count = enemy_count + 1
                end)
            end
        end
    end

    -- 3. Deactivate all security cameras across the map (Camera Operator eliminated)
    if SecurityCamera and SecurityCamera.cameras then
        for _, cam in pairs(SecurityCamera.cameras) do
            if alive(cam) and cam:base() then
                pcall(function()
                    cam:base():set_detection_enabled(false)
                    cam:base():set_update_enabled(false)
                    camera_count = camera_count + 1
                end)
            end
        end
    end

    -- 4. Also sweep world for camera units
    local all_world_cams = World:find_units_quick("all", 1)
    for _, unit in pairs(all_world_cams) do
        if alive(unit) and unit:base() and unit:base().set_detection_enabled and unit:base().set_update_enabled then
            pcall(function()
                unit:base():set_detection_enabled(false)
                unit:base():set_update_enabled(false)
            end)
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({
            text = "Sapphire+: Despawned " .. tostring(enemy_count) .. " enemies and disabled all security cameras!"
        })
    end
    Sapphire:Log("Silently wiped " .. tostring(enemy_count) .. " enemies & disabled cameras.")
end
