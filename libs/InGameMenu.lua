Sapphire.InGameMenu = Sapphire.InGameMenu or {}

local InGameMenu = Sapphire.InGameMenu

InGameMenu._is_open = false
InGameMenu._selected_index = 1
InGameMenu._ws = nil
InGameMenu._panel = nil
InGameMenu._item_panels = {}

InGameMenu._items = {
    {
        id = "teleport_loot",
        num = "01",
        text = "Teleport Loot",
        type = "action",
        desc = "Opens all crates and lockers, packs all unbagged loose loot into carry bags, and ejects them forward in your line of sight.",
        action = function()
            if Sapphire.Loot and Sapphire.Loot.TeleportLoot then
                Sapphire.Loot:TeleportLoot()
            end
        end
    },
    {
        id = "secure_bagged_loot",
        num = "02",
        text = "Secure All Bagged Loot",
        type = "action",
        desc = "Instantly secures all packaged loot bags (Gold, Money, Meth, Coke, Weapons) on the ground directly into the escape zone.",
        action = function()
            if Sapphire.Loot and Sapphire.Loot.SecureAllBags then
                Sapphire.Loot:SecureAllBags()
            end
        end
    },
    {
        id = "unlock_doors",
        num = "03",
        text = "Unlock All Doors",
        type = "action",
        desc = "Instantly unlocks and opens all standard doors, security rooms, keycard readers, and iron cage gates across the heist.",
        action = function()
            if Sapphire.Doors and Sapphire.Doors.UnlockAll then
                Sapphire.Doors:UnlockAll()
            end
        end
    },
    {
        id = "auto_cooker",
        num = "04",
        text = "Auto-Cooker",
        type = "toggle",
        desc = "Automatically detects Bain and Locke's chemical instructions on meth heists (Cook Off, Rats), cooks, bags, and drops meth bags hands-free.",
        get_value = function()
            return Sapphire.Settings.AutoCooker == true
        end,
        toggle = function()
            Sapphire:SetSetting("AutoCooker", not Sapphire.Settings.AutoCooker)
        end
    },
    {
        id = "tie_civilians",
        num = "05",
        text = "Tie All Civilians",
        type = "action",
        desc = "Instantly intimidates and restrains all civilians across the map with cable ties, forcing them to the floor with cable tie limits bypassed.",
        action = function()
            if Sapphire.Civilians and Sapphire.Civilians.TieAll then
                Sapphire.Civilians:TieAll()
            end
        end
    },
    {
        id = "revive_team",
        num = "06",
        text = "Instant Team Revive",
        type = "action",
        desc = "Instantly revives yourself and all downed AI bot companions across the map. Downed remote human players must be revived by their own client, so they are intentionally skipped.",
        action = function()
            if Sapphire.Revive and Sapphire.Revive.ReviveTeam then
                Sapphire.Revive:ReviveTeam()
            end
        end
    },
    {
        id = "wipe_enemies",
        num = "07",
        text = "Wipe All Enemies",
        type = "action",
        desc = "Silently despawns all guards, Murkywater security, and cops across the map. Triggers zero pagers and leaves zero bodies.",
        action = function()
            if Sapphire.Enemies and Sapphire.Enemies.WipeAll then
                Sapphire.Enemies:WipeAll()
            end
        end
    },
    {
        id = "collect_gage",
        num = "08",
        text = "Collect All Gage Packages",
        type = "action",
        desc = "Instantly sweeps the entire map and collects every hidden Gage Courier package (Green Mantis, Yellow Bull, Red Spider, Blue Eagle, Purple Snake).",
        action = function()
            if Sapphire.Gage and Sapphire.Gage.CollectAll then
                Sapphire.Gage:CollectAll()
            end
        end
    },
    {
        id = "army_of_jokers",
        num = "09",
        text = "Army of Jokers",
        type = "action",
        desc = "Instantly converts all active cops on the map into an army of friendly criminal Jokers with minion limits completely bypassed.",
        action = function()
            if Sapphire.Jokers and Sapphire.Jokers.ConvertAll then
                Sapphire.Jokers:ConvertAll()
            end
        end
    },
    {
        id = "custody_breakout",
        num = "10",
        text = "Instant Custody Breakout",
        type = "action",
        desc = "Immediately breaks all teammates and AI companions out of custody without waiting for the police assault break timer.",
        action = function()
            if Sapphire.Custody and Sapphire.Custody.Breakout then
                Sapphire.Custody:Breakout()
            end
        end
    },
    {
        id = "clean_corpses",
        num = "11",
        text = "Clean All Corpses",
        type = "action",
        desc = "Silently despawns and cleans all dead bodies and leftover body bags across the map to prevent detection.",
        action = function()
            if Sapphire.Corpses and Sapphire.Corpses.CleanAll then
                Sapphire.Corpses:CleanAll()
            end
        end
    },
    {
        id = "restock_supplies",
        num = "12",
        text = "Restock All Supplies",
        type = "action",
        desc = "Instantly replenishes player health, armor, weapon ammunition, throwables/grenades, cable ties, and body bags to 100% maximum capacity.",
        action = function()
            if Sapphire.Supplies and Sapphire.Supplies.Restock then
                Sapphire.Supplies:Restock()
            end
        end
    },
    {
        id = "fix_speed_drills",
        num = "13",
        text = "Fix & Finish All Drills",
        type = "action",
        desc = "Instantly unjams and fast-forwards all active drills, thermal saws, timelocks, and hacking panels across the entire map.",
        action = function()
            if Sapphire.Drills and Sapphire.Drills.FixAndSpeedAll then
                Sapphire.Drills:FixAndSpeedAll()
            end
        end
    },
    {
        id = "open_deposit_boxes",
        num = "14",
        text = "Open All Deposit Boxes & ATMs",
        type = "action",
        desc = "Instantly unlocks and pops open all safe deposit boxes, ATMs, lockers, and security cages across the entire heist map.",
        action = function()
            if Sapphire.Loot and Sapphire.Loot.OpenAllDepositBoxes then
                Sapphire.Loot:OpenAllDepositBoxes()
            end
        end
    },
    {
        id = "disable_alarm_lasers",
        num = "15",
        text = "Disable All Alarm Lasers",
        type = "action",
        desc = "Instantly deactivates all mission laser triggers, tripwires, and security sensor grids across the heist map.",
        action = function()
            if Sapphire.Lasers and Sapphire.Lasers.DisableAllLasers then
                Sapphire.Lasers:DisableAllLasers()
            end
        end
    }
}

