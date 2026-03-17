FROM alpine:3.19 AS downloader
ARG XRAY_VERSION=v1.8.23
RUN apk add --no-cache curl unzip ca-certificates
RUN curl -fsSL \
    "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
    -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /tmp/xray-bin && \
    mv /tmp/xray-bin/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip /tmp/xray-bin

FROM alpine:3.19
RUN apk add --no-cache gettext ca-certificates
COPY --from=downloader /usr/local/bin/xray /usr/local/bin/xray
COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Используем стандартный порт для маскировки под HTTPS
EXPOSE 443
ENTRYPOINT ["/entrypoint.sh"]
