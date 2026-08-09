# Sapphire+ Developer Guide: How to Add New Features

This guide documents the architecture, lifecycle, research methodology, and exact step-by-step pipeline for adding any new feature to **Sapphire+**. When starting a new conversation or working with another AI assistant, referencing this document ensures consistent, clean, and bug-free feature implementations.

---

## 1. Architectural Overview

Sapphire+ is built on **SuperBLT** for PAYDAY 2. It follows a modular, defensive design:

```
Sapphire+
├── core.lua               # Global namespace (Sapphire table), logger, init
├── mod.txt                # SuperBLT manifest (metadata, hook registrations, keybinds)
├── settings.json          # User-persisted configuration (JSON)
├── dlcs-to-unlock.txt     # External plain-text config list for DLC management
├── libs/
│   ├── Config.lua         # DefaultSettings table, JSON serialization, SetSetting
│   └── Utils.lua          # Normalization, IsHost, SafeMode logic, EffectiveSettings
├── logs/
│   ├── FunctionsDump.txt  # Local dump of live in-game class functions
│   ├── playermanager.lua  # Full decompiled reference of PlayerManager
│   └── Sapphire+.log      # Runtime debug logs created by Sapphire:Log()
├── keybinds/
│   └── ToggleEnabled.lua  # In-game hotkey action scripts
└── hooks/
    ├── MenuManager.lua    # In-game menu UI, localization, slider/toggle widgets
    ├── PlayerManager.lua  # Carry stats, bag throwing, interaction hooks
    ├── CarryTweakData.lua # Carry weights, speeds, jump multipliers
    ├── CopBrain.lua       # AI alert & detection overrides
    ├── InteractionExt.lua # Range multiplier, instant interaction, blockers
    ├── UnlimitedFavors.lua# Pre-planning budget & cost overrides
    ├── MultiPickup.lua    # Consumable specials stacking (keycards, planks, C4)
    ├── InfiniteCameraLoop.lua # Camera loop duration override (99,999s)
    └── MinDetectionRisk.lua   # Concealment & suspicion offset override (Risk 3)
```

### The Effective Settings Pattern (`Sapphire:GetEffectiveSettings()`)
Hooks should **never** read `Sapphire.Settings` directly. Always call `local effective = Sapphire:GetEffectiveSettings()`:
- Automatically handles the master **Enable/Disable** toggle.
- Automatically handles **Safe Mode**: When you join another player's lobby as a client, gameplay-breaking cheats are neutralized to prevent anti-cheat triggers or disruptive desyncs.
- Allows features to be toggled **live during a heist** without requiring a game restart.

---

## 2. Pre-Implementation Research: When & Where to Search

In PAYDAY 2 modding, original Lua source files are compiled inside game engine packages. **Never guess function names, file paths, or table structures**—if a path is wrong, SuperBLT will silently fail to load the hook with zero crash logs.

### The 5 Research Triggers
Before writing any plan or code, research the game engine if any of these triggers apply:

1. **Hook Path Verification (`mod.txt`)**:
   - *Trigger:* Registering a new class hook.
   - *Example:* Assuming `SecurityCamera` was at `lib/units/cameras/securitycamera` (silent fail). Research revealed the real path is `lib/units/props/securitycamera`.
2. **Vanilla Data Structure Inspection (`tweak_data`)**:
   - *Trigger:* Checking if a field exists on vanilla items.
   - *Example:* Assuming keycards have `data.quantity = 1`. In vanilla, `bank_manager_key` has `quantity = nil`. Checking `if data.quantity` skipped keycards entirely.
3. **Execution Chain & Hidden Gate Discovery**:
   - *Trigger:* An action fails even after hooking the main manager.
   - *Example:* Keycard pickup was blocked by `BaseInteractionExt:can_select()` before `PlayerManager:can_pickup_equipment()` was ever reached.
4. **Hard-Coded Engine Limits & Value Floors**:
   - *Trigger:* Modifying numerical game mechanics.
   - *Example:* Detection risk has an engine floor of `3` (`suspicion_offset = 0.0`). Forcing 0 causes math errors.
5. **Third-Party Mod Compatibility (HUDs, EHI)**:
   - *Trigger:* A feature must reflect in popular HUDs like Extra Heist Info (EHI) or VanillaHUD Plus.
   - *Example:* EHI reads `tweak_data.upgrades.values.player.tape_loop_duration`. Overriding only the camera method left EHI displaying vanilla timers.

---

### Local References & Live Function Dumps (`logs/`)

Before searching online, check the local repository files in `logs/`:

