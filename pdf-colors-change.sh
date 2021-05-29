#!/bin/bash



args=("$@")
nazwa_pliku="${args[0]}"
nazwa=${nazwa_pliku::${#nazwa_pliku}-4}                                                                                   
rozszerzenie=${nazwa_pliku: -4}

ilosc_stron=$(pdfinfo "$nazwa_pliku" | grep Pages | awk '{print $2}')


menu () {
    echo "
    Proszę wybrać:

    1. pdf to gray
    2. pdf invert by image
    3. pdf invert
    0. Wyjdź
    "


    
    read -p "Wpisz wybraną opcję [0-3] > "
    echo
    
    case $REPLY in
        1)  pdf_to_grey
            ;;
        2)  pdf_invert_by_image 
            ;;
        3)  pdf_invert
            ;;
        0)  echo "Program zakończył działanie."
            exit
            ;;
        *)  echo "Nieprawidłowa opcja " >&2
            exit 1
            ;;
        esac
}



pdf_to_grey(){
	gs \
	 -sOutputFile="$nazwa"_gray.pdf \
	 -sDEVICE=pdfwrite \
	 -sColorConversionStrategy=Gray \
	 -dProcessColorModel=/DeviceGray \
	 -dCompatibilityLevel=1.4 \
	 -dNOPAUSE \
	 -dBATCH \
	 "$nazwa_pliku"
}




pdf_invert_by_image(){
	mkdir tmp_directory
	pdftoppm "$nazwa_pliku" tmp_directory/page -png > /dev/null 2>&1
	
	cd tmp_directory
	for i in *.png ; do 
		convert -negate "$i" "${i%.*}_inverted.png" ;
	done 
	
	cd ..
	convert tmp_directory/*_inverted.png "${nazwa}"_inverted-big.pdf
	rm -rf tmp_directory
	
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${nazwa}"_inverted.pdf "${nazwa}"_inverted-big.pdf
	
	rm "${nazwa}"_inverted-big.pdf
}



pdf_invert(){
	gs -q -sDEVICE=pdfwrite -o "$nazwa"_inverted.pdf -c '{1 sub neg} settransfer' -f "$nazwa_pliku"
}

menu
