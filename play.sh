#!/bin/bash
# chmod +x play.sh
# ./play.sh

# Definindo o parâmetro para habilitar o "smash"
enable_smash=false

# Verifica se o parâmetro "-s" ou "--smash" foi fornecido
if [[ "$1" == "-s" || "$1" == "--smash" ]]; then
  enable_smash=true
fi

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
                -t BUILD/${REPOSITORY}:${version} .
        fi
    fi
done

# SMASH GERAL DAS IMAGES
# Verifica se a ação "smash" está habilitada
if [ "$enable_smash" = true ]; then
    # Loop através dos diretórios no diretório atual
    for dir in */; do
        # Extrai o nome do diretório removendo a barra final
        version=${dir%/}

        # Verifica se o nome do diretório corresponde ao padrão de versão
        if [[ $version =~ ^[0-9]+\.[0-9]+$ ]]; then
            if [ -f "$version/Dockerfile" ]; then
                # Esmagando images (remover conteúdo adicional não usado)
                docker run -d --name smash_img BUILD/${REPOSITORY}:${version}
                docker export smash_img > /tmp/docker-smash_img.tar
                docker import /tmp/docker-smash_img.tar smash_latest
                rm /tmp/docker-smash_img.tar

                docker build \
                    -f Dockerfile.smash \
                    --build-arg SMASH_IMG=smash_latest \
                    -t ${REGISTRY}/${REPOSITORY}:${version} .

                rmI smash_latest

            fi
        fi
    done
fi




echo -e "\n\n"
docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | awk -F'\t' '$2 ~ /^alpine/'
docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | awk -F'\t' '$2 ~ /^BUILD/'
docker images --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | awk -v registry="$REGISTRY" -v repository="$REPOSITORY" -F'\t' '$2 ~ ("^" registry "/" repository)'

# Limpeza
rmI BUILD/${REPOSITORY}

