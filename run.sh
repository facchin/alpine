#!/bin/bash
# chmod +x run.sh
# ./run.sh 3.7

# Carregando envs
source .env

version=$1
image="${REGISTRY}/${REPOSITORY}:${version}"

if [ -z $version ]; then
    echo "Informe a versão: ./run <version>";
    exit 1;
fi

rm () {
    imageName=$1

    # Remove containers
    containerIds=$(docker ps -a | grep "$imageName" | awk '{ print $1 }')
    if [[ ! -z "$containerIds" ]]; then
        docker stop $containerIds
        docker rm $containerIds
    fi
}

if docker image inspect "$image" &> /dev/null; then
    echo -e "Imagem '$image' localizada ...\n"

    # Remove o container caso já exista um utilizando a mesma imagem
    rm $image

    echo -e "Iniciando container..."
    docker run -d --name tmp_img $image

    echo -e "Conectando no container..."
    docker exec -it tmp_img sh

    echo "Removendo container ..."
    docker rm -f tmp_img
    echo "Container removido!"
else
    echo "ERROR: A imagem '$image' não existe localmente."
fi
