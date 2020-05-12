#!/bin/bash
set -e
# include needed functions
. ./installationFunctions.sh
. ./services.sh

if [[ ! -f .env ]];then
  cp .env.sample .env
fi


if [ $(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  printf "\x1b[31m >  whiptail is not installed on you system try to install it(sudo apt-get install whiptail) \x1b[0m \n"

fi

if [[ $(git_available) == 1 ]]; then
  printf "\x1b[31m >  GIT is not installed on you system \x1b[0m \n"
  whiptail --title "ERROR" --msgbox "\e[32mTry to install(sudo apt install git)" 6 44
fi



setup_your_code




if [[ ! -f docker-compose.yml ]];then
  touch docker-compose.yml
fi

cmd=(whiptail --separate-output --checklist "Now select docker services you want:" 22 85 16)
options=(1 "Nginx" off
         2 "Php" off
         3 "Mysql" off
         4 "Redis" off
         5 "Phpmyadmin" off
         6 "Queue(Supervisor)" off
         7 "Elasticsearch" off
         8 "Kibana" off
         9 "Redis Admin Client" off
         10 "Mongo" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

clear
init
for choice in $choices
do
    case $choice in
        1)
            setup_nginx
            ;;
        2)
            setup_php
            ;;
        3)
            setup_mysql
            ;;
        4)
            setup_redis
              ;;
        5)
            setup_phpmyadmin
              ;;
        6)
            setup_queue
              ;;
        7)
            setup_elasticsearch
              ;;
        8)
            setup_kibana
              ;;
        9)
            setup_phpredisadmin
              ;;
        10)
            setup_mongo
              ;;

    esac
done
source ./.env
whiptail  --title "\Zb\Z5 OK!" --msgbox "Your project successfully dockerized,enjoy it" 6 104
clear
