#!/bin/sh
set -e
CONF_FILE="/etc/ddclient.conf"

: "${DDNS_USERNAME?Need to set DDNS_USERNAME env var}"
: "${DDNS_PASSWORD?Need to set DDNS_PASSWORD env var}"
: "${DDNS_SERVER?Need to set DDNS_SERVER env var}"
: "${DDNS_PROTOCOL?Need to set DDNS_PROTOCOL env var}"
: "${DDNS_DAEMON_INTERVAL?Need to set DDNS_DAEMON_INTERVAL env var}"
: "${DDNS_HOSTNAME?Need to set DDNS_HOSTNAME env var}"

sed -i "s/USERNAME/${DDNS_USERNAME}/g" ${CONF_FILE}
sed -i "s/PASSWORD/${DDNS_PASSWORD}/g" ${CONF_FILE}
sed -i "s/SERVER/${DDNS_SERVER}/g" ${CONF_FILE}
sed -i "s/PROTOCOL/${DDNS_PROTOCOL}/g" ${CONF_FILE}
sed -i "s/INTERVAL/${DDNS_DAEMON_INTERVAL}/g" ${CONF_FILE}
sed -i "s/HOSTNAME/${DDNS_HOSTNAME}/g" ${CONF_FILE}

ddclient -foreground -verbose
