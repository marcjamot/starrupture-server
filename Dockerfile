FROM cm2network/steamcmd:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAM_HOME=/home/steam
ENV SERVER_DIR="/home/steam/.steam/steam/steamapps/common/StarRupture Dedicated Server"
ENV PROTON_DIR="/home/steam/.steam/steam/steamapps/common/Proton - Experimental"
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    locales \
    ca-certificates \
    curl \
    bash \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && mkdir -p "${SERVER_DIR}" "${PROTON_DIR}" \
    && chown -R steam:steam "${STEAM_HOME}" \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=steam:steam entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER steam
WORKDIR /home/steam

ENTRYPOINT ["/entrypoint.sh"]
