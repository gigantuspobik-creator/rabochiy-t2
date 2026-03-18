FROM alpine:3.19 AS downloader
RUN apk add --no-cache curl unzip ca-certificates
RUN curl -fsSL "https://github.com/XTLS/Xray-core/releases/download/v1.8.23/Xray-linux-64.zip" -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /tmp/xray-bin && mv /tmp/xray-bin/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && rm -rf /tmp/xray.zip /tmp/xray-bin

FROM alpine:3.19
RUN apk add --no-cache gettext ca-certificates
COPY --from=downloader /usr/local/bin/xray /usr/local/bin/xray
COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
