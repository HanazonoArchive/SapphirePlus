dofile(ModPath .. "core.lua")

Sapphire:Log("CopBrain hook loaded.")

local function disable_pager(unit)
    if not unit or not alive(unit) then
        return
    end
    local ud = unit:unit_data()
    if ud then
        ud.has_alarm_pager = false
    end
end

Hooks:PostHook(CopBrain, "post_init", "Sapphire_RandomPagers", function(self)
    local effective = Sapphire:GetEffectiveSettings()

    if not effective.RandomPagers then
        return
    end
    if not self._unit or not alive(self._unit) then
        return
    end

    if not effective.AutoAnswerPagers then
        local chance = effective.RandomPagerChance
        if chance <= 0 then
            return
        end

        local RNG = math.random(1, 100)
        if RNG > chance then
            return
        end
    end

    local char_tweak = self._unit:base() and self._unit:base():char_tweak()
    if not char_tweak or not char_tweak.has_alarm_pager then
        return
    end

    local job_id = Global.level_data and Global.level_data.level_id
    if job_id == "cage" or job_id == "dah" then
        return
    end

    local unit_data = self._unit:unit_data()
    if unit_data.has_alarm_pager ~= nil then
        unit_data.has_alarm_pager = false
        return
    end

    self._Sapphire_pager_pending = true
end)

Hooks:PostHook(CopBrain, "update", "Sapphire_RandomPagersApply", function(self, unit, t, dt)
    if not self._Sapphire_pager_pending then
        return
    end
    disable_pager(self._unit)
    self._Sapphire_pager_pending = nil
end)

Hooks:PostHook(CopBrain, "set_data", "Sapphire_RandomPagersFinalize", function(self, data)
    if not self._Sapphire_pager_pending then
        return
    end
    disable_pager(self._unit)
    self._Sapphire_pager_pending = nil
end)

