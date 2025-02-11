#!/bin/bash

set -e  # Para o script em caso de erro

echo "Iniciando a configuração pós-instalação no Ubuntu..."

# 1. Configurar Proxy Global
echo "Configurando proxy global..."
cat <<EOF | sudo tee /etc/environment
http_proxy="http://192.168.10.1:3128"
https_proxy="http://192.168.10.1:3128"
ftp_proxy="http://192.168.10.1:3128"
no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
EOF

# Configurar proxy para o APT
echo "Configurando proxy para APT..."
cat <<EOF | sudo tee /etc/apt/apt.conf.d/95proxies
Acquire::http::Proxy "http://192.168.10.1:3128/";
Acquire::https::Proxy "http://192.168.10.1:3128/";
EOF

# Configurar proxy para shells interativos
echo "Configurando proxy para shells interativos..."
cat <<EOF | sudo tee /etc/profile.d/proxy.sh
#!/bin/bash
export http_proxy="http://192.168.10.1:3128"
export https_proxy="http://192.168.10.1:3128"
export ftp_proxy="http://192.168.10.1:3128"
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
EOF
sudo chmod +x /etc/profile.d/proxy.sh

# 2. Definir senha do usuário root
echo "Definindo senha para o usuário root..."
echo "root:lionslabroot2025" | sudo chpasswd

# 3. Atualizar repositórios
echo "Atualizando lista de pacotes..."
sudo apt update

# 4. Instalar Programas Necessários
echo "Instalando programas necessários..."

# Instalar curl, git e gnupg
sudo apt install -y curl git gnupg

# Instalar Node.js e npm
echo "Instalando Node.js e npm..."
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g nodemon

# Instalar Visual Studio Code
echo "Instalando Visual Studio Code..."
wget -q https://vscode.download.prss.microsoft.com/dbazure/download/stable/019f4d1419fbc8219a181fab7892ebccf7ee29a2/code_1.87.0-1709078641_amd64.deb
sudo apt install -y ./code_1.87.0-1709078641_amd64.deb
rm -f code_1.87.0-1709078641_amd64.deb

# Instalar Postman via Flatpak
echo "Instalando Postman..."
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.getpostman.Postman

# Instalar Google Chrome
echo "Instalando Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# Instalar MongoDB
echo "Instalando MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# Instalar MongoDB Compass
echo "Instalando MongoDB Compass..."
wget -q https://downloads.mongodb.com/compass/mongodb-compass_1.40.4_amd64.deb
sudo apt install -y ./mongodb-compass_1.40.4_amd64.deb
rm -f mongodb-compass_1.40.4_amd64.deb

# Instalar VirtualBox
echo "Instalando VirtualBox..."
wget -q https://download.virtualbox.org/virtualbox/7.0.14/virtualbox-7.0_7.0.14-161095~Ubuntu~jammy_amd64.deb
sudo apt install -y ./virtualbox-7.0_7.0.14-161095~Ubuntu~jammy_amd64.deb
sudo /sbin/vboxconfig
rm -f virtualbox-7.0_7.0.14-161095~Ubuntu~jammy_amd64.deb

# Baixar a ISO do Ubuntu para futuras instalações
echo "Baixando ISO do Ubuntu 22.04.4..."
wget https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso -P /opt
sudo chmod 777 -R /opt/

# 5. Limpeza Final
echo "Limpando pacotes desnecessários..."
sudo apt autoremove -y

echo "=================================================="
echo "Configuração pós-instalação concluída com sucesso!"
echo "=================================================="
