#!/bin/bash

# Teminal Window
cols=$(tput cols)
fill=$(printf '%*s' "$cols" '' | tr ' ' '=')

# Work Directory
home_dir=/home/ncyu
proj_dir=$home_dir/MyProject
expr_dir=$home_dir/Expr_file

# Parameter ($# -> count arg) ($1 -> no.1 arg) ...
pid=$1	# Project id
pid_low=$(echo $1 | tr 'A-Z' 'a-z')
vid=$2	# Version id

if [ $# -lt 2 ]; then
	echo "⚠️  : At least 2 parameter"
	echo "Example: ./merge_d4j_mut.sh Chart 7"
	echo "Plz try again."
	exit 1
else
	echo "Current pid: $pid"
	echo "Current pid_low: $pid_low"
	echo "Current vid: $vid"
fi

echo
echo "$fill"
echo

# TODO Function: Patching
#echo "👤 Name: $(person_get_name "$person1")"

# TODO: Make Project Space
mkdir_proj() {
	mkdir -p $proj_dir/Buggy/$pid_low
	mkdir -p $proj_dir/Fixed/$pid_low
}

fixed_proj_dir=$proj_dir/Fixed/$pid_low
fixed_pid_vid_dir=$fixed_proj_dir/${pid_low}_${vid}_fixed

# TODO: Checkout Fixed Project Function
checkout_fixed_proj() {
	echo "Checkout Fixed Project"
	cd $fixed_proj_dir
	defects4j checkout -p $pid -v ${vid}f -w $fixed_pid_vid_dir
	cd $expr_dir
}

# TODO: Init Fixed Project Func.
init_checkout_fixed_proj() {
	echo "Removing $fixed_proj_dir"
	# TODO: Remove Checkout Project
	rm -rf $fixed_pid_vid_dir
	echo 
	cd $fixed_proj_dir
	# TODO: Checkout again (Fixed version)
	defects4j checkout -p $pid -v ${vid}f -w $fixed_pid_vid_dir
	cd $expr_dir
}

buggy_proj_dir=$proj_dir/Buggy/$pid_low
buggy_pid_vid_dir=$buggy_proj_dir/${pid_low}_${vid}_buggy

# TODO: Checkout Buggy Project Function
checkout_buggy_proj() {
	echo "Checkout Buggy Project"
	cd $buggy_proj_dir
	defects4j checkout -p $pid -v ${vid}b -w $buggy_pid_vid_dir
	cd $expr_dir
}

# TODO: Init Buggy Project Func.
init_checkout_fixed_proj() {
	echo "Removing $buggy_proj_dir"
	# TODO: Remove Checkout Project
	rm -rf $buggy_pid_vid_dir
	echo 
	cd $proj_dir/$pid_low
	# TODO: Checkout again (Fixed version)
	defects4j checkout -p $pid -v ${vid}b -w $buggy_pid_vid_dir
	cd $expr_dir
}

# TODO: Make Project Space Func 
mkdir_proj
echo 
# TODO: Exec Checkout fixed func
checkout_fixed_proj
echo 
# TODO: Exec Checkout buggy func
checkout_buggy_proj
echo 









