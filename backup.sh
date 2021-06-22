#!/usr/bin/env bash
GREEN='\033[0;32m'
RED='\033[0;31m'
PINK='\033[0;91m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
GREEN_BOLD='\033[1;32m'
RED_BOLD='\033[1;31m'
PINK_BOLD='\033[1;91m'
ORANGE_BOLD='\033[1;33m'
CYAN_BOLD='\033[1;36m'

NC='\033[0m' # No Color
BLINKING_ON='\033[5m'
BLINKING_OFF='\033[0m'


START_POINT=$HOME
DISK="_linux_BACKUP"
CATALOG="_backup_config"
SYSTEM_NAME="awesome_wm [manjaro_20.0]"
MACHINE=$HOSTNAME
NOW=$(date +"%Y [%V]")
# NOW=$(date +"%Y_%m_%d (%H:%M:%S)")
echo $SYSTEM_NAME
echo $NOW
echo $MACHINE


LAN_CATALOG="_LAN"

_LAN_DISK_PATH=$START_POINT/$LAN_CATALOG/$DISK
LOCAL_DISK_PATH=$START_POINT/$DISK

PARTIAL_PATH=$START_POINT/$DISK/$CATALOG
MACHINE_PATH=$PARTIAL_PATH/"$SYSTEM_NAME ${MACHINE}"
TIMED_PATH="$MACHINE_PATH - $NOW"

echo "PARTIAL_PATH  := 	" $PARTIAL_PATH
echo "MACHINE_PATH  :=	" $MACHINE_PATH
echo "TIMED_PATH    := 	" $TIMED_PATH


# pause () {
#  read -s -n 1 -p "Press any key to continue . . ."
#  echo ""
# }

pause () {
	echo 'Press [Enter] key to continue...'
	read -p "$*"
}

menu () {
	echo -e "
	Proszę wybrać:

	0. pokaż listy
	1. backup konfiguracji => (kopia na dysk z datą) LINUX_BACKUP_NOW
	2. backup konfiguracji => (kopia na dysk) LINUX_BACKUP

	${ORANGE_BOLD}5. LINUX_BACKUP => bieżca konfiguracja (zastąp z ostaniego folderu z datą)
	${PINK_BOLD}9. zastąpinie CAŁEGO dysku backupu tym, który jest w _LAN${NC}

	Q|q. Wyjdź
	"



	read -p "Wpisz wybraną opcję [0-3] > "
	echo

	case $REPLY in
		0)	create_backup_include_list
			create_backup_exclude_list
			show_include_list
			show_exclude_list
			remove_lists
			;;
	    1)	create_backup_include_list
			create_backup_exclude_list
			test_backup_current_config_NOW
			remove_lists
			;;
	    2)	create_backup_include_list
			create_backup_exclude_list
			test_backup_current_config
			remove_lists
			;;
		5)	test_restore_config_from_backup
			;;
		9)	test_replace_local_disk
			;;
	    Q|q)  echo "Program zakończył działanie."
	        exit
	        ;;
	    *)  echo "Nieprawidłowa opcja " >&2
	        exit 1
	        ;;
	    esac
}



create_backup_include_list () {
echo -e "
.config/awesome/
.config/cmus/
.config/klavaro/
.config/Kvantum/
.config/lxterminal/
.config/mpv/
.config/nvim/
.config/ranger/
.config/vifm/
.config/vivaldi/Default/Bookmarks
.config/vivaldi/Default/History
.config/vivaldi/Default/Preferences
.config/compton.conf
.doom.d/
.aliasrc
.bashrc
.dir_colors
.profile
.Xmodmap
.Xresources
.zshrc
" | sed '1d' | sed -e '$ d' > $PARTIAL_PATH/backup-include-list
}

create_backup_exclude_list () {
echo -e "
.config/nvim/plugins/
.config/ranger/plugins/__pycache__/
.config/ranger/plugins/__init__.py
.config/ranger/colorschemes/__init__.py
.config/vifm/vifminfo.json_*
" | sed '1d' | sed -e '$ d' > $PARTIAL_PATH/backup-exclude-list
}

show_include_list () {
	echo -e "${GREEN}$(<backup-include-list)${NC}"
}
show_exclude_list () {
	echo -e "${RED}$(<backup-exclude-list)${NC}"
}

remove_lists () {
	if [ -f $PARTIAL_PATH/backup-include-list ]; then
		rm $PARTIAL_PATH/backup-include-list
	fi
	if [ -f $PARTIAL_PATH/backup-exclude-list ]; then
		rm $PARTIAL_PATH/backup-exclude-list
	fi
}

