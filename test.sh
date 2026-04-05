
#!/usr/bin/env bash
#source <(curl -H "Cache-Control: no-cache" -fsSL https://raw.githubusercontent.com/firestation-gateway/scripts/feature/install-script/misc/core.func)
#source <(curl -H "Cache-Control: no-cache" -fsSL https://raw.githubusercontent.com/firestation-gateway/scripts/feature/install-script/app/fsg/fsg.func)
source misc/core.func
source app/fsg/fsg.func

set -e

exit_with_error() {
    echo "Es ist ein FEHLER aufgetreten. Installation ist evtl. unvollständig"
}
trap exit_with_error ERR
core_load

# myval=2 sudo -E bash -c "$(curl -fsSL https://raw.githubusercontent.com/firestation-gateway/scripts/main/installFSG.sh)"

INSTALL_PATH=/opt/firestation
CONFIG_PATH=$INSTALL_PATH/config.yaml
LATEST_VERSION=1.0.0
WHEEL_FILE=firestation_gateway-${LATEST_VERSION}-py3-none-any.whl
APP_USER="$SUDO_USER"

WEB_USER="www-data"
CFG_FILE=0

SCRIPT_NAME="firestation-gw"

SERVICE_NAME="firestation-gateway.service"
SERVICE_PATH=/etc/systemd/system/$SERVICE_NAME

WEB_SITE_CONFIG_PATH=/etc/apache2/sites-available/$(hostname).local.conf


FSG_INSTALL_PATH=/opt/firestation-gateway
FSG_USER=$SUDO_USER
FSG_SYSTEMD_SERVICE=firestation-gateway.service


# try stop running firestation-gateway
set +e
systemctl stop "$FSG_SYSTEMD_SERVICE"
set -e


echo "##################################"
echo "# Installing firestation gateway #"
echo "##################################"

latest_version=$(fsg_latest_version)
version=$(fsg_version)
ask_rc=1
if [[ -n "${version}" ]]; then

    echo "Installierte Version: ${version}"
    echo "Neuste Version:       ${latest_version}"
    
    ask "Soll firestation-gateway aktualisiert werden?"
fi

if [[ "$ask_rc" -eq 1 ]]; then
    out_info "Download firestation-gateway (version: ${latest_version})..."
    wheel_path=$(fsg_download_wheel /tmp ${latest_version})
    install_fsg ${wheel_path}
fi

ask "Soll firestation-gateway Webfrontend installiert werden?"
if [[ "$ask_rc" -eq 0 ]]; then
    exit 0
fi
echo "##################################"
echo "#     Installing Webfrontend     #"
echo "##################################"
setup_apache_website $(hostname).local 
grant_permissions_website firestation-gateway.service $FSG_INSTALL_PATH/config.yaml
