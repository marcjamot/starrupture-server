#!/bin/bash

source "/home/steam/server/functions.sh"

SERVER_FILES="/home/steam/server-files"
SERVER_DATA="/home/steam/server-data"
HOME_DIR="${HOME:-/home/steam}"
WINE_PREFIX="${WINEPREFIX:-$SERVER_DATA/.wine}"

require_writable_path() {
  local path="$1"
  local label="$2"
  local probe_file

  if [ ! -d "$path" ]; then
    LogError "${label} directory is missing: ${path}"
    exit 1
  fi

  if [ ! -w "$path" ]; then
    LogError "${label} directory is not writable by user $(id -un): ${path}"
    exit 1
  fi

  probe_file="${path}/.write-test-$$"
  if ! : > "$probe_file" 2>/dev/null; then
    LogError "${label} directory failed a write test: ${path}"
    exit 1
  fi

  rm -f "$probe_file"
}

if [ "$HOME_DIR" != "/home/steam" ]; then
  LogError "HOME must be /home/steam for non-root startup, got: ${HOME_DIR}"
  exit 1
fi

require_writable_path "$HOME_DIR" "Steam home"

mkdir -p "$SERVER_FILES" || {
  LogError "Failed to create server files directory: ${SERVER_FILES}"
  exit 1
}

require_writable_path "$SERVER_FILES" "Server files"

mkdir -p "$SERVER_DATA" || {
  LogError "Failed to create server data directory: ${SERVER_DATA}"
  exit 1
}

require_writable_path "$SERVER_DATA" "Server data"

mkdir -p "$WINE_PREFIX" || {
  LogError "Failed to create Wine prefix directory: ${WINE_PREFIX}"
  exit 1
}

require_writable_path "$WINE_PREFIX" "Wine prefix"

export HOME="$HOME_DIR"
export WINEPREFIX="$WINE_PREFIX"

cd "$SERVER_DATA" || exit 1

LogAction "Starting StarRupture Dedicated Server"

DEFAULT_PORT="${DEFAULT_PORT:-7777}"
QUERY_PORT="${QUERY_PORT:-27015}"
SERVER_NAME="${SERVER_NAME:-starrupture-server}"
SAVE_GAME_NAME="${SAVE_GAME_NAME:-AutoSave0.sav}"
DSSETTINGS_FILE="$SERVER_DATA/DSSettings.txt"

install

LogInfo "Generating DSSettings.txt from environment variables"
cat > "$DSSETTINGS_FILE" <<EOF
{
  "SessionName": "$SERVER_NAME",
  "SaveGameInterval": "300",
  "StartNewGame": "true",
  "LoadSavedGame": "true",
  "SaveGameName": "$SAVE_GAME_NAME"
}
EOF

LogSuccess "DSSettings.txt configured with SessionName: $SERVER_NAME"
generate_password_files "$SERVER_DATA" "${ADMIN_PASSWORD:-}" "${PLAYER_PASSWORD:-}"

SERVER_EXEC="$SERVER_FILES/StarRupture/Binaries/Win64/StarRuptureServerEOS-Win64-Shipping.exe"

if [ ! -f "$SERVER_EXEC" ]; then
  LogError "Could not find server executable at: $SERVER_EXEC"
  exit 1
fi

LogInfo "Found server executable: ${SERVER_EXEC}"
LogInfo "Server starting on port ${DEFAULT_PORT}"
LogInfo "Query port: ${QUERY_PORT}"
LogInfo "Server name: ${SERVER_NAME}"
LogInfo "Wine prefix: ${WINEPREFIX}"

STARTUP_CMD=(
  xvfb-run
  --auto-servernum
  wine
  "$SERVER_EXEC"
  -Log
  "-Port=${DEFAULT_PORT}"
  "-QueryPort=${QUERY_PORT}"
  "-ServerName=${SERVER_NAME}"
  -RCWebControlDisable
  -RCWebInterfaceDisable
)

if [ -n "${MULTIHOME}" ]; then
  STARTUP_CMD+=("-MULTIHOME=${MULTIHOME}")
fi

LogInfo "Starting with Wine..."
exec "${STARTUP_CMD[@]}"
