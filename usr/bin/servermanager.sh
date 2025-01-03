#!/bin/bash

# SteamCMD APPID for the-forest-dedicated-server
SAVEGAME_PATH="/theforest/saves/"
CONFIG_PATH="/theforest/config/"
CONFIGFILE_PATH="/theforest/config/config.cfg"

function isServerRunning() {
    if ps axg | grep -F "TheForestDedicatedServer.exe" | grep -v -F 'grep' > /dev/null; then
        true
    else
        false
    fi
}

function isVirtualScreenRunning() {
    if ps axg | grep -F "Xvfb :1 -screen 0 1024x768x24" | grep -v -F 'grep' > /dev/null; then
        true
    else
        false
    fi
}

function setupWineInBashRc() {
    echo "> Setting up Wine in bashrc"
    mkdir -p /winedata/WINE64
    if [ ! -d /winedata/WINE64/drive_c/windows ]; then
      cd /winedata
      echo "> Setting up WineConfig and waiting 15 seconds"
      winecfg > /dev/null 2>&1
      sleep 15
    fi
    cat >> /etc/bash.bashrc <<EOF
export WINEPREFIX=/winedata/WINE64
export WINEARCH=win64
export DISPLAY=:1.0
EOF
}

function isWineinBashRcExistent() {
    grep "wine" /etc/bash.bashrc > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "> Checking if Wine is set in bashrc"
        setupWineInBashRc
    fi
}

function startVirtualScreenAndRebootWine() {
    # Start X Window Virtual Framebuffer
    export WINEPREFIX=/winedata/WINE64
    export WINEARCH=win64
    export DISPLAY=:1.0
    Xvfb :1 -screen 0 1024x768x24 &
    wineboot -r
}

function installServer() {
    RANDOM_NUMBER=$RANDOM
    echo ">>> Forcing a fresh server install"
    echo "> Setting server-name to jammsen-docker-generated-$RANDOM_NUMBER"
    isWineinBashRcExistent
    steamcmdinstaller.sh
    mkdir -p $SAVEGAME_PATH $CONFIG_PATH
    cp /server.cfg.example $CONFIGFILE_PATH
    
    # Set environment variables with defaults
    SERVER_IP="${SERVER_IP:-$(hostname -I)}"
    
    # Update config file with environment variables
    sed -i -e "s/^serverIP .*/serverIP $SERVER_IP/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverSteamPort .*/serverSteamPort $SERVER_STEAM_PORT/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverGamePort .*/serverGamePort $SERVER_GAME_PORT/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverQueryPort .*/serverQueryPort $SERVER_QUERY_PORT/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverPlayers .*/serverPlayers $SERVER_PLAYERS/g" $CONFIGFILE_PATH
    sed -i -e "s/^enableVAC .*/enableVAC $SERVER_VAC/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverPassword .*/serverPassword $SERVER_PASSWORD/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverPasswordAdmin .*/serverPasswordAdmin $SERVER_ADMIN_PASSWORD/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverAutoSaveInterval .*/serverAutoSaveInterval $SERVER_AUTO_SAVE_INTERVAL/g" $CONFIGFILE_PATH
    sed -i -e "s/^difficulty .*/difficulty $SERVER_DIFFICULTY/g" $CONFIGFILE_PATH
    sed -i -e "s/^initType .*/initType $SERVER_INIT_TYPE/g" $CONFIGFILE_PATH
    sed -i -e "s/^slot .*/slot $SERVER_SLOT/g" $CONFIGFILE_PATH
    sed -i -e "s/^showLogs .*/showLogs $SERVER_SHOW_LOGS/g" $CONFIGFILE_PATH
    sed -i -e "s/^serverContact .*/serverContact $SERVER_CONTACT/g" $CONFIGFILE_PATH
    sed -i -e "s/^veganMode .*/veganMode $SERVER_VEGAN_MODE/g" $CONFIGFILE_PATH
    sed -i -e "s/^vegetarianMode .*/vegetarianMode $SERVER_VEGETARIAN_MODE/g" $CONFIGFILE_PATH
    sed -i -e "s/^resetHolesMode .*/resetHolesMode $SERVER_RESET_HOLES_MODE/g" $CONFIGFILE_PATH
    sed -i -e "s/^treeRegrowMode .*/treeRegrowMode $SERVER_TREE_REGROW_MODE/g" $CONFIGFILE_PATH
    sed -i -e "s/^allowBuildingDestruction .*/allowBuildingDestruction $SERVER_ALLOW_BUILDING_DESTRUCTION/g" $CONFIGFILE_PATH
    sed -i -e "s/^allowEnemiesCreativeMode .*/allowEnemiesCreativeMode $SERVER_ALLOW_ENEMIES_CREATIVE/g" $CONFIGFILE_PATH
    sed -i -e "s/^allowCheats .*/allowCheats $SERVER_ALLOW_CHEATS/g" $CONFIGFILE_PATH
    sed -i -e "s/^realisticPlayerDamage .*/realisticPlayerDamage $SERVER_REALISTIC_PLAYER_DAMAGE/g" $CONFIGFILE_PATH
    sed -i -e "s/^targetFpsIdle .*/targetFpsIdle $SERVER_TARGET_FPS_IDLE/g" $CONFIGFILE_PATH
    sed -i -e "s/^targetFpsActive .*/targetFpsActive $SERVER_TARGET_FPS_ACTIVE/g" $CONFIGFILE_PATH
    sed -i -e "s/###serverSteamAccount###/$SERVER_STEAM_ACCOUNT_TOKEN/g" $CONFIGFILE_PATH
    sed -i -e "s/###RANDOM###/$RANDOM_NUMBER/g" $CONFIGFILE_PATH
    
    bash /steamcmd/steamcmd.sh +runscript /steamcmdinstall.txt
}

function updateServer() {
    # force an update and validation
    echo ">>> Doing an update of the gameserver"
    bash /steamcmd/steamcmd.sh +runscript /steamcmdinstall.txt
}

function startServer() {
    if ! isVirtualScreenRunning; then
        startVirtualScreenAndRebootWine
    fi
    rm /tmp/.X1-lock 2> /dev/null
    cd /theforest
    wine64 /theforest/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath /theforest/saves -configfilepath /theforest/config/config.cfg
}

function startMain() {
    # Check if server is installed, if not try again
    if [ ! -f "/theforest/TheForestDedicatedServer.exe" ]; then
        installServer
    fi
    if [ $ALWAYS_UPDATE_ON_START == 1 ]; then
        updateServer
    fi
    startServer
}

startMain
