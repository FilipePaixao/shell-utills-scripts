#!/bin/bash

# Verifica se o script é executado com permissões de superusuário
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como superusuário" 1>&2
   exit 1
fi

# Verifica se o número correto de argumentos foi fornecido
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <user1> <user2> <user3>"
    exit 1
fi

# Loop para criar os usuários
for username in "$@"; do
    # Verifica se o usuário já existe
    if id "$username" &>/dev/null; then
        echo "O usuário $username já existe. Pulando..."
    else
        # Cria o usuário com a senha sendo o próprio nome de usuário
        useradd -m -s /bin/bash "$username"
        echo "$username:$username" | chpasswd

        echo "Usuário $username criado com sucesso."
    fi

done

echo "Todos os usuários foram criados com sucesso."