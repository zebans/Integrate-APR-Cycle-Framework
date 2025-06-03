#!/bin/bash

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

apr_patch_dir=/home/ncyu/SimFix/final/patch

buggy_proj_dir=/home/ncyu/MyProject/Buggy/$pid_low/${pid_low}_${vid}_buggy

fixed_proj_dir=/home/ncyu/MyProject/Fixed/$pid_low/${pid_low}_${vid}_fixed

sudo rm -rf $buggy_proj_dir

defects4j checkout -p $pid -v ${vid}b -w $buggy_proj_dir

sudo rm -rf $fixed_proj_dir

defects4j checkout -p $pid -v ${vid}f -w $fixed_proj_dir

sudo rm -rf $apr_patch_dir