test_restore_config_from_backup() {
	cd $PARTIAL_PATH
	LAST_BACKUP=$(ls -td -- */ | head -n 1 | cut -d'/' -f1)
	rsync --dry-run -av --recursive $PARTIAL_PATH/"$LAST_BACKUP"/.config/ $START_POINT/.config/ 2>/dev/null

	echo
	echo "---------------------------"
	echo "Ostatni backup w katalogu:= $LAST_BACKUP"
	echo "==========================="
	read -p "Przywrócić konfigurację z ostatniego backupu [T/N] > "
	echo

	case $REPLY in
	    T|t)	restore_config_from_backup
				;;
	    N|n)  	echo "Program zakończył działanie."
	        	exit
	        	;;
	    *)  	echo "Nieprawidłowa opcja " >&2
	        	exit 1
	        	;;
	    esac
}


test_backup_current_config_NOW (){
	rsync --dry-run -av --delete --recursive --files-from=$PARTIAL_PATH/backup-include-list --exclude-from=$PARTIAL_PATH/backup-exclude-list $START_POINT "$TIMED_PATH" 2>/dev/null

	read -p "Zrobić backup [T/N] > "
	echo

	case $REPLY in
	    T|t)	create_backup_include_list
				create_backup_exclude_list
				backup_current_config_NOW
				;;
	    N|n)  	echo "Program zakończył działanie."
	        	;;
	    *)  	echo "Nieprawidłowa opcja " >&2
				test_backup_current_config_NOW
	        	;;
	    esac
}

test_backup_current_config (){
	rsync --dry-run -av --delete --recursive --files-from=$PARTIAL_PATH/backup-include-list --exclude-from=$PARTIAL_PATH/backup-exclude-list $START_POINT "$MACHINE_PATH" 2>/dev/null

	read -p "Zrobić backup [T/N] > "
	echo

	case $REPLY in
	    T|t)	create_backup_include_list
				create_backup_exclude_list
				backup_current_config
				;;
	    N|n)  	echo "Program zakończył działanie."
	        	;;
	    *)  	echo "Nieprawidłowa opcja " >&2
				test_backup_current_config
	        	;;
	    esac
}

test_replace_local_disk (){
	if [ -d $_LAN_DISK_PATH ]; then
		rsync --dry-run -av --delete --recursive "$_LAN_DISK_PATH/." "$LOCAL_DISK_PATH" 2>/dev/null

		read -p "$(echo -e ${PINK_BOLD}"\nZastąpić (nadpisać) lokalny backup [T/N] >" ${NC})"
		echo

		case $REPLY in
			T|t)
					replace_local_disk
					;;
			N|n)  	echo "Program zakończył działanie."
					;;
			*)  	echo "Nieprawidłowa opcja " >&2
					test_replace_local_disk
					;;
		esac
	else
		echo "Brak połączenia"
	fi
}


last_created_backup () {
	cd $PARTIAL_PATH
	LAST_BACKUP=$(ls -td -- */ | head -n 1 | cut -d'/' -f1)
	echo
	echo -e "${CYAN_BOLD}LAST_BACKUP   := 	" $PARTIAL_PATH/$LAST_BACKUP "${NC}"
}

restore_config_from_backup() {
	last_created_backup
	rsync -av --recursive $PARTIAL_PATH/"$LAST_BACKUP"/.config/ $START_POINT/.config/ 2>/dev/null

	cd $START_POINT/$DISK/
	# mkdir -p new_back/.config/
	rsync -r --exclude='*/' $PARTIAL_PATH/"$LAST_BACKUP"/ $START_POINT/ 2>/dev/null
}

backup_current_config_NOW (){
	rsync -avt --delete --recursive --files-from=$PARTIAL_PATH/backup-include-list --exclude-from=$PARTIAL_PATH/backup-exclude-list $START_POINT "$TIMED_PATH" 2>/dev/null
	touch "$TIMED_PATH"/time_file
	rm "$TIMED_PATH"/time_file
}

backup_current_config (){
	rsync -avt --delete --recursive --files-from=$PARTIAL_PATH/backup-include-list --exclude-from=$PARTIAL_PATH/backup-exclude-list $START_POINT "$MACHINE_PATH" 2>/dev/null
	touch "$MACHINE_PATH"/time_file
	rm "$MACHINE_PATH"/time_file
}



replace_local_disk () {
	rsync -avt --delete --recursive "$_LAN_DISK_PATH/." "$LOCAL_DISK_PATH" 2>/dev/null
}

last_created_backup
menu
