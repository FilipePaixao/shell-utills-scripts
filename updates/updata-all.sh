#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute este script como root (ex.: sudo ./atualiza.sh)."
    exit 1
fi

echo "=============================================="
echo " Iniciando atualização do sistema e pacotes "
echo "=============================================="

echo "Atualizando repositórios e pacotes do sistema..."
apt update && apt upgrade -y

echo "Atualizando Node.js para a versão mais recente..."
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt install -y nodejs

echo "Atualizando npm..."
npm install -g npm

echo "Atualizando MongoDB..."
apt update && apt upgrade -y mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools

echo "=============================================="
echo " Atualizações concluídas com sucesso! "
echo "=============================================="

read -p "Pressione ENTER para sair..."
