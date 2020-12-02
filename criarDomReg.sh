#!/bin/bash

#Declaração do caminho com os nomes dos dominios
ficheiro_dominios="/dominios/todosDominios.txt"

#Criar Dominio e registo do tipo A e MX
echo "Dominios existentes"
cat $ficheiro_dominios

echo " "

#Escolher um dominio
read -p "Escreva um domínio da lista acima a alterar,
(Se pretender voltar ao menu escreva 'menu': " dominioSelect

echo " "

#voltar ao menu
if [ $dominioSelect == "menu" ]; then
sh menu.sh

else

while ! grep $dominioSelect $ficheiro_dominios
do

echo "Não foi possivel encontrar o dominio"
#Escolher um dominio
read -p "Escreva domínio válido da lista acima a alterar,
(Se pretender voltar ao menu escreva 'menu'): " dominioSelect

done

echo " "

read -p "Introduza o registo completo de acordo com os exemplos,
#exemplo.com.	IN	A	ipAddress
#exemplo.com.	IN	MX	10	ipAddress
Registo:
" registoDom
	
#Declaração dos caminho dos ficheiros forward
dominio_forward="/var/named/$dominioSelect"

#Passagem do registo adicionado para o ficheiro hosts
echo "$registoDom" >> $dominio_forward.hosts

fi

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

ficheiro_backup_CDR="/root/criarDomReg.sh"
ficheiro_backup_hosts="/var/named/$dominioSelect.hosts"

tar -cpzf $diretorio_Backup/criarDomReg_"$DATA".tgz --absolute-names $ficheiro_backup_CDR
tar -cpzf $diretorio_Backup$dominioSelect.hosts_"$DATA".tgz --absolute-names $ficheiro_backup_hosts
