#!/bin/bash

#set -e

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



OPT_FORCE="${var_force:-0}"
OPT_QUIET=0
OPT_INSTALL_WEB="${var_install_web:-1}"





main() {
  # --- Argumente parsen ---
  while [[ "$#" -gt 0 ]]; do
      case $1 in
          --install-dir) INSTALL_PATH="$2"; shift ;;
          --user) APP_USER="$2"; shift ;;
          --config) CFG_FILE="$2"; shift ;;
          --force) OPT_FORCE=1; shift;;
          *) echo "Unbekannter Parameter: $1"; exit 1 ;;
      esac
      shift
  done
  out "############################################"
  out "###### Install Firestation Gateway #########"
  out "############################################"
  check_fsg

  out_info "Update Paketdatenbank..."
  # make sure package repos are up to date
  apt update

  # check python dependency
  out_info "Installiere python3..."
  apt install -y python3 python3-venv

  setup_fsg

  setup_systemd_service

  if [[ $OPT_INSTALL_WEB -eq 1 ]]; then
    setup_web_service
  fi
}

if [ $(id -u) -ne 0 ]; then
  echo Please run this script as root or using sudo!
  exit 1
fi

main "$@"

