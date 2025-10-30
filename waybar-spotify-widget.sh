#!/bin/bash
# Script: Music waybar widget

# --- Find the most relevant active player ---
# Priority: 1. "Playing", 2. "Paused"
find_relevant_player() {
    # Using the player names you provided that work correctly
    PLAYERS="spotify_player strawberry"

    # First, search for a player that is "Playing"
    for player in $PLAYERS; do
        status=$(playerctl -p "$player" status 2> /dev/null)
        if [ "$status" = "Playing" ]; then
            echo "$player"
            return 0
        fi
    done

    # If no player is "Playing", search for one that is "Paused"
    for player in $PLAYERS; do
        status=$(playerctl -p "$player" status 2> /dev/null)
        if [ "$status" = "Paused" ]; then
            echo "$player"
            return 0
        fi
    done

    return 1
}

RELEVANT_PLAYER=$(find_relevant_player)

# --- Handle Control Arguments ---
# If an argument is passed (e.g., "play-pause"), pass it to the most relevant player.
if [ -n "$1" ]; then
    if [ -n "$RELEVANT_PLAYER" ]; then
        playerctl -p "$RELEVANT_PLAYER" "$1"
    fi
    exit 0 # Exit after handling the control command
fi

# --- Main Widget Logic (if no arguments) ---
if [ -z "$RELEVANT_PLAYER" ]; then
    echo '' # Output empty if no relevant player is active
    exit 0
fi

player_status=$(playerctl -p "$RELEVANT_PLAYER" status 2> /dev/null)

# Double check status, as it might have changed
if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    # Get metadata and escape special characters for JSON and Pango
    artist=$(playerctl -p "$RELEVANT_PLAYER" metadata artist | sed -e 's/"/\\"/g' -e 's/&/&amp;/g')
    title=$(playerctl -p "$RELEVANT_PLAYER" metadata title | sed -e 's/"/\\"/g' -e 's/&/&amp;/g')

    if [[ "$RELEVANT_PLAYER" == *"spotify"* ]]; then
        icon="" # Spotify icon
        class="custom-spotify"
    elif [[ "$RELEVANT_PLAYER" == *"strawberry"* ]]; then
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
    # Output empty if player status is not what we expect
    echo ''
fi
