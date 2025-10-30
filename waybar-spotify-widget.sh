#!/bin/bash
# Script: Music waybar widget

# --- Configuration ---
# Temp file to store the name of the last actively playing player
LAST_ACTIVE_FILE="/tmp/waybar_last_active_player"

# --- Find the most relevant active player ---
# Priority: 1. Any player that is "Playing"
# Priority: 2. The *last active* player, if it is still "Paused"
# Priority: 3. Any other player that is "Paused"
find_relevant_player() {
    PLAYERS="spotify_player strawberry"

    # --- Priority 1: Check for any player that is "Playing" ---
    for player in $PLAYERS; do
        status=$(playerctl -p "$player" status 2> /dev/null)
        if [ "$status" = "Playing" ]; then
            # Active playback always wins. Record this player as the last one to be active.
            echo "$player" > "$LAST_ACTIVE_FILE"
            echo "$player"
            return 0
        fi
    done

    # --- At this point, no player is "Playing". Now we check for our sticky player. ---

    # --- Priority 2: Check if the last active player is still paused ---
    if [ -f "$LAST_ACTIVE_FILE" ]; then
        last_active_player=$(cat "$LAST_ACTIVE_FILE")
        last_active_status=$(playerctl -p "$last_active_player" status 2> /dev/null)

        if [ "$last_active_status" = "Paused" ]; then
            # The last active player is paused. It remains our most relevant player.
            echo "$last_active_player"
            return 0
        else
            # The last active player is no longer paused (it was likely stopped/closed).
            # We can remove the state file, as it's no longer relevant.
            rm -f "$LAST_ACTIVE_FILE"
        fi
    fi

    # --- Priority 3: No one is playing and sticky is not active. Find the first available paused player. ---
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
# If an argument is passed, send it to the most relevant player.
if [ -n "$1" ]; then
    if [ -n "$RELEVANT_PLAYER" ]; then
        playerctl -p "$RELEVANT_PLAYER" "$1"
    else
        # If no player is active, try to play the last active one as a fallback
        if [ -f "$LAST_ACTIVE_FILE" ]; then
            last_active_player=$(cat "$LAST_ACTIVE_FILE")
            playerctl -p "$last_active_player" "$1"
        fi
    fi
    exit 0 # Exit after handling the control command
fi

# --- Main Widget Logic (if no arguments) ---
if [ -z "$RELEVANT_PLAYER" ]; then
    echo '' # Output empty if no relevant player is found
    exit 0
fi

player_status=$(playerctl -p "$RELEVANT_PLAYER" status 2> /dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    # Get metadata and escape special characters
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
    echo ''
fi
