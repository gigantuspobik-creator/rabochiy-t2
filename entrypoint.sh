#!/bin/sh
set -e
echo "Starting Xray Reality..."
REQUIRED="PORT UUID PRIVATE_KEY SHORT_ID REALITY_DEST REALITY_SNI"
for VAR in $REQUIRED; do
  eval "VALUE=\$$VAR"
  if [ -z "$VALUE" ]; then
    echo "FATAL: Missing $VAR"
    exit 1
  fi
done
envsubst '${PORT} ${UUID} ${PRIVATE_KEY} ${SHORT_ID} ${REALITY_DEST} ${REALITY_SNI}' \
  < /etc/xray/config.template.json > /etc/xray/config.json
echo "Starting Xray on port $PORT..."
exec xray run -config /etc/xray/config.json
