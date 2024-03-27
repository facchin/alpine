FROM alpine:3.19

# Configura timezone
ARG TIMEZONE=UTC
ENV TIMEZONE=$TIMEZONE

# Atualiza pacotes existentes e instala os pacotes necessários
RUN apk update && apk upgrade --force \
    && apk add \
        bash \
        bash-completion \
        coreutils \
        tzdata \
        openssl \
        ca-certificates \
    && update-ca-certificates 2>/dev/null || true \
    # Configura o timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" | tee /etc/timezone  \
    # Cria um usuário não privilegiado chamado "app"
    && adduser -D -u 1001 app

# Direciona o diretorio padrão de cache para o diretorio de cache real
RUN ln -s /var/cache/apk /etc/apk/cache

# Remove arquivos temporários e limpa logs
RUN apk cache clean \
    && rm -rf /tmp/* \
    && find /var/log -type f | while read f; do echo -n '' > ${f}; done

# Define o entrypoint do container
ENTRYPOINT ["watch", "-n", "1", "date"]

# Altera o usuário para "app"
USER app

# Define o diretório de trabalho para o usuário "app"
WORKDIR /home/app
