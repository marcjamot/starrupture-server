#!/bin/bash

export LINE='\n'
export RESET='\033[0m'
export WhiteText='\033[0;37m'
export RedBoldText='\033[1;31m'
export GreenBoldText='\033[1;32m'
export YellowBoldText='\033[1;33m'
export CyanBoldText='\033[1;36m'

LogInfo() {
  Log "$1" "$WhiteText"
}

LogWarn() {
  Log "$1" "$YellowBoldText"
}

LogError() {
  Log "$1" "$RedBoldText"
}

LogSuccess() {
  Log "$1" "$GreenBoldText"
}

LogAction() {
  Log "$1" "$CyanBoldText" "====" "===="
}

Log() {
  local message="$1"
  local color="$2"
  local prefix="$3"
  local suffix="$4"
  printf "$color%s$RESET$LINE" "$prefix$message$suffix"
}

install() {
  LogAction "Starting server install"
  LogInfo "Installing or updating StarRupture Dedicated Server (App ID: 3809400)"
  /home/steam/steamcmd/steamcmd.sh +runscript /home/steam/server/install.scmd
}

generate_password_files() {
  local server_files="$1"
  local admin_pass="$2"
  local player_pass="$3"

  if [ -z "$admin_pass" ] && [ -f "$server_files/Password.json" ]; then
    rm -f "$server_files/Password.json"
    LogInfo "Removed admin password"
  fi

  if [ -z "$player_pass" ] && [ -f "$server_files/PlayerPassword.json" ]; then
    rm -f "$server_files/PlayerPassword.json"
    LogInfo "Removed player password"
  fi

  [ -z "$admin_pass" ] && [ -z "$player_pass" ] && return

  LogInfo "Generating encrypted password files..."

  local response
  response="$(curl -sf -X POST https://starrupture-utilities.com/passwords/ \
    -d "adminpassword=${admin_pass}" \
    -d "playerpassword=${player_pass}")"

  if [ $? -ne 0 ]; then
    LogWarn "Failed to generate passwords via API. Generate manually at: https://starrupture-utilities.com/passwords/"
    return
  fi

  if [ -n "$admin_pass" ]; then
    local admin_encrypted
    admin_encrypted="$(echo "$response" | jq -r '.adminpassword')"
    echo "{\"password\":\"$admin_encrypted\"}" > "$server_files/Password.json"
    LogSuccess "Admin password configured"
  fi

  if [ -n "$player_pass" ]; then
    local player_encrypted
    player_encrypted="$(echo "$response" | jq -r '.playerpassword')"
    echo "{\"password\":\"$player_encrypted\"}" > "$server_files/PlayerPassword.json"
    LogSuccess "Player password configured"
  fi
}
