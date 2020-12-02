#!/bin/bash
#Configurar VirtualHosts

#####################Declaração de variaveis#####################

ficheiro_http="/etc/httpd/conf/httpd.conf"
#echo $domain_name
net_int_ip=$(hostname -I | awk '{print $1}')
diretoria_dominios="/dominios/$domain_name"

################Verificar a existencia do ficheiro nomeDominiosVirtual.txt###################

if [ ! -f "/dominios/nomeDominiosVirtual.txt" ]; then
        > /dominios/nomeDominiosVirtual.txt
        echo "$domain_name" >> /dominios/nomeDominiosVirtual.txt
	else 
	echo "$domain_name" >> /dominios/nomeDominiosVirtual.txt
fi

#################Descomentar e substituir linhas importantes###########################

sed -i '304 s/None/AuthConfig/' $ficheiro_http
sed -i "366 s/^\(.\{3\}\)/\# /" $ficheiro_http
sed -i '373 s/#//' $ficheiro_http

for descomentar in {381..392}
do
	sed -i ''$descomentar' s/#//' $ficheiro_http
done

#######################Criar VirtualHosts#########################3

echo "A criar VirtualHosts"

echo "
NameVirtualHost $net_int_ip:80

<VirtualHost $net_int_ip:80>
DocumentRoot "$diretoria_dominios"
ServerName www.$domain_name
ServerAlias $domain_name
ServerAlias xpto.$domain_name
<Directory "$diretoria_dominios">
Options Indexes FollowSymLinks
AllowOverride All
Order allow,deny
Allow from all
</Directory>
</VirtualHost>" >> $ficheiro_http

#######################Criar dirtorio referente ao hostname######################

mkdir $diretoria_dominios
chmod 755 $diretoria_dominios -R

> /dominios/$domain_name/index.html
echo "Página de Boas Vindas Dominio $domain_name" >> /dominios/$domain_name/index.html
chmod 755 /dominios/$domain_name/index.html

service httpd restart

######################## BACKUPS ###########################

diretorio_Backup="/storageBackups/backups2020"

if [ -d  $diretorio_Backup ]; then
        echo " "
        else
        echo "O diretorio $diretorio_Backup não existe. A criar diretório"
        mkdir -p /storageBackups/backups2020
fi

#echo "A criar Backups para $diretorioBackup"

DATA=$(date +%Y-%m-%d-%H.%M)

ficheiro_backup_VirtualHosts="/root/configVirtualHosts.sh"
ficheiro_backup_http="/etc/httpd/conf/httpd.conf"

tar -cpzf $diretorio_Backup/configVirtualHosts_"$DATA".tgz --absolute-names $ficheiro_backup_VirtualHosts
tar -cpzf $diretorio_Backup/http_"$DATA".tgz --absolute-names $ficheiro_backup_http
