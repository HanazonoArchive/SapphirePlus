# Sapphire+

**Modular Gameplay, Carry, and Stealth Overhaul for PAYDAY 2**

Sapphire+ is a comprehensive, modular SuperBLT modification for PAYDAY 2. It modernizes loot carry mechanics, expands solo stealth capabilities with multi-keycard pickup and infinite camera loops, removes loadout detection penalties, eliminates pre-planning budget constraints, and provides a customizable in-game menu.

All features are fully configurable in-game and protected by an intelligent multiplayer **Safe Mode** system to ensure seamless, fair play in public lobbies.

---

## Features Overview

### Stealth & Infiltration
* **Multi-Pickup (Keycards & Consumables):** Enables stacking consumable mission items (Keycards, Planks, C4, Thermite) in your inventory without hitting vanilla quantity restrictions. Allows solo heisters to open multi-keycard objectives such as the Shadow Raid vault.
* **Infinite Camera Loop:** Extends tape loop duration to 99,999 seconds. Fully synchronized with Extra Heist Info (EHI) and HUD timer overlays.
* **Minimum Detection Risk (Always 3):** Forces detection risk to the engine minimum (3 Detection Risk / 0.0 suspicion offset) regardless of equipped armor (ICTV) or heavy weapons, while granting maximum bonuses to *Sneaky Bastard* and *Low Blow*.
* **AI Can't Alarm:** Prevents guards, civilians, and law enforcement units from raising the global alarm or shooting panic flares.
* **Random Pager Removal:** Configurable slider (1% to 100%) that gives security guards a random chance to drop no pager upon elimination, preserving your 4-pager limit.
* **Auto-Answer Pagers:** Automatically answers security pagers immediately upon neutralizing guards.

### Carry & Movement Mechanics
* **Carry Weight & Sprint Overhaul:** Sprint freely at full speed while carrying gold, artifacts, or nuclear warheads. Eliminates the movement and jumping penalties associated with heavy bags.
* **Bag Throw Distance Multiplier:** Configurable slider (1.0x to 5.0x) to toss loot bags over fences, across rooftops, or directly into escape vehicles.
* **Jump Height with Heavy Bags:** Retains full jumping height while carrying any loot type, allowing effortless vaulting over obstacles.
* **Affect Body Bags:** Optionally applies all carry sprint, jump, and movement multipliers directly to civilian and guard body bags.
* **Ignore Armor Movement Penalties:** Removes agility, stamina drain, and movement speed penalties when wearing heavy ballistic vests and the Improved Combined Tactical Vest (ICTV).
* **No Fall Damage:** Eliminates fall damage when jumping from roofs, balconies, or crane platforms while carrying loot.
* **Bag Damage Absorption (Bag Shield):** Configurable damage reduction (0% to 100%) applied while actively carrying a loot bag.
* **God Mode (Invincible):** Zeroes all incoming bullet and melee damage. A dedicated cheat-tier toggle, independent of "AI Can't Alarm"; automatically disabled by Safe Mode when joining as a multiplayer client.
* **Infinite Stamina:** Prevents stamina drain **while carrying a loot bag**, so you never slow to a walk mid-carry. (It does not remove stamina drain when you are not carrying.)