- **`logs/FunctionsDump.txt`**: A live runtime dump of class methods in the running game (e.g., `PlayerManager`). You can search this file locally to verify if a method exists on a class without needing internet access.
- **`logs/playermanager.lua`**: The full local decompiled reference for `PlayerManager`. Contains `add_special`, `remove_special`, `can_pickup_equipment`, `has_special_equipment`, etc.
- **`logs/Sapphire+.log`**: The active debug log. Review this to confirm when your hooks load and what values they receive during gameplay.

#### How to Dump Any Game Class Live In-Game
If you need to inspect an unverified game class at runtime, paste this snippet into your hook file temporarily:

```lua
-- Dump any class methods to logs/FunctionsDump.txt
local file = io.open(ModPath .. "logs/FunctionsDump.txt", "a")
if file and TargetClass then
    file:write("\n====================================\n")
    file:write("Dumping class: TargetClass\n")
    file:write("====================================\n")
    for k, v in pairs(TargetClass) do
        file:write(tostring(k) .. " (" .. type(v) .. ")\n")
    end
    file:close()
end
```

---

### Primary Online Code Repositories & Knowledgebases

| Resource | Purpose | URL / Path |
|---|---|---|
| **Payday-2-LuaJIT-Complete (GitHub)** | Decompiled PAYDAY 2 game source files (`lib/managers/`, `lib/units/`, `lib/tweak_data/`) | `https://github.com/steam-test1/Payday-2-LuaJIT-Complete` |
| **mwSora / payday-2-luajit (GitHub)** | Alternative up-to-date decompiled Lua archive | `https://github.com/mwSora/payday-2-luajit` |
| **SuperBLT Documentation** | SuperBLT hook APIs, hooks schema, keybinds | `https://superblt.znix.xyz/` |
| **ModWorkshop PAYDAY 2** | Community mod reference and hook conventions | `https://modworkshop.net/` |
| **UnknownCheats PAYDAY 2 Lua Archive** | Reference for internal function names, engine hooks, and quirks | `https://www.unknowncheats.me/forum/payday-2/` |

### Proven Search Query Templates

```
# Finding exact decompiled function definitions:
"function <ClassName>:<method_name>" "PAYDAY 2" lua decompiled

# Finding exact SuperBLT hook file paths:
site:github.com/steam-test1/Payday-2-LuaJIT-Complete "<classname>.lua"

# Finding how other mods implement a specific mechanic:
"<feature name>" "PAYDAY 2" mod lua source code

# Inspecting tweak data tables:
"tweak_data.<category>" "<entry_name>" lua payday 2
```

---

## 3. Hooking Techniques: Which Pattern to Use

SuperBLT gives you 3 ways to intercept game functions:

| Pattern | Best Used For | Can Change Return Value? | Can Bypass Vanilla Code? |
|---|---|---|---|
| **Direct Function Override** | Altering return values, calculations, blocking/bypassing game logic | **YES** | **YES** |
| **`Hooks:PreHook`** | Inspecting/preparing arguments or setting up data before the game runs | NO | NO |
| **`Hooks:PostHook`** | Running additional side-effects or logging after game method finishes | NO | NO |

### Standard Direct Override Template (Recommended for most features):
```lua
if TargetClass then
    local orig_func = TargetClass.func
    if orig_func then
        function TargetClass:func(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MyFeature then
                return custom_value -- Override return value
            end
            return orig_func(self, ...) -- Fallback to vanilla
        end
    end
end
```

---

## 4. The 5-Step Pipeline to Add a Feature

Whenever you add a new feature (e.g. `MyNewFeature`), update **5 files in sequence**:

```
Step 1: libs/Config.lua       → Define default value
Step 2: libs/Utils.lua        → Normalize value + map to GetEffectiveSettings + Safe Mode
Step 3: hooks/MyNewFeature.lua→ Implement core Lua hook/override logic
Step 4: mod.txt               → Register hook file to the game's class path
Step 5: hooks/MenuManager.lua → Add menu toggle/slider + localized text
```

---

### Step 1: Register Setting Default in `libs/Config.lua`

Add your setting key to `Sapphire.DefaultSettings`:

```lua
-- libs/Config.lua
Sapphire.DefaultSettings = {
    -- ... existing settings ...
    MyNewFeature = false -- or default numeric value, e.g., 1.0
}
```

---

### Step 2: Normalization & Safe Mode in `libs/Utils.lua`

1. In `Sapphire:NormalizeSettings()`:
   ```lua
   -- For booleans:
   self.Settings.MyNewFeature = self.Settings.MyNewFeature == true
   -- For numbers / sliders:
   self.Settings.MyNewFeature = self:ClampNumber(self.Settings.MyNewFeature, min_val, max_val, default_val)
   ```

