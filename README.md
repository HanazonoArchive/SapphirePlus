# Sapphire+

**The Ultimate Carry Overhaul & Host Sandbox for PAYDAY 2**

Sapphire+ is a comprehensive accessibility, quality of life (QoL), and sandbox toolkit mod. It modernizes PAYDAY 2's clunky bag carrying mechanics, provides robust sandbox options for hosts who want to run custom game scenarios, and features a strict "Safe Mode" architecture to ensure you never accidentally ruin someone else's public lobby.

---

## 🌟 Key Features

### 🎒 Carry & Movement Overhaul
Moving loot shouldn't feel like a chore. Sapphire+ removes the frustrating speed penalties of heavy armor and allows you to customize how you interact with bags.
* **Always Sprint:** Run freely while carrying even the heaviest of bags.
* **Jump & Throw Multipliers:** Customize how high you can jump and how far you can throw bags.
* **Ignore Armor Penalties:** Wearing the ICTV will no longer slow you down when carrying loot.
* **Body Bag Support:** Optionally apply all carry buffs directly to body bags.

### ⚡ Quality of Life & Accessibility
Options for players who want a more relaxed or streamlined heist experience.
* **Instant Interactions:** Remove the interaction timer completely.
* **Infinite Stamina:** Never run out of breath while sprinting with a bag.
* **No Fall Damage:** Take zero fall damage while carrying a bag.
* **Bag Shield:** Dial in a custom damage reduction percentage (0-100%) that protects you while you are actively carrying a bag.

### 🎭 Host Sandbox Tools
Host your own lobbies and manipulate the game's core AI logic to create custom gamemodes.
* **AI Can't Alarm:** Enemies can detect you, pull their guns, and engage in a full shootout, but they are physically incapable of sounding the global alarm. Perfect for "loud stealth" scenarios! *(Includes full God Mode while active).*
* **Random Pagers:** Randomize which guards have pagers, keeping you on your toes.
* **Auto-Answer Pagers:** Automatically answers any pagers that spawn.
* **Selective DLC Heist Unlocker:** Instantly unlock specific DLC heists (defined in your `dlcs-to-unlock.txt` file) so you can host them for your friends.

---

## 🛡️ The "Safe Mode" Architecture (Public Lobby Safe)

Unlike other overhaul mods, Sapphire+ is built from the ground up to respect the PAYDAY 2 multiplayer community. It features an intelligent **Safe Mode** system that detects your network state.

If you join someone else's lobby as a client, Sapphire+ acts as a polite guest:
1. **Game-Breaking Features are Disabled:** Sandbox tools like *AI Can't Alarm*, *Instant Interactions*, and *Infinite Stamina* are completely disabled. 
2. **Movement is Throttled:** Your jump height, throw distance, and interaction range are capped to low multipliers that look like normal network desync to other players.
3. **Vanilla Mechanics Remain:** Things that rely on vanilla engine mechanics (like sprinting with bags) remain active but fair.

*When you play Offline or Host your own game, you have absolute freedom and all features are fully unlocked!*

---

## 📥 Installation

1. Ensure you have [SuperBLT](https://superblt.znix.xyz/) installed.
2. Drop the `Carry++` folder into your `PAYDAY 2/mods/` directory.
3. Launch the game and configure your settings in the **Options > Mod Options > Sapphire+ Options** menu.

*(Note: The DLC Heist Unlocker feature requires a game restart to take effect after toggling).*
