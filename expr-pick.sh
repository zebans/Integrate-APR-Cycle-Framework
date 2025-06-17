#!/bin/bash

# Teminal Window
cols=$(tput cols)
fill=$(printf '%*s' "$cols" '' | tr ' ' '=')

# Work Directory
home_dir=/home/ncyu
proj_dir=$home_dir/MyProject
expr_dir=$home_dir/Expr_file
d4j_home=$home_dir/defects4j

# TODO: Parameter ($# -> count arg) ($1 -> no.1 arg) ...
pid=$1	# Project id
pid_low=$(echo $1 | tr 'A-Z' 'a-z')
vid=$2	# Version id
top_k=$3
threshold_j=$4

if [ $# -lt 4 ]; then
	echo "⚠️  : At least 4 parameter"
	echo "Example: ./merge_d4j_mut.sh Chart 7 <top-k> <threshold>"
	echo "Plz try again."
	exit 1
else
	echo "Current pid: $pid"
	echo "Current pid_low: $pid_low"
	echo "Current vid: $vid"
	echo "Current top-k: $top_k"
	echo "Current threshold_j: $threshold_j"
fi

echo
echo "$fill"
echo

expr_fixed_dir=$expr_dir/Fixed

# FIXME: Fix(APR) Space
apr_dir=$home_dir/SimFix	# FIXME: APR Tool dir.
apr_final_dir=$apr_dir/final
apr_patch_dir=$apr_final_dir/patch #/home/ncyu/SimFix/final/patch

# TODO: Terminal Condition Function (if no patch exist)
init_apr_patch_dir() {
	cd $apr_final_dir	# TODO: Enter APR final work space
	if [ -d $apr_patch_dir ]; then
		echo 
		rm -rf $apr_patch_dir
		cd $expr_dir	# FIXME: Return to work space (i.e: Expr_file)
		echo "✅ Init $apr_patch_dir Success."
	else
		echo "❌  $apr_patch_dir Not Exist!"
	fi
}

# TODO: Start Framework
Framework(){
	local current_pid=$1
	local current_pid_low=$(echo $current_pid | tr 'A-Z' 'a-z')
	local current_vid=$2
	local buggy_pid_vid_dir=$3
	
	# TODO: Test First
	cd $buggy_pid_vid_dir
	#	defects4j test
	
	cycle=0	# TODO: Init Cycle
	start=$(date +%s)	# TODO: Start timer
	
	# TODO: Fault localization: Gzoltar v1.7.2 with java 1.8
	$expr_dir/gzoltar.sh $current_pid $current_vid
	framework_result=$?
	
	while [ "$framework_result" -ne 99 ]; do
#	while [ -s "$buggy_pid_vid_dir/failing_tests" ]; do
		((cycle++))	# TODO: Enter Cycle
		
		if [ "$cycle" -eq 1 ]; then	# TODO: The first time cycle
			echo "🔁 Starting repair cycle #$cycle"

			cd $expr_dir

			# TODO: Select test cases
			./selection_algo.sh $current_pid $current_vid $top_k $threshold_j # FIXME: Copy the script into project/sfl/txt
			cd $expr_dir

			# TODO: Fix
			$expr_dir/fix_process.sh $current_pid $current_vid $cycle
			cd $expr_dir
			
			# TODO: Timer
			cycle_end=$(date +%s)
			cycle_duration=$((cycle_end - start))
			touch $expr_dir/Fixed/$current_pid_low/$current_vid/${current_pid}_${current_vid}_cycle_${cycle}_cost.txt
			echo "⏱️ Cycle #$cycle time: $cycle_duration seconds."
			echo "⏱️ Cycle #$cycle time: $cycle_duration seconds." >> $expr_dir/Fixed/$current_pid_low/$current_vid/${current_pid}_${current_vid}_cycle_${cycle}_cost.txt
			
			cd $buggy_pid_vid_dir
			defects4j test
			
		elif [[ -d $apr_patch_dir && "$cycle" -ne 1 && $cycle -le 5 ]]; then	# TODO: Terminal Condition
			
			init_apr_patch_dir	 # TODO: Initialize apr patch
			
			echo "🔁 Starting repair cycle #$cycle"
			
			# TODO: Fault localization: Gzoltar v1.7.2 with java 1.8
			$expr_dir/gzoltar.sh $current_pid $current_vid
			framework_result=$?
			cd $expr_dir

			# TODO: Select test cases
			./selection_algo.sh $current_pid $current_vid $top_k $threshold_j # FIXME: Copy the script into project/sfl/txt
			cd $expr_dir

			# TODO: Fix
			$expr_dir/fix_process.sh $current_pid $current_vid $cycle
			cd $expr_dir
			
			# TODO: Timer
			cycle_end=$(date +%s)
			cycle_duration=$((cycle_end - start))
			touch $expr_dir/Fixed/$current_pid_low/$current_vid/${current_pid}_${current_vid}_cycle_${cycle}_cost.txt
			echo "⏱️ Cycle #$cycle time: $cycle_duration seconds."
			echo "⏱️ Cycle #$cycle time: $cycle_duration seconds." >> $expr_dir/Fixed/$current_pid_low/$current_vid/${current_pid}_${current_vid}_cycle_${cycle}_cost.txt
			
			cd $buggy_pid_vid_dir
			defects4j test
		else
			echo "🛑 No new patch found in previous cycle. Exiting loop."
			break
		fi	# TODO: If cycle != 1 and there's no patch in [cycle n-1] quit the loop
		
		# TODO: Timer
		total_end=$(date +%s)
		total_duration=$((total_end - start))
		echo "⏱️ ${current_pid}-${current_vid} time: $total_duration seconds."
		echo "⏱️ ${current_pid}-${current_vid} time: $total_duration seconds." >> $expr_dir/${current_pid}_Timer.txt
	done
}

# FIXME: Project Space 
#fixed_proj_dir=$proj_dir/Fixed/$pid_low
#fixed_pid_vid_dir=$fixed_proj_dir/${pid_low}_${vid}_fixed

#buggy_proj_dir=$proj_dir/Buggy/$pid_low
#buggy_pid_vid_dir=$buggy_proj_dir/${pid_low}_${vid}_buggy

#> Exclude_pid_vid

# FIXME: Original for loop control flow
#for ((current_vid=1;current_vid<=vid;current_vid++))

project_fixed_txt=$expr_dir/$pid_low.txt

mapfile -t proj_fixed_vid < $project_fixed_txt

for current_vid in "${proj_fixed_vid[@]}";
do
	fixed_proj_dir=$proj_dir/Fixed/$pid_low
	fixed_pid_vid_dir=$fixed_proj_dir/${pid_low}_${current_vid}_fixed
	
	buggy_proj_dir=$proj_dir/Buggy/$pid_low
	buggy_pid_vid_dir=$buggy_proj_dir/${pid_low}_${current_vid}_buggy
	
	# TODO: Build Current Project
	$expr_dir/checkout.sh $pid $current_vid
	
	# TODO: Start Framework
	Framework $pid $current_vid $buggy_pid_vid_dir
	
	
	# TODO: Prepare dataset
#	for ((round=1;round<=5;round++))
#	do
#		if [ -d $expr_fixed_dir/$pid_low/$current_vid/selected_mutants ];then
#			echo "Selected Mutants prepared."
#			echo
			
#			$expr_dir/seed_mut_bug.sh $pid $current_vid
		
#			Framework $pid $current_vid $buggy_pid_vid_dir
#		else
#			$expr_dir/checkout.sh $pid $current_vid
	
#			$expr_dir/d4j_mut.sh $pid $current_vid
			
#			if [ -d $expr_fixed_dir/$pid_low/$current_vid/selected_mutants ];then
#				$expr_dir/seed_mut_bug.sh $pid $current_vid
				
#				Framework $pid $current_vid $buggy_pid_vid_dir
#			else
#				echo "❌  Error msg: No selected_mutants, Bug-$current_vid exclude !"
#				echo "❌  Failed to Repair ${pid_low}-${current_vid}"
#				echo "Exclude: ${pid_low}-${current_vid}" >> Exclude_pid_vid
#				continue
#			fi
#		fi
#	done
done


# TODO: Checkout project
#$expr_dir/checkout.sh $pid $vid

# TODO: Mutate make own data project, observe multiple failing tests. (p.s: Doing in fixed project)
#$expr_dir/d4j_mut.sh $pid $vid

# TODO: Seed Dev-bug and Mut-bug. (p.s: Doing in buggy project)
#$expr_dir/seed_mut_bug.sh $pid $vid



# TODO: Select test cases
#cd $buggy_pid_vid_dir/sfl/txt/
#./selection_algo.sh $pid $vid $top_k $threshold_j	# FIXME: Copy the script into project/sfl/txt
#cd $expr_dir

# TODO: Fix
#$expr_dir/fix_process.sh $pid $vid 







