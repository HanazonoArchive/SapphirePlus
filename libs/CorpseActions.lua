Sapphire.Corpses = Sapphire.Corpses or {}

-- Clean All Corpses.
--
-- Two dead code paths were removed after verification against decompiled source:
--   * managers.enemy:all_corpses() does NOT exist (EnemyManager only defines
--     all_enemies, enemymanager.lua:432) -- the old block was inert.
--   * managers.slot:get_mask("player_interactions") references a slot mask that is
--     not defined in SlotManager._masks (slotmanager.lua only defines all,
--     players, criminals, civilians, hostages, cameras, enemies, corpses, ... --
--     there is no "player_interactions" mask), so that sweep never matched.
--
-- The two remaining paths are the real, verified ones:
--   1. The "corpses" slot mask (slot 17, slotmanager.lua:59) catches dead-body
--      units directly.
--   2. managers.interaction._interactive_units catches loose "corpse_dispose"
--      body bags -- the correct registry the engine actually populates.
function Sapphire.Corpses:CleanAll()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Clean All Corpses is disabled in Safe Mode." })
        end
        return
    end

    local cleaned_count = 0
    local processed_keys = {}

    local function remove_corpse_unit(unit)
        if not alive(unit) or processed_keys[unit:key()] then return end
        processed_keys[unit:key()] = true

        pcall(function()
            if unit:slot() ~= 0 then
                unit:set_slot(0)
                cleaned_count = cleaned_count + 1
            end
        end)
    end

    -- 1. Sweep the "corpses" collision slot mask (slot 17).
    local corpse_mask = managers.slot and managers.slot:get_mask("corpses")
    if corpse_mask then
        local units = World:find_units_quick("all", corpse_mask)
        for _, unit in pairs(units) do
            remove_corpse_unit(unit)
        end
    end

    -- 2. Sweep all interactables for bagged corpses ("corpse_dispose").
    local all_interactables = managers.interaction and managers.interaction._interactive_units or {}
    for _, unit in pairs(all_interactables) do
        if alive(unit) and unit.interaction and unit:interaction() then
            local tweak = unit:interaction().tweak_data
            if tweak == "corpse_dispose" then
                remove_corpse_unit(unit)
            end
        end
    end

    if managers and managers.hud and managers.hud.show_hint then
        if cleaned_count > 0 then
            managers.hud:show_hint({ text = "Sapphire+: Silently cleaned " .. tostring(cleaned_count) .. " corpses and body bags!" })
        else
            managers.hud:show_hint({ text = "Sapphire+: No corpses or body bags found on the map." })
        end
    end

    Sapphire:Log("Cleaned " .. tostring(cleaned_count) .. " corpses/bags.")
end
