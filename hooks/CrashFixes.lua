-- Sapphire+ Core Engine Crash Protections
-- Protects against vanilla Diesel vehicle animation callback crashes

if string.lower(RequiredScript) == "lib/units/vehicles/animatedvehiclebase" and AnimatedVehicleBase then
    local orig_recall_pose = AnimatedVehicleBase.anim_clbk_recall_pose
    function AnimatedVehicleBase:anim_clbk_recall_pose(unit, pose_id, delete)
        if not self._saved_poses then
            return
        end
        orig_recall_pose(self, unit, pose_id, delete)
    end
end
