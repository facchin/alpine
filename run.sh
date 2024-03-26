#!/bin/bash
# chmod +x run.sh
# ./run.sh 3.7
# ./play.sh && ./run.sh 3.7

# Carregando envs
source .env
# Incluindo funções de suporte
source utils.sh

version=$1
image="${REGISTRY}/${REPOSITORY}:${version}"

# Verificar se o argumento de versão foi fornecido
if [ -z "$version" ]; then
    echo "Erro: Por favor, informe a versão: ./run.sh <version>"
    exit 1
fi

if docker image inspect "$image" &> /dev/null; then
    echo "Imagem '$image' localizada."

    # Remover o container se já existir um utilizando a mesma imagem
    rmC "$image"

    echo "Iniciando container..."
    container_id=$(docker run -d --name tmp_img "$image")

    if [ $? -eq 0 ]; then
        echo "Conectando ao container..."
        # Passando comandos diretamente para o container
        docker exec -it tmp_img sh
        echo "Saindo do container..."
    else
        echo "Erro ao iniciar o container."
        exit 1
    fi

    echo "Removendo container..."
    docker rm -f tmp_img
    echo "Container removido!"
else
    echo "Erro: A imagem '$image' não existe localmente."
    exit 1
fi
