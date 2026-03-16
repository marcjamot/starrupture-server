# StarRupture

## Build

```
docker build --platform=linux/amd64 -t starrupture-server .
```

## Run

```
docker run --rm -it \
  --name starrupture \
  --platform=linux/amd64 \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -e STEAM_LOGIN="your_login" \
  -e STEAM_PASSWORD="your_password" \
  -e SERVER_NAME="YOUR SERVER NAME" \
  -e MULTIHOME_IP="0.0.0.0" \
  -e PROTON_LOG=1 \
  -v ./proton:/home/steam/.steam/steam/steamapps/common/Proton\ -\ Experimental \
  -v ./server:/home/steam/.steam/steam/steamapps/common/StarRupture\ Dedicated\ Server \
  starrupture-server
```
