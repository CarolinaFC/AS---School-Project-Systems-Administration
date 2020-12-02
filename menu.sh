#!/bin/bash

# Function Section
function menu {
  echo "########################### Menu de Configuração ############################"
  echo "###                       O que pretende fazer ?                          ###"
  echo "###    1) Desativar Selinux e Firewall		                          ###" 
  echo "###    2) Instalar Pacotes de serviços                                    ###"
  echo "###    3) Criar Domínio automático (Zona Master, Dns e VirtualHosts)      ###"
  echo "###    4) Escolher Domínio e criar registo automático                     ###"
  echo "###    5) Criar Zonas Reverse			                          ###"
  echo "###    6) Eliminar Zonas Master, Reverse e VirtualHosts                   ###"
  echo "###    7) Configurar NFS			                          ###"
  echo "###    8) Fazer e eliminar backups                                        ###"
  echo "###    9) Configurar Raid                                                 ###"
  echo "###    10) Sair do programa                                               ###"
  echo "#############################################################################"
  echo " "
  echo " "


##################  Configuração do Menu  #############

read -p "Escolha uma opcção de Configuração: "  choix                     
    if [ "$choix" = "1" ]; then
    	sh stopSelinuxFirewall.sh
    	menu            
	elif [ "$choix" = "2" ]; then
    	sh instalarPacotesServer.sh
        menu
    	elif [ "$choix" = "3" ]; then
    	sh configDns.sh
        menu
   	elif [ "$choix" = "4" ]; then
        sh criarDomReg.sh
        menu
    	elif [ "$choix" = "5" ]; then
        sh reverse.sh
	menu
	elif [ "$choix" = "6" ]; then
        sh deleteZonasVirtualHosts.sh
	elif [ "$choix" = "7" ]; then
        sh nfs.sh
	menu
	elif [ "$choix" = "8" ]; then
        sh backups.sh
	menu
	elif [ "$choix" = "9" ]; then
        sh raid.sh
	menu
        elif [ "$choix" = "10" ]; then
        clear
    echo "--------------------------------------"
    echo " Script Terminated Good Bye $(logname)"
    echo "--------------------------------------"
        exit        
    else
    clear
    menu
    echo " "
    echo " "        
    echo " "        
    echo " "        
    echo "################################################################"
    echo "###         Please Try again wrong number   !!!              ###"
    echo "################################################################"
        sleep 2
    clear
    menu
    fi
}
menu 
