dofile(ModPath .. "core.lua")

-- ============================================================
-- MENU SYSTEM: Single page with category headers and dividers
-- ============================================================
-- All settings on one scrollable page, organized by category.
-- Uses priority values to enforce order (higher = appears first).
-- Dividers and header buttons separate each section visually.
-- ============================================================

local menu_id = "Sapphire_options_menu"
local callback_id = "Sapphire_MenuSettingChanged"
local dummy_callback_id = "Sapphire_DummyCallback"
local menu_populated = false

local setting_keys = {
    Sapphire_Enabled           = "Enabled",
    Sapphire_SafeMode          = "SafeMode",
    Sapphire_ForceSafeModeHost = "ForceSafeModeHost",
    Sapphire_Debug             = "Debug",
    Sapphire_AlwaysSprint      = "AlwaysSprint",
    Sapphire_JumpHeight        = "JumpHeight",
    Sapphire_ThrowDistance     = "ThrowDistance",
    Sapphire_AffectBodyBags    = "AffectBodyBags",
    Sapphire_InteractionSpeedReduction = "InteractionSpeedReduction",
    Sapphire_InfiniteStamina   = "InfiniteStamina",
    Sapphire_GodMode           = "GodMode",
    Sapphire_BagDamageReduction = "BagDamageReduction",
    Sapphire_NoFallDamage      = "NoFallDamage",
    Sapphire_ExtendedInteract  = "ExtendedInteract",
    Sapphire_NoWeaponRestrictions = "NoWeaponRestrictions",
    Sapphire_IgnoreArmorPenalty = "IgnoreArmorPenalty",
    Sapphire_RandomPagers      = "RandomPagers",
    Sapphire_RandomPagerChance = "RandomPagerChance",
    Sapphire_AutoAnswerPagers  = "AutoAnswerPagers",
    Sapphire_AICantAlarm         = "AICantAlarm",
    Sapphire_UnlockDLCHeists     = "UnlockDLCHeists",
    Sapphire_MultiPickup         = "MultiPickup",
    Sapphire_UnlimitedFavors     = "UnlimitedFavors",
    Sapphire_InfiniteCameraLoop  = "InfiniteCameraLoop",
    Sapphire_MinDetectionRisk    = "MinDetectionRisk",
    Sapphire_DrillNoJams         = "DrillNoJams",
    Sapphire_InstantDrills       = "InstantDrills",
    Sapphire_OmnidirectionalSprint = "OmnidirectionalSprint",
}

local function parse_item_value(item, key)
    if key == "Debug" or key == "AlwaysSprint" or key == "Enabled" or key == "SafeMode" or
       key == "ForceSafeModeHost" or
       key == "RandomPagers" or key == "InfiniteStamina" or
       key == "AutoAnswerPagers" or key == "NoFallDamage" or key == "IgnoreArmorPenalty" or
       key == "AffectBodyBags" or key == "NoWeaponRestrictions" or key == "AICantAlarm" or key == "UnlockDLCHeists" or
       key == "MultiPickup" or
       key == "GodMode" or
       key == "UnlimitedFavors" or
       key == "InfiniteCameraLoop" or
       key == "MinDetectionRisk" or
       key == "DrillNoJams" or
       key == "InstantDrills" or
       key == "OmnidirectionalSprint" then
        return item:value() == "on"
    end

    return tonumber(item:value()) or Sapphire.DefaultSettings[key]
end

-- ============================================================
-- LOCALIZATION
-- ============================================================

