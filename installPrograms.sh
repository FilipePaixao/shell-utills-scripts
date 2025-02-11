#!/bin/bash

cd ~

# Update package lists
sudo apt update

#install curl
sudo apt-get install -y gnupg curl

#install git
sudo apt-get install git -y

# Install Node.js and npm
curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt-get install nodejs -y

#install nodemon
sudo npm install -g nodemon

# Install Visual Studio Code
wget -q https://vscode.download.prss.microsoft.com/dbazure/download/stable/019f4d1419fbc8219a181fab7892ebccf7ee29a2/code_1.87.0-1709078641_amd64.deb
sudo apt install -y ./code_1.87.0-1709078641_amd64.deb

#install postman
#sudo snap install postman #in snap the download is slow
sudo apt install flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.getpostman.Postman -y

# Install Chrome
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Install MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

#install compass
wget -q https://downloads.mongodb.com/compass/mongodb-compass_1.40.4_amd64.deb
sudo apt install ./mongodb-compass_1.40.4_amd64.deb

#configs for vm
sudo apt install -y dkms

#install virtual box
wget -q https://download.virtualbox.org/virtualbox/7.0.14/virtualbox-7.0_7.0.14-161095~Ubuntu~jammy_amd64.deb
sudo apt install ./virtualbox-7.0_7.0.14-161095~Ubuntu~jammy_amd64.deb -y

#build vm kernel
sudo /sbin/vboxconfig

#download ubuntu
wget https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso -P /opt

sudo chmod 777 -R /opt/*
sudo chmod 777 /opt

# Clean up
rm -rf google-chrome-stable_current_amd64.deb code_1.87.0-1709078641_amd64.deb mongodb-compass_1.40.4_amd64.deb

echo "Installation complete!"