echo
echo --------------------- Atualizando o Sistema ----------------------
echo

sudo apt update
sudo apt upgrade -y

echo
echo --------------------- Instalando dependencias ---------------------
echo

sudo apt install isc-dhcp-server tftpd-hpa wget -y

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

systemctl restart isc-dhcp-server

echo
echo ------------------- Configurando o TFTP Server --------------------
echo

sudo cat <<EOT > /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOT

sudo systemctl restart tftpd-hpa

sudo mkdir  /srv/tftp
cd  /srv/tftp
wget https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar xvzf netboot.tar.gz
rm netboot.tar.gz
chmod -R a+r *
ln -s debian-installer/amd64/grubx64.efi .
ln -s debian-installer/amd64/grub .
systemctl restart tftpd-hpa