* **Anti-Flashbang Shield:** Grants complete immunity against flashbang whiteout blinding screens, camera shake, and ear-ringing audio.
* **Instant Full-Charge Melee:** Quick-tap melee attacks automatically deliver 100% full charged damage and maximum knockdown impulse without holding the key.
* **No Weapon Sway (Zero Drift):** Nullifies stance breathing amplitudes across all stances for laser-steady crosshairs and precision aiming.
* **Fast Weapon Reload (2.5x):** Accelerates primary and secondary weapon magazine and shotgun reloads by 2.5x.
* **Instant Mask On:** Puts on your mask immediately in casing mode without holding the interaction key for 2 seconds.
* **Instant Armor Recovery:** Regenerates broken armor shields instantly upon exiting combat without the standard 3-second delay.
* **Sentry Gun Invulnerability:** Makes player-placed sentry guns immune to bullet, fire, and explosive damage.
* **Infinite Weapon Ammo:** Prevents weapon clip depletion upon firing with zero reload downtime.
* **No Weapon Recoil:** Completely eliminates vertical and horizontal recoil kick when firing any weapon.
* **No Bullet Spread (Laser Beam):** Zeroes bullet cone deviation for pin-point laser accuracy on all guns.
* **All Weapons Full Auto:** Enables full-automatic fire mode toggling on semi-auto pistols, DMRs, and shotguns.
* **Infinite Cable Ties:** Unlimited cable ties to secure all civilians and hostages in stealth or crowd control.
* **Infinite Body Bags:** Unlimited body bags to package and hide eliminated guards in stealth operations.
* **Infinite Throwables & Grenades:** Prevents grenades, molotovs, and shurikens from depleting on throw.
* **Fast Weapon Swap (3x Speed):** Triples weapon switching animation speed for rapid arsenal cycling.
* **Disable All Alarm Lasers:** Tactical in-game action that instantly deactivates all laser grids, tripwires, and alarm sensor fields map-wide.
* **Unlock & Open All Doors:** Tactical in-game action that instantly unlocks all doors, security rooms, and keycard gates.
* **Open All Deposit Boxes & ATMs:** Tactical in-game action that instantly pops open all safe deposit boxes, ATMs, and lockers.
* **Fix & Finish All Drills:** Tactical in-game action that instantly unjams and fast-forwards all active drills, saws, and hacking panels.
* **Restock All Supplies:** Tactical in-game action that instantly replenishes player health, armor, weapon ammunition, throwables/grenades, cable ties, and body bags to 100% capacity.
* **Unlimited Pre-Planning Favors:** Removes pre-planning favor budget limits and sets asset favor and offshore cash costs to $0. Purchase every asset and escape route without restriction.
* **Extended Interaction Range:** Increases interaction distance up to 5x, allowing lockpicking, keycard grabbing, and pager answering through grates or from cover.
* **Instant Interactions:** Completes interactions (bag pickup, cable tying, lockpicking, pager responses) immediately without waiting for progress bars.
* **Unlock DLC Heists for Hosting:** Allows you to host any paid DLC heist on Crime.net for your squad (configured via `dlcs-to-unlock.txt`).
* **Single-Page Menu:** Clean, priority-sorted menu under **Options > Mod Options > Sapphire+ Options** with category headers and zero sub-menus.

---

## Safe Mode Architecture

Sapphire+ includes an automated **Safe Mode** system designed to prevent anti-cheat triggers and desyncs when joining other players:

| Mode / Environment | Safe Mode Status | Behavior |
|---|---|---|
| **Singleplayer / Offline** | Inactive | All features and maximum multipliers are fully unlocked. |
| **Lobby Host** | Inactive | The host has full control over all modules and multipliers. |
| **Multiplayer Client** | **ACTIVE** | Cheat-tier features (God Mode, AI Can't Alarm, Instant Interactions, Infinite Stamina, Unlimited Favors) are automatically neutralized. Interaction distance and bag throw multipliers are capped to safe, desync-tolerant thresholds. |

*You can also force Safe Mode permanently for host sessions via the in-game settings menu.*

---

## Installation

### Requirements
* **[PAYDAY 2](https://store.steampowered.com/app/218620/PAYDAY_2/)** (PC / Steam)
* **[SuperBLT](https://superblt.znix.xyz/)** (Latest release)

### Setup
1. Download or clone this repository.
2. Extract the `Sapphire+` folder into your PAYDAY 2 `mods/` directory:
   ```text
   PAYDAY 2/mods/Sapphire+/
   ```
3. Launch PAYDAY 2.
4. Navigate to **Options > Mod Options > Sapphire+ Options** to customize your settings.

### Keybind Configuration
To set up a quick toggle hotkey, go to **Options > Mod Keybinds** and assign a key to **Toggle Sapphire+**.

---

## Documentation & Developer Guide

* **Developer Guide:** See [`ADDING_FEATURES.md`](ADDING_FEATURES.md) for architectural details, the 5-step pipeline for adding new hooks, and local function dump documentation.
* **Safe Mode Documentation:** See [`SafeMode_Restrictions.md`](SafeMode_Restrictions.md) for a breakdown of multiplayer client limitations.
* **Showcase Webpage:** Open `docs/index.html` in your web browser or enable GitHub Pages on the `/docs` folder.

---

## License

This project is licensed under the **MIT License**. See the [`LICENSE`](LICENSE) file for full details:

```text
MIT License

Copyright (c) 2026 Sapphire+ Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Disclaimer

PAYDAY 2 is a registered trademark of Starbreeze Studios AB and OVERKILL Software. Sapphire+ is an independent, community-created modification and is not affiliated with or endorsed by Starbreeze Studios or OVERKILL Software.
