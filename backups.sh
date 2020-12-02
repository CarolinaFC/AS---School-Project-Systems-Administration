#!/bin/bash
#Criar backups

function menuBackup {
  echo " "
  echo "#################### Menu de Configuração de Backups ########################"
  echo "###                     O que pretende fazer ?                            ###"
  echo "###    1) Fazer backup de um dirtório especifico                          ###"
  echo "###    2) Eliminar backup						  ###"
  echo "###    3) Voltar ao menu anterior					  ###"
  echo "#############################################################################"
  echo " "

diretorio_Backup="/storageBackups/backups2020"
DATA=$(date +%Y-%m-%d-%H.%M)


function backup {
read -p "Escreva o caminho do diretório pretendido para a realização do backup: " dirBack

if [ grep $dirBack "/" ]; then
	echo "A realizar backup de $dirBack no directório $diretorio_Backup"
	tar -cpzf $diretorio_Backup/$dirBack_"$DATA".tgz --absolute-names $dirBack
	else 
	echo "Diretório $dirBack não encontrado"
fi
}

function delBackup {

for dir in $diretorio_Backup/*
do
	echo $(basename $dir)
done

echo " "
read -p "Escreva o nome do arquivo pretendido para eliminar backup, (nota: escrever até ao '_' )" dirBackDel

if grep $dirBackDel $diretorio_Backup ; then
	echo "A eliminar backup $diretorio/$dirBackDel_"$DATA".tgz"
	rm $diretorio_Backup/dirBackDel_"$DATA".tgz
	else 
	echo "Diretório $dirBackDel já se encontra eliminado"
fi
}

####Menu de Backups ####

read -p "Escolha uma opcção de Configuração: "  choix
if [ "$choix" = "1" ]; then
        backup
        menuBackup
        elif [ "$choix" = "2" ]; then
        delBackup
        menuBackup
        elif [ "$choix" = "3" ]; then
        clear
	sh menu.sh
fi
}
menuBackup

