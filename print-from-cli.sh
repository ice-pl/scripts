#!/usr/bin/env bash
args=("$@")
NAZWA_PLIKU=${args[0]}
PARAMETR_MENU=${args[1]}


echo $PARAMETR_MENU


menu () {
    clear
	if [ -z $PARAMETR_MENU ]; then
    	echo "
    	Proszę wybrać:
    	[ H|h ] help (jak używać)
    		[ B|b ] parzyste odwrotnie następnie nieparzyste po kolei
    		[ E|e ] parzyste odwrotnie
    		[ O|o ] nieparzyste po kolei
    	[ Q|q ] Quit
    	"

    	read -p "	Wpisz wybraną opcję [ ... lub Q ] > "
	else
		REPLY=$PARAMETR_MENU
	fi

    case $REPLY in
        H|h)
			# usage
            read -p "Press any key to continue... " -n1 -s
            menu
            ;;
		B|b)
			print_even_reverse_and_odd_normal
            ;;
		E|e)
			print_even_reverse
            ;;
		O|o)
			print_odd_normal
            ;;
		Q|q)
			exit 0
            ;;
        *)
			echo "Nieprawidłowa opcja " >&2
            menu
            ;;
        esac
}

sleep_exit_dialog () {
	const=10
	for (( i=$const; i>=2; i=i-1)); do
		COUNTER=$i
		while [  $COUNTER -lt $const ]; do
			printf "%s" "."
			let COUNTER=COUNTER+1
		done

		printf "%s" "."
		variable=$(awk -v var=$i 'BEGIN{ ans=var/10} { print ans}'<<</dev/null)
		sleep $variable
	done
	printf "%s\n" ""
	sleep 0.1
}

check_parameters () {
	if [ -z "$NAZWA_PLIKU" ]; then
            echo "Nie podano nazwy pliku"
            echo -e "wychodzę \c"
			sleep_exit_dialog
			exit 1
	fi
	if [ ! -f "$NAZWA_PLIKU" ]; then
            echo "Plik nie istnieje"
            echo -e "wychodzę \c"
			sleep_exit_dialog
			exit 1
	fi
}

print_even_reverse () {
	check_parameters
    # echo "przesłano nazwe pliku $NAZWA_PLIKU do parzystego i parametr $PARAMETR_MENU"
	lpr -o outputorder=reverse -o page-set=even "$NAZWA_PLIKU"
    echo -e "\ndrukowanie stron parzystych odwrotnie \c"
	sleep_exit_dialog
}

print_odd_normal () {
	check_parameters
    # echo "przesłano nazwe pliku $NAZWA_PLIKU do nieparzystego i parametr $PARAMETR_MENU"
	lpr -o outputorder=normal -o page-set=odd "$NAZWA_PLIKU"
    echo -e "\ndrukowanie stron nieparzystych po kolei \c"
	sleep_exit_dialog
}


sub_menu () {
    	echo "
    	Proszę wybrać:

    		[ T|t ] TAK
    		[ N|n ] NIE (przerwać skrypt)
    	"
	read -p "	Czy strony w druarce są przełożone (T/N)? " wybor
	case "$wybor" in
		t|T )
			;;
		n|N )
			exit 0
			;;
		* )
			echo "Błędny wybór"
			sub_menu
			;;
	esac
}

print_even_reverse_and_odd_normal () {
	print_even_reverse
	sub_menu
	print_odd_normal
}

menu
