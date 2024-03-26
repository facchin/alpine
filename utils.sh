#!/bin/bash

rmI () {
    local imageName=$1
    echo "FOI5"
    if [[ "$(docker images -q $imageName 2> /dev/null)" != "" ]]; then
        echo "FOI6"
        # remove containers
        rmC $imageName
        echo "FOI7"
        # remove dangling images
        danglingIds=$(docker images --filter "dangling=true" -q --no-trunc)
        if [[ ! -z "$danglingIds" ]]; then
            docker rmi $danglingIds &> /dev/null
        fi
        echo "FOI8"
        # remove images
        docker images -q $imageName | xargs docker rmi -f &> /dev/null
    fi
}

rmC () {
    local imageName=$1

    # Remove containers
    containerIds=$(docker ps -a | grep "$imageName" | awk '{ print $1 }')
    if [[ ! -z "$containerIds" ]]; then
        docker stop $containerIds &> /dev/null
        docker rm $containerIds &> /dev/null
    fi
}


navigation() {
    local callback=$1

    # Loop através dos diretórios no diretório atual
    for dir in */; do
        # Extrai o nome do diretório removendo a barra final
        version=${dir%/}

        # Verifica se o nome do diretório corresponde ao padrão de versão
        if [[ $version =~ ^[0-9]+\.[0-9]+$ ]]; then
            if [ -f "$version/Dockerfile" ]; then
                $callback $version
            fi
        fi
    done
}

# Define a função que será chamada de volta
callback_build() {
    # Baixando imagem alpine
    docker pull ${REPOSITORY}:$1 &> /dev/null

    # BUILD VERSION
    docker build \
        -f $1/Dockerfile \
        --build-arg TIMEZONE=$TIMEZONE \
        -t ${build_registry}/${REPOSITORY}:$1 .
}

# Define a função que será chamada de volta
callback_smash() {
    # Esmagando images (remover conteúdo adicional não usado)
    echo "FOI1"
    docker run -d --name smash_img ${build_registry}/${REPOSITORY}:$1
    docker export smash_img > /tmp/docker-smash_img.tar
    docker import /tmp/docker-smash_img.tar ${build_registry}/smash:latest
    echo "FOI2"
    docker build \
        -f Dockerfile.smash \
        --build-arg SMASH_IMG=${build_registry}/smash:latest \
        -t ${REGISTRY}/${REPOSITORY}:$1 .
    echo "FOI3"
    # Limpeza
    rmC ${build_registry}/${REPOSITORY}
    echo "FOI4"
    rmI ${build_registry}/smash
    echo "FOI9"
    rm /tmp/docker-smash_img.tar
    echo "FOI10"
}
