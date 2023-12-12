# PXE-Server
Repositório com tutorial para instalação de um servidor PXE no Debian 11
# Tutorial de Instalação do Servidor PXE com Debian 11

Neste tutorial, vamos aprender a configurar um servidor PXE (Preboot Execution Environment) usando o Debian 11 como sistema base. O PXE permite a inicialização de computadores pela rede, facilitando a instalação de sistemas operacionais em várias máquinas. Disponibilizo um script (https://github.com/zeraimundo/PXE-Server/blob/main/pxeserver.sh) para instalação em Servidores Debian com duas placas de rede, sendo a primeira para interface Wan e a segunda para a Lan e serviços DHCP.

## Pré-requisitos

Certifique-se de que você tenha os seguintes requisitos antes de começar:

- Um computador com Debian 11 instalado (este será o servidor PXE).
- Uma rede local funcionando.

## Passos

### 1. Instalação dos pacotes necessários

Primeiro, atualize o sistema e instale os pacotes necessários:

```bash
sudo apt update
sudo apt install isc-dhcp-server tftpd-hpa wget -y
```
Neste cenário será utilizado um servidor Debian com o ip 10.0.0.1/24. Configuraremos o servidor DHCP através do arquivo dhcpd.conf. Ele se encontra na pasta /etc/dhcp/

### 2. Configuração do servidor DHCP

Edite o arquivo /etc/dhcp/dhcpd.conf com estas configurações.

```pearl
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
```
Reinicie o servico

```bash
systemctl restart isc-dhcp-server
```

### 3. Configuração do servidor TFTP

Agora vamos definir as configurações do Servidor TFTP através do arquivo tftpd-hpa. Ele se encontra na pasta  /etc/default/

Edite o arquivo /etc/default/tftpd-hpa com as seguintes configurações.

```pearl
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```

Reinicie o servico

```bash
systemctl restart tftpd-hpa
```
Na próxima etapa criaremos o diretório que disponibilizará os arquivos de instalação:

 ```bash
mkdir  /srv/tftp
```
Faremos o download dos arquivos de instalação que estão disponíveis no site oficial de downloads do Debian: https://deb.debian.org/debian/dists/Debian11.8/main/installer-amd64/current/images/netboot/

Para o propósito deste tutorial faremos o download do arquivo netboot.tar.gz na pasta /srv/tftp, descompactaremos o seu conteúdo, excluiremos o arquivo .gz, daremos permissões necessárias para o seu funcionamento e criaremos links simbólicos (necessários para boot em computadores que usam UEFI).

 ```bash
cd  /srv/tftp
wget https://deb.debian.org/debian/dists/Debian11.8/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar xvzf netboot.tar.gz
rm netboot.tar.gz
chmod -R a+r *
ln -s debian-installer/amd64/grubx64.efi .
ln -s debian-installer/amd64/grub .
```

Reinicie o serviço:

```bash
systemctl restart tftpd-hpa
```

### 4. Testando o servidor PXE

Configure outro computador na rede para inicializar através do boot PXE. O computador inicializará a partir da instalação do Debian mais atual.



<p align="center">
  <img src="https://private-user-images.githubusercontent.com/82219488/265848561-8853d446-4a34-4342-b54c-867c2aaf4eea.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE2OTM5NTY4NDYsIm5iZiI6MTY5Mzk1NjU0NiwicGF0aCI6Ii84MjIxOTQ4OC8yNjU4NDg1NjEtODg1M2Q0NDYtNGEzNC00MzQyLWI1NGMtODY3YzJhYWY0ZWVhLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFJV05KWUFYNENTVkVINTNBJTJGMjAyMzA5MDUlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjMwOTA1VDIzMjkwNlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWM0MjRhY2Y1ZGRjOTk5YWM5MWEyOWI5YzgzNzUwMTdiNjc5MGMzMTI3NDA4OTViNjRiODBmZjg4ZTViMGIzOGQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.iqQvrrrvNfIUy35ROE4DgDs9nbfXZ7zAJLoNyEC7xYQ" alt="Exemplo de GIF">
</p>
