#!/bin/bash
# Script para apagar todos os usuários não-administradores (que não pertencem ao grupo "sudo")
# e remover seus arquivos (diretório home, etc.).
#
# ATENÇÃO: Use este script com MUITA cautela!
# Ele excluirá usuários e seus arquivos permanentemente.
#
# Execute este script como root, por exemplo:
#     sudo ./remove_nao_admin.sh

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute este script como root (ex.: sudo ./remove_nao_admin.sh)"
    exit 1
fi

# Exibe aviso e pede confirmação
echo "=================================================="
echo "ATENÇÃO: Este script irá apagar TODOS os usuários não-administradores (UID>=1000)"
echo "         e remover seus arquivos. Certifique-se de ter backup dos dados!"
echo "=================================================="
read -p "Deseja continuar? (s/N): " confirm
if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
    echo "Operação cancelada."
    exit 0
fi

# Itera sobre os usuários listados em /etc/passwd
while IFS=: read -r username _ uid _ _ home shell; do
    # Considera apenas usuários com UID >= 1000 (usuários comuns) e ignora "nobody"
    if [ "$uid" -ge 1000 ] && [ "$username" != "nobody" ]; then
        # Verifica se o usuário pertence ao grupo "sudo"
        if id -nG "$username" | grep -qw "sudo"; then
            echo "Pulando usuário administrativo: $username"
        else
            echo "Apagando usuário não-administrativo: $username"
            # Remove o usuário e seus arquivos (incluindo o diretório home)
            if userdel -r "$username"; then
                echo "Usuário $username removido com sucesso."
            else
                echo "Falha ao remover o usuário $username."
            fi
        fi
    fi
done < /etc/passwd

echo "Operação concluída."
