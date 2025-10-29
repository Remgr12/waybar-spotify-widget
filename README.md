# waybar-spotify-widget

This is a widget for Waybar which takes your Title/Artist from your Spotify client (using playerctl) and then lists it for you.

To install you should have jq installed (requirement) and then after running the script it will automatically set the waybar config so that there's no manual setup at all.

If you do wish to do it manually though, you should add "custom/spotify" to your modules (either left, right or center) (eg. "modules-center": ["clock", "custom/update", "custom/screenrecording-indicator", "custom/spotify"]) and then paste the following part to the end (or whereever you want it to be):

```bash
 },
  "custom/spotify": {
      "format": "{}",
      "exec": "~/scripts/spotify-now-playing.sh", // Path to your script from step 2
      "return-type": "json",
      "interval": 1,
      "exec-if": "pgrep spotify",
      "on-click": "playerctl -p spotify_player play-pause",
      "on-scroll-up": "playerctl -p spotify_player next",
      "on-scroll-down": "playerctl -p spotify_player previous",
      "tooltip": true
    },
```    
