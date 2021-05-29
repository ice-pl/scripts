#!/bin/bash

# instalacja pdfCropMargins dla obecnego użytkownika w ~/.local/bin
# pip install pdfCropMargins --user --upgrade

GREEN='\033[0;32m'
RED='\033[1;31m'
ORANGE='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BLINKING_ON='\033[5m'
BLINKING_OFF='\033[0m'


# set -x
args=("$@")

NazwaPliku=${args[0]}
Nazwa=${NazwaPliku::${#NazwaPliku}-4}
Rozszerzenie=${NazwaPliku: -4}

StronaPoczatkowa[0]=${args[1]}
StronaKoncowa[0]=${args[2]}
Przesuniecie=${args[3]}


amount_of_pages () {
	echo $(pdfinfo "$NazwaPliku" | grep Pages | awk '{print $2}')
}
cut_pages () {
	pdftk "$NazwaPliku" cat ${ZakresStron} output "$NazwaTymczsowa${Rozszerzenie}"
}
crop_margins () {
	pdf-crop-margins -v -s -u "$NazwaTymczsowa${Rozszerzenie}"
}
two_pages_in_one () {
	pdfbook2 -n "${NazwaTymczsowa}_cropped${Rozszerzenie}"
}
rotate_odd_pages () {
	pdftk "${NazwaTymczsowa}_cropped-book${Rozszerzenie}" rotate 1-end oddsouth output "${NazwaTymczsowa}_cropped-book-rotated${Rozszerzenie}"
}
remove_unused () {
	ls "${NazwaTymczsowa}"* | grep -v "rotated" | xargs -d "\n" -I {} rm {} 
}


unset_values () {
	unset StronaPoczatkowa
	unset StronaKoncowa
	unset var
}
check_if_numbers () {
	if ! [[ ${var} =~ ^-?[0-9]+$ ]]; then
		echo -e "\t${RED}Tylko typ całkowity${NC}"
		unset_values
		menu
	fi
}


insert_shift () {
	echo -e "${ORANGE}\tWstawianie przesunięcia:"
	echo -e "\t\t-należy podać nr strony w pliku i odpowiadający mu nr strony w dokumencie${NC}"
	echo
	read -p "	nr strony w Pliku > " StronaPliku 
	var=${StronaPliku}
	check_if_numbers
	read -p "	nr strony w Dokumencie > " StronaDokumentu 
	var=${StronaDokumentu}
	check_if_numbers
	Przesuniecie=$((StronaDokumentu-StronaPliku))
	if [[ $Przesuniecie != ?(-)+([0-9]) ]]; then
		Przesuniecie=0
	fi
}
count_shifted () {
	for ((i = 0; i<=((${#StronaKoncowa[@]}-1)); i = i+1)); do
		StronaPoczatkowa[i]=$((${StronaPoczatkowa[i]}-$Przesuniecie))
		StronaKoncowa[i]=$((${StronaKoncowa[i]}-$Przesuniecie))
	done
}


insert_first_pages_of_chapters () {
	unset_values
	echo -e "${ORANGE}\tWstawianie wielu rozdziałów:"
	echo -e "\t\t-tylko początkowe strony kolejnych rozdziałów"
	echo -e "\t\t-gdy wstawiany jest tylko jeden zakres to wstawić o jedną stronę więcej${NC}"
	echo
	i=0
	while true; do
		read -p "	Rozdział $((${i}+1)) > " StronaPoczatkowa[i]
		count_last_page_of_chapters
		if [ ${#StronaPoczatkowa[i]} -eq 0 ]; then
			unset 'StronaPoczatkowa[i-1]'
			unset 'StronaKoncowa[i-1]'
			break
		fi
		var=${StronaPoczatkowa[i]}
		check_if_numbers
		if [[ $i > 0 ]]; then
			if [[ ${StronaPoczatkowa[i]} -le ${StronaPoczatkowa[i-1]} ]]; then
				echo -e "\t${RED}Obecna wartość nie może być mniejsza od poprzedniej${NC}"
				i=$((i - 1))
			fi
		fi



		i=$((i + 1))
		continue
	done
}
count_last_page_of_chapters () {
	if [[ $i > 0 ]]; then
		StronaKoncowa[$((i-1))]=$((${StronaPoczatkowa[${#StronaPoczatkowa[@]}-1]}-1))
	fi
}




run_once () {
	ZakresStron=${StronaPoczatkowa[i]}-${StronaKoncowa[i]}
	NazwaTymczsowa=${Nazwa}_${ZakresStron}
	cut_pages
	crop_margins
	two_pages_in_one
	rotate_odd_pages
	remove_unused
}
run_multiple_times () {
	for ((i = 0; i<=((${#StronaKoncowa[@]}-1)); i = i + 1)); do
		run_once
	done
}
run () {
	run_multiple_times
}




show () {
	if [[ -z ${args[1]} && -z ${StronaPoczatkowa[0]} ]]; then
		StronaPoczatkowa[0]=1
	fi
	if [[ -z ${args[2]}  && -z ${StronaKoncowa[0]} ]]; then
		StronaKoncowa[0]=$(amount_of_pages)
	fi
	if [[ -z ${args[3]} && -z ${Przesuniecie} ]]; then
		Przesuniecie=0
	fi
	printf '\n'
	echo "	--------------------------"
	printf '%s\t' "	  StronaPoczatkowa :=        ""  ${StronaPoczatkowa[@]}"
	printf '\n'
	printf '%s\t' "	  StronaKoncowa :=           ""  ${StronaKoncowa[@]}"
	printf '\n'
	echo "	--------------------------"
	printf '%s\t' "	  Przesuniecie :=            ""  ${Przesuniecie}"
	show_with_shift
}
show_with_shift () {
	count_shifted
	printf '\n'
	echo "	--------------------------"
	echo -en "${CYAN}"
	printf '%s\t' "	  StronaPoczatkowa :=        ""  ${StronaPoczatkowa[@]}"
	printf '\n'
	printf '%s\t' "	  StronaKoncowa :=           ""  ${StronaKoncowa[@]}"
	echo -en "${NC}"
}



menu () {
	clear
	show
	echo "
	==========================
	  MENU:
	  M|m)  Wstaw strony
	  S|s)  Wstaw przesunięcie
	  R|r)  Wykonaj program
	  Q|q)  Wyjdź
	=========================="
	echo
	read -p "	Wpisz wybraną opcję >>> "
	echo
	case $REPLY in
	    Q|q)  echo -e "\tProgram zakończył działanie."
	        exit
	        ;;
	    M|m)	insert_first_pages_of_chapters
				menu
			;;
	    S|s)	insert_shift	
				menu
			;;
	    R|r)	clear
			run
			;;
	    *)  echo -e "\t${RED}Nieprawidłowa opcja${NC}" >&2
	        exit 1
	        ;;
	    esac
}


menu

