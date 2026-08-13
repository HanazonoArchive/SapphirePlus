# Sapphire+ Developer Guide: How to Add New Features

This guide documents the architecture, lifecycle, research methodology, and exact step-by-step pipeline for adding any new feature or tactical action to **Sapphire+**. When starting a new conversation or working with another AI assistant, referencing this document ensures consistent, clean, and bug-free feature implementations.

---

## 1. Architectural Overview

Sapphire+ is built on **SuperBLT** for PAYDAY 2. It follows a modular, defensive design adhering to the **UNIX Philosophy** (every file does one dedicated job and does it exceptionally well):

```
SapphirePlus
├── core.lua                    # Global namespace (Sapphire table), logger, bootstrap loader
├── mod.txt                     # SuperBLT manifest (metadata, hook registrations, keybinds)
├── settings.json               # User-persisted configuration (JSON)
├── dlcs-to-unlock.txt          # External plain-text config list for DLC management
├── libs/
│   ├── Version.lua             # Global version constant (e.g. "0.6.0")
│   ├── Config.lua              # DefaultSettings table, JSON serialization, SetSetting
│   ├── Logger.lua              # Logging utility (Sapphire:Log)
│   ├── Utils.lua               # Normalization, IsHost, SafeMode logic, GetEffectiveSettings
│   ├── LootActions.lua         # Container opening, loose loot packing, forward bag ejection
│   ├── DoorActions.lua         # Unlocking standard doors, security rooms, keycard readers, gates
│   ├── CivilianActions.lua     # Mass civilian intimidation and instant cable tying
│   ├── ReviveActions.lua       # Instant local player and squad/AI revival
│   ├── EnemyActions.lua        # Silent enemy despawning and security camera shutdown
│   ├── GageActions.lua         # Map-wide Gage Courier package instant collection
│   ├── JokerActions.lua        # Minion limit bypass & instant cop conversion into Jokers
│   ├── CustodyActions.lua      # Teammate custody breakout & instant hostage trade
│   ├── CorpseActions.lua       # Silent corpse despawn & body bag cleanup
│   ├── SupplyActions.lua       # Full replenish of health, armor, ammo, grenades, ties, bags
│   ├── DrillActions.lua        # Fix and finish all active drills, saws & hacking devices
│   ├── DoorActions.lua         # Map-wide door, gate, keycard reader & security cage unlocker
│   └── InGameMenu.lua          # Fullscreen overlay modal GUI & keyboard navigation
├── logs/
│   ├── FunctionsDump.txt       # Local dump of live in-game class functions
│   ├── playermanager.lua       # Full decompiled reference of PlayerManager
│   └── Sapphire+.log           # Runtime debug logs created by Sapphire:Log()
├── keybinds/
│   ├── ToggleEnabled.lua       # Master mod toggle hotkey
│   └── OpenMenu.lua            # In-game tactical modal menu hotkey
└── hooks/
    ├── MenuManager.lua         # Single-page Mod Options UI, localization, widgets
    ├── PlayerManager.lua       # Carry stats, bag throwing, interaction hooks
    ├── CarryTweakData.lua      # Carry weights, speeds, jump multipliers
    ├── CarryRestrictions.lua  # Prevents body bag auto-removal on weapons hot
    ├── CopBrain.lua            # Random pager removal (post_init + update ticks)
    ├── PlayerMovement.lua      # Stamina drain suppression while carrying
    ├── PlayerDamage.lua        # God mode, bag shield, no fall damage, anti-flashbang, fast regen
    ├── InteractionExt.lua      # Range multipliers, interaction speed reduction
    ├── UnlimitedFavors.lua     # Pre-planning budget & cost overrides
    ├── MultiPickup.lua         # Consumable specials stacking (keycards, planks, C4)
    ├── InfiniteCameraLoop.lua  # Camera loop duration override (99,999s) & EHI sync
    ├── MinDetectionRisk.lua    # Suspicion offset override (Risk 3 / 0.0 offset)
    ├── DrillOverhaul.lua       # Anti-jamming logic & instant 0.01s timers
    ├── AutoCooker.lua          # Automated Bain & Locke meth lab chemical detection
    ├── GroupAIStateBase.lua    # AI Can't Alarm (whisper-mode alarm suppression)
    ├── DLCManager.lua          # DLC heist host-unlock ownership overrides
    ├── OmnidirectionalSprint.lua # 360-degree sprinting in any direction
    ├── MeleeOverhaul.lua       # 100% full-charge damage on quick melee tap
    ├── WeaponSway.lua          # Stance breathing amplitude zeroing (no sway)
    ├── FastReload.lua          # 2.5x weapon magazine and shotgun reload speed
    ├── MaskUpOverhaul.lua      # Instant mask-up in casing mode (0.05s)
    ├── SentryOverhaul.lua      # Invulnerable player-placed sentry guns
    ├── WeaponCombat.lua        # Infinite ammo, zero recoil, zero spread
    ├── FireModeOverhaul.lua    # Full-auto firemode toggle on all weapons
    ├── PlayerInventoryHooks.lua # Infinite cable ties, infinite body bags, infinite throwables
    ├── WeaponSwapOverhaul.lua  # 3x fast weapon switching animation speed
    ├── LifecycleManager.lua    # Async task cleanup on heist restart
    └── CrashFixes.lua          # Diesel vehicle animation callback crash guard
```

