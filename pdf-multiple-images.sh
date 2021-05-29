#!/bin/bash

# set -x

args=("$@")
dir="$(pwd)"

prefix_name="working_process_"

var_files_list=$prefix_name"files_list"
quantity_of_images_in_one_page="${args[0]}"
base_val=0


delete_file(){
	if [ -f $(basename $(pwd)).pdf ]; then
		rm $(basename $(pwd)).pdf
	fi
}
delete_folder(){
	if [ -d $prefix_name ]; then
		rm -rf $prefix_name
	fi
}



save_files_list(){
	if [ ! -f "$var_files_list" ]; then
		printf '%s\n' * > $var_files_list
	fi
}



get_line_from_file(){
	sed -n ${line_nr}'p' < $var_files_list
}
how_many_lines_in_file(){
	wc -l < $var_files_list
}



create_image_from_n_lines(){
	names=""
	for ((line_nr=$(($base_val+1)); line_nr<=base_val+quantity_of_images_in_one_page ; line_nr=$(($line_nr+1)) )); do
		names+=" $(get_line_from_file)"
	done
	merged_file_name=$prefix_name$(printf '%04d' $((${base_val}+1)))_$(printf '%04d' $((${line_nr}-1))).jpeg
	rm $merged_file_name  > /dev/null 2>&1
	convert -append $names $prefix_name$( printf '%04d' $((${base_val}+1)))_$( printf '%04d' $((${line_nr}-1))).jpeg
	base_val=$((${line_nr}-1))
}
next_n_lines(){
	while [ $base_val -lt $(how_many_lines_in_file) ]; do
		create_image_from_n_lines
		names_merged+=" $merged_file_name"
	done
}
merge_to_pdf(){
	convert $prefix_name*.jpeg $(basename $(pwd)).pdf
}



create_folder(){
	if [ ! -d $prefix_name ]; then
		mkdir $prefix_name
	fi
}
move_files(){
	mv $prefix_name* $prefix_name/ > /dev/null 2>&1
}




delete_file
delete_folder

save_files_list
next_n_lines
merge_to_pdf

create_folder
move_files

delete_folder