Hooks:Add("LocalizationManagerPostInit", "Sapphire_Localization", function(loc)
    loc:add_localized_strings({
        -- Root menu
        Sapphire_menu_title = "Sapphire+ Options",
        Sapphire_menu_desc  = "Configure Sapphire+ behavior and save settings.",

        -- Category headers
        Sapphire_header_core_title    = "--- Core Settings ---",
        Sapphire_header_core_desc     = "",
        Sapphire_header_carry_title   = "--- Carry & Movement ---",
        Sapphire_header_carry_desc    = "",
        Sapphire_header_qol_title     = "--- Quality of Life ---",
        Sapphire_header_qol_desc      = "",
        Sapphire_header_stealth_title = "--- Stealth Tools ---",
        Sapphire_header_stealth_desc  = "",
        Sapphire_header_extras_title  = "--- Extras ---",
        Sapphire_header_extras_desc   = "",

        -- Core Settings
        Sapphire_enabled_title = "Enable Sapphire+",
        Sapphire_enabled_desc  = "Master toggle for all Sapphire+ effects.",

        Sapphire_safe_mode_title = "Safe Mode (Multiplayer)",
        Sapphire_safe_mode_desc  = "Automatically cap settings when joining other lobbies.",

        Sapphire_force_safe_mode_host_title = "Force Safe Mode (Host)",
        Sapphire_force_safe_mode_host_desc  = "Apply Safe Mode restrictions even when you are the host.",

        Sapphire_debug_title = "Debug Logging",
        Sapphire_debug_desc  = "Enable or disable Sapphire+ debug logging.",

        -- Carry & Movement
        Sapphire_always_sprint_title = "Always Sprint With Carry",
        Sapphire_always_sprint_desc  = "Allow sprinting while carrying bags.",

        Sapphire_jump_height_title = "Carry Jump Height",
        Sapphire_jump_height_desc  = "Jump strength multiplier while carrying.",

        Sapphire_throw_distance_title = "Carry Throw Distance",
        Sapphire_throw_distance_desc  = "Throw distance multiplier for carried bags.",

        Sapphire_affect_body_bags_title = "Affect Body Bags",
        Sapphire_affect_body_bags_desc  = "Apply carry speed and distance tweaks to body bags.",

        Sapphire_ignore_armor_penalty_title = "Ignore Armor Speed Penalty",
        Sapphire_ignore_armor_penalty_desc  = "Wearing heavy armor no longer slows you down.",

        Sapphire_no_weapon_restrictions_title = "Keep Body Bags When Loud",
        Sapphire_no_weapon_restrictions_desc  = "Carried and dropped body bags are no longer auto-removed when enemies go loud (weapons hot). PAYDAY 2 has no 'cannot fire while carrying' rule, so this replaces the misnamed weapon lock. (Disabled in Safe Mode)",

        Sapphire_omnidirectional_sprint_title = "360 Sprinting (Omnidirectional)",
        Sapphire_omnidirectional_sprint_desc  = "Allows sprinting at full speed in any direction, including backwards and sideways.",

        -- Quality of Life
        Sapphire_interaction_speed_reduction_title = "Interaction Speed Reduction (%)",
        Sapphire_interaction_speed_reduction_desc  = "Reduces interaction timer duration linearly (0% = vanilla, 50% = twice as fast, 100% = instant).",

        Sapphire_infinite_stamina_title = "Infinite Stamina With Carry",
        Sapphire_infinite_stamina_desc  = "Sprint infinitely while carrying a bag.",

        Sapphire_bag_damage_reduction_title = "Bag Shield (%)",
        Sapphire_bag_damage_reduction_desc  = "Percentage of damage to ignore while carrying a bag (0 = none, 100 = invincible while carrying).",

        Sapphire_god_mode_title = "God Mode (Invincible)",
        Sapphire_god_mode_desc  = "Ignore all incoming bullet and melee damage at all times. Cheat-tier: automatically disabled in Safe Mode. (Independent of AI Can't Alarm.)",

        Sapphire_no_fall_damage_title = "No Fall Damage",
        Sapphire_no_fall_damage_desc  = "You will not take any fall damage.",

        Sapphire_extended_interact_title = "Interaction Range Multiplier",
        Sapphire_extended_interact_desc  = "Multiplier for your interaction distance (useful for catching bags).",

        Sapphire_drill_no_jams_title = "Drills Never Jam",
        Sapphire_drill_no_jams_desc  = "Prevents drills, saws, and hacking devices from ever breaking down. (Disabled in Safe Mode)",

        Sapphire_instant_drills_title = "Instant Drills (Zero Timer)",
        Sapphire_instant_drills_desc  = "Forces all drills, saws, and hacking devices to finish in 0.01 seconds. (Disabled in Safe Mode)",

        -- Stealth Tools
        Sapphire_ai_cant_alarm_title = "AI Can't Alarm",
        Sapphire_ai_cant_alarm_desc  = "Enemies can detect you and fight, but they cannot call the police to trigger a loud heist.",

        Sapphire_multi_pickup_title = "Multi-Pickup (Solo Stealth)",
        Sapphire_multi_pickup_desc  = "Pick up keycards and other consumable items multiple times. Essential for solo stealth on maps like Shadow Raid.",

        Sapphire_infinite_camera_loop_title = "Infinite Camera Loop",
        Sapphire_infinite_camera_loop_desc  = "Camera loops last forever and multiple cameras can be looped simultaneously. (Disabled in Safe Mode)",

        Sapphire_min_detection_risk_title = "Minimum Detection Risk (Always 3)",
        Sapphire_min_detection_risk_desc  = "Forces your detection risk to 3 regardless of what armor or weapons you wear. (Disabled in Safe Mode)",

        Sapphire_random_pagers_title = "Random Pagers",
        Sapphire_random_pagers_desc  = "Randomly remove alarm pagers from security guards.",

        Sapphire_random_pager_chance_title = "No Pager Chance (%)",
        Sapphire_random_pager_chance_desc  = "Percentage chance that a guard has no pager.",

        Sapphire_auto_answer_pagers_title = "Auto-Answer Pagers",
        Sapphire_auto_answer_pagers_desc  = "Automatically answers any pagers that spawn.",

        -- Extras
        Sapphire_unlock_dlc_heists_title = "Unlock DLC Heists",
        Sapphire_unlock_dlc_heists_desc  = "Unlocks specific DLC heists listed in dlcs-to-unlock.txt (Requires a game restart to take effect).",

        Sapphire_unlimited_favors_title = "Unlimited Favors",
        Sapphire_unlimited_favors_desc  = "Removes the pre-planning favor budget. Select as many assets as you want at zero cost."
    })
end)

