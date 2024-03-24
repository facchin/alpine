#!/bin/bash
# chmod +x play.sh
# ./play.sh

rmI () {
    imageName=$1
    if [[ "$(docker images -q $imageName 2> /dev/null)" != "" ]]; then

        # Remove containers
        containerIds=$(docker ps -a | grep "$imageName" | awk '{ print $1 }')
        if [[ ! -z "$containerIds" ]]; then
            docker stop $containerIds
            docker rm $containerIds
        fi

        # Remove dangling images
        danglingIds=$(docker images --filter "dangling=true" -q --no-trunc)
        if [[ ! -z "$danglingIds" ]]; then
            docker rmi $danglingIds
        fi

        # Remove images
        docker images -q $imageName | xargs docker rmi -f
    fi
}

# Carregando envs
source .env

# Removendo build anterior
rmI ${REGISTRY}/${REPOSITORY}

# Loop através dos diretórios no diretório atual
for dir in */; do
    # Extrai o nome do diretório removendo a barra final
    version=${dir%/}

    # Verifica se o nome do diretório corresponde ao padrão de versão
    if [[ $version =~ ^[0-9]+\.[0-9]+$ ]]; then
        if [ -f "$version/Dockerfile" ]; then
            # BUILD final
            docker build \
                -f $version/Dockerfile \
                --build-arg TIMEZONE=$TIMEZONE \
                -t ${REGISTRY}/${REPOSITORY}:${version} .
        fi
    fi
done


echo -e "\n\n"
docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | awk -F'\t' '$2 ~ /^alpine/'
docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | awk -v registry="$REGISTRY" -v repository="$REPOSITORY" -F'\t' '$2 ~ ("^" registry "/" repository)'
