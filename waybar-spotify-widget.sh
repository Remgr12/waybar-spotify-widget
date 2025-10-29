#!/bin/bash
# Script: Spotify waybar widget

PLAYER_NAME="spotify_player"  # <--- CHANGE THIS to the name of your Spotify client (spotify;spotify-player;etc.)

player_status=$(playerctl -p "$PLAYER_NAME" status 2> /dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    # Get metadata and escape ampersands for JSON
    artist=$(playerctl -p "$PLAYER_NAME" metadata artist | sed 's/&/\\&/g')
    title=$(playerctl -p "$PLAYER_NAME" metadata title | sed 's/&/\\&/g')
    
    text="     $title - $artist"
    
    # Output as JSON
    echo '{"text": "'"$text"'", "class": "custom-spotify"}'
else
    # Output empty if player is not running or not playing
    echo ''
fi
