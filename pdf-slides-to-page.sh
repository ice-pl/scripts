#!/usr/bin/env bash
# set -x

args=("$@")
nazwa_pliku="${args[0]}"
nazwa=${nazwa_pliku::${#nazwa_pliku}-4}
rozszerzenie=${nazwa_pliku: -4}

ilosc_stron=$(pdfinfo "$nazwa_pliku" | grep Pages | awk '{print $2}')
# echo $ilosc_stron

# dir=$(pwd)
dir="$(pwd)"

if [[ -d "$dir/tmp_directory" ]]; then
	rm -rf "$dir/tmp_directory"
fi
mkdir tmp_directory


# pdftk "$nazwa_pliku" burst output tmp_directory/page_%04d.pdf > /dev/null 2>&1
# pdftk "$nazwa_pliku" burst output tmp_directory/page_%04d.pdf

pdfseparate "$nazwa_pliku" tmp_directory/page_%04d.pdf



if [[ -f "$dir/tmp_directory/doc_data.txt" ]]; then
	rm "$dir/tmp_directory/doc_data.txt"
fi

files=`ls "${dir}/tmp_directory" | wc -l`


for ((i=1; i<=$files; i=i+2)); do

	odd=$( printf '%04d' $i )
	even=$( printf '%04d' $((i+1)) )

	if [ ${even##+(0)} -gt $ilosc_stron ]; then
		even=$odd
	fi

	# echo $odd
	# echo $even

	pdfjam "$dir"/tmp_directory/page_${odd}.pdf "$dir"/tmp_directory/page_${even}.pdf --nup 1x2 --no-landscape --paper a4paper --quiet --outfile "$dir"/tmp_directory/out_${odd}.pdf
done

cd "$dir/tmp_directory"
rm page_*.pdf

pdfunite *.pdf "${nazwa}_a4_bigger$rozszerzenie"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${nazwa}_a4_NOnr$rozszerzenie" "${nazwa}_a4_bigger$rozszerzenie"


printf '%s' '
\documentclass[a4paper,12pt,twoside]{book}
\usepackage{pdfpages}
\usepackage{bera}
\usepackage{fancyhdr}
\usepackage[left=0.5cm,right=0.5cm,top=0cm,bottom=1.5cm]{geometry}
\usepackage{ifthen}
\usepackage{currfile}

\fancyhf{}
\renewcommand{\headrulewidth}{0pt}

\fancyfoot[LE,RO]{\ifthenelse{\value{page}=1}{\currfilename \hspace{1cm}  \huge\thepage}{\huge\thepage}}

\pagestyle{fancy}

\begin{document}
\includepdf[pages=-,pagecommand={\thispagestyle{fancy}}]{'"${nazwa}_a4_NOnr$rozszerzenie"'}
\end{document}
' > "${nazwa}_a4".tex

pdflatex "${nazwa}_a4".tex


mv "${nazwa}_a4$rozszerzenie" ../"${nazwa}_a4$rozszerzenie"
cd ..
rm -rf tmp_directory
