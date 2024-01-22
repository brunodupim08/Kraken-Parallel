#!/usr/bin/env bash

# Função para lidar com a interrupção (Ctrl+C)
trap 'kill $(jobs -p) && exit' INT

# Função tentacles para executar comandos em segundo plano
tentacles() {
    # Seu código para executar o comando em segundo plano usando &
    fixed_command="$1"
    line_input="$2"
    force_y="$3"

    # Seu comando aqui
    "$fixed_command $line_input $force_y" &
}

# Exemplo de uso:
tentacles echo "Hello, world!"
tentacles sleep 10

# Aguarda as subshells concluírem antes de encerrar
wait