---

## 2. The Dual-System Architecture

Sapphire+ features operate in two distinct execution environments:

### A. Persistent Mod Options (Heist Configuration)
* **Where Configured:** Main Menu or In-Game Pause Menu > **Options > Mod Options > Sapphire+**.
* **Storage:** Persisted automatically to `settings.json` via `libs/Config.lua`.
* **Execution:** Intercepts game engine systems via SuperBLT hooks in `hooks/`.
* **Safe Mode:** Automatically clamps or neutralizes cheat-tier values when joining multiplayer lobbies as a client.

### B. In-Game Tactical Actions (Mid-Game Modal Execution)
* **Where Triggered:** During an active heist by pressing the modal hotkey (Default: `N`).
* **Implementation:** Dedicated single-responsibility action modules in `libs/<Feature>Actions.lua`.
* **Input Isolation:** The modal (`libs/InGameMenu.lua`) suspends character input controller (`player:base():controller():set_enabled(false)`) while open, preventing accidental gunfire or movement.
* **Safe Mode:** Tactical action functions check `effective.SafeModeActive` and gracefully notify the player via HUD hints if disabled.

---

## 3. The Effective Settings Pattern (`Sapphire:GetEffectiveSettings()`)

Hooks must **never** read `Sapphire.Settings` directly. Always call `local effective = Sapphire:GetEffectiveSettings()`:
* Automatically respects the master **Enable/Disable** toggle.
* Automatically handles **Multiplayer Safe Mode**: Neutralizes cheat-tier features and clamps multipliers when joining public lobbies as a client.
* Supports **Live Runtime Updates**: Modifying a setting in Mod Options updates the game immediately without requiring a heist restart.

---

## 4. Pre-Implementation Research: When & Where to Search

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

* **`logs/FunctionsDump.txt`**: A live runtime dump of class methods in the running game (e.g., `PlayerManager`). You can search this file locally to verify if a method exists on a class without needing internet access.
* **`logs/playermanager.lua`**: The full local decompiled reference for `PlayerManager`. Contains `add_special`, `remove_special`, `can_pickup_equipment`, `has_special_equipment`, etc.
* **`logs/Sapphire+.log`**: The active debug log. Review this to confirm when your hooks load and what values they receive during gameplay.

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

---

## 5. Pipeline A: How to Add a Persistent Mod Option (5 Steps)

When adding a persistent setting (e.g. `MyNewFeature`), update **5 files in sequence**:

