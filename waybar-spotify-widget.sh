#!/bin/bash
# Script: Music waybar widget

# --- Find the first active player ---
find_active_player() {
    # Add any other players you want to support here
    PLAYERS="spotify org.strawberrymusicplayer.strawberry"

    for player in $PLAYERS; do
        # Check if the player is running and controllable
        status=$(playerctl -p "$player" status 2> /dev/null)
        if [ -n "$status" ]; then
            echo "$player"
            return 0
        fi
    done
    return 1
}

ACTIVE_PLAYER=$(find_active_player)

# --- Handle Control Arguments ---
# If an argument is passed (e.g., "play-pause"), pass it to the active player
if [ -n "$1" ]; then
    if [ -n "$ACTIVE_PLAYER" ]; then
        playerctl -p "$ACTIVE_PLAYER" "$1"
    fi
    exit 0 # Exit after handling the control command
fi

# --- Main Widget Logic (if no arguments) ---
if [ -z "$ACTIVE_PLAYER" ]; then
    echo '' # Output empty if no player is active
    exit 0
fi

player_status=$(playerctl -p "$ACTIVE_PLAYER" status 2> /dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    # Get metadata and escape ampersands for JSON
    artist=$(playerctl -p "$ACTIVE_PLAYER" metadata artist | sed 's/&/\\&/g')
    title=$(playerctl -p "$ACTIVE_PLAYER" metadata title | sed 's/&/\\&/g')

    if [[ "$ACTIVE_PLAYER" == *"spotify"* ]]; then
        icon="" # Spotify icon
        class="custom-spotify"
    elif [[ "$ACTIVE_PLAYER" == *"strawberry"* ]]; then
        icon="🍓" # Strawberry icon
        class="custom-strawberry"
    else
        icon="🎵" # Generic music icon
        class="custom-music"
    fi
    
    text="   $icon  $title - $artist"
    
    # Output as JSON
    echo '{"text": "'"$text"'", "class": "'"$class"'"}'
else
    # Output empty if player is not running or not playing
    echo ''
fi
