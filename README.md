# mxm_plug
'NPC Waypoint and Shop Script'
Here’s a draft for your `README.md` file for the GitHub repository of your "NPC Waypoint and Shop Script":

---

# NPC Waypoint and Shop Script

A FiveM script that spawns NPCs offering waypoints to specific dealers (Plug NPC and Gun NPC) and allows players to purchase items from them. This script integrates with `ox_lib`, `ox_target`, `ox_inventory`, and `es_extended` for smooth interaction and inventory management.

## Features
- **Waypoint Purchase System**: Buy waypoints to the Plug NPC or Gun Dealer NPC.
- **Jail and Bail System**: NPCs can be jailed based on player interactions, with a system to bail them out.
- **Item Shops**: Purchase various items from the Plug NPC and Gun Dealer NPC.
- **Randomized NPC Locations**: NPCs spawn at random locations that change every real-life hour.
- **Police Alerts**: Chance for the Plug NPC to alert the police, notifying law enforcement of suspicious activity.
- **Configurable**: Customize NPC locations, items, prices, jail chances, and more in `config.lua`.

## Requirements
- [ESX Framework](https://github.com/esx-framework/es_extended)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [mysql-async](https://github.com/brouznouf/fivem-mysql-async) (or oxmysql if you're using ox_lib database management)

## Installation

1. **Clone or download the repository**:
   ```bash
   git clone https://github.com/YourGitHubUsername/npc-waypoint-shop.git
   ```

2. **Add the resource to your `resources` folder**.

3. **Configure your `server.cfg`**:
   - Ensure that the dependencies are started before this script. Add the following to your `server.cfg`:
     ```cfg
     ensure ox_lib
     ensure ox_target
     ensure ox_inventory
     ensure es_extended
     ensure npc-waypoint-shop
     ```

4. **Database Setup**:
   - If your script interacts with a database (e.g., for item purchases), make sure to have the necessary tables set up using `mysql-async` or `oxmysql`.

5. **Configuration**:
   - Open `config.lua` and adjust the settings to your needs:
     - NPC models, locations, jail chances, item prices, and more can be configured here.
   - Localization strings can be edited in `locale/en.lua`.

## Usage

- **Waypoint NPC (Middle Man)**: Players can purchase waypoints to either the Plug NPC or Gun NPC. The waypoint is marked on their map.
- **Plug NPC**: Players can buy items such as cocaine, heroin, meth, or weed from the Plug NPC.
- **Gun NPC**: Players can purchase weapons such as pistols, SMGs, shotguns, and rifles from the Gun NPC.
- **Jail System**: After a certain number of purchases, NPCs can be sent to jail, and players will need to bail them out by interacting with a Cop NPC.

## Commands

- **`/testRemoveShopNpc`**: Used for testing purposes. Removes and respawns the Shop NPC (Plug NPC).

## Configuration

You can edit the following in `config.lua`:

- **Waypoint Costs**:
  - `Config.WaypointToPlugCost` (default: 2000)
  - `Config.WaypointToGunNpcCost` (default: 5000)
  
- **Jail Settings**:
  - `Config.PurchaseThreshold`: Number of purchases before jail chance is calculated.
  - `Config.JailChance`: Percent chance for an NPC to be jailed after enough purchases (default: 30%).
  - `Config.SnitchChance`: Percent chance for the Plug NPC to alert the police (default: 20%).

- **Items Sold by NPCs**:
  - You can configure the items and prices that both the Plug NPC and Gun NPC sell by editing the `Config.PlugItems` and `Config.GunItems` arrays.

## Dependencies

Make sure you have the following resources running on your server:
- `es_extended`
- `ox_lib`
- `ox_target`
- `ox_inventory`
- `mysql-async` or `oxmysql`

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Credits

- **Author**: KnowGoodVision
- **Contributors**: If any, list them here.

---
