#!/bin/bash
#Criaçãos de Zonas Reverse

###############Declaração de variaveis######################

ficheiro_named="/etc/named.conf"

########################################################################

read -p  "Introduza o nome FQDN: " nome_FQDN
echo " "

read -p  "Indique o endereço de IP para a zona reverse,
(Se pretender voltar ao menu escreva 'menu'): " ipAddr_Reverse

#voltar ao menu
if [ $ipAddr_Reverse == "menu" ]; then

	sh menu.sh

else
#####################Verificar a existencia do ficheiro nomeDominiosReverse.txt###################

	if [ ! -f "/dominios/nomeDominiosReverse.txt" ]; then
		> /dominios/nomeDominiosReverse.txt
		echo "$ipAddr_Reverse" >> /dominios/nomeDominiosReverse.txt	
	fi	

	if [ ! -f "/dominios/todosDominios.txt" ]; then
		> /dominios/todosDominios.txt
		echo "$ipAddr_Reverse" >> /dominios/todosDominios.txt
		else
		echo "$ipAddr_Reverse" >> /dominios/todosDominios.txt
	fi

	if grep -q $ipAddr_Reverse /dominios/nomeDominiosReverse.txt ; then
		sh menu.sh
	else
		echo "$ipAddr_Reverse" >> /dominios/nomeDominiosReverse.txt
	fi

##########################Mudar o IP para reverse####################################

oct_1=$(expr $ipAddr_Reverse | cut -d"." -f1)
oct_2=$(expr $ipAddr_Reverse | cut -d"." -f2)
oct_3=$(expr $ipAddr_Reverse | cut -d"." -f3)
oct_4=$(expr $ipAddr_Reverse | cut -d"." -f4)
ipReverse="${oct_3}.${oct_2}.${oct_1}"

########################Caminho do ficheiro das zonas reverse#######################

zona_reverse="/var/named/$ipReverse.in-addr.arpa.hosts"

################################Inserir zonas Reverses############################

sed -i '45 s/^/\n\n\n\n\n\n/' $ficheiro_named

#zone "[ipReverse]" IN {
sed -i '46 s/^/.in-addr.arpa" IN {/' $ficheiro_named
sed -i "46 s/^/$ipReverse/" $ficheiro_named
sed -i '46 s/^/zone "/' $ficheiro_named

#type master;
sed -i '47 s/^/\t type master;/' $ficheiro_named

#file "/var/named/domain_name.hosts";
sed -i '48 s/^/";/' $ficheiro_named
sed -i "48 s/^/${zona_reverse//\//\\/}/" $ficheiro_named
sed -i '48 s/^/ \t file "/' $ficheiro_named

#};
sed -i '49 s/^/};/' $ficheiro_named

##############################Zona reverse HOSTS############################################

cifrao="$"

echo "${cifrao}ttl 38400
@	IN	SOA	server.estig.pt. mail.estig.pt (
  			1165190726 ;serial
			10800 ;refresh
			3600 ; retry
			604800 ; expire
               	      	38400 ; minimum
			)
	IN	NS	dns.estig.pt.	
${oct_4}	IN	PTR	$nome_FQDN" >> $zona_reverse

service named restart

######################## BACKUPS ###########################

diretorio_Backup="/storageBackups/backups2020"

echo " "
if [ -d  $diretorio_Backup ]; then
        echo ""
        else
        echo "O diretorio $diretorio_Backup não existe. A criar diretório"
        mkdir -p /storageBackups/backups2020
fi

echo "A criar Backups para $diretorioBackup"

DATA=$(date +%Y-%m-%d-%H.%M)

ficheiro_backup_Reverse="/root/reverse.sh"
ficheiro_backup_Named_Reverse="/etc/named.conf"
ficheiro_backup_hosts="/var/named/$ipAddr_Reverse.hosts"


tar -cpzf $diretorio_Backup/reverse_"$DATA".tgz --absolute-names $ficheiro_backup_Reverse
tar -cpzf $diretorio_Backup/named.conf_Reverse_"$DATA".tgz --absolute-names $ficheiro_backup_Named_Reverse
tar -cvzf $diretorio_Backup/$ipAddr_Reverse.hosts_"$DATA".tgz --absolute-names $ficheiro_bakup_hosts

fi

sh menu.sh 