```
Step 1: libs/Config.lua        → Register default value in Sapphire.DefaultSettings
Step 2: libs/Utils.lua         → Normalize value + map to GetEffectiveSettings + Safe Mode
Step 3: hooks/MyNewFeature.lua → Implement core Lua hook/override logic
Step 4: mod.txt                → Register hook file to the game's class path
Step 5: hooks/MenuManager.lua  → Add setting key, localized text, and UI widget
```

### Step-by-Step Code Templates:

#### Step 1: Register in `libs/Config.lua`
```lua
Sapphire.DefaultSettings = {
    -- ...
    MyNewFeature = false -- or default numeric value, e.g. 1.0
}
```

#### Step 2: Normalize & Map in `libs/Utils.lua`
```lua
-- In Sapphire:NormalizeSettings():
self.Settings.MyNewFeature = self.Settings.MyNewFeature == true

-- In Sapphire:GetEffectiveSettings():
MyNewFeature = self.Settings.MyNewFeature,

-- In safe_mode_active block:
effective.MyNewFeature = false
```

#### Step 3: Implement Hook in `hooks/MyNewFeature.lua`
```lua
dofile(ModPath .. "core.lua")

Sapphire:Log("MyNewFeature hook loaded.")

if TargetClass then
    local orig_func = TargetClass.target_function
    if orig_func then
        function TargetClass:target_function(...)
            local effective = Sapphire:GetEffectiveSettings()
            if effective.Enabled and effective.MyNewFeature then
                return custom_value
            end
            return orig_func(self, ...)
        end
    end
    Sapphire:Log("MyNewFeature: TargetClass overrides applied.")
end
```

#### Step 4: Register in `mod.txt`
```json
{
    "hook_id": "lib/path/to/game_file",
    "script_path": "hooks/MyNewFeature.lua"
}
```

#### Step 5: Add UI & Localization in `hooks/MenuManager.lua`
```lua
-- 1. In setting_keys:
Sapphire_MyNewFeature = "MyNewFeature",

-- 2. In parse_item_value:
key == "MyNewFeature" or

-- 3. In LocalizationManagerPostInit:
Sapphire_my_new_feature_title = "My New Feature",
Sapphire_my_new_feature_desc  = "Description of what this does. (Disabled in Safe Mode)",

-- 4. In MenuManagerPopulateCustomMenus (choose appropriate priority):
MenuHelper:AddToggle({
    id = "Sapphire_MyNewFeature",
    title = "Sapphire_my_new_feature_title",
    desc = "Sapphire_my_new_feature_desc",
    callback = callback_id,
    value = Sapphire.Settings.MyNewFeature,
    menu_id = menu_id,
    priority = 688
})
```

---

## 6. Pipeline B: How to Add an In-Game Tactical Action (4 Steps)

When adding a mid-game tactical action (e.g. `MyNewAction`), follow this 4-step pipeline:

```
Step 1: libs/MyNewActionActions.lua → Implement dedicated action module
Step 2: core.lua                    → Load module via dofile()
Step 3: libs/InGameMenu.lua         → Add entry to InGameMenu._items table
Step 4: docs/app.js (Optional)      → Add feature card to showcase website
```

### Step-by-Step Code Templates:

#### Step 1: Create `libs/MyNewActionActions.lua`
```lua
Sapphire.MyAction = Sapphire.MyAction or {}

function Sapphire.MyAction:Execute()
    local effective = Sapphire:GetEffectiveSettings()
    if effective.SafeModeActive then
        if managers and managers.hud and managers.hud.show_hint then
            managers.hud:show_hint({ text = "Sapphire+: My Action is disabled in Safe Mode." })
        end
        return
    end

    local player = managers.player and managers.player:player_unit()
    if not alive(player) then return end

    -- Core action logic wrapped in pcall
    local count = 0
    pcall(function()
        -- Perform action on game units
        count = count + 1
    end)

    if managers and managers.hud and managers.hud.show_hint then
        managers.hud:show_hint({ text = "Sapphire+: Action executed on " .. tostring(count) .. " targets!" })
    end
    Sapphire:Log("MyAction executed. Targets: " .. tostring(count))
end
```