-- ============================================================
-- MENU SETUP
-- ============================================================

Hooks:Add("MenuManagerSetupCustomMenus", "Sapphire_MenuSetup", function(menu_manager, nodes)
    if MenuHelper == nil then
        Sapphire:Log("MenuHelper is unavailable during setup.")
        return
    end
    MenuHelper:NewMenu(menu_id)
end)

-- ============================================================
-- MENU POPULATE: Single page with priority-ordered categories
-- ============================================================
-- Priority ranges (higher = appears first):
--   Core:     900-999
--   Carry:    700-899
--   QoL:      500-699
--   Stealth:  300-499
--   Extras:   100-299
-- ============================================================

Hooks:Add("MenuManagerPopulateCustomMenus", "Sapphire_MenuPopulate", function(menu_manager, nodes)
    if MenuHelper == nil then
        Sapphire:Log("MenuHelper is unavailable during populate.")
        return
    end

    if menu_populated then
        return
    end
    menu_populated = true

    -- Dummy callback for category headers (does nothing when clicked)
    MenuCallbackHandler[dummy_callback_id] = function() end

    -- Shared callback for all real settings
    MenuCallbackHandler[callback_id] = function(_, item)
        local item_name = item:name()
        local option_key = setting_keys[item_name]

        if option_key ~= nil then
            local option_value = parse_item_value(item, option_key)
            Sapphire:SetSetting(option_key, option_value)

            -- LIVE UPDATE: re-apply carry modifiers AND all registered tweak_data
            -- syncs (MultiPickup, InfiniteCameraLoop, ...) so sliders/toggles take
            -- effect immediately, even mid-heist, and toggling a feature off
            -- restores vanilla values rather than leaving them buffed.
            Sapphire:ApplyLiveTweaks()
            return
        end
    end

    -- ========================================================
    -- CORE SETTINGS (priority 900-999)
    -- ========================================================
    MenuHelper:AddButton({
        id = "Sapphire_header_core",
        title = "Sapphire_header_core_title",
        desc = "Sapphire_header_core_desc",
        callback = dummy_callback_id,
        menu_id = menu_id,
        priority = 999
    })

    MenuHelper:AddToggle({
        id = "Sapphire_Enabled",
        title = "Sapphire_enabled_title",
        desc = "Sapphire_enabled_desc",
        callback = callback_id,
        value = Sapphire.Settings.Enabled,
        menu_id = menu_id,
        priority = 998
    })

    MenuHelper:AddToggle({
        id = "Sapphire_SafeMode",
        title = "Sapphire_safe_mode_title",
        desc = "Sapphire_safe_mode_desc",
        callback = callback_id,
        value = Sapphire.Settings.SafeMode,
        menu_id = menu_id,
        priority = 997
    })

    MenuHelper:AddToggle({
        id = "Sapphire_ForceSafeModeHost",
        title = "Sapphire_force_safe_mode_host_title",
        desc = "Sapphire_force_safe_mode_host_desc",
        callback = callback_id,
        value = Sapphire.Settings.ForceSafeModeHost,
        menu_id = menu_id,
        priority = 996
    })

    MenuHelper:AddToggle({
        id = "Sapphire_Debug",
        title = "Sapphire_debug_title",
        desc = "Sapphire_debug_desc",
        callback = callback_id,
        value = Sapphire.Settings.Debug,
        menu_id = menu_id,
        priority = 995
    })

    MenuHelper:AddDivider({
        id = "Sapphire_div_core",
        size = 16,
        menu_id = menu_id,
        priority = 900
    })

    -- ========================================================
    -- CARRY & MOVEMENT (priority 700-899)
    -- ========================================================
    MenuHelper:AddButton({
        id = "Sapphire_header_carry",
        title = "Sapphire_header_carry_title",
        desc = "Sapphire_header_carry_desc",
        callback = dummy_callback_id,
        menu_id = menu_id,
        priority = 899
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AlwaysSprint",
        title = "Sapphire_always_sprint_title",
        desc = "Sapphire_always_sprint_desc",
        callback = callback_id,
        value = Sapphire.Settings.AlwaysSprint,
        menu_id = menu_id,
        priority = 898
    })

    MenuHelper:AddSlider({
        id = "Sapphire_JumpHeight",
        title = "Sapphire_jump_height_title",
        desc = "Sapphire_jump_height_desc",
        callback = callback_id,
        value = Sapphire.Settings.JumpHeight,
        min = 0.1,
        max = 5,
        step = 0.1,
        show_value = true,
        menu_id = menu_id,
        priority = 897
    })

    MenuHelper:AddSlider({
        id = "Sapphire_ThrowDistance",
        title = "Sapphire_throw_distance_title",
        desc = "Sapphire_throw_distance_desc",
        callback = callback_id,
        value = Sapphire.Settings.ThrowDistance,
        min = 0.1,
        max = 20,
        step = 0.1,
        show_value = true,
        menu_id = menu_id,
        priority = 896
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AffectBodyBags",
        title = "Sapphire_affect_body_bags_title",
        desc = "Sapphire_affect_body_bags_desc",
        callback = callback_id,
        value = Sapphire.Settings.AffectBodyBags,
        menu_id = menu_id,
        priority = 895
    })

    MenuHelper:AddToggle({
        id = "Sapphire_IgnoreArmorPenalty",
        title = "Sapphire_ignore_armor_penalty_title",
        desc = "Sapphire_ignore_armor_penalty_desc",
        callback = callback_id,
        value = Sapphire.Settings.IgnoreArmorPenalty,
        menu_id = menu_id,
        priority = 894
    })

    MenuHelper:AddToggle({
        id = "Sapphire_NoWeaponRestrictions",
        title = "Sapphire_no_weapon_restrictions_title",
        desc = "Sapphire_no_weapon_restrictions_desc",
        callback = callback_id,
        value = Sapphire.Settings.NoWeaponRestrictions,
        menu_id = menu_id,
        priority = 893
    })

    MenuHelper:AddToggle({
        id = "Sapphire_OmnidirectionalSprint",
        title = "Sapphire_omnidirectional_sprint_title",
        desc = "Sapphire_omnidirectional_sprint_desc",
        callback = callback_id,
        value = Sapphire.Settings.OmnidirectionalSprint,
        menu_id = menu_id,
        priority = 892
    })

    MenuHelper:AddDivider({
        id = "Sapphire_div_carry",
        size = 16,
        menu_id = menu_id,
        priority = 700
    })

    -- ========================================================
    -- QUALITY OF LIFE (priority 500-699)
    -- ========================================================
    MenuHelper:AddButton({
        id = "Sapphire_header_qol",
        title = "Sapphire_header_qol_title",
        desc = "Sapphire_header_qol_desc",
        callback = dummy_callback_id,
        menu_id = menu_id,
        priority = 699
    })

    MenuHelper:AddSlider({
        id = "Sapphire_InteractionSpeedReduction",
        title = "Sapphire_interaction_speed_reduction_title",
        desc = "Sapphire_interaction_speed_reduction_desc",
        callback = callback_id,
        value = Sapphire.Settings.InteractionSpeedReduction,
        min = 0,
        max = 100,
        step = 5,
        show_value = true,
        menu_id = menu_id,
        priority = 698
    })

    MenuHelper:AddToggle({
        id = "Sapphire_InfiniteStamina",
        title = "Sapphire_infinite_stamina_title",
        desc = "Sapphire_infinite_stamina_desc",
        callback = callback_id,
        value = Sapphire.Settings.InfiniteStamina,
        menu_id = menu_id,
        priority = 697
    })

    MenuHelper:AddSlider({
        id = "Sapphire_BagDamageReduction",
        title = "Sapphire_bag_damage_reduction_title",
        desc = "Sapphire_bag_damage_reduction_desc",
        callback = callback_id,
        value = Sapphire.Settings.BagDamageReduction,
        min = 0,
        max = 100,
        step = 1,
        show_value = true,
        menu_id = menu_id,
        priority = 696
    })

    MenuHelper:AddToggle({
        id = "Sapphire_GodMode",
        title = "Sapphire_god_mode_title",
        desc = "Sapphire_god_mode_desc",
        callback = callback_id,
        value = Sapphire.Settings.GodMode,
        menu_id = menu_id,
        priority = 695.5
    })

    MenuHelper:AddToggle({
        id = "Sapphire_NoFallDamage",
        title = "Sapphire_no_fall_damage_title",
        desc = "Sapphire_no_fall_damage_desc",
        callback = callback_id,
        value = Sapphire.Settings.NoFallDamage,
        menu_id = menu_id,
        priority = 695
    })

    MenuHelper:AddSlider({
        id = "Sapphire_ExtendedInteract",
        title = "Sapphire_extended_interact_title",
        desc = "Sapphire_extended_interact_desc",
        callback = callback_id,
        value = Sapphire.Settings.ExtendedInteract,
        min = 1.0,
        max = 5.0,
        step = 0.5,
        show_value = true,
        menu_id = menu_id,
        priority = 694
    })

    MenuHelper:AddToggle({
        id = "Sapphire_DrillNoJams",
        title = "Sapphire_drill_no_jams_title",
        desc = "Sapphire_drill_no_jams_desc",
        callback = callback_id,
        value = Sapphire.Settings.DrillNoJams,
        menu_id = menu_id,
        priority = 693
    })

    MenuHelper:AddToggle({
        id = "Sapphire_InstantDrills",
        title = "Sapphire_instant_drills_title",
        desc = "Sapphire_instant_drills_desc",
        callback = callback_id,
        value = Sapphire.Settings.InstantDrills,
        menu_id = menu_id,
        priority = 692
    })

    MenuHelper:AddDivider({
        id = "Sapphire_div_qol",
        size = 16,
        menu_id = menu_id,
        priority = 500
    })

    -- ========================================================
    -- STEALTH TOOLS (priority 300-499)
    -- ========================================================
    MenuHelper:AddButton({
        id = "Sapphire_header_stealth",
        title = "Sapphire_header_stealth_title",
        desc = "Sapphire_header_stealth_desc",
        callback = dummy_callback_id,
        menu_id = menu_id,
        priority = 499
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AICantAlarm",
        title = "Sapphire_ai_cant_alarm_title",
        desc = "Sapphire_ai_cant_alarm_desc",
        callback = callback_id,
        value = Sapphire.Settings.AICantAlarm,
        menu_id = menu_id,
        priority = 498
    })

    MenuHelper:AddToggle({
        id = "Sapphire_MultiPickup",
        title = "Sapphire_multi_pickup_title",
        desc = "Sapphire_multi_pickup_desc",
        callback = callback_id,
        value = Sapphire.Settings.MultiPickup,
        menu_id = menu_id,
        priority = 497
    })

    MenuHelper:AddToggle({
        id = "Sapphire_InfiniteCameraLoop",
        title = "Sapphire_infinite_camera_loop_title",
        desc = "Sapphire_infinite_camera_loop_desc",
        callback = callback_id,
        value = Sapphire.Settings.InfiniteCameraLoop,
        menu_id = menu_id,
        priority = 496
    })

    MenuHelper:AddToggle({
        id = "Sapphire_MinDetectionRisk",
        title = "Sapphire_min_detection_risk_title",
        desc = "Sapphire_min_detection_risk_desc",
        callback = callback_id,
        value = Sapphire.Settings.MinDetectionRisk,
        menu_id = menu_id,
        priority = 495
    })

    MenuHelper:AddToggle({
        id = "Sapphire_RandomPagers",
        title = "Sapphire_random_pagers_title",
        desc = "Sapphire_random_pagers_desc",
        callback = callback_id,
        value = Sapphire.Settings.RandomPagers,
        menu_id = menu_id,
        priority = 494
    })

    MenuHelper:AddSlider({
        id = "Sapphire_RandomPagerChance",
        title = "Sapphire_random_pager_chance_title",
        desc = "Sapphire_random_pager_chance_desc",
        callback = callback_id,
        value = Sapphire.Settings.RandomPagerChance,
        min = 1,
        max = 100,
        step = 1,
        show_value = true,
        menu_id = menu_id,
        priority = 493
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AutoAnswerPagers",
        title = "Sapphire_auto_answer_pagers_title",
        desc = "Sapphire_auto_answer_pagers_desc",
        callback = callback_id,
        value = Sapphire.Settings.AutoAnswerPagers,
        menu_id = menu_id,
        priority = 492
    })

    MenuHelper:AddDivider({
        id = "Sapphire_div_stealth",
        size = 16,
        menu_id = menu_id,
        priority = 300
    })

    -- ========================================================
    -- EXTRAS (priority 100-299)
    -- ========================================================
    MenuHelper:AddButton({
        id = "Sapphire_header_extras",
        title = "Sapphire_header_extras_title",
        desc = "Sapphire_header_extras_desc",
        callback = dummy_callback_id,
        menu_id = menu_id,
        priority = 299
    })

    MenuHelper:AddToggle({
        id = "Sapphire_UnlockDLCHeists",
        title = "Sapphire_unlock_dlc_heists_title",
        desc = "Sapphire_unlock_dlc_heists_desc",
        callback = callback_id,
        value = Sapphire.Settings.UnlockDLCHeists,
        menu_id = menu_id,
        priority = 298
    })

    MenuHelper:AddToggle({
        id = "Sapphire_UnlimitedFavors",
        title = "Sapphire_unlimited_favors_title",
        desc = "Sapphire_unlimited_favors_desc",
        callback = callback_id,
        value = Sapphire.Settings.UnlimitedFavors,
        menu_id = menu_id,
        priority = 297
    })
end)

-- ============================================================
-- MENU BUILD
-- ============================================================

Hooks:Add("MenuManagerBuildCustomMenus", "Sapphire_MenuBuild", function(menu_manager, nodes)
    if MenuHelper == nil then
        Sapphire:Log("MenuHelper is unavailable during build.")
        return
    end

    nodes[menu_id] = MenuHelper:BuildMenu(menu_id)

    if nodes.blt_options then
        MenuHelper:AddMenuItem(nodes.blt_options, menu_id, "Sapphire_menu_title", "Sapphire_menu_desc")
    elseif nodes.options then
        MenuHelper:AddMenuItem(nodes.options, menu_id, "Sapphire_menu_title", "Sapphire_menu_desc")
    else
        Sapphire:Log("No compatible parent menu node found for Sapphire+ options.")
    end
end)
