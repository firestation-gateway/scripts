#!/usr/bin/env bash

# Copyright (c) 2026 firestation-gateway
# License: MIT | https://raw.githubusercontent.com/firestation-gateway/scripts/main/LICENSE

source <(curl -H "Cache-Control: no-cache" -fsSL https://raw.githubusercontent.com/firestation-gateway/scripts/main/misc/core.func)
source <(curl -H "Cache-Control: no-cache" -fsSL https://raw.githubusercontent.com/firestation-gateway/scripts/main/app/fsg/fsg.func)


set -e

exit_with_error() {
    out_err "Es ist ein FEHLER aufgetreten. Installation ist evtl. unvollständig!"
}
trap exit_with_error ERR

core_load

FSG_USER=$SUDO_USER



echo -e "${YELLOW}${BOLD}##################################${RESET}"
echo -e "${YELLOW}${BOLD}# Installing firestation-gateway #${RESET}"
echo -e "${YELLOW}${BOLD}##################################${RESET}"

latest_version=$(fsg_latest_version)
version=$(fsg_version)
ask_rc=1
if [[ -n "${version}" ]]; then

    echo -e "Installierte Version: ${BOLD}${version}${RESET}"
    echo -e "Neuste Version:       ${GREEN}${BOLD}${latest_version}${RESET} (kann heruntergeladen werden)"
    echo
    ask "Soll firestation-gateway aktualisiert werden?"
fi

if [[ "$ask_rc" -eq 1 ]]; then
    # try stop running firestation-gateway
    systemctl stop "$FSG_SYSTEMD_SERVICE" &>/dev/null && true

    out_info "Download firestation-gateway (version: ${latest_version})..."
    wheel_path=$(fsg_download_wheel /tmp ${latest_version})
    install_fsg ${wheel_path}
fi

echo
echo -e "${YELLOW}${BOLD}##################################${RESET}"
echo -e "${YELLOW}${BOLD}#     Installing Webfrontend     #${RESET}"
echo -e "${YELLOW}${BOLD}##################################${RESET}"
echo
ask "Soll firestation-gateway Webfrontend installiert werden?"
if [[ "$ask_rc" -eq 0 ]]; then
    exit 0
fi
install_fsg_webfrontend  $(hostname).local 

echo