function InGameMenu:IsOpen()
    return self._is_open
end

function InGameMenu:Toggle()
    if self._is_open then
        self:Close()
    else
        self:Open()
    end
end

function InGameMenu:Open()
    if self._is_open then return end

    local effective = Sapphire:GetEffectiveSettings()
    if not effective.Enabled then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: Mod is currently disabled." })
        end
        return
    end

    self._is_open = true
    self._selected_index = 1

    -- 1. BLOCK ALL IN-GAME CHARACTER INPUT WHILE MODAL IS OPEN
    local player = managers.player and managers.player:player_unit()
    if alive(player) and player:base() and player:base().controller and player:base():controller() then
        pcall(function()
            player:base():controller():set_enabled(false)
        end)
    end

    -- 2. CREATE FULLSCREEN WORKSPACE & DARKENED BACKDROP
    self._ws = Overlay:gui():create_screen_workspace()
    local full_panel = self._ws:panel()

    self._backdrop = full_panel:rect({
        name = "backdrop",
        color = Color(0.01, 0.02, 0.03),
        alpha = 0.85,
        layer = 100
    })

    -- 3. CENTERED PREMIUM MODAL CARD
    local card_w = 600
    local card_h = 700
    local card_x = (full_panel:w() - card_w) / 2
    local card_y = (full_panel:h() - card_h) / 2

    self._panel = full_panel:panel({
        name = "sapphire_modal_card",
        x = card_x,
        y = card_y,
        w = card_w,
        h = card_h,
        layer = 1000
    })

    -- Outer Border Glow
    self._panel:rect({
        name = "border",
        color = Color(0.12, 0.65, 1.0),
        alpha = 0.6,
        layer = 1
    })

    -- Inner Card Background
    self._panel:rect({
        name = "card_bg",
        x = 2,
        y = 2,
        w = card_w - 4,
        h = card_h - 4,
        color = Color(0.04, 0.05, 0.08),
        alpha = 0.98,
        layer = 2
    })

    -- Top Cyan Neon Bar
    self._panel:rect({
        name = "neon_bar",
        x = 2,
        y = 2,
        w = card_w - 4,
        h = 3,
        color = Color(0.1, 0.8, 1.0),
        layer = 3
    })

    -- System Subtitle Tag
    self._panel:text({
        name = "sub_tag",
        text = "SAPPHIRE+ TACTICAL SYSTEM",
        font = tweak_data.menu.pd2_small_font,
        font_size = 11,
        color = Color(0.1, 0.75, 1.0),
        x = 22,
        y = 12,
        layer = 4
    })

    -- Main Header Title
    self._panel:text({
        name = "title",
        text = "MOD CONTROL INTERFACE",
        font = tweak_data.menu.pd2_large_font,
        font_size = 19,
        color = Color(0.95, 0.97, 1.0),
        x = 22,
        y = 25,
        layer = 4
    })

    -- Online Status Indicator Badge
    self._panel:text({
        name = "status_dot",
        text = "● ONLINE",
        font = tweak_data.menu.pd2_small_font,
        font_size = 12,
        color = Color(0.2, 0.9, 0.4),
        x = card_w - 95,
        y = 25,
        layer = 4
    })

    -- Header Divider
    self._panel:rect({
        name = "divider_top",
        x = 22,
        y = 50,
        w = card_w - 44,
        h = 1,
        color = Color(0.15, 0.3, 0.45),
        alpha = 0.7,
        layer = 3
    })

    -- Items Container
    local item_h = 32
    local item_gap = 2
    local total_items_h = #self._items * (item_h + item_gap)
    
    self._items_container = self._panel:panel({
        name = "items_container",
        x = 22,
        y = 56,
        w = card_w - 44,
        h = total_items_h + 5,
        layer = 4
    })

    self._item_panels = {}
    local row_y = 0
    for i, item in ipairs(self._items) do
        local row = self._items_container:panel({
            name = "row_" .. tostring(i),
            x = 0,
            y = row_y,
            w = card_w - 44,
            h = item_h
        })

        local row_bg = row:rect({
            name = "row_bg",
            color = Color(0.08, 0.35, 0.7),
            alpha = 0.0,
            layer = 1
        })

        local left_bar = row:rect({
            name = "left_bar",
            x = 0,
            y = 0,
            w = 4,
            h = item_h,
            color = Color(0.1, 0.85, 1.0),
            alpha = 0.0,
            layer = 2
        })

        local pill_badge = row:text({
            name = "pill",
            text = "[" .. item.num .. "]",
            font = tweak_data.menu.pd2_medium_font,
            font_size = 13,
            color = Color(0.1, 0.75, 1.0),
            x = 10,
            y = 6,
            layer = 3
        })

        local label = row:text({
            name = "label",
            text = item.text,
            font = tweak_data.menu.pd2_medium_font,
            font_size = 14,
            color = Color(0.75, 0.75, 0.75),
            x = 48,
            y = 5,
            layer = 3
        })

        local state_text = row:text({
            name = "state",
            text = item.type == "toggle" and "[ OFF ]" or "[ EXECUTE ]",
            font = tweak_data.menu.pd2_small_font,
            font_size = 11,
            color = Color(0.4, 0.55, 0.7),
            x = card_w - 140,
            y = 8,
            layer = 3
        })

        self._item_panels[i] = {
            row = row,
            bg = row_bg,
            left_bar = left_bar,
            pill = pill_badge,
            label = label,
            state = state_text
        }
        row_y = row_y + item_h + item_gap
    end

    -- Description Box Panel
    local desc_y = 56 + total_items_h + 8
    local desc_box = self._panel:panel({
        name = "desc_box",
        x = 22,
        y = desc_y,
        w = card_w - 44,
        h = 60,
        layer = 3
    })

    desc_box:rect({
        name = "desc_bg",
        color = Color(0.02, 0.03, 0.05),
        alpha = 0.8,
        layer = 1
    })

    desc_box:rect({
        name = "desc_border",
        color = Color(0.1, 0.2, 0.3),
        alpha = 0.5,
        layer = 2
    })

    self._desc_text = desc_box:text({
        name = "desc_content",
        text = "",
        font = tweak_data.menu.pd2_small_font,
        font_size = 12,
        color = Color(0.7, 0.8, 0.9),
        x = 10,
        y = 8,
        w = card_w - 64,
        h = 44,
        wrap = true,
        word_wrap = true,
        layer = 3
    })

    -- Footer Divider
    local divider_b_y = desc_y + 68
    self._panel:rect({
        name = "divider_bottom",
        x = 22,
        y = divider_b_y,
        w = card_w - 44,
        h = 1,
        color = Color(0.15, 0.3, 0.45),
        alpha = 0.5,
        layer = 3
    })

    -- Navigation Hotkey Pill Guide
    self._panel:text({
        name = "footer_nav",
        text = "[UP/DOWN] NAVIGATE    [LEFT/RIGHT] TOGGLE    [SPACE/ENTER] EXECUTE    [ESC] RETURN",
        font = tweak_data.menu.pd2_small_font,
        font_size = 11,
        color = Color(0.4, 0.55, 0.7),
        x = 22,
        y = divider_b_y + 10,
        layer = 4
    })

    -- Connect Keyboard to modal workspace
    self._ws:connect_keyboard(Input:keyboard())
    self._panel:key_press(callback(self, self, "OnKeyPress"))

    self:UpdateSelection()
    self:PlaySound("menu_enter")
