function git_available()
{
    git --version 2>&1 >/dev/null

    echo $?
}

function install_new_repository() {

    repo=$(whiptail --title "Clone git repository" --inputbox "Enter your project git repository:" 8 40 3>&1 1>&2 2>&3 3>&- )

    git clone $repo . &>/dev/null

    whiptail --title "Hint"  --msgbox " Your project successfully downloaded in 'ProjectSource' folder" 6 104
}

function setup_your_code() {

  cd ProjectSource

if [[ "$(ls -A $DIR)" ]]; then

    if ! whiptail  --title "ERROR" --yesno --defaultno "There is project on 'ProjectSource' folder,you want install docker for this project" 8 78;then
      whiptail --title "Hint" --msgbox "Than remove all file and folder inside it,consider HIDDEN files" 8 78
      clear
      exit 1
    fi

else
    whiptail --title "Hint" --msgbox "Hey,welcome\nPress Enter to continue setup" 8 78
    install_new_repository
fi

cd ..
}