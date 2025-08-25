# Alpine - Imagens Base Docker

Este repositório contém imagens Docker baseadas no Alpine Linux, otimizadas para desenvolvimento e produção. As imagens são configuradas com configurações de segurança, timezone e ferramentas essenciais.

## Descrição

O projeto fornece imagens Docker baseadas no Alpine Linux com as seguintes características:

- **Segurança**: Usuário não privilegiado (`app`) com UID 1001
- **Configuração de Timezone**: Configurável via variável de ambiente
- **Ferramentas Essenciais**: coreutils, tzdata, openssl, ca-certificates
- **Otimização**: Cache limpo e arquivos temporários removidos
- **Múltiplas Versões**: Suporte para diferentes versões do Alpine (3.7, 3.19)

## Estrutura do Projeto

```
alpine/
├── 3.7/                 # Imagem Alpine 3.7
│   └── Dockerfile
├── 3.19/                # Imagem Alpine 3.19
│   └── Dockerfile
├── Dockerfile.smash     # Dockerfile para processo de "smash"
├── play.sh             # Script para build das imagens
├── run.sh              # Script para executar containers
├── utils.sh            # Funções utilitárias
└── README.md           # Este arquivo
```

## Como Usar

### Pré-requisitos

- Docker instalado e configurado
- Arquivo `.env` configurado (veja seção de configuração)

### Build das Imagens

Para construir todas as imagens:

```bash
./play.sh
```

Para construir com processo de "smash" (otimização adicional):

```bash
./play.sh --smash
```

### Executar Container

Para executar um container com uma versão específica:

```bash
./run.sh 3.19
```

ou

```bash
./run.sh 3.7
```

### Usar Imagens Prontas

Caso queiram usar as imagens prontas, podem usar as imagens no registry público:

```bash
docker pull facchin/alpine:3.7
docker pull facchin/alpine:3.19
```

## Configuração

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```bash
# Registry e repositório
REGISTRY=seu-registry
REPOSITORY=alpine
CONTEXT_SLUG=alpine

# Configuração de timezone
TIMEZONE=UTC
```

## Scripts Disponíveis

### `play.sh`
Script principal para build das imagens:
- Remove imagens anteriores
- Constrói todas as versões disponíveis
- Suporte ao processo de "smash" para otimização
- Exibe imagens construídas

### `run.sh`
Script para executar containers:
- Verifica se a imagem existe
- Remove containers anteriores
- Executa o container em modo interativo
- Limpa recursos após uso

### `utils.sh`
Funções utilitárias:
- `rmI`: Remove imagens Docker
- `rmC`: Remove containers Docker
- `navigation`: Navega pelos diretórios de versão
- `callback_build`: Callback para build
- `callback_smash`: Callback para processo de smash
- `callback_push`: Callback para push das imagens

## Processo de "Smash"

O processo de "smash" é uma técnica de otimização que:
1. Exporta a imagem construída
2. Re-importa como uma nova imagem base
3. Aplica configurações adicionais
4. Reduz o tamanho final da imagem

## Versões Disponíveis

- **Alpine 3.7**: Versão mais antiga, compatível com sistemas legados
- **Alpine 3.19**: Versão mais recente, com melhorias de segurança e performance

## Segurança

- Usuário não privilegiado (`app`) com UID 1001
- Certificados SSL atualizados
- Cache e arquivos temporários limpos
- Configurações de timezone seguras

## Licença

Este projeto está licenciado sob os termos da licença incluída no arquivo `LICENSE`.

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Suporte

Para dúvidas ou problemas, abra uma issue no repositório.
