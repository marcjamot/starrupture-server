#!/usr/bin/env bash
set -euo pipefail

APP_ID="${APP_ID:-3809400}"
STEAM_LOGIN="${STEAM_LOGIN:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"

STEAMCMD_BIN="${STEAMCMD_BIN:-/home/steam/steamcmd/steamcmd.sh}"
SERVER_DIR="${SERVER_DIR:-/home/steam/.steam/steam/steamapps/common/StarRupture Dedicated Server}"
PROTON_DIR="${PROTON_DIR:-/home/steam/.steam/steam/steamapps/common/Proton - Experimental}"
SERVER_EXE="${SERVER_EXE:-./StarRupture/Binaries/Win64/StarRuptureServerEOS-Win64-Shipping.exe}"

SERVER_NAME="${SERVER_NAME:-StarRupture Server}"
MULTIHOME_IP="${MULTIHOME_IP:-0.0.0.0}"
GAME_PORT="${GAME_PORT:-7777}"
QUERY_PORT="${QUERY_PORT:-27015}"
VALIDATE="${VALIDATE:-true}"
PROTON_LOG="${PROTON_LOG:-0}"

mkdir -p "${SERVER_DIR}"

args=(
  "+@sSteamCmdForcePlatformType" "windows"
  "+force_install_dir" "${SERVER_DIR}"
)

if [[ "${STEAM_LOGIN}" == "anonymous" ]]; then
  args+=("+login" "anonymous")
else
  args+=("+login" "${STEAM_LOGIN}" "${STEAM_PASSWORD}")
fi

if [[ "${VALIDATE}" == "true" ]]; then
  args+=("+app_update" "${APP_ID}" "validate")
else
  args+=("+app_update" "${APP_ID}")
fi

args+=("+quit")

"${STEAMCMD_BIN}" "${args[@]}"

if [[ ! -x "${PROTON_DIR}/proton" ]]; then
  echo "Proton not found at: ${PROTON_DIR}/proton" >&2
  exit 1
fi

export STEAM_COMPAT_DATA_PATH="${SERVER_DIR}/compatdata"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/steam/.steam/steam"
export PROTON_LOG

mkdir -p "${STEAM_COMPAT_DATA_PATH}"
cd "${SERVER_DIR}"

exec "${PROTON_DIR}/proton" run "${SERVER_EXE}" \
  -Log \
  -Port="${GAME_PORT}" \
  -QueryPort="${QUERY_PORT}" \
  -MULTIHOME="${MULTIHOME_IP}" \
  -ServerName="${SERVER_NAME}"
