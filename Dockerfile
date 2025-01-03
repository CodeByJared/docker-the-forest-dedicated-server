FROM jammsen/base:wine-stable-debian-bookworm

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=/winedata/WINE64 \
    WINEARCH=win64 \
    DISPLAY=:1.0 \
    TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    SERVER_STEAM_ACCOUNT_TOKEN="" \
    ALWAYS_UPDATE_ON_START=1 \
    SERVER_IP="" \
    SERVER_STEAM_PORT="8766" \
    SERVER_GAME_PORT="27015" \
    SERVER_QUERY_PORT="27016" \
    SERVER_PLAYERS="8" \
    SERVER_VAC="off" \
    SERVER_PASSWORD="" \
    SERVER_ADMIN_PASSWORD="" \
    SERVER_AUTO_SAVE_INTERVAL="30" \
    SERVER_DIFFICULTY="Normal" \
    SERVER_INIT_TYPE="Continue" \
    SERVER_SLOT="1" \
    SERVER_SHOW_LOGS="off" \
    SERVER_CONTACT="email@gmail.com" \
    SERVER_VEGAN_MODE="off" \
    SERVER_VEGETARIAN_MODE="off" \
    SERVER_RESET_HOLES_MODE="off" \
    SERVER_TREE_REGROW_MODE="off" \
    SERVER_ALLOW_BUILDING_DESTRUCTION="on" \
    SERVER_ALLOW_ENEMIES_CREATIVE="off" \
    SERVER_ALLOW_CHEATS="off" \
    SERVER_REALISTIC_PLAYER_DAMAGE="off" \
    SERVER_TARGET_FPS_IDLE="0" \
    SERVER_TARGET_FPS_ACTIVE="0"

VOLUME ["/theforest", "/steamcmd", "/winedata"]

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests ping lib32gcc-s1 winbind xvfb \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./usr/bin/servermanager.sh /usr/bin/servermanager.sh
COPY ./usr/bin/steamcmdinstaller.sh /usr/bin/steamcmdinstaller.sh
COPY server.cfg.example steamcmdinstall.txt /

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh

CMD ["servermanager.sh"]
