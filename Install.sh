#!/bin/bash
set -euo pipefail

# --- Configuration ---
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
BACKUP_FILE="$HOME/.config/waybar/config.jsonc.bak"

# --- Find the directory this script is in ---
# This gets the absolute path, resolving any symlinks
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WIDGET_SCRIPT_NAME="waybar-spotify-widget.sh"
WIDGET_SCRIPT_PATH="$SCRIPT_DIR/$WIDGET_SCRIPT_NAME"

# --- Check for jq ---
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed." >&2
    echo "Please install it first (e.g., 'sudo apt install jq' or 'sudo pacman -S jq')." >&2
    exit 1
fi

# --- Check for config file ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

# --- Check if the widget script exists where expected ---
if [[ ! -f "$WIDGET_SCRIPT_PATH" ]]; then
    echo "Error: Widget script not found." >&2
    echo "Expected: $WIDGET_SCRIPT_PATH" >&2
    echo "Please make sure '$WIDGET_SCRIPT_NAME' is in the same directory as this script." >&2
    exit 1
fi

# --- Define the new module by building it with jq ---
# This safely inserts the absolute path into the JSON object
NEW_MODULE_JSON=$(jq -n --arg exec_path "$WIDGET_SCRIPT_PATH" '{
  "custom/music": {
    "format": "{}",
    "exec": $exec_path,
    "return-type": "json",
    "interval": 1,
    "exec-if": "pgrep spotify || pgrep strawberry",
    "on-click": "$exec_path play-pause",
    "on-scroll-up": "$exec_path next",
    "on-scroll-down": "$exec_path previous",
    "tooltip": true
  }
}')

# --- Create a backup ---
echo "Backing up $CONFIG_FILE to $BACKUP_FILE..."
cp "$CONFIG_FILE" "$BACKUP_FILE"

# --- Create a temporary file for the new config ---
TMP_FILE=$(mktemp)

# --- Sanitize JSONC to be compatible with jq ---
# This removes // comments and trailing commas that are valid in JSONC but not in strict JSON.
# It is not a perfect parser, but it handles the most common cases.
SANITIZED_JSON=$(sed -e 's|//.*||' -e 's/,\s*\]/]/g' -e 's/,\s*\}/}/g' "$CONFIG_FILE")

# --- Merge the JSON object AND add to modules-center ---
echo "Adding 'custom/music' definition (Exec: $WIDGET_SCRIPT_PATH)..."

# This command chains two operations:
# 1. '(. * $new_module)' merges the new module definition into the root.
# 2. '| .["modules-center"] |= (. + ["custom/music"] | unique)' takes that
#    result, adds "custom/music" to the "modules-center" array,
#    and filters for uniqueness to prevent duplicates.
if ! echo "$SANITIZED_JSON" | jq --argjson new_module "$NEW_MODULE_JSON" \
       '(. * $new_module) | .["modules-center"] |= (. + ["custom/music"] | unique)' > "$TMP_FILE"; then
    
    # --- Error Handling ---
    echo "---------------------------------------------------------------" >&2
    echo "Error: 'jq' failed to parse $CONFIG_FILE." >&2
    echo "This is likely because your file has comments (JSONC) or" >&2
    echo "another feature that this script could not automatically clean." >&2
    echo >&2
    echo "Please manually remove all comments (lines starting with //" >&2
    echo "and /* ... */ blocks) and trailing commas, then try again." >&2
    echo "Your original file has been restored from backup." >&2
    echo "---------------------------------------------------------------" >&2
    
    # Clean up and restore backup
    rm "$TMP_FILE"
    mv "$BACKUP_FILE" "$CONFIG_FILE"
    exit 1
fi

# --- Replace old config with new one ---
mv "$TMP_FILE" "$CONFIG_FILE"

echo "Success! $CONFIG_FILE has been updated."
echo "Added 'custom/music' module definition."
echo "Added 'custom/music' to 'modules-center' array."
