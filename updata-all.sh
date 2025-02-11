#!/bin/bash
set -e  # Interrompe o script se ocorrer algum erro

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute este script como root (ex.: sudo ./atualiza_tudo.sh)."
    exit 1
fi

echo "=============================================="
echo " Iniciando atualização do sistema e pacotes "
echo "=============================================="

# 1. Atualiza repositórios e todos os pacotes do sistema
echo "Atualizando repositórios e pacotes do sistema..."
apt update && apt upgrade -y

# 2. Atualiza Node.js para a versão mais recente (current)
echo "Atualizando Node.js para a versão mais recente..."
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt install -y nodejs

# 3. Atualiza o npm globalmente
echo "Atualizando npm..."
npm install -g npm

# 4. Atualiza o MongoDB (mongodb-org)
# Se houver uma nova versão disponível no repositório configurado, ela será instalada
echo "Atualizando MongoDB..."
apt update && apt upgrade -y mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools

echo "=============================================="
echo " Atualizações concluídas com sucesso! "
echo "=============================================="

# Aguarda o usuário pressionar ENTER antes de sair (opcional)
read -p "Pressione ENTER para sair..."