#### Step 2: Register in `core.lua`
```lua
dofile(ModPath .. "libs/MyNewActionActions.lua")
```

#### Step 3: Register in `libs/InGameMenu.lua`
```lua
{
    id = "my_action",
    num = "11",
    text = "My Action Title",
    type = "action",
    desc = "Detailed description explaining what this action does when executed.",
    action = function()
        if Sapphire.MyAction and Sapphire.MyAction.Execute then
            Sapphire.MyAction:Execute()
        end
    end
}
```

---

## 7. Verified PAYDAY 2 Hook Paths Reference

| Game System | Internal Class | SuperBLT `hook_id` | Notes & Key Methods |
|---|---|---|---|
| **Player Equipment & Carry** | `PlayerManager` | `lib/managers/playermanager` | `add_special`, `can_pickup_equipment`, `current_carry_id` |
| **Black Market / Detection** | `BlackMarketManager` | `lib/managers/blackmarketmanager` | `get_suspicion_offset_of_local`, `get_suspicion_offset_from_custom_data`, `_calculate_suspicion_offset` *(offset getters return a 3-tuple `value, max_reached, min_reached` = `val, index == 1, index == #concealment - 1`; `get_real_armor_concealment` / `get_armor_concealment` do **NOT** exist)* |
| **Pre-planning & Favors** | `PrePlanningManager` | `lib/managers/preplanningmanager` | `get_type_budget_cost`, `can_reserve_mission_element` |
| **Money & Purchases** | `MoneyManager` | `lib/managers/moneymanager` | `get_preplanning_type_cost`, `can_afford_preplanning_type` |
| **Security Cameras** | `SecurityCamera` | `lib/units/props/securitycamera` | `_start_tape_loop`, `_start_tape_loop_by_upgrade_level`, `start_tape_loop` *(in props, NOT cameras; EHI reads `tweak_data.upgrades.values.player.tape_loop_duration`)* |
| **World Interactions** | `BaseInteractionExt` | `lib/units/interactions/interactionext` | `can_select`, `can_interact`, `_get_timer`, `interact_distance` |
| **Meth Lab Cook Cues** | `ObjectInteractionManager` | `lib/managers/objectinteractionmanager` | `add_unit` (AutoCooker chemical-unit detection) |
| **Enemy AI & Pagers** | `CopBrain` | `lib/units/enemies/cop/copbrain` | `post_init`, `update` (random pager removal) *(`CopBrain:set_data` does **NOT** exist — the pending flag is finalized on the next `update` tick)* |
| **Enemy AI & Alarm** | `GroupAIStateBase`<br>`ElementAiGlobalEvent` | `lib/managers/group_ai_states/groupaistatebase`<br>`lib/managers/mission/elementaiglobalevent` | `on_police_called`, `convert_hostage_to_criminal`; `ElementAiGlobalEvent:on_executed` (tags scripted loud transitions) |
| **Player Movement & Stances** | `PlayerMovement`<br>`PlayerStandard` | `lib/units/beings/player/playermovement`<br>`lib/units/beings/player/states/playerstandard` | `PlayerMovement:_change_stamina`; `PlayerStandard:_can_run_directional` *(`_can_run` does **NOT** exist)* |
| **Player Damage & Health** | `PlayerDamage` | `lib/units/beings/player/playerdamage` | `damage_bullet`, `damage_melee`, `damage_fall` (God Mode, bag shield, no-fall) |
| **DLC Ownership** | `DLCManager` | `lib/managers/dlcmanager` | `_check_dlc_data` |
| **Drills & Saws** | `TimerGui` / `Drill` | `lib/units/props/timergui`<br>`lib/units/props/drill` | `_start`, `_set_jamming_values`, `_set_jammed` *(`set_timer` does **NOT** exist)* |
| **Meth Lab Dialog** | `DialogManager` | `lib/managers/dialogmanager` | `queue_dialog` (Bain & Locke chemical cue routing) |
| **Engine Crash Guards** | `AnimatedVehicleBase` | `lib/units/vehicles/animatedvehiclebase` | `anim_clbk_recall_pose` (guards nil `_saved_poses`) |
| **Custody & Trades** | `TradeManager` | `lib/managers/trademanager` | `clbk_respawn_criminal`, `begin_hostage_trade` *(used by `CustodyActions`, not a SuperBLT hook)* |
| **Gage Packages** | `GageAssignmentManager`| `lib/managers/gageassignmentmanager`| `on_unit_interacted` *(referenced by `GageActions`, not a SuperBLT hook)* |

