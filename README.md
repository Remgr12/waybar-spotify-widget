# waybar-music-widget

This is a widget for Waybar that displays your currently playing song title and artist from either Spotify or Strawberry, automatically detecting which one is active.

## Features
-   **Multi-Player Support:** Automatically detects and displays music from Spotify and Strawberry Music Player.
-   **Dynamic Player Controls:** Use `on-click` and `on-scroll` events in Waybar to control playback (play/pause, next, previous) on whichever player is currently active.
-   **Easy Installation:** Comes with an `Install.sh` script to automatically configure Waybar for you.
-   **Customizable:** Shows different icons for each player (  for Spotify, 🍓 for Strawberry).

## Supported Players
-   **Spotify:** `spotify`
-   **Strawberry:** `org.strawberrymusicplayer.strawberry`

## Installation
1.  **Dependencies:** Make sure you have `jq` and `playerctl` installed.
    -   On Arch: `sudo pacman -S jq playerctl`
    -   On Debian/Ubuntu: `sudo apt install jq playerctl`
2.  **Run the Installer:** Navigate to the repository directory and run the install script:
    ```bash
    ./Install.sh
    ```
    This will back up your existing Waybar config, then add the necessary module definition and add it to your `modules-center` array.

## Manual Configuration
If you prefer to set it up manually, add `"custom/music"` to your `modules-center` array in `~/.config/waybar/config.jsonc`, and then add the following module definition.

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
*Remember to replace `/path/to/your/script/` with the actual absolute path to the `waybar-spotify-widget.sh` script.*
