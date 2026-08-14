dofile(ModPath .. "core.lua")

Sapphire:Log("StealthGPS hook loaded.")

-- ============================================================
-- STEALTH GPS: GUARD PATROL & NAVIGATION PATH VISUALIZER
-- ============================================================
-- Renders 3D navigation paths, destination waypoints, and unit
-- tags for moving guards in real-time during stealth mode.
--
-- Performance & Stability Optimizations:
-- 1. O(1) direct rendering from self._unit (no quadratic World searches).
-- 2. Nil-guards for self._nav_path to prevent vanilla engine crashes.
-- 3. Automatic deactivation when heist goes loud (whisper_mode = false).
-- 4. 100% client-side rendering (zero network desync or matchmaking impact).
-- ============================================================

local unit_colors = {}

local function get_unit_color(unit_id)
    if not unit_colors[unit_id] then
        math.randomseed(unit_id * 1000 + 42)
        unit_colors[unit_id] = {
            r = math.random(30, 100) / 100,
            g = math.random(50, 100) / 100,
            b = math.random(50, 100) / 100
        }
    end
    return unit_colors[unit_id]
end

if CopActionWalk and not CopActionWalk._sapphire_gps_hooked then
    CopActionWalk._sapphire_gps_hooked = true

    local orig_cop_action_walk_update = CopActionWalk.update
    function CopActionWalk:update(t, ...)
        if orig_cop_action_walk_update then
            orig_cop_action_walk_update(self, t, ...)
        end

        local effective = Sapphire:GetEffectiveSettings()
        if not effective.Enabled or not effective.StealthGPS then
            return
        end

        -- Only render while in stealth mode
        if not managers.groupai or not managers.groupai:state() or not managers.groupai:state():whisper_mode() then
            return
        end

        local player_unit = managers.player and managers.player:player_unit()
        if not alive(player_unit) then
            return
        end

        local unit = self._unit
        if not alive(unit) then
            return
        end

        local camera = managers.viewport and managers.viewport:get_current_camera()
        if not camera then
            return
        end

        local positions = self._nav_path
        if not positions or #positions < 2 then
            return
        end

        local u_id = unit:id()
        local color = get_unit_color(u_id)
        local r, g, b = color.r, color.g, color.b

        local movement = unit:movement()
        if not movement then
            return
        end

        local cam_rot = camera:rotation()
        local cam_up = cam_rot:z()
        local cam_right = cam_rot:x()

        local tweak_name = (unit:base() and unit:base()._tweak_table) or "guard"
        local name_brush = Draw:brush(Color(r, g, b))
        name_brush:set_font(Idstring("fonts/font_medium"), 14)
        name_brush:set_render_template(Idstring("OverlayVertexColorTextured"))
        name_brush:center_text(movement:m_head_pos() + Vector3(0, 0, 25), tweak_name, cam_right, -cam_up)

        local app = Application
        local last_nav_pos = self._nav_point_pos and self._nav_point_pos(positions[#positions])

        for i = 2, #positions do
            local current_pos = positions[i - 1]
            local next_pos = positions[i]
            if current_pos and next_pos and self._nav_point_pos then
                local current_nav_pos = self._nav_point_pos(current_pos)
                local next_nav_pos = self._nav_point_pos(next_pos)
                if current_nav_pos and next_nav_pos then
                    app:draw_cylinder(next_nav_pos, current_nav_pos, 1.2, r, g, b)
                end
            end
        end

        if last_nav_pos then
            app:draw_sphere(last_nav_pos, 6, r, g, b)
        end
    end
end
