FROM alpine:3.7

# Configura timezone
ARG TIMEZONE=UTC
ENV TIMEZONE=$TIMEZONE

# Atualiza pacotes existentes e instala os pacotes necessários
RUN apk update && apk upgrade --force \
    && apk add \
        tzdata \
        openssl \
    && update-ca-certificates 2>/dev/null || true \
    # Configura o timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" | tee /etc/timezone

ENTRYPOINT ["watch", "-n", "1", "date"]