---

## 8. Menu Organization & Priority Reference

The single-page menu in `hooks/MenuManager.lua` uses explicit `priority` bands (higher numbers appear first) to ensure clean category ordering without sub-menus:

| Category | Priority Range | Header ID & Priority | Features Inside Band |
|---|---|---|---|
| **Core Settings** | `900 - 999` | `Sapphire_header_core` (`999`) | `Enabled` (998), `SafeMode` (997), `ForceSafeModeHost` (996), `Debug` (995) |
| **Carry & Movement** | `700 - 899` | `Sapphire_header_carry` (`899`) | `AlwaysSprint` (898), `JumpHeight` (897), `ThrowDistance` (896), `AffectBodyBags` (895), `IgnoreArmorPenalty` (894), `NoWeaponRestrictions` (893), `OmnidirectionalSprint` (892) |
| **Quality of Life** | `500 - 699` | `Sapphire_header_qol` (`699`) | `InteractionSpeedReduction` (698), `InfiniteStamina` (697), `BagDamageReduction` (696), `GodMode` (695.5), `NoFallDamage` (695), `ExtendedInteract` (694), `DrillNoJams` (693), `InstantDrills` (692) |
| **Stealth Tools** | `300 - 499` | `Sapphire_header_stealth` (`499`) | `AICantAlarm` (498), `MultiPickup` (497), `InfiniteCameraLoop` (496), `MinDetectionRisk` (495), `RandomPagers` (494), `RandomPagerChance` (493), `AutoAnswerPagers` (492) |
| **Extras** | `100 - 299` | `Sapphire_header_extras` (`299`) | `UnlockDLCHeists` (298), `UnlimitedFavors` (297) |

> **Note:** `AutoCooker` has **no widget on this BLT options page** — its toggle lives in the **in-game tactical menu** (`libs/InGameMenu.lua`, item `04 Auto-Cooker`), alongside the tactical actions. It is deliberately force-reset to `false` on every mission `init` (`hooks/AutoCooker.lua`) so it never auto-persists across heists; the player re-arms it per-heist from the tactical menu.

---

## 9. Summary Checklist for Any New Feature

- [ ] Researched decompiled source on `Payday-2-LuaJIT-Complete` or local dumps for exact class signatures.
- [ ] Added default key/value to `Sapphire.DefaultSettings` in `libs/Config.lua` (if Mod Option).
- [ ] Added normalization to `Sapphire:NormalizeSettings()` in `libs/Utils.lua`.
- [ ] Added mapping to `Sapphire:GetEffectiveSettings()` in `libs/Utils.lua`.
- [ ] Enforced `Safe Mode` protection for multiplayer client lobbies.
- [ ] Created single-responsibility file in `hooks/` or `libs/` with defensive `pcall` isolation.
- [ ] Registered hook path in `mod.txt` (if hook) or `core.lua` / `InGameMenu.lua` (if action).
- [ ] Added localization string keys in `hooks/MenuManager.lua`.
- [ ] Added UI widget (`MenuHelper:AddToggle` or `AddSlider`) with correct priority.
- [ ] Updated devlog in `docs/app.js` and bumped version in `libs/Version.lua` and `mod.txt`.
- [ ] Tested live in-game: toggle on/off, host vs client behavior, and persistence across restarts.
