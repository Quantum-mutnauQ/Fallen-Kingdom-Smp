#!/bin/sh
set -eu

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FORGE_VERSION=40.2.26
INSTALLER="forge-1.18.2-$FORGE_VERSION-installer.jar"
FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/forge-1.18.2-$FORGE_VERSION-installer.jar"

pause() {
    printf "%s\n" "${YELLOW}Press enter to continue...${NC}"
    read ans
}

cd "$(dirname "$0")"
if [ ! -d libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION ] ; then
    echo "${YELLOW}Forge not installed, installing it now.${NC}"
    if [ ! -f "$INSTALLER" ]; then
        echo "${YELLOW}No Forge installer found, downloading it now.${NC}"
        if command -v wget >/dev/null 2>&1; then
            echo "${GREEN}wget: Downloading $FORGE_URL${NC}"
            wget -O "$INSTALLER" "$FORGE_URL"
        else
            if command -v curl >/dev/null 2>&1; then
                echo "${GREEN}curl: Downloading $FORGE_URL${NC}"
                curl -o "$INSTALLER" -L "$FORGE_URL"
            else
                echo "${RED}Neither wget or curl were found on your system. Please install one of them and try again.${NC}"
                pause
                exit 1
            fi
        fi
    fi

    echo "${GREEN}Running Forge installer.${NC}"
    "${FKS_JAVA:-java}" -jar "$INSTALLER" -installServer
fi

if [ "${FKS_INSTALL_ONLY:-false}" = "true" ]; then
    echo "${GREEN}INSTALL_ONLY: complete${NC}"
    exit 0
fi

if [ ! -f eula.txt ]; then
    echo "${YELLOW}Do you want to accept Minecraft server EULA [y/n]${NC}: "    
    read accept_eula
    if [ "$accept_eula" = "y" ]; then
        echo "eula=true" > eula.txt
        echo "${GREEN}EULA accepted. eula.txt created.${NC}"
    else
        echo "${RED}EULA not accepted. Exiting.${NC}"
        exit 1
    fi
fi

echo "${GREEN}Running server${NC}"

"${FKS_JAVA:-java}" @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/unix_args.txt