2. In `Sapphire:GetEffectiveSettings()`:
   ```lua
   -- Add to the effective table:
   MyNewFeature = self.Settings.MyNewFeature,
   ```

3. In `safe_mode_active` block:
   ```lua
   -- If this feature should be disabled in multiplayer client lobbies:
   effective.MyNewFeature = false -- or capped safe value
   ```

---

### Step 3: Implement Core Hook in `hooks/MyNewFeature.lua`

Create a new file in `hooks/`:

```lua
-- hooks/MyNewFeature.lua
dofile(ModPath .. "core.lua")

Sapphire:Log("MyNewFeature hook loaded.")

if TargetClass then
    local orig_target_function = TargetClass.target_function
    if orig_target_function then
        function TargetClass:target_function(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MyNewFeature then
                return modified_value
            end
            return orig_target_function(self, ...)
        end
    end

    Sapphire:Log("MyNewFeature: TargetClass overrides applied.")
end
```

---

### Step 4: Register Hook in `mod.txt`

Add the hook entry under the `"hooks"` array:

```json
{
    "hook_id": "lib/path/to/game_file",
    "script_path": "hooks/MyNewFeature.lua"
}
```

---

### Step 5: Add Menu UI & Localization in `hooks/MenuManager.lua`

1. **Add to `setting_keys` table**:
   ```lua
   Sapphire_MyNewFeature = "MyNewFeature",
   ```

2. **Add to `parse_item_value`**:
   - If boolean: add `key == "MyNewFeature" or`
   - If slider/number: it automatically parses via `tonumber(item:value())`

3. **Add localization strings in `LocalizationManagerPostInit`**:
   ```lua
   Sapphire_my_new_feature_title = "My New Feature Title",
   Sapphire_my_new_feature_desc  = "Clear description of what this does. (Disabled in Safe Mode)",
   ```

4. **Add UI widget in `MenuManagerPopulateCustomMenus`**:
   - **For a Toggle**:
     ```lua
     MenuHelper:AddToggle({
         id = "Sapphire_MyNewFeature",
         title = "Sapphire_my_new_feature_title",
         desc = "Sapphire_my_new_feature_desc",
         callback = callback_id,
         value = Sapphire.Settings.MyNewFeature,
         menu_id = menu_id,
         priority = 490 -- Assign priority based on section ordering
     })
     ```
   - **For a Slider**:
     ```lua
     MenuHelper:AddSlider({
         id = "Sapphire_MyNewFeature",
         title = "Sapphire_my_new_feature_title",
         desc = "Sapphire_my_new_feature_desc",
         callback = callback_id,
         value = Sapphire.Settings.MyNewFeature,
         min = 1.0,
         max = 10.0,
         step = 0.5,
         show_value = true,
         menu_id = menu_id,
         priority = 489
     })
     ```

---

## 5. How to Add a Custom Keybind (Hotkey)

If a feature needs an in-game keybind (configurable in **Options > Mod Keybinds**):

1. **Create the keybind script in `keybinds/<ActionName>.lua`**:
   ```lua
   dofile(ModPath .. "core.lua")
   -- Example: Toggle a setting
   Sapphire:SetSetting("MyNewFeature", not Sapphire.Settings.MyNewFeature)
   ```

2. **Register in `mod.txt` under `"keybinds"`**:
   ```json
   {
       "keybind_id": "Sapphire_my_action",
       "name": "Toggle My Feature",
       "description": "Quickly toggle my feature with a hotkey.",
       "script_path": "keybinds/MyAction.lua",
       "run_in_menu": false,
       "run_in_game": true,
       "localized": false
   }
   ```

---

## 6. SuperBLT Utilities Reference

### DelayedCalls (Running Code After Level/Game Load)
To run code safely after level geometry and entities have finished loading:
```lua
DelayedCalls:Add("UniqueCallID", delay_in_seconds, function()
    -- Code to execute after delay (e.g. 0.1s or 1.0s)
end)
```

### Reading External Text Files (`ModPath .. "filename.txt"`)
To read external config files (like `dlcs-to-unlock.txt`):
```lua
local file = io.open(ModPath .. "filename.txt", "r")
if file then
    for line in file:lines() do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not trimmed:match("^#") then
            -- Process item
        end
    end
    file:close()
end
```

---

## 7. PAYDAY 2 SuperBLT Hook Paths Reference

