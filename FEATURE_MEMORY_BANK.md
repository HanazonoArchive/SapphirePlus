# Sapphire+ Master Engine & Feature Knowledgebase (65 Systems)

This document is the ultimate, definitive technical manual and memory bank for **Sapphire+**. It covers all 65 core engine systems of the PAYDAY 2 Diesel engine, detailing verified decompiled method signatures, internal data structures, network synchronization RPCs, and modding best practices.

---

## Master Table of Contents

1. [Player State Machine & Movement (`PlayerStandard`, `PlayerMovement`)](#1-player-state-machine--movement)
2. [Carry Weight, Sprint, Jump & Bag Physics (`CarryTweakData`, `PlayerManager`)](#2-carry-weight-sprint-jump--bag-physics)
3. [Combat, Damage Processing & Health (`PlayerDamage`)](#3-combat-damage-processing--health)
4. [Weapon Systems, Recoil & Ammo (`NewRaycastWeaponBase`, `RaycastWeaponBase`)](#4-weapon-systems-recoil--ammo)
5. [Special Equipment & Multi-Pickup Pipeline (`PlayerManager`, `BaseInteractionExt`)](#5-special-equipment--multi-pickup-pipeline)
6. [Stealth, Concealment Math & Detection Risk (`BlackMarketManager`)](#6-stealth-concealment-math--detection-risk)
7. [AI State Machine, Alarms & Group AI (`GroupAIStateBase`)](#7-ai-state-machine-alarms--group-ai)
8. [Guard AI, Pagers & Death Interception (`CopBrain`, `CopDamage`)](#8-guard-ai-pagers--death-interception)
9. [Civilian Submission State Machine (`CivilianBrain`, `CivilianLogicSurrender`)](#9-civilian-submission-state-machine)
10. [Camera Systems, Tape Loops & HUD Synchronization (`SecurityCamera`, `EHI`)](#10-camera-systems-tape-loops--hud-synchronization)
11. [World Interactions & Range Multipliers (`BaseInteractionExt`, `ObjectInteractionManager`)](#11-world-interactions--range-multipliers)
12. [Drills, Saws, Timers & Anti-Jam Mechanics (`TimerGui`, `Drill`)](#12-drills-saws-timers--anti-jam-mechanics)
13. [Meth Lab Chemistry & Dialog Interception (`DialogManager`, `AutoCooker`)](#13-meth-lab-chemistry--dialog-interception)
14. [Pre-Planning Favors & Economy (`PrePlanningManager`, `MoneyManager`)](#14-pre-planning-favors--economy)
15. [DLC Licensing & Contract Hosting (`DLCManager`)](#15-dlc-licensing--contract-hosting)
16. [Mission Script Engine & World Triggers (`MissionManager`, `MissionScriptElement`)](#16-mission-script-engine--world-triggers)
17. [Special Enemy Classes & Action Trees (`CopActionSpooc`, `CopActionTase`, `CopActionHeal`)](#17-special-enemy-classes--action-trees)
18. [Police Assault Wave Orchestration (`GroupAIStateBesiege`)](#18-police-assault-wave-orchestration)
19. [Progression, Economy & EXP/Cash Formulas (`ExperienceManager`, `MoneyManager`)](#19-progression-economy--expcash-formulas)
20. [Keypads, Timers & Saws (`DigitalGui`, `SawWeaponBase`)](#20-keypads-timers--saws)
21. [Skill Trees, Upgrades & Perk Deck Engines (`UpgradesTweakData`, `SkillTreeManager`)](#21-skill-trees-upgrades--perk-deck-engines)
22. [Vehicle Mechanics & Driving State Machine (`PlayerDriving`, `VehicleDrivingExt`)](#22-vehicle-mechanics--driving-state-machine)
23. [Contour & Visual Overlays (`ContourExt`, `HUDManager`)](#23-contour--visual-overlays)
24. [Tactical Action Algorithms (Loot Teleport, Door Unlock, Team Revive, Enemy Wipe)](#24-tactical-action-algorithms)
25. [Overlay UI, Controller Ingestion & Audio Events (`InGameMenu`, `MenuManager`)](#25-overlay-ui-controller-ingestion--audio-events)
26. [SuperBLT Packet Networking, RPCs & Native Anti-Cheat Subsystems](#26-superblt-packet-networking-rpcs--native-anti-cheat-subsystems)
27. [Deployables Engine (`SentryGunBase`, `DoctorBagBase`, `AmmoBagBase`)](#27-deployables-engine)
28. [Throwables & Projectiles Framework (`ProjectileBase`, `GrenadeBase`)](#28-throwables--projectiles-framework)
29. [Melee Combat, Charge Scaling & Knockdown Physics (`PlayerStandard`)](#29-melee-combat-charge-scaling--knockdown-physics)
30. [Armor Gating, Regeneration & Perk Mechanics (`PlayerDamage`)](#30-armor-gating-regeneration--perk-mechanics)
31. [Enemy AI Pathfinding & Joker Minion Conversion (`GroupAIStateBase`)](#31-enemy-ai-pathfinding--joker-minion-conversion)
32. [Weapon Attachments & Modding Factory (`WeaponFactoryManager`)](#32-weapon-attachments--modding-factory)
33. [Achievements & Trophy Progress Systems (`AchievementManager`)](#33-achievements--trophy-progress-systems)
34. [Delayed Macro Sequences & Timer Architecture (`DelayedCalls`)](#34-delayed-macro-sequences--timer-architecture)
35. [Sound Engine & Character Audio Routing (`SoundDevice`, `DialogManager`)](#35-sound-engine--character-audio-routing)
36. [Level Environment, Lighting & Fog (`CoreEnvironmentManager`)](#36-level-environment-lighting--fog)
37. [Cable Ties & Hostage Management Engine (`PlayerManager`, `TradeManager`)](#37-cable-ties--hostage-management-engine)
38. [Custody, Down Counters & Instant Trade (`PlayerDamage`, `TradeManager`)](#38-custody-down-counters--instant-trade)
39. [Inventory & Mask / Weapon Customization (`BlackMarketManager`)](#39-inventory--mask--weapon-customization)
40. [Crime.net Contract Generator & Job Lifecycle (`JobManager`, `CrimeSpreeManager`)](#40-crimenet-contract-generator--job-lifecycle)
41. [Sound, Music & Jukebox State Machine (`MusicManager`)](#41-sound-music--jukebox-state-machine)
42. [Raycasting, Collision Slot Masks & Physics Layers (`World:raycast`, `managers.slot`)](#42-raycasting-collision-slot-masks--physics-layers)
43. [Camera, FOV & FreeFlight / Noclip (`FreeFlightCamera`, `Camera`)](#43-camera-fov--freeflight--noclip)
44. [Flashbangs, Tear Gas & Stun Immunity (`PlayerDamage`, `SmokeScreenEffect`)](#44-flashbangs-tear-gas--stun-immunity)
45. [Stealth Alert & Sound Emission Propagation (`GroupAIStateBase:propagate_alert`)](#45-stealth-alert--sound-emission-propagation)
46. [Bot / Crew AI Mechanics & Crew Boosts (`TeamAIBrain`, `TeamAIDamage`)](#46-bot--crew-ai-mechanics--crew-boosts)
47. [Bipod & Mounted Weapons Engine (`BipodWeaponBase`)](#47-bipod--mounted-weapons-engine)
48. [Underbarrel Weapons & Modular Fire Modes (`WeaponUnderbarrel`)](#48-underbarrel-weapons--modular-fire-modes)
49. [Sight Magnification, Reticles & Scope Overlays (`WeaponSight`)](#49-sight-magnification-reticles--scope-overlays)
50. [Body Bag Inventory & Placement Engine (`BodyBagsBagBase`)](#50-body-bag-inventory--placement-engine)
51. [Armor Skin Pattern & Cosmetics Quality Engine (`BlackMarketManager:get_cosmetics_data`)](#51-armor-skin-pattern--cosmetics-quality-engine)
52. [Criminal & Civilian Voice Lines & Subtitles (`DialogManager`, `SubtitleManager`)](#52-criminal--civilian-voice-lines--subtitles)
53. [Safehouse Upgrades, Trophies & Butler Logic (`CustomSafehouseManager`)](#53-safehouse-upgrades-trophies--butler-logic)
54. [Gage Courier Packages & Mod Drop Engine (`GageAssignmentManager`)](#54-gage-courier-packages--mod-drop-engine)
55. [Infamy Matrix & Prestige Card Engine (`InfamyManager`)](#55-infamy-matrix--prestige-card-engine)
56. [VR Mechanics & Dual-Wield Controller Mapping (`PlayerVR`, `PlayerStandardVR`)](#56-vr-mechanics--dual-wield-controller-mapping)
57. [Weapon Sway, Bobbing & Screen Shake (`PlayerStandard`, `CameraManager`)](#57-weapon-sway-bobbing--screen-shake)
58. [Crosshair, Hit Markers & Critical Hit Visuals (`HUDHitConfirm`)](#58-crosshair-hit-markers--critical-hit-visuals)
59. [Laser Gadget Color Customization & Dynamic Rainbow Lasers (`WeaponLaser`)](#59-laser-gadget-color-customization--dynamic-rainbow-lasers)
60. [Enemy Dismemberment & Decapitation Physics (`CopDamage:_dismember`)](#60-enemy-dismemberment--decapitation-physics)
61. [Instant Heist Restart & Fast Level Loading (`managers.game_play_central`)](#61-instant-heist-restart--fast-level-loading)
62. [End-Screen Card Drops & Loot Generation Engine (`LootDropManager:make_drop`)](#62-end-screen-card-drops--loot-generation-engine)
63. [Hostage Count & Assault Wave Delay (`GroupAIStateBesiege`)](#63-hostage-count--assault-wave-delay)
64. [Swan Song, Messiah & Self-Revive Triggers (`PlayerDamage`, `PlayerManager`)](#64-swan-song-messiah--self-revive-triggers)
65. [Stealth Body Bag Cleanup & Corpse Disposer (`CopDamage`, `World:find_units_quick`)](#65-stealth-body-bag-cleanup--corpse-disposer)

---

## 1. Player State Machine & Movement

```lua
PlayerStandard:_can_run_directional() -- Real method: returns boolean if directional sprint is allowed. NOTE: _can_run() does NOT exist on PlayerStandard.
PlayerStandard:_start_action_running(t) -- Initiates sprint animation, FOV shift, stamina drain
PlayerStandard:_end_action_running(t) -- Halts sprint state
PlayerStandard:_can_jump() -- Returns boolean if jump is permitted
PlayerMovement:_change_stamina(value) -- Updates player stamina pool (negative = drain)
PlayerMovement:warp_to(pos, rot) -- Teleports player unit directly in 3D world space
```

---

## 2. Carry Weight, Sprint, Jump & Bag Physics

```lua
tweak_data.carry.types[weight_class] = {   -- keyed by WEIGHT-CLASS, not item id
    move_speed_modifier = 1.0,         -- Walk speed multiplier (0.25 to 1.0)
    jump_modifier = 1.0,               -- Jump vertical velocity multiplier
    throw_distance_multiplier = 1.0,   -- Throw impulse velocity multiplier
    can_run = true                     -- Boolean allowing sprint while holding
}
-- NOTE: there is NO sprint_speed_modifier and NO weapon_category_fallback field on
-- carry types (verified against lib/tweak_data/carrytweakdata.lua -- only the four
-- fields above exist). Body bags/corpses use the "being" weight-class, shared by
-- exactly `person` + `special_person`.
```

---

## 3. Combat, Damage Processing & Health

```lua
PlayerDamage:damage_bullet(attack_data) -- Handles bullet damage from enemies
PlayerDamage:damage_melee(attack_data) -- Handles melee attacks (cloakers, cops)
PlayerDamage:damage_fall(data) -- Handles gravity impact calculations
PlayerDamage:damage_explosion(attack_data) -- Handles grenades and explosive barrels
PlayerDamage:on_flashbanged(sound_eff_mul) -- Triggers flashbang whiteout blindness and ear ringing
PlayerDamage:need_revive() -- Returns true if in bleedout, fatal, or incapacitated state
PlayerDamage:revive(revive_unit) -- Restores player to standing health
PlayerDamage:set_god_mode(enabled) -- Engine invulnerability toggle
```

---

## 4. Weapon Systems, Recoil & Ammo

```lua
NewRaycastWeaponBase:recoil_multiplier() -- Recoil kick multiplier (0 = zero recoil)
NewRaycastWeaponBase:spread_multiplier() -- Bullet deviation spread (0 = laser beam)
NewRaycastWeaponBase:fire_rate_multiplier() -- Rate of fire multiplier
NewRaycastWeaponBase:reload_speed_multiplier() -- Reload animation speed multiplier
RaycastWeaponBase:reload_speed_multiplier() -- Base weapon reload speed multiplier
RaycastWeaponBase:get_ammo_max() -- Max ammo capacity (digested)
RaycastWeaponBase:get_ammo_total() -- Total ammo remaining
RaycastWeaponBase:set_ammo_total(ammo) -- Sets total ammo pool directly
RaycastWeaponBase:clip_empty() -- Returns false & keeps clip full when InfiniteAmmo is active
RaycastWeaponBase:replenish() -- Instantly refills clip and total ammo capacity
tweak_data.weapon[id].CAN_TOGGLE_FIREMODE -- Unlocks full auto toggles on pistols/shotguns/DMRs
```

---

## 5. Special Equipment & Multi-Pickup Pipeline

* Decrypt: `local count = Application:digest_value(special.amount, false)`
* Encrypt: `special.amount = Application:digest_value(1, true)`
* Bypasses `special_equipment_block` in `BaseInteractionExt:can_select` and `can_interact`.
* Bypasses limits in `PlayerManager:can_pickup_equipment` and `_can_pickup_special_equipment`.

---

## 6. Stealth, Concealment Math & Detection Risk

* **`0.0 suspicion offset`** = **Detection Risk 3** (Engine minimum).
* **`1.0 suspicion offset`** = **Detection Risk 75** (Spotted instantly).

```lua
-- These public getters return a 3-tuple: (value, max_reached, min_reached), where
--   max_reached = (index == 1)                -- lowest concealment  / MAX detection
--   min_reached = (index == #concealment - 1) -- highest concealment / MIN detection
-- (verified against lib/managers/blackmarketmanager.lua:3150-3164). At full
-- concealment (0 suspicion) the correct flags are max_reached=false, min_reached=true;
-- returning them inverted paints the "0" readout in the max-detection warning color.
BlackMarketManager:get_suspicion_offset_of_local(...) -> return 0, false, true
BlackMarketManager:get_suspicion_offset_from_custom_data(...) -> return 0, false, true
BlackMarketManager:_calculate_suspicion_offset(...) -> return 0
-- NOTE: get_real_armor_concealment / get_armor_concealment do NOT exist in the engine.
--       Concealment feeds suspicion through the index math above, which is already zeroed.
```

---

## 7. AI State Machine, Alarms & Group AI

```lua
-- AI Can't Alarm suppresses ONLY organic detections during stealth. Mission-scripted
-- loud transitions flow through the same on_police_called via ElementAiGlobalEvent:on_executed
-- and MUST always pass, or the heist soft-locks. The engine never passes a "script" reason
-- string, so scripted calls are tagged (not keyed off called_reason).
function ElementAiGlobalEvent:on_executed(...)
    Sapphire._scripted_police_call = true   -- real code saves/restores prev + wraps in pcall
    -- ... call original ...
end

function GroupAIStateBase:on_police_called(called_reason, ...)
    local effective = Sapphire:GetEffectiveSettings()
    if effective.Enabled and effective.AICantAlarm then
        if self:whisper_mode() and not Sapphire._scripted_police_call then
            return -- suppress the organic alarm only
        end
    end
    return orig_on_police_called(self, called_reason, ...)
end
```

---

## 8. Guard AI, Pagers & Death Interception

```lua
local ud = unit:unit_data()
if ud then
    ud.has_alarm_pager = false
end
```
* Hooked in `CopBrain:post_init` and `update`. (`set_data` does NOT exist on `CopBrain` and is not hooked; `update` finalizes the pending-pager state.)

---

## 9. Civilian Submission State Machine

* 4 submission states: `alerted` -> `hands_up` -> `kneeling` -> `tied`.
* Injected directly via `brain:set_logic("surrender")`, `logic_data.is_tied = true`, `submission_state = "tied"`, and `civ:movement():play_redirect(Idstring("tied"))`.

---

## 10. Camera Systems, Tape Loops & HUD Synchronization

```lua
SecurityCamera:_start_tape_loop(tape_loop_t) -- Overridden to 99,999s
SecurityCamera.active_tape_loop_unit = nil -- Cleared for concurrent loops
unit:contour():add("mark_unit_friendly") -- Friendly 3D contour
managers.ehi_tracker:RemoveTracker(key) -- Suppresses EHI timer boxes
```

---

## 11. World Interactions & Range Multipliers

```lua
BaseInteractionExt:interact_distance(...) -> return distance * ExtendedInteract
BaseInteractionExt:_get_timer(...) -> return timer * (1 - Reduction / 100)
```

---

## 12. Drills, Saws, Timers & Anti-Jam Mechanics

```lua
TimerGui:_start(timer, current_timer) -> timer = 0.01 (Instant Drills). NOTE: set_timer does NOT exist; force the timer here instead.
TimerGui:_set_jamming_values() -> self._jamming_values = {}
TimerGui:set_jammed(jammed) -> Blocked if jammed == true
TimerGui:_set_jammed(jammed) -> Blocked if jammed == true
Drill:set_jammed(jammed) -> Blocked if jammed == true
```

---

## 13. Meth Lab Chemistry & Dialog Interception

| Heist / Caller | Sound Trigger ID | Chemical Name | Target Interaction Tweak ID |
|---|---|---|---|
| **Cook Off / Rats (Bain)** | `pln_rt1_20` / `21` | Muriatic Acid (Mu) | `methlab_gas_to_salt` |
| **Cook Off / Rats (Bain)** | `pln_rt1_22` / `23` | Caustic Soda (Cs) | `methlab_caustic_cooler` |
| **Cook Off / Rats (Bain)** | `pln_rt1_24` / `25` | Hydrogen Chloride (HCl) | `methlab_bubbling` |
| **Border Crossing (Locke)** | `loc_mex_cook_01` / `04` | Muriatic Acid (Mu) | `methlab_gas_to_salt` |
| **Border Crossing (Locke)** | `loc_mex_cook_02` / `05` | Caustic Soda (Cs) | `methlab_caustic_cooler` |
| **Border Crossing (Locke)** | `loc_mex_cook_03` / `06` | Hydrogen Chloride (HCl) | `methlab_bubbling` |

---

## 14. Pre-Planning Favors & Economy

```lua
PrePlanningManager:get_type_budget_cost(type) -> return 0
PrePlanningManager:can_reserve_mission_element(type) -> return true
MoneyManager:get_preplanning_type_cost(type) -> return 0
MoneyManager:can_afford_preplanning_type(type) -> return true
```

---

## 15. DLC Licensing & Contract Hosting

```lua
WinSteamDLCManager:_check_dlc_data(dlc_data) -> return true (Matches dlcs-to-unlock.txt)
WinEpicDLCManager:_check_dlc_data(dlc_data) -> return true
WINDLCManager:_check_dlc_data(dlc_data) -> return true
```

---

## 16. Mission Script Engine & World Triggers

```lua
for _, script in pairs(managers.mission:scripts()) do
    for _, element in pairs(script:elements()) do
        if element:editor_name() == target_name then
            element:on_executed(managers.player:player_unit())
        end
    end
end
```

---

## 17. Special Enemy Classes & Action Trees

* **Cloakers (`CopActionSpooc`)**: `lib/units/enemies/spooc/actions/lower_body/ActionSpooc.lua` (Charging sprint, dropkick down).
* **Tasers (`CopActionTase`)**: `lib/units/enemies/cop/actions/upper_body/copactiontase.lua` (Taser beam lock, spasms).
* **Medics (`CopActionHeal`)**: `lib/units/enemies/cop/actions/upper_body/copactionheal.lua` (Healing cooldown, invulnerability frames).
* **Shields (`ShieldLogic`)**: Penetration flags and stagger reactions.
* **Bulldozers**: Faceplate/visor armor stats in `tweak_data.character[name].damage`.

---

## 18. Police Assault Wave Orchestration

### `GroupAIStateBesiege` Assault Phases:
1. `anticipation` (30s dramatic countdown)
2. `build` (Perimeter reinforcement)
3. `sustain` (Full combat assault spawns)
4. `fade` (SWAT retreat logic)
5. `regroup / break` (Cooldown before next wave)

---

## 19. Progression, Economy & EXP/Cash Formulas

```lua
ExperienceManager:add_points(points, is_skill_point) -- Adds XP points
MoneyManager:add_to_spending(amount) -- Spending cash balance
MoneyManager:add_to_offshore(amount) -- Offshore cash balance
```

---

## 20. Keypads, Timers & Saws

* **`DigitalGui:update`**: Fast-forwards keypad access codes and PC download timers.
* **`SawWeaponBase:fire`**: Handles deposit box opening and silent blade penetration.

---

## 21. Skill Trees, Upgrades & Perk Deck Engines

* `tweak_data.skilltree.trees`: Tier definitions and point costs.
* `tweak_data.upgrades.values`: Modifiers for dodge, crit, reload speed, stamina regen, armor recovery.
* Perk Deck Mechanics: Anarchist (Armor gate), Stoic (Damage-over-time flask cleanse), Leech (Health segment immunity), Hacker (Pocket ECM stun), Kingpin (Adrenaline heal).

---

## 22. Vehicle Mechanics & Driving State Machine

```lua
VehicleDrivingExt:set_input(axis_x, axis_y, handbrake) -- Steering & throttle
PlayerDriving:_check_action_exit_vehicle(t, input) -- Vehicle exit state
```

---

## 23. Contour & Visual Overlays

* `"mark_unit_friendly"` (Blue/Cyan outline)
* `"mark_enemy"` (Red highlight)
* `"highlight_character"` (Yellow outline)
* `"taxman"` (Green VIP outline)

---

## 24. Tactical Action Algorithms

1. **Teleport Loot**: Unbox containers -> 0.08s debounce -> batch loose items at 0.05s intervals -> interact & drop forward via `managers.player:drop_carry()`.
2. **Unlock All Doors**: Interacts with doors, keycard readers, iron gates, and timelocks map-wide.
3. **Tie All Civilians**: Injects `surrender` brain logic and `tied` state directly, bypassing intimidation delays.
4. **Instant Team Revive**: Revives self via `player:character_damage():revive(true)` and squad via `unit:character_damage():revive(player)`.
5. **Wipe All Enemies**: Sets `unit:brain():set_active(false)`, despawns via `unit:set_slot(0)`, and shuts down cameras.
6. **Restock All Supplies**: Restores player health, armor, all weapon ammo via `replenish()`, grenades, cable ties, and body bags to 100% capacity.

---

## 25. Overlay UI, Controller Ingestion & Audio Events

```lua
self._ws = Overlay:gui():create_screen_workspace()
player:base():controller():set_enabled(false) -- Disable player control during modal
managers.menu_component:post_event("menu_enter") -- Play native sound cues
```

---

## 26. SuperBLT Packet Networking, RPCs & Native Anti-Cheat Subsystems

```lua
-- Send to host:
managers.network:session():send_to_host("sync_interacted", unit, -2, tweak_data, 1)

-- Send to peers:
managers.network:session():send_to_peers_synched("sync_unit_module_event", unit, event_id)
```

---

## 27. Deployables Engine

```lua
AmmoBagBase:take_ammo(unit) -- Calculates ammo refill percentage and Bullet Storm trigger
DoctorBagBase:take(unit) -- Restores 100% health and resets down counter to zero
FirstAidKitBase:take(unit) -- Restores 100% health (auto-triggered by Uppers skill on lethal damage)
SentryGunBase:set_ammo(amount) -- Updates sentry ammunition pool
SentryGunBase:on_death() -- Triggered when sentry unit runs out of health
```

---

## 28. Throwables & Projectiles Framework

```lua
ProjectileBase.throw_projectile(projectile_type, pos, dir) -- Spawns thrown projectile with velocity vector
ProjectileBase:clbk_impact(...) -- Collision and detonation trigger
PlayerManager:has_grenades() -- Checks if player has grenades/throwables
PlayerManager:on_throw_grenade() -- Decrements grenade count upon throwing
PlayerManager:has_cable_ties() -- Checks if player has cable ties
PlayerManager:remove_cable_ties(amount) -- Decrements cable tie count
PlayerManager:has_total_body_bags() -- Checks if player has body bags
PlayerManager:remove_body_bags_amount(amount) -- Decrements body bag count
PlayerStandard:_get_swap_speed_multiplier() -- Calculates weapon switching animation multiplier
```

---

## 29. Melee Combat, Charge Scaling & Knockdown Physics

```lua
PlayerStandard:_do_action_melee(t, input) -- Initiates melee raycast and damage interpolation
```

---

## 30. Armor Gating, Regeneration & Perk Mechanics

* **Shield Gating**: Excess damage on single break frame is nullified.
* **Anarchist**: Regenerates armor chunks every 2.0s (Suit), 3.0s (Light Vest), or 4.0s (ICTV).
* **Stoic**: Converts 75% incoming damage into DoT over 12s. Stoic Flask instantly cleanses pending DoT.

---

## 31. Enemy AI Pathfinding & Joker Minion Conversion

```lua
GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit)
```

---

## 32. Weapon Attachments & Modding Factory

```lua
WeaponFactoryManager:get_parts_from_weapon_id(weapon_id) -- Returns compatible attachment parts
WeaponFactoryManager:create_weapon_blueprint(weapon_id, blueprint) -- Assembles weapon
```

---

## 33. Achievements & Trophy Progress Systems

```lua
managers.achievment:award(id) -- Unlocks in-game and Steam achievement
managers.custom_safehouse:add_coins(amount) -- Adds Continental Coins
```

---

## 34. Delayed Macro Sequences & Timer Architecture

```lua
DelayedCalls:Add("Call_ID_Unique", delay_seconds, function()
    -- Asynchronous execution block
end)
```

---

## 35. Sound Engine & Character Audio Routing

```lua
managers.player:player_unit():sound():say("v46", true) -- Play character voice line
managers.dialog:queue_dialog(dialog_id, params) -- Queue narrator line
```

---

## 36. Level Environment, Lighting & Fog

* Post-processing environment presets in `managers.environment_controller`.

---

## 37. Cable Ties & Hostage Management Engine

```lua
PlayerManager:get_cable_ties_amount() -- Decrypts current cable ties amount
PlayerManager:add_cable_ties(amount) -- Increments cable tie supply
TradeManager:get_best_hostage() -- Scans map for optimal trade hostage unit
TradeManager:begin_hostage_trade() -- Initiates custody trade sequence
```

---

## 38. Custody, Down Counters & Instant Trade

* Down counter limits: `tweak_data.player.damage.lives` (3 base, 4 Nine Lives Aced, 1 One Down).
* Instant Custody Release: `TradeManager:begin_hostage_trade()`.

---

## 39. Inventory & Mask / Weapon Customization

```lua
BlackMarketManager:on_buy_weapon_platform(category, weapon_id)
BlackMarketManager:on_equip_weapon_slot(category, slot)
BlackMarketManager:get_crafted_category_slot(category, slot)
```

---

## 40. Crime.net Contract Generator & Job Lifecycle

```lua
managers.job:current_job_id() -- Returns active heist ID
managers.job:current_difficulty_stars() -- Returns difficulty (0 = Normal, 6 = Death Sentence)
managers.crime_spree:spree_level() -- Returns active Crime Spree level
```

---

## 41. Sound, Music & Jukebox State Machine

```lua
managers.music:post_event("music_heist_stealth")
managers.music:post_event("music_heist_control")
managers.music:post_event("music_heist_anticipation")
managers.music:post_event("music_heist_assault")
```

---

## 42. Raycasting, Collision Slot Masks & Physics Layers

```lua
local mask = managers.slot:get_mask("bullet_impact_targets")
local hit = World:raycast("ray", from_pos, to_pos, "slot_mask", mask, "ignore_unit", player_unit)
```

---

## 43. Camera, FOV & FreeFlight / Noclip

```lua
Camera:set_position(pos)
Camera:set_rotation(rot)
```

---

## 44. Flashbangs, Tear Gas & Stun Immunity

* `PlayerDamage:on_flashbanged(...)` -> return (Nullifies whiteout).
* `PlayerDamage:damage_tear_gas(...)` -> return false (Gas immunity).

---

## 45. Stealth Alert & Sound Emission Propagation

```lua
GroupAIStateBase:propagate_alert(alert_data)
```

---

## 46. Bot / Crew AI Mechanics & Crew Boosts

* Crew Boosts: `Accelerator` (+50% reload/swap speed), `Armorer` (+30 armor), `Concealed` (+3 concealment), `Healer` (5 HP / 5s), `Reinforcer` (+60 HP), `Stockpiler` (+50% ammo pickup).

---

## 47. Bipod & Mounted Weapons Engine

```lua
PlayerStandard:_check_action_bipod(t, input) -- Polls bipod deploy keybind
BipodWeaponBase:destroy() -- Halts deployed mount state
```

---

## 48. Underbarrel Weapons & Modular Fire Modes

```lua
PlayerStandard:_check_action_deploy_underbarrel(t, input) -- Toggles underbarrel secondary launcher
WeaponUnderbarrel:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
```

---

## 49. Sight Magnification, Reticles & Scope Overlays

* Manages zoom multiplier, thermal scope color inverted overlays, and canted 45-degree angled iron sight swapping.

---

## 50. Body Bag Inventory & Placement Engine

```lua
managers.player:get_body_bags_amount() -- Returns remaining body bag inventory
managers.player:add_body_bags_amount(amount) -- Increments body bag pool
BodyBagsBagBase:take(unit) -- Restores body bags from deployable case
```

---

## 51. Armor Skin Pattern & Cosmetics Quality Engine

```lua
BlackMarketManager:get_cosmetics_data(cosmetic_id) -- Returns rarity, wear, pattern, and color grade
```

---

## 52. Criminal & Civilian Voice Lines & Subtitles

```lua
managers.dialog:queue_dialog(dialog_id, params) -- Queue character or narrator line
managers.subtitle:show_subtitle(string_id, duration) -- Displays custom localized subtitle
```

---

## 53. Safehouse Upgrades, Trophies & Butler Logic

```lua
managers.custom_safehouse:get_room_current_tier(room_id) -- Returns tier level of safehouse room
managers.custom_safehouse:award(trophy_id) -- Unlocks custom safehouse trophy
```

---

## 54. Gage Courier Packages & Mod Drop Engine

```lua
for _, unit in pairs(World:find_units_quick("all", managers.slot:get_mask("player_interactions"))) do
    if alive(unit) and unit:interaction() and unit:interaction().tweak_data:find("^gage_assignment") then
        unit:interaction():interact(managers.player:player_unit())
    end
end
```

---

## 55. Infamy Matrix & Prestige Card Engine

```lua
managers.infamy:points() -- Returns available infamy points
managers.infamy:reward_progress() -- Returns Infamy 3.0+ track level
```

---

## 56. VR Mechanics & Dual-Wield Controller Mapping

* Manages dual-handed independent aiming, ladder room-scale climbing, and head-mounted display (HMD) orientation matrices.

---

## 57. Weapon Sway, Bobbing & Screen Shake

### Engine Classes & Source Locations
* **`PlayerStandard`**: `lib/units/beings/player/states/playerstandard`
* **`CameraManager`**: `lib/managers/cameramanager`
* **`tweak_data.player.stances`**: Stance bobbing and sway definitions

### Sway & Bobbing Nullification:
* Overriding `PlayerStandard:_update_fakesettings` and setting stance bobbing variables to `0.0` eliminates weapon bouncing during sprints and crosshair drift during sustained fire.

---

## 58. Crosshair, Hit Markers & Critical Hit Visuals

### Engine Classes & Source Locations
* **`HUDHitConfirm`**: `lib/managers/hud/hudhitconfirm`
* **`HUDManager`**: `lib/managers/hudmanager`

### Callback Methods
```lua
HUDHitConfirm:on_hit_confirmed() -- Triggers standard white/red hit marker tick
HUDHitConfirm:on_headshot_confirmed() -- Triggers lethal headshot visual/audio cue
HUDHitConfirm:on_crit_confirmed() -- Triggers critical strike visual/audio cue
```

---

## 59. Laser Gadget Color Customization & Dynamic Rainbow Lasers

### Engine Class: `WeaponLaser` (`lib/units/weapons/weaponlaser`)
```lua
WeaponLaser._color = Vector3(r, g, b) -- Sets laser beam RGB vector
```
* Dynamic rainbow lasers iterate RGB hue values across game delta time (`dt`) inside `WeaponLaser:update`.

---

## 60. Enemy Dismemberment & Decapitation Physics

### Engine Classes & Source Locations
* **`CopDamage`**: `lib/units/enemies/cop/copdamage`
* **`tweak_data.physics.ragdoll`**: Ragdoll impulse multipliers

### Dismemberment Mechanics
* `CopDamage:_dismember(unit, body_part)` handles explosive and high-caliber shotgun decapitations and limb dismemberment.

---

## 61. Instant Heist Restart & Fast Level Loading

### Engine Method:
```lua
managers.game_play_central:restart_the_game()
```
* Bypasses card drop end screens, black screen waiting transitions, and vote confirmation delays.

---

## 62. End-Screen Card Drops & Loot Generation Engine

### Engine Class: `LootDropManager` (`lib/managers/lootdropmanager`)
```lua
LootDropManager:make_drop(category, drop_pc, peer_id)
```
* Generates weapon mod, mask, pattern, material, or Continental Coin loot cards.

---

## 63. Hostage Count & Assault Wave Delay

### Engine Mechanism in `GroupAIStateBesiege`:
* Each tied civilian or dominated police hostage adds +10 seconds to the police assault break / regroup phase up to the difficulty maximum (e.g. 60s extra peace time).

---

## 64. Swan Song, Messiah & Self-Revive Triggers

### Engine Classes & Source Locations
* **`PlayerDamage`**: `lib/units/beings/player/playerdamage`
* **`PlayerManager`**: `lib/managers/playermanager`

### Method Signatures
```lua
PlayerDamage:_check_bleed_out() -- Swan Song trigger entry point
PlayerManager:messiah_charges() -- Returns remaining Messiah self-revive charges
PlayerDamage:clbk_feign_death() -- Feign Death RNG roll calculation
```

---

## 65. Stealth Body Bag Cleanup & Corpse Disposer

### Engine Logic:
* Sweeps dead enemy body units (`World:find_units_quick("all", managers.slot:get_mask("corpses"))`) and calls `unit:set_slot(0)` or triggers corpse interaction directly to place into body bags automatically.

---

## 66. Guard Patrol Pathfinding & Stealth GPS Navigation

### Engine Classes & Source Locations
* **`CopActionWalk`**: `lib/units/enemies/cop/actions/lower_body/copactionwalk`
* **`Application` / `Draw`**: 3D Debug render primitives (`draw_cylinder`, `draw_sphere`, `Draw:brush`)

### Engine Logic:
* Hooks `CopActionWalk:update(t)` to access `self._nav_path`.
* Checks `managers.groupai:state():whisper_mode()` and `alive(self._unit)`.
* Computes real-time world-space waypoint coordinates via `self._nav_point_pos(positions[i])`.
* Draws 3D laser-projected navigation lines connecting waypoints directly to the guard's destination sphere.
* Renders 3D overhead character labels rotated to face active player camera (`camera:rotation():x()` and `camera:rotation():z()`).

