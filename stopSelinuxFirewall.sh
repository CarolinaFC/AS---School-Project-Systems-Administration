#!/bin/bash

chmod +x stopSelinuxFirewall.sh

diretorio_Backup="/storageBackups/backups2020"

echo " "
if [ -e  $diretorio_Backup ]; then
        echo "O diretório $diretorio_Backup já existe"
        else
        echo "O diretorio $diretorio_Backup não existe. A criar diretório"
        mkdir /storageBackups/backups2020
fi

echo "A criar Backups para $diretorioBackup"

DATA=`date +&Y-%m-%d-%H.%M`

ficheiro_backup_stopSelinuxFirewall="/root/stopSelinuxFirewall.sh"

tar -cpzf $diretorio_Backup/stopSelinuxFirewall_"$DATA".tgz $ficheiro_backup_stopSelinuxFirewall

echo "A Desativar o Selinux"

sed -i '6 s/enforcing/disabled/' /etc/selinux/config

echo "A Desativar a Firewall"

chkconfig iptables off
service iptables stop

echo "A Reiniciar a máquina"

reboot
