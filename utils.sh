#!/bin/bash

rmI () {
    local imageName=$1

    if [[ "$(docker images -q $imageName 2> /dev/null)" != "" ]]; then
        # remove containers
        rmC $imageName

        # remove dangling images
        danglingIds=$(docker images --filter "dangling=true" -q --no-trunc)
        if [[ ! -z "$danglingIds" ]]; then
            docker rmi $danglingIds &> /dev/null
        fi

        # remove images
        docker images -q $imageName | xargs docker rmi -f &> /dev/null
    fi
}

rmC() {
    local imageName=$1
    local containerIds=$(docker ps -a | grep "$imageName" | awk '{ print $1 }')

    if [[ ! -z "$containerIds" ]]; then
        echo "Parando e removendo contêineres..."
        for id in $containerIds; do
            docker stop $id &> /dev/null
            docker rm $id &> /dev/null
            echo "Contêiner $id parado e removido."
        done
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

callback_build() {
    # Baixando imagem alpine
    docker pull ${REPOSITORY}:$1 &> /dev/null

    # BUILD VERSION
    docker build \
        -f $1/Dockerfile \
        --build-arg TIMEZONE=$TIMEZONE \
        -t ${build_registry}/${REPOSITORY}:$1 .
}

callback_smash() {
    # Esmagando images
    docker run -d --name smash_img ${build_registry}/${REPOSITORY}:$1
    docker export smash_img > /tmp/docker-smash_img.tar
    docker import /tmp/docker-smash_img.tar ${build_registry}/smash:latest

    docker build \
        -f Dockerfile.smash \
        --build-arg SMASH_IMG=${build_registry}/smash:latest \
        --build-arg VERSION=$1 \
        -t ${REGISTRY}/${REPOSITORY}:$1 .

    # Limpeza
    rmC ${build_registry}/${REPOSITORY}
    rmI ${build_registry}/smash
    rm /tmp/docker-smash_img.tar
}

callback_push() {
    # Realizando o push da imagem
    docker push ${REGISTRY}/${REPOSITORY}:$1
}
