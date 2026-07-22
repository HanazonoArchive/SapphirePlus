dofile(ModPath .. "core.lua")

local menu_id = "Sapphire_options_menu"
local callback_id = "Sapphire_MenuSettingChanged"
local menu_populated = false

-- MenuHelper sorts items by their localized display title alphabetically.
-- The [N] prefix scheme in each title naturally groups settings:
--   [1]-[3]      = Core
--   [4]-[4F]     = Movement & Carry
--   [5],[Extra]  = Extras
--   [Pager]      = Random Pagers
local setting_keys = {
    Sapphire_Enabled           = "Enabled",
    Sapphire_SafeMode          = "SafeMode",
    Sapphire_ForceSafeModeHost = "ForceSafeModeHost",
    Sapphire_Debug             = "Debug",
    Sapphire_AlwaysSprint      = "AlwaysSprint",
    Sapphire_JumpHeight        = "JumpHeight",
    Sapphire_ThrowDistance     = "ThrowDistance",
    Sapphire_AffectBodyBags    = "AffectBodyBags",
    Sapphire_NoInteractionCooldown = "NoInteractionCooldown",
    Sapphire_InfiniteStamina   = "InfiniteStamina",
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
}

local function parse_item_value(item, key)
    if key == "Debug" or key == "AlwaysSprint" or key == "Enabled" or key == "SafeMode" or
       key == "ForceSafeModeHost" or key == "NoInteractionCooldown" or
       key == "RandomPagers" or key == "InfiniteStamina" or
       key == "AutoAnswerPagers" or key == "NoFallDamage" or key == "IgnoreArmorPenalty" or
       key == "AffectBodyBags" or key == "NoWeaponRestrictions" or key == "AICantAlarm" or key == "UnlockDLCHeists" then
        return item:value() == "on"
    end

    return tonumber(item:value()) or Sapphire.DefaultSettings[key]
end

Hooks:Add("LocalizationManagerPostInit", "Sapphire_Localization", function(loc)
    loc:add_localized_strings({
        Sapphire_menu_title = "Sapphire+ Options",
        Sapphire_menu_desc  = "Configure Sapphire+ behavior and save settings.",

        -- [1]-[3] Core
        Sapphire_enabled_title = "[1] Enable Sapphire+",
        Sapphire_enabled_desc  = "Master toggle for all Sapphire+ effects.",

        Sapphire_safe_mode_title = "[2A] Safe Mode (Multiplayer)",
        Sapphire_safe_mode_desc  = "Automatically cap settings when joining other lobbies.",

        Sapphire_force_safe_mode_host_title = "[2B] Force Safe Mode (Host)",
        Sapphire_force_safe_mode_host_desc  = "Apply Safe Mode restrictions even when you are the host.",

        Sapphire_debug_title = "[3] Debug Logging",
        Sapphire_debug_desc  = "Enable or disable Sapphire+ debug logging.",

        -- [4]-[4F] Movement & Carry
        Sapphire_always_sprint_title = "[4A] Always Sprint With Carry",
        Sapphire_always_sprint_desc  = "Allow sprinting while carrying bags.",

        Sapphire_jump_height_title = "[4B] Carry Jump Height",
        Sapphire_jump_height_desc  = "Jump strength multiplier while carrying.",

        Sapphire_throw_distance_title = "[4C] Carry Throw Distance",
        Sapphire_throw_distance_desc  = "Throw distance multiplier for carried bags.",

        Sapphire_affect_body_bags_title = "[4D] Affect Body Bags",
        Sapphire_affect_body_bags_desc  = "Apply carry speed and distance tweaks to body bags.",

        -- [5] + [Extra] Extras
        Sapphire_no_interaction_cd_title = "[5] No Interaction Timer",
        Sapphire_no_interaction_cd_desc  = "Removes interaction timer.",

        Sapphire_infinite_stamina_title = "[Extra - A1] Infinite Stamina With Carry",
        Sapphire_infinite_stamina_desc  = "Sprint infinitely while carrying a bag.",

        Sapphire_bag_damage_reduction_title = "[Extra - A2] Bag Shield (%)",
        Sapphire_bag_damage_reduction_desc  = "Percentage of damage to ignore while carrying a bag (0 = none, 100 = invincible).",

        Sapphire_no_fall_damage_title = "[Extra - B2] No Fall Damage",
        Sapphire_no_fall_damage_desc  = "You will not take any fall damage.",

        Sapphire_extended_interact_title = "[Extra - B3] Interaction Range Multiplier",
        Sapphire_extended_interact_desc  = "Multiplier for your interaction distance (useful for catching bags).",

        Sapphire_ignore_armor_penalty_title = "[Extra - B4] Ignore Armor Speed Penalty",
        Sapphire_ignore_armor_penalty_desc  = "Wearing heavy armor no longer slows you down.",

        Sapphire_no_weapon_restrictions_title = "[Extra - C2] No Weapon Restrictions",
        Sapphire_no_weapon_restrictions_desc  = "Allows you to use primary weapons while carrying heavy bags.",

        Sapphire_ai_cant_alarm_title = "[Extra - S1] AI Can't Alarm",
        Sapphire_ai_cant_alarm_desc  = "Enemies can detect you and fight, but they cannot call the police to trigger a loud heist.",

        -- [Pager] Pagers
        Sapphire_random_pagers_title = "[Pager - 1] Random Pagers",
        Sapphire_random_pagers_desc  = "Randomly remove alarm pagers from security guards.",

        Sapphire_random_pager_chance_title = "[Pager - 2] No Pager Chance (%)",
        Sapphire_random_pager_chance_desc  = "Percentage chance that a guard has no pager.",

        Sapphire_auto_answer_pagers_title = "[Pager - 3] Auto-Answer Pagers",
        Sapphire_auto_answer_pagers_desc  = "Automatically answers any pagers that spawn.",

        -- [DLC] DLC Management
        Sapphire_unlock_dlc_heists_title = "[DLC - 1] Unlock DLC Heists",
        Sapphire_unlock_dlc_heists_desc  = "Unlocks specific DLC heists listed in dlcs-to-unlock.txt (Requires a game restart to take effect).",
    })
end)

