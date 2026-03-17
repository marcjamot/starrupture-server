# StarRupture Dedicated Server Docker

A Docker image for running a StarRupture dedicated server with SteamCMD.

The dedicated server is downloaded and updated during container startup so the
image stays smaller.

## Quick Start

### 1. Build the image

`bash`:

```bash
docker build --platform=linux/amd64 -t starrupture-server .
```

### 2. Create an env file

Copy `.env.example` to `.env` and adjust any values you want to change.

`bash`:

```bash
cp .env.example .env
```

`powershell`:

```powershell
Copy-Item .env.example .env
```

### 3. Start the server

`bash`:

```bash
mkdir -p server-files server-data

docker run \
  --rm -it \
  --name starrupture \
  --platform=linux/amd64 \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  --env-file .env \
  -v ./server-files:/home/steam/server-files \
  -v ./server-data:/home/steam/server-data \
  starrupture-server
```

`powershell`:

```powershell
New-Item -ItemType Directory -Force server-files | Out-Null
New-Item -ItemType Directory -Force server-data | Out-Null

docker run `
  --rm -it `
  --name starrupture `
  --platform=linux/amd64 `
  -p 7777:7777/udp `
  -p 27015:27015/udp `
  --env-file .env `
  -v ${PWD}/server-files:/home/steam/server-files `
  -v ${PWD}/server-data:/home/steam/server-data `
  starrupture-server
```

### 4. Stop the server

`bash` or `powershell`:

```bash
Ctrl+C
```

## Connect In-Game

- Open StarRupture and go to the in-game server join flow.
- Connect to the host running the container on UDP port `7777`.
- From the same PC, try `127.0.0.1:7777`.
- From another device on your LAN, use the Docker host's local IP, for example `192.168.1.50:7777`.
- From outside your network, use your public IP and make sure `7777/udp` is forwarded to the Docker host.
- `27015/udp` is for queries/server discovery and is not the main gameplay port.

## Notes

- The image now runs as the bundled non-root `steam` user.
- The mounted `./server-files` directory must be writable by the bundled `steam` user so SteamCMD can install and update the dedicated server.
- The mounted `./server-data` directory must be writable by the bundled `steam` user so Wine and config generation can succeed.
- Downloaded server files are stored in `./server-files`.
- Saves, password files, Wine prefix data, and generated `DSSettings.txt` are stored in `./server-data`.
- Port `7777/udp` is required for gameplay.
- Port `27015/udp` is used for queries.
- Runtime scripts live in `scripts/`.

## Environment Variables

| Variable | Default | Info |
| --- | --- | --- |
| `SERVER_NAME` | `starrupture-server` | Name of the server |
| `DEFAULT_PORT` | `7777` | Main game port |
| `QUERY_PORT` | `27015` | Query port |
| `MULTIHOME` | empty | Optional bind address |
| `ADMIN_PASSWORD` | empty | Admin password to encrypt into `Password.json` |
| `PLAYER_PASSWORD` | empty | Player password to encrypt into `PlayerPassword.json` |
| `SAVE_GAME_NAME` | `AutoSave0.sav` | Save file to load or create |

## Save Configuration

The container always writes `DSSettings.txt` into `/home/steam/server-data`
from environment variables and starts the server with remote control disabled.
It always attempts to load `SAVE_GAME_NAME` and allows the server to create a
new world if that save does not exist.

The dedicated server executable is installed and launched from
`/home/steam/server-files`.

Preferred built-in settings:

- `SaveGameInterval=300`
- `StartNewGame=true`
- `LoadSavedGame=true`
- Remote control endpoints disabled
