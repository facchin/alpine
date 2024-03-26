#!/bin/bash
# chmod +x play.sh
# ./play.sh

# Carregando envs
source .env
# Incluindo funções de suporte
source utils.sh

# Definindo o parâmetro para habilitar o "smash"
enable_smash=false

# Inicializando registry de build
build_registry=$REGISTRY
# Inicializando registry temporario
temp_registry="localhost"

# Verifica se o parâmetro "-s" ou "--smash" foi fornecido
if [[ "$1" == "-s" || "$1" == "--smash" ]]; then
  enable_smash=true
fi

# Removendo build anterior
rmI ${REGISTRY}/${REPOSITORY}

# Verifica se a ação "smash" está habilitada
if [ "$enable_smash" = true ]; then
    # REGISTRY TEMPORARIO
    build_registry=$temp_registry

    # BUILD TEMPORARIO
    navigation callback_build

    # SMASH GERAL DAS IMAGES
    navigation callback_smash
else
    # BUILD TEMPORARIO
    navigation callback_build
fi

echo -e "\n\n"
docker images --format '{{.Repository}}:{{.Tag}}\t\t{{.Size}}'| grep "^alpine"
docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}'  | grep "^${temp_registry}"
docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}'  | grep "^${REGISTRY}/${CONTEXT_SLUG}"

# Limpeza
rmI ${temp_registry}/${REPOSITORY}
