# waybar-music-widget

This is a widget for Waybar that displays your currently playing song title and artist from either Spotify or Strawberry, automatically detecting the most relevant player to show.

## Features
-   **Intelligent Player Detection:** Automatically detects and displays the music player that is actively "Playing", prioritizing it over any that are "Paused".
-   **Sticky Player Cooldown:** To prevent the display from flickering when you briefly pause, the Strawberry player will remain "stuck" on the display for 5 minutes after being paused. Active playback from any other player will immediately override this.
-   **Multi-Player Support:** Works with both Spotify and Strawberry Music Player.
-   **Dynamic Player Controls:** Use `on-click` and `on-scroll` events in Waybar to control playback (play/pause, next, previous) on whichever player is currently active.
-   **Customizable:** Shows different icons for each player ( for Spotify, 🍓 for Strawberry).

## Supported Players
-   **Spotify:** `spotify_player`
-   **Strawberry:** `strawberry`

## Installation

### 1. Dependencies
First, make sure you have `jq` and `playerctl` installed.
-   **On Arch Linux:** `sudo pacman -S jq playerctl`
-   **On Debian/Ubuntu:** `sudo apt install jq playerctl`

### 2. Manual Configuration (Recommended)
This is the most reliable way to install the widget.

First, add `"custom/music"` to your `modules-center` (or left/right) array in `~/.config/waybar/config.jsonc`.

Then, add the following module definition to your config file.

**Note:** The `exec-if` condition is important. It ensures the script only runs when a supported player is active, saving resources.

```json
"custom/music": {
    "format": "{}",
    "exec": "/path/to/your/script/waybar-spotify-widget.sh",
    "return-type": "json",
    "interval": 1,
    "exec-if": "pgrep spotify || pgrep strawberry",
    "on-click": "/path/to/your/script/waybar-spotify-widget.sh play-pause",
    "on-scroll-up": "/path/to/your/script/waybar-spotify-widget.sh next",
    "on-scroll-down": "/path/to/your/script/waybar-spotify-widget.sh previous",
    "tooltip": true
},
```
***Important:*** *Remember to replace `/path/to/your/script/` with the actual absolute path to the `waybar-spotify-widget.sh` script.*

### 3. Installation Script (Alternative)
An installer script is included for convenience, but it can be a bit finicky. It attempts to modify your Waybar configuration file automatically, which may not work reliably with all setups. **The manual method is strongly recommended.**

If you'd like to try it, navigate to the repository directory and run the script:
```bash
./Install.sh
```
This will back up your existing Waybar config, then attempt to add the necessary module definition and add it to your `modules-center` array.
