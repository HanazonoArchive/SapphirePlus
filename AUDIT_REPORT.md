# Sapphire+ Hardening Audit Report

**Project:** Sapphire+ (PAYDAY 2 SuperBLT overhaul)
**Audit date:** August 2026
**Scope:** Full-codebase correctness/robustness audit — every feature cross-verified against decompiled PAYDAY 2 source *and* the web, then fixed so each one works as intended.

---

## 1. Objective & Method

The mandate was to *"audit and bulletproof"* the mod so **every feature works as intended**, with **zero guessing** — every engine fact (class name, method signature, return tuple, `tweak_data` field) verified before it was relied on.

The single most important property of this codebase is that **a wrong hook path or a wrong method name fails silently.** SuperBLT does not crash or log when a detour targets a class/method that does not exist — the hook simply never fires. So the whole class of bugs found here is *"code that looks correct, registers cleanly, and does nothing."* Every fix below was validated against one or more of:

- **Decompiled source** — `Payday-2-LuaJIT-Complete` / `mwSora/payday-2-luajit` (local copy at `pd2src`). File + line references are cited inline in the code comments.
- **SuperBLT documentation** — hook lifecycle, `Hooks:PostHook`/`PreHook`, `DelayedCalls`.
- **Local dumps** — `logs/FunctionsDump.txt` (live in-engine method lists).

Three bug classes were found and eliminated:

1. **Dead hooks / phantom fields** — detours on methods and `tweak_data` fields that do not exist in the engine (silent no-ops).
2. **Wrong call signatures** — real methods called with the wrong arguments, so they never did anything (or errored inside a `pcall` that swallowed it).
3. **State leaks** — buffed values written into *shared* `tweak_data` that were never restored when a feature was toggled off, so the buff persisted into vanilla code paths.

---

## 2. Summary of Changes

