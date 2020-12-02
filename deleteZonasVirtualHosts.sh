#!/bin/bash

function menuDel {
  echo " "
  echo "################ Eliminar Zonas Master, Reverse e VirtualHosts ##############"
  echo "###                     O que pretende fazer ?                            ###"
  echo "###    1) Apagar Zonas Master                                             ###"
  echo "###    2) Apagar Zonas Reverse                                            ###"
  echo "###    3) Apagar VirtualHosts                                             ###"
  echo "###    4) Voltar ao menu anterior                                         ###"
  echo "#############################################################################"
  echo " "

#####Declaração de Variaveis Gerais########

nomeDominios="/dominios/nomeDominios.txt"
nomeDominiosReverse="/dominios/nomeDominiosReverse.txt"
nomeDominiosVirtual="/dominios/nomeDominiosVirtual.txt"

ficheiro_named="/etc/named.conf"
ficheiro_http="/etc/httpd/conf/httpd.conf"

####Apagar Zonas Master#####
function masterDel {
	cat $nomeDominios
	echo " "
	read -p "Escreva o nome do Domínio que deseja eliminar,
(Se pretender voltar ao menu escreva 'menu'): " delDominio
	
	#voltar ao menu
	if [ $delDominio == "menu" ]; then
	menuDel
	
	else
	
	linha_Apagar="zone \"$delDominio\""
	
	#Descobrir qual a linha e delimitar	
	contarlinhaDel=$(grep -in "$linha_Apagar" $ficheiro_named | awk -F: '{print $1}')
	linhasDelDom=$(expr $contarlinhaDel + 3) 
	
	#Apagar as linhas
	sed -i "${contarlinhaDel},${linhasDelDom}d" $ficheiro_named
	
	echo " "
	#Remover /var/named/delDominio.hosts
	if [ -f "/var/named/$delDominio.hosts" ]; then
        	rm /var/named/$delDominio.hosts
		echo "Ficheiro $delDominio.hosts eliminado"
        	else
        	echo "Ficheiro $delDominio.hosts já se encontra eliminado"
	fi

	#Remover linha com delDominio no ficheiro nomeDominios.txt
	sed -i "/\b${delDominio}\b/d" $nomeDominios        

	echo "Zona master $delDominio eliminada"
	fi
}

####Apagar Zonas Reverse#####
function reverseDel {
	cat $nomeDominiosReverse
	echo " "
	read -p "Escreva o nome do IP que deseja eliminar,
(Se pretender voltar ao menu escreva 'menu'): " delDominioReve
	
	#voltar ao menu
	if [ $delDominioReve == "menu" ]; then
	menuDel
	
	else

	#Mudar o IP para reverse
	oct_1=$(expr $delDominioReve | cut -d"." -f1)
	oct_2=$(expr $delDominioReve | cut -d"." -f2)
	oct_3=$(expr $delDominioReve | cut -d"." -f3)
	oct_4=$(expr $delDominioReve | cut -d"." -f4)
	ipReverse="${oct_3}.${oct_2}.${oct_1}"

	linha_Apagar_reverse="zone \"$ipReverse.in-addr.arpa\""
	
	#Descobrir qual a linha e delimitar
	contarlinhaDel=$(grep -in "$linha_Apagar_reverse" $ficheiro_named | awk -F: '{print $1}')
	linhasDelDom=$(expr $contarlinhaDel + 3)

	#Apagar as linhas 
	sed -i "${contarlinhaDel},${linhasDelDom}d" $ficheiro_named
	
	#Remover /var/name/ipReverse.in-addr.arpa.hosts
	if [ -f "/var/named/$ipReverse.in-addr.arpa.hosts" ]; then
        	rm /var/named/$ipReverse.in-addr.arpa.hosts
		echo "Ficheiro $delDominioReve.in-addr.arpa.hosts eliminado"
        	else
        	echo "Ficheiro $delDominioReve.in-addr.arpa.hosts já se encontra eliminado"
	fi
	
	#Remover linha com delDominio no ficheiro nomeDominiosReverse.txt
	sed -i "/\b${delDominioReve}\b/d" $nomeDominiosReverse
	
	echo " "
	echo "Zona reverse $delDominioReve eliminada"
	fi
}

####Apagar VirtualHosts####
function virtHostDel {
	cat $nomeDominiosVirtual
	echo " "
	read -p "Escreva o nome do Dominio que deseja eliminar,
(Se pretender voltar ao menu escreva 'menu'): " delVirtual
	
	#voltar ao menu
	if [ $delVirtual == "menu" ]; then
	menuDel
	
	else

	linha_Apagar_virtual="DocumentRoot /dominios/$delVirtual"

	#Procurar a linha para depois limitar a remoção
	linhaDel=$(grep -in "$linha_Apagar_virtual" $ficheiro_http | awk -F: '{print $1}')
	
	#Isolar as linhas para depois remove-las
	linhasDelDomCima=$(expr $linhaDel - 3) 
	linhasDelDomBaixo=$(expr $linhaDel + 10)
	sed -i "${linhasDelDomCima},${linhasDelDomBaixo}d" $ficheiro_http

	#Remover /dominios/delVirtual

	caminhoDomVirtual="/dominios/$delVirtual"
	echo " "
	if [ -d "$caminhoDomVirtual" ]; then
        	rm $caminhoDomVirtual/index.html
                rm -r $caminhoDomVirtual
                echo "Ficheiro $delVirtual eliminado"
		else
		echo "Ficheiro $delVirtual já se encontra eliminado"	
	fi  

	#Remover linha com delDominio no ficheiro nomeDominiosVirtual.txt
        sed -i "/\b${delVirtual}\b/d" $nomeDominiosVirtual

	echo "VirtualHosts $delVirtual eliminado"
	fi
}

################## Menu de eliminação de Zonas Master, Reverse e VirtualHosts ##################

############# BACKUPS ###############

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

ficheiro_backup_delZVH="/root/deleteZonasVirtualHosts.sh"

tar -cpzf $diretorio_Backup/deleteZonasVirtualHosts_"$DATA".tgz --absolute-names $ficheiro_backup_delZVH


read -p "Escolha uma opcção de Configuração: "  choix
if [ "$choix" = "1" ]; then
	masterDel
	menuDel
	elif [ "$choix" = "2" ]; then
        reverseDel
        menuDel
        elif [ "$choix" = "3" ]; then
        virtHostDel
        menuDel
        elif [ "$choix" = "4" ]; then
        clear
    	sh menu.sh
fi
}
menuDel
