#!/bin/bash

chmod +x configDns.sh

#Configurar DNS

########### configurar  o nome de dominio para o sistema ########

read -p "Insira o novo nome do dominio para o seu sistema: " domain_name
echo " "
echo "Nome do dominio: '$domain_name'"

####### Configurar ficheiro named.conf ########

echo 'A configurar as zonas master'

################# Declaração de variaveis ################

ficheiro_named="/etc/named.conf"
zona_master_forward="/var/named/$domain_name.hosts"

##### Designar ip address à variavel ######

net_ip="any" 

################ Verificar ficheiro em relação ao IP address #############

if grep -q $net_ip $ficheiro_named; then
	echo "A configurar o endereço de IP"
else
	#20Colocar a palavra any no ficheiro named.conf
	sed -i "11 s/^\(.\{32\}\)/\1$net_ip; /" $ficheiro_named
	sed -i "17 s/^\(.\{30\}\)/\1$net_ip; /" $ficheiro_named
fi

##########################Inserir zonas Master############################

sed -i '41 s/^/\n\n\n\n\n\n/' $ficheiro_named

#zone "[domain_name]" IN { 
sed -i '41 s/^/" IN {/' $ficheiro_named
sed -i "41 s/^/$domain_name/" $ficheiro_named
sed -i '41 s/^/zone "/' $ficheiro_named

#type master;
sed -i '42 s/^/\t type master;/' $ficheiro_named

#file "/var/named/domain_name.hosts";
sed -i '43 s/^/";/' $ficheiro_named
sed -i "43 s/^/${zona_master_forward//\//\\/}/" $ficheiro_named
sed -i '43 s/^/ \t file "/' $ficheiro_named

#};
sed -i '44 s/^/};/' $ficheiro_named

##################Criar diretorias dos dominios#################

echo " "
echo "A criar diretorias para os dominios"

####################Verificar se os diretórios ja foram criados##################

if [ -d "/dominios" ]; then
	echo "O diretório dominios já existe"
	else
	echo "O diretorio dominios não existe. A criar diretório"
	mkdir /dominios
	chmod 755 /dominios/ -R
fi

##########Criação do ficheiro que vai conter o nome dos dominios criados###################

if [ ! -f "/dominios/nomeDominios.txt" ]; then
	> /dominios/nomeDominios.txt
	echo "${domain_name}" >> /dominios/nomeDominios.txt
	else	
	echo "${domain_name}" >> /dominios/nomeDominios.txt
fi

if [ ! -f "/dominios/todosDominios.txt" ]; then
	> /dominios/todosDominios.txt
	echo "${domain_name}" >> /dominios/todosDominios.txt
        else
	echo "${domain_name}" >> /dominios/todosDominios.txt
fi

#####################Zona MASTER HOSTS###########################

net_int_ip=$(hostname -I | awk '{print $1}')
cifrao="$"

echo "${cifrao}ttl 38400
@	IN	SOA	server.$domain_name. mail.$domain_name (
			1165190726 ;serial
			10800 ;refresh
			3600 ; retry
			604800 ; expire
			38400 ; minimum
			)
	IN	NS	dns.estig.pt.
@	IN	A	$net_int_ip
www	IN	A	$net_int_ip" >> $zona_master_forward

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

#echo "A criar Backups para $diretorioBackup"

DATA=$(date +%Y-%m-%d-%H.%M)

ficheiro_backup_DNS="/root/configDns.sh"
ficheiro_backup_Named="/etc/named.conf"
ficheiro_backup_hosts="/var/named/$domain_name.hosts"

tar -cpzf $diretorio_Backup/configDNS_"$DATA".tgz --absolute-names $ficheiro_backup_DNS
tar -cpzf $diretorio_Backup/named.conf_"$DATA".tgz --absolute-names $ficheiro_backup_Named
tar -cpzf $diretorio_Backup/$domain_name.hosts_"$DATA".tgz --absolute-names $ficheiro_backup_hosts

export domain_name
sh configVirtualHosts.sh
