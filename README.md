# Spy Addon (v1.3)

Spy is a 3.3.5 WOTLK addon designed to enhance your situational awareness in PvP environments. It provides real-time alerts and comprehensive tracking of nearby enemy players, helping you stay one step ahead of the competition.

## ⚠️ Important Notice for Version 1.3 Users

Due to updates in the main window to display the nearby player count, the window dimensions have changed. If you are upgrading from a previous version, you **must** run the following command once to reset the window to its correct position and size:

```
/spy reset
```

## Key Features

-   **Stability Fixes:** Squashed a major bug that caused game crashes (CTD) when zoning into dungeons or instances.
-   **New World List:** See enemies detected by your guild or party across the entire zone, not just nearby.
-   **Nearby Distance Threshold:** New slider in the options lets you filter out faraway players reported by your network, keeping your Nearby list focused on immediate threats.
-   **Nearby Player Count:** The main window title now shows a live count of local players on your Nearby list.
-   **Real-Time Enemy Tracking:** Get instant alerts for nearby enemy players.
-   **Kill on Sight (KOS) System:** Mark your rivals for special alarms and track KOS reasons.
-   **Intel Sharing:** Automatically share and receive enemy locations with other Spy users in your party, raid, or guild.
-   **Full Map Integration:** See enemy locations on both your minimap and the world map.

## Installation

1.  Download the `Spy` addon folder.
2.  Extract it into your `\Interface\AddOns` directory.
3.  Launch the game and enable the addon from the character selection screen.

## Usage

### Slash Commands

-   `/spy show` - Shows the main Spy window.
-   `/spy reset` - Resets the window's position and size.
-   `/spy config` - Opens the options panel.
-   `/spy kos [PlayerName]` - Toggles KOS status for a player.
-   `/spy ignore [PlayerName]` - Toggles ignore status for a player.

### Configuration

Spy is configured via the standard **Interface Options** panel (`Esc -> Interface -> AddOns -> Spy`). Here you can customize everything from alert sounds and display settings to data management and list expiration times.

---

## Credits

-   **Original Author:** Immolation
-   **Contributing Author & Maintainer:** Plagueheart

## License

This addon is distributed under the MIT License. See the `LICENSE` file for more details.