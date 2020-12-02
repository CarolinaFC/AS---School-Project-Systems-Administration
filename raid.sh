#!/bin/bash
#Configurar raid

function menuRaid {
  echo " "
  echo "##################### Menu de Configuração do RAID ##########################"
  echo "###                     O que pretende fazer ?                            ###"
  echo "###    1) Criar e montar diretoria                                        ###"
  echo "###    2) Eliminar diretoria						  ###"
  echo "###    3) Voltar ao menu anterior					  ###"
  echo "#############################################################################"
  echo " "

#####################Menu do Raid##################
echo "Antes de criar um novo diretório tem de aceitar criar um array para poder montar o novo diretorio [y]"
echo " "
mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc --spare-devices=1 /dev/sdd

mkfs.xfs /dev/md0

read -p "Escolha uma opcção de Configuração: "  choix
if [ "$choix" = "1" ]; then

        read -p "Escreva o nome do novo diretório a criar: " arquivoNovo

	if [ -d "/$arquivoNovo" ] ; then
		echo " "
		echo "Diretório existente"
		else
		> "/$arquivoNovo"
	fi

	if [ ! -f "/root/arquivoRaid.txt" ]; then
		> /root/arquivoRaid.txt
		echo "$arquivoNovo" >> /root/arquivoRaid.txt
	else
		echo "$arquivoNovo" >> /root/arquivoRaid.txt
	fi

	if grep $arquivoNovo "/root/arquivoRaid.txt" ; then
		mount /dev/md0 /$arquivoNovo
		else
		echo "Diretoria inexistente"
	fi

	echo "Diretoria $arquivoNovo montada"	

        menuNFS
        elif [ "$choix" = "2" ]; then
	cat /root/arquivoRaid.txt
	read -p "Escreva o nome da diretoria a eliminar: " dirEl	
	
	umount /$dirEl
	rm -r /$dirEl
	mdadm --stop /dev/md0
	mdadm --remove /dev/md0 

	echo "Diretoria $arquivoNovo "

        menuRaid
        elif [ "$choix" = "3" ]; then
        sh menu.sh
fi
}
menuRaid
