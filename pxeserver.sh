#!/bin/bash

echo
echo --------------------- Atualizando o Sistema ----------------------
echo

sudo apt update
sudo apt upgrade -y

echo
echo --------------------- Instalando dependencias ---------------------
echo

sudo apt install isc-dhcp-server tftpd-hpa apache2 wget -y

echo
echo ------------------- Configurando o DHCP Server --------------------
echo

sudo cat <<EOT > /etc/dhcp/dhcpd.conf
default-lease-time 600; 
max-lease-time 7200;

allow booting;

subnet 10.0.0.0 netmask 255.255.255.0 {
  range 10.0.0.3 10.0.0.253;
  option broadcast-address 10.0.0.255;
  option routers 10.0.0.1;         
  option domain-name-servers 1.1.1.1;
  next-server 10.0.0.1;
  filename "pxelinux.0";
}
EOT

sudo cat <<EOT > /etc/default/isc-dhcp-server

INTERFACESv4="enp0s8"
INTERFACESv6=""
EOT

echo
echo ------------------ Compartilhando a Internet -------------------
echo

export INTERFACE=$(ip route | grep default | cut -d ' ' -f 5)
export IP_ADDRESS=$(ip -4 addr show dev $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p
sudo iptables -t nat -A POSTROUTING -o $INTERFACE -j SNAT --to $IP_ADDRESS
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y

echo
echo ------------------- Configurando o TFTP Server --------------------
echo

sudo cat <<EOT > /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOT

sudo mkdir  /srv/tftp
cd  /srv/tftp
wget https://deb.debian.org/debian/dists/Debian11.8/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar xvzf netboot.tar.gz
rm netboot.tar.gz
chmod -R a+r *
ln -s debian-installer/amd64/grubx64.efi .
ln -s debian-installer/amd64/grub .
systemctl restart tftpd-hpa
cd -

echo
echo ---------------- Instalando e configurando HTTP Server -----------------
echo

mv preseed.cfg /var/www/html/

echo
echo ---------------- Configurando instalação automática -------------------
echo

mv syslinux.cfg /srv/tftp/debian-installer/amd64/boot-screens/

mv menu.cfg /srv/tftp/debian-installer/amd64/boot-screens/

systemctl restart isc-dhcp-server
systemctl restart tftpd-hpa
sudo systemctl restart apache2.service
