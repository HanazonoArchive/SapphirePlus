dofile(ModPath .. "core.lua")

Sapphire:Log("RagdollPhysics hook loaded.")

if CopDamage then
    local orig_die = CopDamage.die
    if orig_die then
        function CopDamage:die(variant, ...)
            local res = orig_die(self, variant, ...)
            
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.RagdollSpaceProgram and alive(self._unit) then
                pcall(function()
                    local num_bodies = self._unit:num_bodies()
                    local launch_force = 45000
                    local upward_bias = Vector3(0, 0, 1.2)
                    
                    for i = 0, num_bodies - 1 do
                        local body = self._unit:body(i)
                        if body and body:enabled() then
                            local rand_dir = Vector3(
                                (math.random() - 0.5) * 0.8,
                                (math.random() - 0.5) * 0.8,
                                1.0 + math.random() * 0.5
                            ):normalized()
                            
                            local impulse = (rand_dir + upward_bias):normalized() * launch_force
                            if body.push then
                                body:push(body:mass() * 40, impulse)
                            elseif body.push_at then
                                body:push_at(body:mass() * 40, impulse, body:position())
                            end
                        end
                    end
                end)
            end

            return res
        end
    end

    Sapphire:Log("RagdollPhysics: CopDamage overrides applied.")
end
