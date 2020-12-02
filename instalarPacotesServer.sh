echo "Inicio da instalação de pacotes"

diretorio_Backup="/storageBackups/backups2020"

echo " "
if [ -d  $diretorio_Backup ]; then
        echo "O diretório $diretorio_Backup já existe"
        else
        echo "O diretorio $diretorio_Backup não existe. A criar diretório"
        mkdir /storageBackups/backups2020
fi

echo "A criar Backups para $diretorioBackup"

DATA=$(date +%Y-%m-%d-%H.%M)

ficheiro_backup_pacotes="/root/instalarPacotesServer.sh"

tar -cpzf $diretorio_Backup/pacote_instalacao_"$DATA".tgz --absolute-names $ficheiro_backup_pacotes

yum install setuptool -y
yum install system-config-network-tui -y
yum install system-config-securitylevel-tui -y
yum install ntsysv -y

yum install nfs-utils -y
yum install dhcp -y
yum install bind* -y
yum install httpd -y
sh menu.sh
