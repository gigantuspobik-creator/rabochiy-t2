#!/bin/sh
set -e

echo "Starting Xray WS + Cloudflare Tunnel..."

REQUIRED="PORT UUID WS_PATH"
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

echo "Waiting for Xray to start..."
sleep 2

echo "Starting Cloudflare Tunnel..."
cloudflared tunnel --no-autoupdate --url http://localhost:$PORT 2>&1 | tee /tmp/cf.log &

echo "Waiting for tunnel URL..."
for i in $(seq 1 30); do
  TUNNEL_URL=$(grep -o 'https://[a-zA-Z0-9._-]*\.trycloudflare\.com' /tmp/cf.log 2>/dev/null | head -1)
  if [ -n "$TUNNEL_URL" ]; then
    break
  fi
  sleep 1
done

if [ -z "$TUNNEL_URL" ]; then
  echo "WARNING: Could not get tunnel URL, check logs"
else
  echo ""
  echo "=========================================="
  echo "TUNNEL URL: $TUNNEL_URL"
  echo ""
  echo "VLESS LINK:"
  echo "vless://${UUID}@$(echo $TUNNEL_URL | sed 's/https:\/\///')":443"?type=ws&security=tls&path=$(echo $WS_PATH | sed 's/\//%2F/g')&sni=$(echo $TUNNEL_URL | sed 's/https:\/\///') #Railway-CF-Tunnel"
  echo "=========================================="
  echo ""
fi

wait
