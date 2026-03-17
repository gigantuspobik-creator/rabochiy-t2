#!/bin/sh
set -e
REQUIRED="PORT UUID PRIVATE_KEY SHORT_ID REALITY_DEST REALITY_SNI"
for VAR in $REQUIRED; do
  eval "VALUE=\$$VAR"
  if [ -z "$VALUE" ]; then echo "FATAL: Missing $VAR"; exit 1; fi
done
envsubst '${PORT} ${UUID} ${PRIVATE_KEY} ${SHORT_ID} ${REALITY_DEST} ${REALITY_SNI}' \
  < /etc/xray/config.template.json > /etc/xray/config.json
exec xray run -config /etc/xray/config.json