end

function InGameMenu:Close()
    if not self._is_open then return end

    -- RESTORE IN-GAME CHARACTER INPUT
    local player = managers.player and managers.player:player_unit()
    if alive(player) and player:base() and player:base().controller and player:base():controller() then
        pcall(function()
            player:base():controller():set_enabled(true)
        end)
    end

    if self._ws then
        self._ws:disconnect_keyboard()
        Overlay:gui():destroy_workspace(self._ws)
        self._ws = nil
    end

    self._panel = nil
    self._item_panels = {}
    self._is_open = false
    self:PlaySound("menu_exit")
end

function InGameMenu:UpdateSelection()
    for i, p in ipairs(self._item_panels) do
        local item = self._items[i]
        local is_sel = (i == self._selected_index)
        p.bg:set_alpha(is_sel and 0.4 or 0.0)
        p.left_bar:set_alpha(is_sel and 1.0 or 0.0)
        p.label:set_color(is_sel and Color(1.0, 1.0, 1.0) or Color(0.65, 0.65, 0.65))
        p.pill:set_color(is_sel and Color(0.1, 0.85, 1.0) or Color(0.3, 0.5, 0.7))

        if item.type == "toggle" then
            local val = item.get_value and item.get_value() or false
            p.state:set_text(val and "[ ON ]" or "[ OFF ]")
            p.state:set_color(val and Color(0.2, 0.9, 0.4) or Color(0.7, 0.4, 0.2))
        else
            p.state:set_text("[ EXECUTE ]")
            p.state:set_color(is_sel and Color(0.1, 0.85, 1.0) or Color(0.4, 0.55, 0.7))
        end
    end

    if self._desc_text and self._items[self._selected_index] then
        self._desc_text:set_text(self._items[self._selected_index].desc or "")
    end
