#!/bin/sh
set -e

echo "Starting Xray WS + Cloudflare Named Tunnel..."

REQUIRED="PORT UUID WS_PATH TUNNEL_TOKEN"
for VAR in $REQUIRED; do
  eval "VALUE=\$$VAR"
  if [ -z "$VALUE" ]; then
    echo "FATAL: Missing $VAR"
    exit 1
  fi
done

envsubst '${PORT} ${UUID} ${WS_PATH}' \
  < /etc/xray/config.template.json > /etc/xray/config.json

echo "Starting Xray on port $PORT..."
xray run -config /etc/xray/config.json &

echo "Waiting for Xray..."
sleep 2

echo "Starting Cloudflare Named Tunnel..."
exec cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN"
