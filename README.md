# PXE-Server
Repositório com tutorial para instalação de um servidor PXE no Debian 11
# Tutorial de Instalação do Servidor PXE com Debian 11

Neste tutorial, vamos aprender a configurar um servidor PXE (Preboot Execution Environment) usando o Debian 11 como sistema base. O PXE permite a inicialização de computadores pela rede, facilitando a instalação de sistemas operacionais em várias máquinas.

## Pré-requisitos

Certifique-se de que você tenha os seguintes requisitos antes de começar:

- Um computador com Debian 11 instalado (este será o servidor PXE).
- Uma rede local funcionando.

## Passos

### 1. Instalação dos pacotes necessários

Primeiro, atualize o sistema e instale os pacotes necessários:

```bash
sudo apt update
sudo apt install isc-dhcp-server tftpd-hpa syslinux pxelinux
