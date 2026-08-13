Sapphire.Supplies = Sapphire.Supplies or {}

-- ============================================================
-- RESTOCK ALL SUPPLIES (Health, Armor, Ammo, Grenades, Cable Ties, Bags)
-- ============================================================
-- Instantly restores player health, armor, ammunition, deployables,
-- cable ties, body bags, and throwables to maximum capacity.
--
-- Gated by Safe Mode for multiplayer clients.
-- ============================================================

function Sapphire.Supplies:Restock()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Restock Supplies is disabled in Safe Mode." })
        end
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    pcall(function()
        local char_dmg = player:character_damage()

        -- 1. Restore Health & Armor to 100%
        if char_dmg then
            if char_dmg.band_aid_health then
                char_dmg:band_aid_health()
            end
            if char_dmg.restore_health then
                char_dmg:restore_health(1.0, true, false)
            end
            if char_dmg.restore_armor then
                char_dmg:restore_armor()
            end
        end

        -- 2. Replenish all primary & secondary weapon ammunition
        local inv = player:inventory()
        if inv and inv.available_selections then
            for id, weapon in pairs(inv:available_selections()) do
                if weapon and alive(weapon.unit) and weapon.unit:base() and weapon.unit:base().replenish then
                    weapon.unit:base():replenish()
                    if managers.hud and managers.hud.set_ammo_amount and weapon.unit:base().ammo_info then
                        pcall(function()
                            managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
                        end)
                    end
                end
            end
        end

        -- 3. Refill throwables / grenades to max
        if managers.player then
            local max_grenades = managers.player.get_max_grenades and managers.player:get_max_grenades() or 3
            if managers.player.add_grenade_amount then
                managers.player:add_grenade_amount(max_grenades)
            end

            -- 4. Refill cable ties
            if managers.player.add_cable_ties then
                managers.player:add_cable_ties(9)
            end

            -- 5. Refill body bags to maximum
            local max_bags = managers.player.max_body_bags and managers.player:max_body_bags() or 3
            if managers.player.add_body_bags_amount then
                managers.player:add_body_bags_amount(max_bags)
            end

            -- 6. Refill deployable equipment (Ammo/Doc bags, ECMs, Sentries, FAKs)
            if managers.player._equipment and managers.player._equipment.selections then
                for _, eq in ipairs(managers.player._equipment.selections) do
                    if eq and eq.equipment and managers.player.add_equipment_amount then
                        pcall(function()
                            managers.player:add_equipment_amount(eq.equipment, 5, 1)
                            if eq.amount and #eq.amount > 1 then
                                managers.player:add_equipment_amount(eq.equipment, 5, 2)
                            end
                        end)
                    end
                end
            end
        end
    end)

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Restocked Health, Armor, Ammo, Grenades, Cable Ties & Body Bags to 100%!" })
    end

    Sapphire:Log("Supplies: Restocked all player resources to 100%.")
end
