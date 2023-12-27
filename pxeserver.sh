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
wget https://deb.debian.org/debian/dists/Debian11.8/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar xvzf netboot.tar.gz
rm netboot.tar.gz
chmod -R a+r *
ln -s debian-installer/amd64/grubx64.efi .
ln -s debian-installer/amd64/grub .
systemctl restart tftpd-hpa

echo
echo ---------------- Instalando e configurando HTTP Server -----------------
echo

sudo apt install apache2 -y

sudo cat <<EOT > /var/www/html/preseed.cfg


# Configurações básicas
d-i debian-installer/locale string pt_BR
d-i console-setup/layoutcode string br
d-i keyboard-configuration/xkb-keymap select br

# Configurações de rede
d-i netcfg/get_hostname string ifpb
d-i netcfg/get_domain string ifpb.local
d-i netcfg/choose_interface select auto

# Configurações do relógio
d-i clock-setup/utc-auto boolean true
d-i clock-setup/utc boolean true
d-i time/zone string America/Recife
d-i clock-setup/ntp-server string a.st1.ntp.br

# Configurações do particionamento
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string regular
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Configurações do usuário
d-i passwd/user-fullname string Aluno
d-i passwd/username string aluno
d-i passwd/user-password-crypted password $1$6xHou2nH$VsjII2lXW87b3bNFC6kET/
d-i user-setup/encrypt-home boolean false

# Configurações de autenticação
d-i passwd/root-login boolean true
d-i passwd/root-password-crypted password $1$6xHou2nH$VsjII2lXW87b3bNFC6kET/

# Pacotes adicionais
tasksel tasksel/first multiselect standard, ssh-server, gnome-desktop

# Instalação do GRUB
#d-i grub-installer/bootdev  string /dev/sda
d-i grub-installer/bootdev  string default

# Finalização da instalação
d-i finish-install/reboot_in_progress note
EOT

sudo systemctl restart apache2.service

echo
echo ---------------- Configurando instalação automática -------------------
echo

sudo cat <<EOT > /srv/tftp/debian-installer/amd64/boot-screens/adtxt.cfg
label expert
	menu label E^xpert install
	kernel debian-installer/amd64/linux
	append priority=low vga=788 initrd=debian-installer/amd64/initrd.gz --- 
include debian-installer/amd64/boot-screens/rqtxt.cfg
label auto
	menu label ^Automated install
	kernel debian-installer/amd64/linux
	append auto=true priority=critical vga=788 url=http://10.0.0.1/preseed.cfg initrd=debian-installer/amd64/initrd.gz --- quiet 
EOT

systemctl restart isc-dhcp-server
systemctl restart tftpd-hpa
sudo systemctl restart apache2.service

