# Sapphire+ Safe Mode Restrictions

The **Safe Mode** system in Sapphire+ is designed to protect the integrity of multiplayer lobbies and prevent accidental cheating when playing with randoms or joining other hosts.

The mod intelligently detects whether you are playing alone, hosting a game, or joining someone else's lobby, and it automatically caps or disables specific features based on your status.

---

## 🟢 PvE (Offline / Single Player)
When playing offline or in a strictly single-player environment:
- **Restrictions:** None.
- **Behavior:** You have absolute freedom. Every setting, slider, and toggle operates exactly as you configure it. There are no limits to jump height, throw distance, damage reduction, or interaction speeds.

---

## 🟡 Host (Multiplayer)
When you are hosting a multiplayer lobby and other players join you:
- **Restrictions:** None (by default).
- **Behavior:** As the host of the lobby, you make the rules. The mod functions identically to Single Player, allowing you to use all extreme values without restrictions.
- **Optional Override:** You can enable the **Force Safe Mode (Host)** toggle in the mod options. If checked, your own game will restrict your modded values to the "Client" limits (see below) so you play fairly alongside your guests.

---

## 🔴 Join (Client Multiplayer)
When you join another player's hosted lobby as a client (assuming Safe Mode is enabled in your options):
- **Restrictions:** Active (Regulated).
- **Behavior:** The mod categorizes features into three groups to ensure you don't break the host's game or look like a blatant cheater:

### 1. No Go (Disabled Completely)
These features are considered unfair advantages in a standard lobby and are entirely disabled when joining:
- **Instant Interaction Timer** (No Interaction Cooldown)
- **Infinite Stamina**
- **No Fall Damage**
- **Ignore Armor Speed Penalty**
- **No Weapon Restrictions** (Heavy bags will restrict weapons as normal)
- **Auto-Answer Pagers**
- **Affect Body Bags**
- **AI Can't Alarm** (Includes God Mode)

### 2. Acceptable but Regulated (Capped)
These features are allowed but heavily throttled to look like normal network desync or minor latency rather than blatant cheating:
- **Jump Height:** Capped at a maximum of **1.1x**.
- **Throw Distance:** Capped at a maximum of **1.25x**.
- **Interaction Range:** Capped at a maximum of **1.25x**.
- **Bag Shield (Damage Reduction):** Capped at a maximum of **50%**.

### 3. Acceptable (Unrestricted)
These features rely entirely on vanilla game mechanics or don't affect other players, so they remain fully active:
- **Weightless Carry** (Movement speed returns to normal while carrying a bag).
- **Always Sprint** (The ability to run with heavy bags).
- **Random Pagers** (Spawning guards with no pagers works based on the host's level generation, though mileage may vary depending on sync).

---

> **Note:** If you want to bypass the "Join" restrictions, you can turn off the `SafeMode` toggle in the Sapphire+ options entirely. However, doing so in public lobbies is highly discouraged and may result in kicks or bans by hosts running anti-cheat trackers.