Hooks:Add("MenuManagerSetupCustomMenus", "Sapphire_MenuSetup", function(menu_manager, nodes)
    if MenuHelper == nil then
        Sapphire:Log("MenuHelper is unavailable during setup.")
        return
    end
    MenuHelper:NewMenu(menu_id)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "Sapphire_MenuPopulate", function(menu_manager, nodes)
    if MenuHelper == nil then
        Sapphire:Log("MenuHelper is unavailable during populate.")
        return
    end

    if menu_populated then
        return
    end
    menu_populated = true

    MenuCallbackHandler[callback_id] = function(_, item)
        local item_name = item:name()
        local option_key = setting_keys[item_name]

        if option_key ~= nil then
            local option_value = parse_item_value(item, option_key)
            Sapphire:SetSetting(option_key, option_value)
            
            -- LIVE UPDATE: Apply changes to CarryTweakData immediately so sliders work mid-heist
            if tweak_data and tweak_data.carry and tweak_data.carry.types then
                local effective = Sapphire:GetEffectiveSettings()
                for id, data in pairs(tweak_data.carry.types) do
                    -- If the setting is disabled, or it's a body bag and AffectBodyBags is false, restore vanilla
                    if not effective.Enabled or (id == "person" and not effective.AffectBodyBags) then
                        if Sapphire.VanillaCarryTypes and Sapphire.VanillaCarryTypes[id] then
                            local vanilla = Sapphire.VanillaCarryTypes[id]
                            data.move_speed_modifier = vanilla.move_speed_modifier
                            data.sprint_speed_modifier = vanilla.sprint_speed_modifier
                            data.jump_modifier = vanilla.jump_modifier
                            data.throw_distance_multiplier = vanilla.throw_distance_multiplier
                            data.can_run = vanilla.can_run
                        end
                    else
                        -- Apply Carry++ active modifiers
                        data.move_speed_modifier = 1.0
                        data.sprint_speed_modifier = 1.0
                        data.jump_modifier = effective.JumpHeight
                        data.throw_distance_multiplier = effective.ThrowDistance
                        
                        if effective.AlwaysSprint then
                            data.can_run = true
                        else
                            if Sapphire.VanillaCarryTypes and Sapphire.VanillaCarryTypes[id] then
                                data.can_run = Sapphire.VanillaCarryTypes[id].can_run
                            end
                        end
                    end
                end
            end
            return
        end

        Sapphire:Log("Unknown menu action id: " .. tostring(item_name))
    end

    MenuHelper:AddToggle({
        id = "Sapphire_Enabled",
        title = "Sapphire_enabled_title",
        desc = "Sapphire_enabled_desc",
        callback = callback_id,
        value = Sapphire.Settings.Enabled,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_SafeMode",
        title = "Sapphire_safe_mode_title",
        desc = "Sapphire_safe_mode_desc",
        callback = callback_id,
        value = Sapphire.Settings.SafeMode,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_ForceSafeModeHost",
        title = "Sapphire_force_safe_mode_host_title",
        desc = "Sapphire_force_safe_mode_host_desc",
        callback = callback_id,
        value = Sapphire.Settings.ForceSafeModeHost,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_Debug",
        title = "Sapphire_debug_title",
        desc = "Sapphire_debug_desc",
        callback = callback_id,
        value = Sapphire.Settings.Debug,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AlwaysSprint",
        title = "Sapphire_always_sprint_title",
        desc = "Sapphire_always_sprint_desc",
        callback = callback_id,
        value = Sapphire.Settings.AlwaysSprint,
        menu_id = menu_id
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
        menu_id = menu_id
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
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AffectBodyBags",
        title = "Sapphire_affect_body_bags_title",
        desc = "Sapphire_affect_body_bags_desc",
        callback = callback_id,
        value = Sapphire.Settings.AffectBodyBags,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_NoInteractionCooldown",
        title = "Sapphire_no_interaction_cd_title",
        desc = "Sapphire_no_interaction_cd_desc",
        callback = callback_id,
        value = Sapphire.Settings.NoInteractionCooldown,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_InfiniteStamina",
        title = "Sapphire_infinite_stamina_title",
        desc = "Sapphire_infinite_stamina_desc",
        callback = callback_id,
        value = Sapphire.Settings.InfiniteStamina,
        menu_id = menu_id
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
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_NoFallDamage",
        title = "Sapphire_no_fall_damage_title",
        desc = "Sapphire_no_fall_damage_desc",
        callback = callback_id,
        value = Sapphire.Settings.NoFallDamage,
        menu_id = menu_id
    })

    MenuHelper:AddSlider({
        id = "Sapphire_ExtendedInteract",
        title = "Sapphire_extended_interact_title",
        desc = "Sapphire_extended_interact_desc",
        callback = callback_id,
        value = Sapphire.Settings.ExtendedInteract,
        min = 1.0,
        max = 30.0,
        step = 0.5,
        show_value = true,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_IgnoreArmorPenalty",
        title = "Sapphire_ignore_armor_penalty_title",
        desc = "Sapphire_ignore_armor_penalty_desc",
        callback = callback_id,
        value = Sapphire.Settings.IgnoreArmorPenalty,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_NoWeaponRestrictions",
        title = "Sapphire_no_weapon_restrictions_title",
        desc = "Sapphire_no_weapon_restrictions_desc",
        callback = callback_id,
        value = Sapphire.Settings.NoWeaponRestrictions,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_RandomPagers",
        title = "Sapphire_random_pagers_title",
        desc = "Sapphire_random_pagers_desc",
        callback = callback_id,
        value = Sapphire.Settings.RandomPagers,
        menu_id = menu_id
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
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AutoAnswerPagers",
        title = "Sapphire_auto_answer_pagers_title",
        desc = "Sapphire_auto_answer_pagers_desc",
        callback = callback_id,
        value = Sapphire.Settings.AutoAnswerPagers,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_AICantAlarm",
        title = "Sapphire_ai_cant_alarm_title",
        desc = "Sapphire_ai_cant_alarm_desc",
        callback = callback_id,
        value = Sapphire.Settings.AICantAlarm,
        menu_id = menu_id
    })

    MenuHelper:AddToggle({
        id = "Sapphire_UnlockDLCHeists",
        title = "Sapphire_unlock_dlc_heists_title",
        desc = "Sapphire_unlock_dlc_heists_desc",
        callback = callback_id,
        value = Sapphire.Settings.UnlockDLCHeists,
        menu_id = menu_id
    })
end)

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
