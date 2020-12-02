#!/bin/bash
#Configurar NFS

function menuNFS {
  echo " "
  echo "################ Menu de Configuração do serviço NFS ########################"
  echo "###                     O que pretende fazer ?                            ###"
  echo "###    1) Criar arquivo para partilha                                     ###"
  echo "###    2) Alterar partilha						  ###"
  echo "###    3) Eliminar partilha						  ###"
  echo "###    4) Desativar partilha                         			  ###"
  echo "###    5) Ativar serviço NFS						  ###"
  echo "###    6) Voltar ao menu de configuração anterior                         ###"
  echo "#############################################################################"
  echo " "

#####Declaração de Variaveis Gerais########

#IP automático
net_int_ip=$(hostname -I | awk '{print $1}')

ficheiro_exports="/etc/exports"
nomesNFS="/root/nomeArquivoNFS.txt"

################ Reiniciar a máquina ###################

function rebootMaquina { 
echo " "
read -p "Aceita a máquina reiniciar agora para guardar as alterações?,
Se aceitar, de seguida vá à quinta opção do menu para continuar a configuração do NFS 'sim/nao': " reiniciar 

if [ $reiniciar == "sim" ]; then
	reboot
	elif [ $reiniciar == "nao" ]; then
	menuNFS
fi
}

###################################### Ativar serviço NFS #######################################

function ativar {
chkconfig iptables off
service iptables stop
chkconfig nfs on
service nfs restart
}

############################## Criar Arquivo ##############################################

function arquivo {

read -p "Indique o nome da diretoria a criar para criação de partilhas de sistema de ficheiros: " part_NFS

if [ ! -f "$nomesNFS" ]; then
        > $nomesNFS
fi

if ! grep -q $part_NFS $nomesNFS ; then
	echo "$part_NFS" >> $nomesNFS
	else
	echo "A arquivo $part_NFS já existe"
	menuNFS 
fi

mkdir /$part_NFS
chmod 777 /$part_NFS

read -p "Indique as permissões do arquivo criado, separadas entre virgulas: " perm

echo " "
echo "/$part_NFS $net_int_ip/24($perm)" >> $ficheiro_exports
cat $ficheiro_exports

######################## BACKUPS ###########################

diretorio_Backup="/storageBackups/backups2020"

DATA=$(date +%Y-%m-%d-%H.%M)

ficheiro_backup_exports="/etc/exports"

tar -cpzf $diretorio_Backup/exports_"$DATA".tgz --absolute-names $ficheiro_backup_exports

rebootMaquina
}

########################## Alterar partilha #######################################

function altPart {
cat $ficheiro_exports

echo " "

#Escolher um arquivo
read -p "Escreva o arquivo da lista acima a alterar,
(Se pretender voltar ao menu escreva 'menu'): " arquSelect

#voltar ao menu
if [ $arquSelect == "menu" ]; then
	menuNFS

elif grep -q $arquSelect $nomesNFS ; then
	
	linhaAlterar=$(grep -in $arquSelect $ficheiro_exports | awk -F: '{print $1}')
	permissoes=$(grep -in $arquSelect $ficheiro_exports | awk -F "[()]" '{print $2}')
	
	echo " "
	echo "/$arquSelect $net_int_ip/24($permissoes)"

	###### Alterar NOME do arquivo #####
	read -p "Pretende alterar o nome do aquivo? (sim/nao):  " altArqu
	
	if [ $altArqu == "sim" ]; then
        
		#Apagar a linha a alterar
        	sed -i "${linhaAlterar}d" $ficheiro_exports

		read -p "Novo nome do arquivo: " newName
        	echo " "
        	echo "/$newName $net_int_ip/24($permissoes)" >> $ficheiro_exports
    
		echo "/$newName $net_int_ip/24($permissoes)"
		echo " "
		
		rm -r /$arquSelect
		> /$newName

################## Alterar as PERMISSOES com o  NOVO NOME ##############################
        	read -p "Pretende alterar as permissões do aquivo? (sim/nao) " altPerm
    
        	if [ $altPerm == "sim" ]; then
    
			linhaNovaAlterar=$(grep -in $newName $ficheiro_exports | awk -F: '{print $1}')

        		#Apagar a linha a alterar
   			sed -i "${linhaNovaAlterar}d" $ficheiro_exports
    	
			read -p "Novas permissões do arquivo: " newPerm
        		echo " "
        		echo "/$newName $net_int_ip/24($newPerm)" >> $ficheiro_exports
 	
        		echo "/$newName $net_int_ip/24($newPerm)"

			######################## BACKUPS ###########################
			diretorio_Backup="/storageBackups/backups2020"

			DATA=$(date +%Y-%m-%d-%H.%M)

			ficheiro_backup_exports="/etc/exports"
			ficheiro_backup_nomesNFS="/root/nomeArquivoNFS.txt"

			tar -cpzf $diretorio_Backup/exports_"$DATA".tgz --absolute-names $ficheiro_backup_exports
			tar -cpzf $diretorio_Backup/nomesNFS_"$DATA".tgz --absolute-names $ficheiro_backup_nomesNFS

        		rebootMaquina

		elif [ $altArqu == "nao" ]; then
		
			######################## BACKUPS ###########################
			diretorio_Backup="/storageBackups/backups2020"

			DATA=$(date +%Y-%m-%d-%H.%M)

			ficheiro_backup_exports="/etc/exports"
			ficheiro_backup_nomesNFS="/root/nomeArquivoNFS.txt"

			tar -cpzf $diretorio_Backup/exports_"$DATA".tgz --absolute-names $ficheiro_backup_exports
			tar -cpzf $diretorio_Backup/nomesNFS_"$DATA".tgz --absolute-names $ficheiro_backup_nomesNFS

			menuNFS
		fi
	
#################### Alterar SÓ as PERMISSOES MANTENDO NOME #############################
	elif [ $altArqu == "nao" ]; then
        
        	read -p "Pretende alterar as permissões do aquivo? (sim/nao) " altPerm
     
	        if [ $altPerm == "sim" ]; then
	
			#Apagar a linha a alterar
        		sed -i "${linhaAlterar}d" $ficheiro_exports     

			read -p "Novas permissões do arquivo: " newPerm
        		echo " "
        		echo "/$arquSelect $net_int_ip/24($newPerm)" >> $ficheiro_exports
	
			echo "/$arquSelect $net_int_ip/24($newPerm)"
     
			######################## BACKUPS ###########################
			diretorio_Backup="/storageBackups/backups2020"

			DATA=$(date +%Y-%m-%d-%H.%M)

			ficheiro_backup_exports="/etc/exports"
			ficheiro_backup_nomesNFS="/root/nomeArquivoNFS.txt"

			tar -cpzf $diretorio_Backup/exports_"$DATA".tgz --absolute-names $ficheiro_backup_exports
			tar -cpzf $diretorio_Backup/nomesNFS_"$DATA".tgz --absolute-names $ficheiro_backup_nomesNFS

    	  		rebootMaquina
       
        	elif [ $altPerm == "nao" ]; then
        		######################## BACKUPS ###########################
			diretorio_Backup="/storageBackups/backups2020"

			DATA=$(date +%Y-%m-%d-%H.%M)

			ficheiro_backup_exports="/etc/exports"
			ficheiro_backup_nomesNFS="/root/nomeArquivoNFS.txt"

			tar -cpzf $diretorio_Backup/exports_"$DATA".tgz --absolute-names $ficheiro_backup_exports
			tar -cpzf $diretorio_Backup/nomesNFS_"$DATA".tgz --absolute-names $ficheiro_backup_nomesNFS

			menuNFS
		fi
	fi
fi
}

######################### Eliminar partilha #######################################

function eliPart {
cat $ficheiro_exports

echo " "

#Escolher um arquivo a eliminar
read -p "Escreva o arquivo da lista acima a eliminar,
(Se pretender voltar ao menu escreva 'menu'): " arquSelectEl

#voltar ao menu
if [ $arquSelectEl == "menu" ]; then
	menuNFS

elif  grep $arquSelectEl $nomesNFS ; then
	linhaAlterarNFS=$(grep -in $arquSelectEl $nomesNFS | awk -F: '{print $1}')
	linhaAlterar=$(grep -in $arquSelectEl $ficheiro_exports | awk -F: '{print $1}')
        permissoes=$(grep -in $arquSelectEl $ficheiro_exports | awk -F "[()]" '{print $2}')

	echo "/$arquSelectEl $net_int_ip/24($permissoes)"

	#Apagar e ficheiro a linha a alterar
	sed -i "/\b${linhaAlterarNFS}\b/d" $nomesNFS
	sed -i "/\b${linhaAlterar}\b/d" $ficheiro_exports
	
	read -p "Escreva o caminho do arquivo a ser eliminado, (exemplo: /arquivo): " caminhoEl
	rm -r "$caminhoEl"

	cat $ficheiro_exports	

	echo "Partilha eliminada"
	rebootMaquina
fi
}

########################### Desativar partilha #######################################

function desativarPart {
cat $ficheiro_exports

echo " "

#Escolher um arquivo a eliminar
read -p "Escreva o arquivo da lista acima a desativar,
(Se pretender voltar ao menu escreva 'menu'): " arquSelectDes

#voltar ao menu
if [ $arquSelectDes == "menu" ]; then
	menuNFS

elif grep -q $arquSelectDes $nomesNFS; then
	linhaAlterarNFS=$(grep -in $arquSelectDes $nomesNFS | awk -F: '{print $1}')
	linhaAlterar=$(grep -in $arquSelectDes $ficheiro_exports | awk -F: '{print $1}')
        permissoes=$(grep -in $arquSelectDes $ficheiro_exports | awk -F "[()]" '{print $2}')
	
	echo "test"
	
	echo "$linhaAlterarNFS"
	echo "$linhaAlterar"

	#Comentar a linha a alterar
	sed -i "${linhaAlterarNFS}s/^/#/" $nomesNFS
	sed -i "${linhaAlterar}s/^/#/" $ficheiro_exports

	echo "Partilha desativada"

	######################## BACKUPS ###########################

	diretorio_Backup="/storageBackups/backups2020"

	#DATA=$(date +%Y-%m-%d-%H.%M)

	ficheiro_backup_exports_desativar="/etc/exports"
	ficheiro_backup_nomesNFS_desativar="/root/nomeArquivoNFS.txt"

	tar -cpzf $diretorio_Backup/exports_desativar_"$DATA".tgz --absolute-names $ficheiro_backup_exports_desativar
	tar -cpzf $diretorio_Backup/nomesNFS_desativar_"$DATA".tgz --absolute-names $ficheiro_backup_nomesNFS_desativar

	rebootMaquina
fi

}

###############################Menu de eliminação de Zonas Master, Reverse e VirtualHosts##################

############## BACKUPS #######################

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

ficheiro_backup_nfs="/root/nfs.sh"

tar -cpzf $diretorio_Backup/nfs_"$DATA".tgz --absolute-names $ficheiro_backup_nfs

read -p "Escolha uma opcção de Configuração: "  choix
if [ "$choix" = "1" ]; then
	arquivo
        menuNFS
        elif [ "$choix" = "2" ]; then
        altPart
        menuNFS
        elif [ "$choix" = "3" ]; then
        eliPart
	menuNFS
        elif [ "$choix" = "4" ]; then
        desativarPart
        menuNFS
	elif [ "$choix" = "5" ]; then
        ativar
	elif [ "$choix" = "6" ]; then
        clear
	sh menu.sh
fi
}
menuNFS
