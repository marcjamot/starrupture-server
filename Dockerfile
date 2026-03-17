FROM --platform=linux/amd64 cm2network/steamcmd:root

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    gettext-base \
    jq \
    procps \
    wine \
    wine32:i386 \
    wine64 \
    xvfb \
    xauth \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/home/steam \
    DEFAULT_PORT=7777 \
    QUERY_PORT=27015 \
    SERVER_NAME=starrupture-server \
    MULTIHOME="" \
    SAVE_GAME_NAME=AutoSave0.sav

COPY scripts /home/steam/server/

RUN mkdir -p /home/steam/server /home/steam/server-files /home/steam/server-data \
    && chown -R steam:steam /home/steam \
    && chmod +x /home/steam/server/*.sh

USER steam
WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m CMD pgrep wine > /dev/null || exit 1

ENTRYPOINT ["/home/steam/server/start.sh"]
