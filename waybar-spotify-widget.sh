#!/bin/bash
# Script: Music waybar widget

# --- Configuration ---
STICKY_PLAYER="strawberry"
STICKY_DURATION=300 # 5 minutes in seconds
STICKY_FILE="/tmp/waybar_sticky_player_pause_time"

# --- Find the most relevant active player ---
# Priority: 1. Any player that is "Playing"
# Priority: 2. A "sticky" player that was recently paused
# Priority: 3. Any other player that is "Paused"
find_relevant_player() {
    PLAYERS="spotify_player strawberry"

    # --- Priority 1: Check for any player that is "Playing" ---
    for player in $PLAYERS; do
        status=$(playerctl -p "$player" status 2> /dev/null)
        if [ "$status" = "Playing" ]; then
            # Active playback always wins. If something is playing, clear any sticky state.
            rm -f "$STICKY_FILE"
            echo "$player"
            return 0
        fi
    done

    # --- At this point, no player is "Playing". Now we check statuses to manage stickiness. ---

    # Get the status of our designated sticky player
    sticky_player_status=$(playerctl -p "$STICKY_PLAYER" status 2> /dev/null)

    if [ "$sticky_player_status" = "Paused" ]; then
        # If the sticky player is paused, write the current time to the sticky file to start/refresh the cooldown.
        date +%s > "$STICKY_FILE"
    else
        # If the sticky player is not paused (e.g., it was stopped), remove the sticky file.
        rm -f "$STICKY_FILE"
    fi

    # --- Priority 2: Check if the sticky player is within its cooldown period ---
    if [ -f "$STICKY_FILE" ]; then
        pause_time=$(cat "$STICKY_FILE")
        current_time=$(date +%s)
        time_diff=$((current_time - pause_time))

        if [ "$time_diff" -lt "$STICKY_DURATION" ]; then
            # Cooldown is active. If the sticky player is still paused, it's our most relevant player.
            if [ "$sticky_player_status" = "Paused" ]; then
                echo "$STICKY_PLAYER"
                return 0
            fi
        else
            # Cooldown has expired, so remove the file.
            rm -f "$STICKY_FILE"
        fi
    fi

    # --- Priority 3: No one is playing and sticky is not active. Find the first paused player. ---
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
