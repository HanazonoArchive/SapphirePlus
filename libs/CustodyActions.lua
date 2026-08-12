Sapphire.Custody = Sapphire.Custody or {}

-- Instant Custody Breakout.
--
-- Verified against lib/managers/trademanager.lua:
--   * _criminals_to_respawn is an ARRAY of criminal records, each with a
--     `respawn_penalty` countdown (:419 inserts, :6 inits).
--   * get_criminal_to_trade(false) (:273) only returns a criminal whose
--     respawn_penalty has already reached <= 0.
--   * clbk_respawn_criminal(pos, rotation) (:958) takes a POSITION, not a name --
--     it self-selects the next eligible criminal via get_criminal_to_trade,
--     respawns them (criminal_respawn, :980), and removes them from the queue via
--     _remove_criminal_respawn (:1048). With no pos it derives the spawn point
--     from the AI follow objective.
--
-- The previous implementation called clbk_respawn_criminal(name) (wrong argument),
-- pushed malformed {id=name} records that lacked respawn_penalty/ai/peer_id, and
-- referenced non-existent respawn_criminal/_criminals fields -- so it never worked.
-- The correct instant breakout is: zero every penalty, then drain the queue.
function Sapphire.Custody:Breakout()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Custody Breakout is disabled in Safe Mode." })
        end
        return
    end

    local respawned_count = 0

    if managers.trade then
        pcall(function()
            local queue = managers.trade._criminals_to_respawn
            if not queue or #queue == 0 then
                return
            end

            -- 1. Zero every respawn penalty so all queued criminals are
            --    immediately eligible for get_criminal_to_trade.
            for _, crim in ipairs(queue) do
                if crim then
                    crim.respawn_penalty = 0
                end
            end

            -- 2. Drain the queue. Each call respawns one eligible criminal and
            --    removes it from the queue. The guard prevents an infinite loop
            --    if an entry ever fails to respawn (queue does not shrink).
            local guard = 8
            while #queue > 0 and guard > 0 and managers.trade:get_criminal_to_trade(false) do
                local before = #queue
                managers.trade:clbk_respawn_criminal()
                if #queue < before then
                    respawned_count = respawned_count + (before - #queue)
                else
                    guard = guard - 1
                end
            end
        end)
    end

    if managers and managers.hud and managers.hud.show_hint then
        if respawned_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Released " .. tostring(respawned_count) .. " teammates from custody!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: No teammates currently in custody." })
        end
    end

    Sapphire:Log("Custody breakout executed. Respawned: " .. tostring(respawned_count))
end
