# GG-DrivingSchool 🚗

A high-quality, interactive driving school script for **QBCore** featuring a Theory Test (NUI-based), a Practical Driving Test with checkpoints, and an advanced License Management system.

---

## 🌟 Key Features

* **Two-Stage Testing- ORIGINAL**: Includes a custom NUI theory exam followed by a live driving practical with a dedicated instructor vehicle.
* **Inventory Protection- ADDED**: Automatically prevents players from re-purchasing a test if they already have a license item in their inventory.
* **Database Syncing - ADDED**: Saves license status to player metadata. If a player has a physical license item from a previous script, this script will "Legacy Sync" it to their database automatically.
* **Smart Reprint System - ADDED**: 
    * Players who lost their card can buy a replacement for **75% of the original cost**.
    * The "Reprint" option **only** appears if the player has passed the test but doesn't have the card in their pocket.
* **Progress Persistence -- Updated**: If a player passes the Theory test but fails the Driving test, the script remembers. They can skip straight back to the driving portion on their next attempt.
* **Fail Cooldown -- Updated**: Includes a configurable cooldown (default 20 mins) after failing to prevent "brute-forcing" the test.
* **Multi-Inventory/Target Support -- Updated**: Optimized for `qb-inventory`, `ox_inventory`, `qb-target`, `ox_target`, and `interact`.

---

## 🛠️ Commands -- ADDED

| Command | Description | Permission |
| :--- | :--- | :--- |
| `/checklicense` | View your current theory, practical, and cooldown status. | Player |
| `/grantlicense [ID]` | Instantly grants license metadata and the item to a player. | Admin |

---

## 📦 Installation

1.  **Item Creation**: Ensure you have the `driver_license` item in your `shared/items.lua` (for QB) or `data/items.lua` (for OX).
    ```lua
    ['driver_license'] = {['name'] = 'driver_license', ['label'] = 'Drivers License', ['weight'] = 0, ['type'] = 'item', ['image'] = 'driver_license.png', ['unique'] = true, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A drivers license for operating motor vehicles.'},
    ```

2.  **Dependencies**:
    * `qb-core`
    * `ox_lib` (Used for server callbacks)
    * A target system (`qb-target` or `ox_target`)

3.  **Config**: Ensure `Config.Inventory` and `Config.Target` in your `config.lua` match the scripts you use on your server.

---

## 📝 Script Logic Flow

1.  **The Check**: When clicking "Start Test", the server checks for:
    * Existing metadata (Has the player already passed?)
    * Existing item (Does the player already have the card?)
    * Cooldown (Is the player currently timed out?)
2.  **The Payment**: If checks pass, the fee is deducted from the bank.
3.  **Theory Stage**: Player answers questions in the UI. Progress is saved to metadata immediately upon passing.
4.  **Practical Stage**: A car spawns. The player must hit checkpoints, stay under the speed limit, and avoid vehicle damage.
5.  **Completion**: Upon finishing, the player receives the "Driver" metadata flag and a physical item with their character details.

---
*Developed for QBCore Framework*

Original Author and credit to GreenGhost
Added features by Freakii79ttv: 
