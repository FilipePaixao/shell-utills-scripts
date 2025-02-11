#!/bin/bash

set -e 

echo "Starting proxy configuration"

echo "Setting global proxy configuration..."
cat <<EOF | sudo tee /etc/environment
http_proxy="http://111.111.11.1:1111" 
https_proxy="https://111.111.11.1:1111"
ftp_proxy="http://111.111.11.1:1111"
no_proxy="localhost,127.0.0.1,.localdomain.com"
EOF

echo "Setting APT proxy configuration..."
cat <<EOF | sudo tee /etc/apt/apt.conf.d/95proxies
Acquire::http::Proxy "http://111.111.11.1:1111/";
Acquire::https::Proxy "https://111.111.11.1:1111/";
EOF

echo "Setting interactive shell proxy configuration..."
cat <<EOF | sudo tee /etc/profile.d/proxy.sh
#!/bin/bash
export http_proxy="http://111.111.11.1:1111"
export https_proxy="https://111.111.11.1:1111"
export ftp_proxy="http://111.111.11.1:1111"
export no_proxy="localhost,127.0.0.1,.localdomain.com"
EOF
sudo chmod +x /etc/profile.d/proxy.sh

echo "Removing unnecessary packages..."
sudo apt autoremove -y

echo "=================================================="
echo "Post-installation configuration completed successfully!"
echo "=================================================="
