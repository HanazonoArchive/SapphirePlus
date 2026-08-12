Sapphire.Revive = Sapphire.Revive or {}

-- Team Revive.
--
-- Scope verified against decompiled source: revive()/need_revive() exist ONLY on
--   * PlayerDamage  (the LOCAL player)      -- playerdamage.lua:2514/2574
--   * TeamAIDamage  (AI teammate bots)      -- teamaidamage.lua:1094/1072
-- Remote human teammates use HuskPlayerDamage, which defines NEITHER method
-- (huskplayerdamage.lua). A downed remote player can only be brought back through
-- the network by their own client; forcing it host-side would desync. So this
-- action revives YOURSELF and AI teammates, and intentionally skips downed remote
-- human players rather than faking a result.
function Sapphire.Revive:ReviveTeam()
    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Team Revive is disabled in Safe Mode." })
        end
        return
    end

    local revived_count = 0

    -- 1. Revive the local player from any down state
    --    (Bleedout, Fatal, Tased, Incapacitated, Arrested).
    do
        local char_dmg = player:character_damage()
        local current_state = managers.player and managers.player:current_state()

        if char_dmg and char_dmg.need_revive and char_dmg:need_revive() then
            pcall(function()
                char_dmg:revive(true)
                revived_count = revived_count + 1
            end)
        elseif current_state == "incapacitated" or current_state == "tased" or current_state == "arrested" or current_state == "bleed_out" or current_state == "fatal" then
            pcall(function()
                managers.player:set_player_state("standard")
                if char_dmg and char_dmg.band_aid_health then
                    char_dmg:band_aid_health()
                end
                revived_count = revived_count + 1
            end)
        end
    end

    -- 2. Revive downed AI teammate bots (TeamAIDamage supports host-side revive).
    local group_ai = (managers.groupai or managers.group_ai) and (managers.groupai or managers.group_ai):state()
    if group_ai then
        for _, c in pairs(group_ai:all_AI_criminals() or {}) do
            local unit = c and c.unit
            if alive(unit) and unit ~= player then
                local u_dmg = unit:character_damage()
                -- Only act when the damage ext actually implements revive/need_revive
                -- (TeamAIDamage does; a husk would not, and is skipped).
                if u_dmg and u_dmg.revive and u_dmg.need_revive then
                    pcall(function()
                        if u_dmg:need_revive() then
                            u_dmg:revive(player)
                            revived_count = revived_count + 1
                        end
                    end)
                end
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if revived_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Revived " .. tostring(revived_count) .. " (you + AI teammates)!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: You and your AI teammates are already up." })
        end
    end

    Sapphire:Log("Team revive executed. Revived: " .. tostring(revived_count))
end
