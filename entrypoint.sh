#!/bin/sh

set -e

SCRIPT="$1"
VPN_CLIENT_CONFIG="$2"
VPN_AUTOLOAD_CONFIG="$3"
VPN_CLIENT_DIR=$HOME/.openvpn3/client
VPN_CLIENT_CONFIG_PATH=$VPN_CLIENT_DIR/config.ovpn
VPN_CLIENT_AUTOLOAD_PATH=$VPN_CLIENT_DIR/config.autoload

echo $VPN_CLIENT_CONFIG
echo $VPN_AUTOLOAD_CONFIG

mkdir -m700 -p $VPN_CLIENT_DIR
if [ -z "$VPN_AUTOLOAD_CONFIG" ]; then
  echo "$VPN_CLIENT_CONFIG" | base64 --decode >> $VPN_CLIENT_CONFIG_PATH
  openvpn3 session-start --config $VPN_CLIENT_CONFIG_PATH
else
  echo "$VPN_CLIENT_CONFIG" | base64 --decode >> $VPN_CLIENT_CONFIG_PATH
  echo "$VPN_AUTOLOAD_CONFIG" | base64 --decode >> VPN_CLIENT_AUTOLOAD_PATH
  openvpn3-autoload --directory $VPN_CLIENT_DIR
fi
while [ -z "$(openvpn3 sessions-list | grep -io 'client connected')" ]; do
  sleep 0.1;
done

sh -c $SCRIPT
