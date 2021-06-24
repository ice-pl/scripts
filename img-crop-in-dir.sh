#!/usr/bin/env bash
GREEN='\033[0;32m'
RED='\033[1;31m'
ORANGE='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BLINKING_ON='\033[5m'
BLINKING_OFF='\033[0m'


AllFiles=(*)
FileName=${AllFiles[0]}
Name=${FileName::${#FileName}-4}
Extension=${FileName: -4}


# TOP=110
# LEFT=200
# BOTTOM=140
# RIGHT=520

TOP=130
LEFT=390
BOTTOM=160
RIGHT=390

# TOP=0
# LEFT=0
# BOTTOM=0
# RIGHT=0


show () {
	printf '\n'
	echo "	--------------------------"
	echo -en "${CYAN}"
	printf '%s\t' "	  TOP :=         ""  +${TOP[@]}"
	printf '\n'
	printf '%s\t' "	  LEFT :=        ""  +${LEFT[@]}"
	printf '\n'
	printf '%s\t' "	  BOTTOM :=      ""  -${BOTTOM[@]}"
	printf '\n'
	printf '%s\t' "	  RIGHT :=       ""  -${RIGHT[@]}"
	printf '\n'
	echo -en "${NC}"
	echo "	--------------------------"
}

which_file () {
	echo -en "${ORANGE}" "	${AllFiles[0]}" "${NC}"
}

preview () {
	feh -. "test"$Extension
	rm "test"$Extension
}

top_margin () {
	which_file
	echo
	read -p "   TOP > " TOP
	convert "${FileName}" -crop +0+$TOP "test"$Extension
	preview
}

left_margin () {
	which_file
	echo
	read -p "   LEFT > " LEFT
	convert "${FileName}" -crop +$LEFT+0 "test"$Extension
	preview
}

bottom_margin () {
	which_file
	echo
	read -p "   BOTTOM > " BOTTOM
	convert "${FileName}" -crop -0-$BOTTOM "test"$Extension
	preview
}

right_margin () {
	which_file
	echo
	read -p "   RIGHT > " RIGHT
	convert "${FileName}" -crop -$RIGHT-0 "test"$Extension
	preview
}

run_top_left () {
	if [ -d cropped_top_left ]; then
		rm -rf cropped_top_left
	fi
	mkdir cropped_top_left
	for f in *.jpg; do
		convert "$f" -crop +$LEFT+$TOP cropped_top_left/"$f"
	done
	cd cropped_top_left
	mkdir cropped_bottom_right
	for f in *.jpg; do
		convert "$f" -crop -$RIGHT-$BOTTOM cropped_bottom_right/"$f"
	done
	cd ..
}

move_files () {
	if [ -d cropped ]; then
		rm -rf cropped
	fi
	mkdir cropped
	mv cropped_top_left/cropped_bottom_right/* cropped/
	if [ -d cropped_top_left ]; then
		rm -rf cropped_top_left
	fi
}



run () {
	run_top_left
	move_files
}

menu () {
	clear
	show
	echo "
	==========================
	  MENU:
	  Q|q)  Quit

	  T|t)  TOP
	  L|l)  LEFT
	  B|b)  BOTTOM
	  R|r)  RIGHT

	  E|e)  Execute program
	=========================="
	echo
	read -p "	Enter your choice >>> "
	echo
	case $REPLY in
	    Q|q)  echo -e "\tProgram terminated."
	        exit
	        ;;
	    T|t)	top_margin
				menu
			;;
	    L|l)	left_margin
				menu
			;;
	    B|b)	bottom_margin
				menu
			;;
	    R|r)	right_margin
				menu
			;;
	    E|e)	clear
			run
			;;
	    *)  echo -e "\t${RED}Incorrect option${NC}" >&2
			sleep 1
	        menu
	        ;;
	    esac
}


menu
