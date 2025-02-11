#!/bin/bash
# ===============================================================
# SCRIPT AUTOMÁTICO DE APAGAR E REINSTALAR O UBUNTU COM PROXY E
# DEFINIÇÃO DE SENHA PADRÃO PARA O USUÁRIO ROOT
# ===============================================================
#
# ESTE SCRIPT:
#  - Apaga TODOS os dados do disco especificado.
#  - Cria uma nova tabela de partição e formata uma partição.
#  - Instala uma versão mínima do Ubuntu via debootstrap.
#  - Configura o sistema para usar o proxy 192.168.10.1:3128:
#      * Variáveis de ambiente globais (/etc/environment).
#      * Configuração do APT (/etc/apt/apt.conf.d/95proxies).
#      * Script em /etc/profile.d/ para shells interativos.
#  - Define a senha do usuário root para "lionslabroot2025".
#  - Instala pacotes essenciais (kernel e GRUB) e configura o boot.


set -e  # Encerra o script se algum comando falhar

DISCO="/dev/sda"

echo "INICIANDO A INSTALAÇÃO AUTOMÁTICA: Todos os dados em $DISCO serão apagados!"


echo "Desmontando partições de $DISCO (se existirem)..."
for part in $(ls ${DISCO}?* 2>/dev/null); do
    umount "$part" 2>/dev/null || true
done


echo "Apagando a tabela de partição de $DISCO..."
dd if=/dev/zero of="$DISCO" bs=512 count=1


echo "Criando nova tabela de partição e partição primária..."
parted "$DISCO" --script mklabel msdos
parted "$DISCO" --script mkpart primary ext4 1MiB 100%


partprobe "$DISCO"


PARTICAO="${DISCO}1"
echo "Formatando a partição $PARTICAO em ext4..."
mkfs.ext4 "$PARTICAO"


echo "Montando $PARTICAO em /mnt..."
mount "$PARTICAO" /mnt


UBUNTU_RELEASE="mantic"
UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu"

echo "Instalando o Ubuntu $UBUNTU_RELEASE via debootstrap..."
debootstrap --arch amd64 "$UBUNTU_RELEASE" /mnt "$UBUNTU_MIRROR"


echo "Configurando o proxy no novo sistema..."

cat <<EOF | tee /mnt/etc/environment
http_proxy="http://192.168.10.1:3128"
https_proxy="http://192.168.10.1:3128"
ftp_proxy="http://192.168.10.1:3128"
no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
EOF

chroot /mnt bash -c 'cat <<EOF > /etc/apt/apt.conf.d/95proxies
Acquire::http::Proxy "http://192.168.10.1:3128/";
Acquire::https::Proxy "http://192.168.10.1:3128/";
EOF'

chroot /mnt bash -c 'cat <<EOF > /etc/profile.d/proxy.sh
#!/bin/bash
export http_proxy="http://192.168.10.1:3128"
export https_proxy="http://192.168.10.1:3128"
export ftp_proxy="http://192.168.10.1:3128"
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
EOF'
chroot /mnt chmod +x /etc/profile.d/proxy.sh



UUID=$(blkid -s UUID -o value "$PARTICAO")
echo "UUID=$UUID  /  ext4  defaults  0 1" | tee /mnt/etc/fstab
    
echo "ubuntu-auto" | tee /mnt/etc/hostname

# Configura o sources.list
cat <<EOF | tee /mnt/etc/apt/sources.list
deb $UBUNTU_MIRROR $UBUNTU_RELEASE main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_RELEASE-updates main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_RELEASE-security main restricted universe multiverse
EOF

# 10. Monta os pseudo-sistemas de arquivos para o chroot
echo "Montando /dev, /proc e /sys em /mnt..."
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys

echo "Atualizando e instalando pacotes essenciais no chroot..."
chroot /mnt apt-get update


echo "Definindo a senha do usuário root..."
chroot /mnt bash -c "echo 'root:lionslabroot2025' | chpasswd"


chroot /mnt apt-get install -y linux-image-generic grub-pc


echo "Instalando o GRUB em $DISCO..."
chroot /mnt grub-install "$DISCO"
chroot /mnt update-grub

echo "Desmontando /mnt/dev, /mnt/proc, /mnt/sys e /mnt..."
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt

echo "===================================================================="
echo "Instalação mínima do Ubuntu com proxy e senha root configurados concluída!"
echo "Remova o pendrive live e reinicie o sistema."
echo "===================================================================="

exit 0