| Game System | Internal Class | SuperBLT `hook_id` | Common Methods / Notes |
|---|---|---|---|
| **Player Equipment & Carry** | `PlayerManager` | `lib/managers/playermanager` | `add_special`, `remove_special`, `can_pickup_equipment` |
| **Black Market / Concealment** | `BlackMarketManager` | `lib/managers/blackmarketmanager` | `get_suspicion_offset_of_local`, `get_real_armor_concealment` |
| **Pre-planning & Favors** | `PrePlanningManager` | `lib/managers/preplanningmanager` | `get_type_budget_cost`, `can_reserve_mission_element` |
| **Money & Purchases** | `MoneyManager` | `lib/managers/moneymanager` | `get_preplanning_type_cost`, `can_afford_preplanning_type` |
| **Security Cameras** | `SecurityCamera` | `lib/units/props/securitycamera` | `_start_tape_loop`, `_start_tape_loop_by_upgrade_level` *(Note: in props, not cameras)* |
| **World Interactions** | `BaseInteractionExt` | `lib/units/interactions/interactionext` | `can_select`, `can_interact`, `_get_timer`, `interact_distance` |
| **Enemy AI & Detection** | `CopBrain` / `GroupAI` | `lib/units/enemies/cop/copbrain`<br>`lib/managers/group_ai_states/groupaistatebase` | `clbk_death`, `on_alarm_pager_interaction`, `register_cop` |
| **Player Movement** | `PlayerMovement` / `PlayerStandard` | `lib/units/beings/player/playermovement`<br>`lib/units/beings/player/states/playerstandard` | Speed modifiers, stamina consumption, fall damage |
| **Player Damage & Health** | `PlayerDamage` | `lib/units/beings/player/playerdamage` | `damage_bullet`, `damage_fall`, damage absorption |
| **DLC Ownership** | `DLCManager` | `lib/managers/dlcmanager` | `is_dlc_unlocked`, `has_dlc` |
| **Carry Tweak Data** | `CarryTweakData` | `lib/tweak_data/carrytweakdata` | `tweak_data.carry.types` definitions |

---

## 8. Menu Organization & Priority Reference

The single-page menu in `MenuManager.lua` uses `priority` values (higher = appears earlier) to structure categories without sub-menus:

| Category | Priority Range | Header Identifier |
|---|---|---|
| **Core Settings** | `900 - 999` | `Sapphire_header_core` (`priority = 999`) |
| **Carry & Movement** | `700 - 899` | `Sapphire_header_carry` (`priority = 899`) |
| **Quality of Life** | `500 - 699` | `Sapphire_header_qol` (`priority = 699`) |
| **Stealth Tools** | `300 - 499` | `Sapphire_header_stealth` (`priority = 499`) |
| **Extras** | `100 - 299` | `Sapphire_header_extras` (`priority = 299`) |

---

---

## 9. Updating the Showcase Website & Devlog (`docs/`)

Whenever you release an update or add features, updating the website is a 1-step edit:

1. **Add a Devlog Entry in `docs/app.js`**:
   Add a new object at the top of the `devlogs` array:
   ```javascript
   {
       version: "v0.6.0",
       isLatest: true, // Auto-updates the navbar version badge
       tag: "Heist & Stealth Expansion",
       items: [
           { label: "Feature Name", desc: "Short description of what was added or fixed." },
           { label: "Another Feature", desc: "Details about the change." }
       ]
   }
   ```
2. **Add to Feature Grid in `docs/app.js` (Optional)**:
   Add any new feature card to the `features` array in `docs/app.js`. The website will automatically render the card and filter tabs.

---

## 10. Summary Checklist for Any New Feature

- [ ] Researched decompiled source on `Payday-2-LuaJIT-Complete` or modding archive for real class signatures.
- [ ] Checked `logs/FunctionsDump.txt` or `logs/playermanager.lua` for local verified methods.
- [ ] Added default key/value to `Sapphire.DefaultSettings` in `libs/Config.lua`.
- [ ] Added normalization to `Sapphire:NormalizeSettings()` in `libs/Utils.lua`.
- [ ] Added mapping to `Sapphire:GetEffectiveSettings()` in `libs/Utils.lua`.
- [ ] Checked whether the feature should be capped or disabled in `Safe Mode`.
- [ ] Created `hooks/<FeatureName>.lua` with safe override patterns.
- [ ] Verified correct SuperBLT `hook_id` in `mod.txt`.
- [ ] Added localization string keys in `hooks/MenuManager.lua`.
- [ ] Added UI widget (`MenuHelper:AddToggle` or `AddSlider`) with correct priority.
- [ ] Added keybind in `mod.txt` and `keybinds/` if a hotkey is desired.
- [ ] (Optional) Added release entry to `devlogs` in `docs/app.js`.
- [ ] Tested live in-game: toggle on/off, host vs client behavior, and persistence after restart.