end

function InGameMenu:SelectPrev()
    self._selected_index = self._selected_index - 1
    if self._selected_index < 1 then
        self._selected_index = #self._items
    end
    self:UpdateSelection()
    self:PlaySound("highlight")
end

function InGameMenu:SelectNext()
    self._selected_index = self._selected_index + 1
    if self._selected_index > #self._items then
        self._selected_index = 1
    end
    self:UpdateSelection()
    self:PlaySound("highlight")
end

function InGameMenu:AdjustLeft()
    local item = self._items[self._selected_index]
    if item and item.type == "toggle" and item.toggle then
        item.toggle()
        self:UpdateSelection()
        self:PlaySound("menu_enter")
    else
        self:PlaySound("highlight")
    end
end

function InGameMenu:AdjustRight()
    local item = self._items[self._selected_index]
    if item and item.type == "toggle" and item.toggle then
        item.toggle()
        self:UpdateSelection()
        self:PlaySound("menu_enter")
    else
        self:PlaySound("highlight")
    end
end

function InGameMenu:ExecuteSelected()
    local item = self._items[self._selected_index]
    if item then
        if item.type == "toggle" and item.toggle then
            item.toggle()
            self:UpdateSelection()
            self:PlaySound("menu_enter")
        elseif item.action then
            self:PlaySound("menu_skill_investment")
            local p = self._item_panels[self._selected_index]
            if p and p.bg then
                p.bg:set_color(Color(0.1, 0.8, 0.4))
                p.bg:set_alpha(0.7)
                DelayedCalls:Add("Sapphire_FlashReset", 0.15, function()
                    if p and p.bg then
                        p.bg:set_color(Color(0.08, 0.35, 0.7))
                        p.bg:set_alpha(0.4)
                    end
                end)
            end
            item.action()
        end
    end
end

function InGameMenu:OnKeyPress(o, key)
    if not self._is_open then return end

    if key == Idstring("up") then
        self:SelectPrev()
    elseif key == Idstring("down") then
        self:SelectNext()
    elseif key == Idstring("left") then
        self:AdjustLeft()
    elseif key == Idstring("right") then
        self:AdjustRight()
    elseif key == Idstring("space") or key == Idstring("enter") or key == Idstring("num enter") then
        self:ExecuteSelected()
    elseif key == Idstring("esc") or key == Idstring("escape") then
        self:Close()
    end
end

function InGameMenu:PlaySound(sound_name)
    if managers and managers.menu_component and managers.menu_component.post_event then
        pcall(function()
            managers.menu_component:post_event(sound_name)
        end)
    end
end
