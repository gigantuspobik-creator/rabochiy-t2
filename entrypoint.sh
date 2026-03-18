#!/bin/sh
set -e
echo "Starting Xray WS..."
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
echo "Starting Xray on port $PORT with WS path $WS_PATH..."
exec xray run -config /etc/xray/config.json