| Area | Files | Result |
|---|---|---|
| Dead hooks removed | `CopBrain`, `DrillOverhaul`, `MinDetectionRisk`, `OmnidirectionalSprint`, `PlayerManager` | 6 non-existent method hooks deleted |
| Phantom `tweak_data` fields removed | `CarryTweakData`, `InteractionExt`, `MultiPickup`, `InfiniteCameraLoop`, `MenuManager` | `sprint_speed_modifier`, `weapon_category_fallback`, `amount`, `tape_loop_duration_2` |
| Wrong signatures fixed | `CustodyActions`, `JokerActions`, `ReviveActions`, `MinDetectionRisk` | 4 features that silently never worked now work |
| State-leak fixes | `MultiPickup`, `InfiniteCameraLoop`, `Utils` (+ live-apply registry) | toggling off now restores vanilla values |
| Idempotency guards | `AutoCooker`, `DrillOverhaul`, `UnlimitedFavors`, `GroupAIStateBase`, `DLCManager`, `MinDetectionRisk`, `OmnidirectionalSprint`, `CarryRestrictions` | dual-registered files no longer double-wrap |
| Feature redesign | `PlayerDamage` (God Mode), `GroupAIStateBase` (AI Can't Alarm), `CarryRestrictions` (new) | correct, decoupled implementations |
| Crash-safety | `DLCManager`, `PlayerMovement`, `Logger` | nil-guards + always-on log file |
| Cleanup | `DoorActions`, `EnemyActions`, `GageActions`, `LootActions`, `Config` | dead `slot-1` sweeps + dead settings removed |
| Docs corrected | `REPORT.md`, `ADDING_FEATURES.md`, `FEATURE_MEMORY_BANK.md`, `README.md`, `SafeMode_Restrictions.md` | 5 stale/wrong facts fixed |

**1 new file, 34 modified.**

---

## 3. New File

### `hooks/CarryRestrictions.lua`
- **What:** Detours the static, server-only `CarryData._register_remove_on_weapons_hot(unit, carry_id)` to a no-op when `NoWeaponRestrictions` is on.
- **Why:** The old "No Weapon Restrictions" feature was a myth — PAYDAY 2 has **no "cannot fire while carrying" rule** (you can always shoot while holding a bag). The only real carry restriction tied to going loud is that body bags with `remove_on_weapons_hot` set are auto-disposed ~2s after enemies go weapons-hot. This hook suppresses that disposal so you keep hauling the bag.
- **Verified:** `lib/units/props/carrydata.lua:18` (static fn definition) and `:709` (call site in `set_carry_id` gated on `carry_tweak.remove_on_weapons_hot`). The function early-returns for non-servers, so it is inert for MP clients — doubly safe under Safe Mode.
- Registered in `mod.txt` on `lib/units/props/carrydata`. Idempotency-guarded (`_sapphire_carryrestrict_hooked`).

---

## 4. Correctness Fixes (features that silently did nothing)

### `hooks/OmnidirectionalSprint.lua` — hooked a method that doesn't exist
- **Before:** Detoured `PlayerStandard:_can_run` — **which does not exist** on `PlayerStandard`. The hook registered cleanly and never fired; 360 sprint was a placebo.
- **After:** Detours the real `PlayerStandard:_can_run_directional()`, returning `true` when enabled to remove only the forward-cone angle limit.
- **Verified:** `lib/units/beings/player/states/playerstandard.lua` + `logs/FunctionsDump.txt` — `_can_run_directional` exists, `_can_run` does not. Crouch/steelsight interrupts live in separate checks (`_start_action_running`), so forcing this true does **not** let you sprint while aiming or crouched.

### `hooks/CopBrain.lua` — hooked a method that doesn't exist
- **Before:** A `Hooks:PostHook(CopBrain, "set_data", …)` finalized the pager-removal flag — but `CopBrain:set_data` **does not exist** in the engine.
- **After:** Removed that PostHook; the `update`-tick PostHook is the sole finalizer (it already existed). Also fixed the `post_init` gate to respect the master `Enabled` flag and to fire when *either* `RandomPagers` or `AutoAnswerPagers` is on.
- **Verified:** decompiled `copbrain.lua` — no `set_data`.

### `hooks/MinDetectionRisk.lua` — wrong return arity + non-existent hooks
- **Before:** The suspicion getters returned a bare `return 0`. The engine's getters return a **3-tuple** `(value, max_reached, min_reached)`; the concealment UI reads the 2nd/3rd values to color/flag the readout. Returning one value made the "0" readout render in the max-detection *warning* color. It also hooked `get_real_armor_concealment` / `get_armor_concealment`, **neither of which exists**.
- **After:** Getters return `0, false, true` (fully concealed: `max_reached=false`, `min_reached=true`). The two phantom concealment hooks were deleted. `get_suspicion_offset_from_custom_data` now passes through all its args instead of hardcoding the first.
- **Verified:** `lib/managers/blackmarketmanager.lua:3150-3164` — tuple is `(val, index == 1, index == #concealment - 1)`; `get_*_armor_concealment` has zero tree-wide hits.

### `libs/CustodyActions.lua` — wrong argument, never worked
- **Before:** Called `managers.trade:clbk_respawn_criminal(name)` (passing a **name**), pushed malformed `{id=name}` records, and referenced non-existent `respawn_criminal` / `_criminals` fields. Nothing respawned.
- **After:** Zero every queued criminal's `respawn_penalty`, then drain the queue by calling the **no-arg** `clbk_respawn_criminal()` (it self-selects the next eligible criminal), with a loop guard.
- **Verified:** `lib/managers/trademanager.lua` — `_criminals_to_respawn` is an array of records with `respawn_penalty` (`:419`, `:6`); `get_criminal_to_trade(false)` (`:273`) only returns criminals whose penalty ≤ 0; `clbk_respawn_criminal(pos, rotation)` (`:958`) takes a **position**, self-selects, respawns (`:980`), and dequeues (`:1048`).

### `libs/JokerActions.lua` — wrong argument silently capped conversions
- **Before:** `convert_hostage_to_criminal(unit, player)` — passing `peer_unit`.
- **After:** `convert_hostage_to_criminal(unit)` — **no** peer_unit.
- **Why:** `groupaistatebase.lua:5081` reads the minion cap two ways — with a `peer_unit` it reads `peer_unit:base():upgrade_value(...)` (which our upgrade override does **not** cover → real cap of 0 applies → conversion silently fails); with no `peer_unit` it reads `managers.player:upgrade_value(...)`, which our hook forces to 999 → conversion always succeeds.

### `libs/ReviveActions.lua` — attempted the impossible, faked the rest
- **Before:** Iterated *all* criminals (including remote humans) and poked `_incapacitated` / `_tased` fields directly to fake a revive.
- **After:** Revives the **local player** (`PlayerDamage`) and **AI bots** (`TeamAIDamage`) only, guarded on the damage ext actually implementing `revive`/`need_revive`. Remote humans are intentionally skipped.
- **Verified:** `revive()`/`need_revive()` exist only on `PlayerDamage` (`:2514`/`:2574`) and `TeamAIDamage` (`:1094`/`:1072`). Remote humans use `HuskPlayerDamage`, which defines **neither** — a downed remote player can only be revived by their own client; forcing it host-side would desync.

---

## 5. State-Leak Fixes (buffs that persisted after toggle-off)

The core problem: several features wrote buffed values into **shared** `tweak_data`. When toggled off mid-heist, the now-disabled detour called the *original* engine method, which read the still-mutated `tweak_data` — so the buff never went away.

### New infrastructure — Live-Apply Registry (`libs/Utils.lua`)
```
Sapphire:RegisterLiveApply(fn)   -- hooks register a re-sync callback
Sapphire:ApplyLiveTweaks()       -- runs ApplyCarryModifiers + all callbacks (each pcall'd)
```
`hooks/MenuManager.lua`'s setting-change handler now calls `ApplyLiveTweaks()` (was inline carry logic). Every registered callback is idempotent and decides *apply-vs-restore* from its own effective settings.

### `hooks/MultiPickup.lua`
- Added `restore_multi_pickup_tweaks()` and made the apply path **restore** vanilla `max_quantity` / `special_equipment_block` when the feature is off. Registered with the live-apply registry.
- Removed phantom `data.amount = 999` writes — the engine reads `max_quantity` in `_can_pickup_special_equipment`; `tweak_data.amount` is never read (live count lives on `self._equipment.specials[name].amount`).

### `hooks/InfiniteCameraLoop.lua`
- Captures the vanilla `tape_loop_duration` once, applies `99999` when on, and **restores** the captured value when off. Registered with the live-apply registry.
- Removed phantom `tape_loop_duration_2` write (field does not exist).
- **Why restore matters:** vanilla `SecurityCamera:_start_tape_loop_by_upgrade_level` reads `tweak_data.upgrades.values.player.tape_loop_duration` directly — leaving it at `99999` keeps loops permanent even with the detour disabled.

### `libs/Utils.lua` — `ApplyCarryModifiers` single source of truth
- **Body-bag gate fixed:** was gated on item id `"person"`, but `tweak_data.carry.types` is keyed by **weight-class**, not item id — so the gate never matched and body bags were always buffed regardless of `AffectBodyBags`/Safe Mode. Now gates on the `"being"` weight-class (the class used by `person` + `special_person`).
- Removed 3 dead helper functions referencing phantom fields (`IsCarryingBodyBag`, `GetPlayerCarryTypeName`, `GetVanillaCarryModifiers`).
- `CarryTweakData.lua` and `InteractionExt.lua` now both delegate here instead of duplicating (drift-prone) inline logic.

---

## 6. Feature Redesigns

### God Mode (`hooks/PlayerDamage.lua`)
- **Before:** Invincibility was an undocumented side effect of "AI Can't Alarm" (it zeroed `attack_data.damage` only in `damage_bullet`/`damage_melee`). You couldn't get one without the other, and coverage was bullet+melee only.
- **After:** A dedicated `GodMode` toggle that sets the engine's **native `_god_mode` flag**, honored at *every* damage entry point (bullet, tase, melee-via-bullet, explosion, fire, killzone, fall, simple). Enforced every frame from a `PlayerDamage:update` PostHook as `_god_mode = Global.god_mode or (Enabled and GodMode)` — survives respawns/live-toggle and never clobbers the game's own console/scripted god mode when ours is off.
- **Bag Shield** split into `apply_bag_damage_reduction(attack_data)` with a **re-entrancy guard** (`_sapphire_dmg_modded`) — `damage_melee` re-enters via `damage_bullet` (`playerdamage.lua:1189`), so without the guard the reduction applied twice per melee hit.
- **Verified:** `lib/units/beings/player/playerdamage.lua` — `_god_mode`'s only vanilla writers are `init` (seeds from `Global.god_mode`) and `set_god_mode` (sets both).

### AI Can't Alarm (`hooks/GroupAIStateBase.lua`)
- **Before:** Distinguished scripted vs organic alarms via `called_reason ~= "script"` — **dead code**: the engine never passes a `"script"` reason. Scripted loud transitions share the same `on_police_called` method with an ordinary/nil reason, so this could have soft-locked scripted-loud heists.
- **After:** Tags the *source* instead of the reason: a second detour on `ElementAiGlobalEvent:on_executed` sets a flag (pcall-wrapped, always restored) while a mission-script event runs. `on_police_called` suppresses only when `whisper_mode() and not scripted` — organic detection is blocked in stealth; scripted loud transitions always pass through.
- Registered on **both** `groupaistatebase` and `elementaiglobalevent` for load-order safety; both detours idempotency-guarded.

---

## 7. Robustness & Crash-Safety

### `hooks/DLCManager.lua` — would crash on non-matching platforms
- **Before:** Unconditionally detoured `WinSteamDLCManager` / `WinEpicDLCManager` / `WINDLCManager` as globals (also leaking `old_steam_check` etc. into `_G`). A Steam install has no `WinEpicDLCManager` — indexing the nil manager **crashes the mod**.
- **After:** A guarded `install_check(manager)` helper using `rawget(_G, ...)`, per-class origin capture, idempotency, no global leaks.

### Idempotency guards on dual-registered files
Files registered on two `hook_id`s run their top-level code **twice**. Raw detours (`local orig = X.m; function X:m()…`) are **not** idempotent — double-wrapping stacks the detour or captures the already-wrapped function as "original." Added `_sapphire_*_hooked` guards to:
`AutoCooker` (dialogmanager + objectinteractionmanager), `DrillOverhaul` (timergui + drill), `UnlimitedFavors` (preplanningmanager + moneymanager), `GroupAIStateBase` (groupaistatebase + elementaiglobalevent), plus class-scoped guards on `DLCManager`, `MinDetectionRisk`, `OmnidirectionalSprint`, `CarryRestrictions`.

### `hooks/DrillOverhaul.lua` — removed 3 phantom hooks
Deleted `TimerGui:set_timer` (does not exist), `Drill:clbk_jam`, `Drill:clbk_power_cut` (neither exists). Kept the verified `_start` / `start` / `set_jammed` / `_set_jammed` / `update` failsafe.

### `libs/Logger.lua` — always persist the log
The Debug flag previously suppressed **file** logging too. Since the mod's main failure mode is a silently-unloaded hook, the on-disk log is the only diagnostic — it now always writes to `logs/Sapphire+.log`; the Debug flag gates only the noisy console echo.

### `hooks/PlayerMovement.lua`
Added a nil-guard: `value and value < 0` (defensive — `_change_stamina` can receive nil).

---

## 8. Cleanup

- **Dead `World:find_units_quick("all", 1)` sweeps removed** from `DoorActions`, `EnemyActions`, `GageActions`, `LootActions`. Slot `1` is not a meaningful interaction mask — these brute-force passes never matched useful units and only cost perf. The real slot-mask / `_interactive_units` passes were kept.
- **`libs/CorpseActions.lua`** — removed `managers.enemy:all_corpses()` (does not exist; `EnemyManager` only defines `all_enemies`, `enemymanager.lua:432`) and the `"player_interactions"` slot-mask sweep (that mask is not defined in `SlotManager._masks`). Kept the real `"corpses"` slot-17 mask + `_interactive_units` `"corpse_dispose"` sweep.
- **`libs/Config.lua`** — removed dead keys `WalkSpeed` / `SprintSpeed` / `CrouchWithCarry`; added `GodMode = false`; set `Debug = false` and `BagDamageReduction = 50` (numeric, was `false`).
- **`hooks/MenuManager.lua`** — `ExtendedInteract` slider max reduced `30.0 → 5.0` (30× interaction range is desync-risky and unusable); added the God Mode toggle (priority 695.5); renamed "No Weapon Restrictions" → "Keep Body Bags When Loud" with an accurate description (setting **key** unchanged for `settings.json` compatibility).

---

## 9. Documentation Corrections

Cross-verified against source and corrected in `REPORT.md`, `ADDING_FEATURES.md`, `FEATURE_MEMORY_BANK.md`, `README.md`, `SafeMode_Restrictions.md`:

1. **Suspicion tuple** — corrected to `(value, max_reached, min_reached)` = `(val, index == 1, index == #concealment - 1)` (one doc had the flags backwards).
2. **God Mode mechanism** — documented as the native `_god_mode` flag enforced via `PlayerDamage:update`, decoupled from AI Can't Alarm.
3. **Hook count** — corrected to 22 registrations / 18 unique hook scripts.
4. **AutoCooker location** — documented as an in-game tactical-menu toggle (`InGameMenu.lua` item 04), force-reset to `false` each mission init — **not** a BLT options widget.
5. **Phantom carry fields** — noted that `sprint_speed_modifier` / `weapon_category_fallback` do not exist; carry types carry only `move_speed_modifier`, `jump_modifier`, `throw_distance_multiplier`, `can_run`.
6. **Team Revive** — documented that remote human players cannot be host-revived.

---

## 10. Verification Status

| Check | Status |
|---|---|
| Every hooked method verified to exist in decompiled source | ✅ |
| Every `tweak_data` field verified to exist | ✅ |
| Every method call signature / return arity verified | ✅ |
| Dual-registered files idempotency-guarded | ✅ |
| Toggle-off restores vanilla state (no leaks) | ✅ |
| No references to removed dead helpers remain (grep-confirmed) | ✅ |
| Live-apply wiring coherent across Utils/MenuManager/MultiPickup/InfiniteCameraLoop | ✅ |
| Safe Mode neutralizes cheat-tier features + tactical actions for MP clients | ✅ |

**Not covered by this audit — requires a live game session:** in-engine runtime testing (toggle on/off during an actual heist, host-vs-client behavior, persistence across restarts). The static audit is exhaustive against source, but the final checklist item — running it in PAYDAY 2 — is on the user. If issues surface, `logs/Sapphire+.log` (now always written) is the diagnostic.

---

*Every fact in this report was verified against decompiled PAYDAY 2 source before the corresponding change was made — per the project mandate, no engine behavior was assumed.*
