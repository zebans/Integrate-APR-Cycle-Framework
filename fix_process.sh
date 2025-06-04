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
cycle=$3

if [ $# -lt 3 ]; then
	echo "⚠️  : At least 4 parameter"
	echo "Example: ./merge_d4j_mut.sh Chart 7 <Cycle>"
	echo "Plz try again."
	exit 1
fi

# FIXME: Project Space 
fixed_proj_dir=$proj_dir/Fixed/$pid_low
fixed_pid_vid_dir=$fixed_proj_dir/${pid_low}_${vid}_fixed

buggy_proj_dir=$proj_dir/Buggy/$pid_low
buggy_pid_vid_dir=$buggy_proj_dir/${pid_low}_${vid}_buggy

# XXX: ⚠️ compile_src_dir=$(${d4j_home}/framework/bin/defects4j export -p dir.bin.classes) #build
src_dir=$buggy_pid_vid_dir$(sed -n '1p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# <project_path>/source
compile_src_dir=$(sed -n '2p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# /build
compile_src_dir=${buggy_pid_vid_dir}${compile_src_dir}

# XXX: ⚠️ test_dir=$(${d4j_home}/framework/bin/defects4j export -p dir.bin.tests) #build-tests
test_dir=$buggy_pid_vid_dir$(sed -n '3p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# /tests
compile_test_dir=$(sed -n '4p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# /build-tests
compile_test_dir=${buggy_pid_vid_dir}${compile_test_dir}



#<------------------------------------------------------------ Split -------------------------------------------------->




# FIXME: Selected_tests Preprocess space
tmp_selected_tests=$buggy_pid_vid_dir/selected_tmp_tests.txt
selected_tests=$buggy_pid_vid_dir/selected_tests.txt

# FIXME: Fix(APR) Space
apr_dir=$home_dir/SimFix	# FIXME: APR Tool dir.
apr_final_dir=$apr_dir/final
apr_patch_dir=$apr_final_dir/patch #/home/ncyu/SimFix/final/patch

apr_tool=$apr_final_dir/topk=150_Untitled.jar



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Preprocess Selected Tests
> $selected_tests
cut -d':' -f2- $tmp_selected_tests | cut -d',' -f1 | sed 's/#/::/' > $selected_tests

# TODO: Using APR Tool(SimFix) and set the configuration
cd $apr_final_dir	# TODO: Enter APR work space
echo "-> Enter SimFix/final Space"

if [ -d $apr_patch_dir ];then		# TODO: Make sure there's no remain patch in patch space.
	echo "⚠️  Remain the error patch dir."
	rm -rf $apr_patch_dir
	if [ ! -d $apr_patch_dir ];then
		echo "✅ Init $apr_patch_dir Success."
	else
		echo "❌  Failed to remove $apr_patch_dir"
	fi
	
fi

java -jar $apr_tool --proj_home=$proj_dir/Buggy --proj_name=$pid_low --bug_id=$vid



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Function
init_apr_patch_dir() {
	cd $apr_final_dir	# TODO: Enter APR final work space

	rm -rf $apr_patch_dir
	if [ ! -d $apr_patch_dir ];then
		echo "✅ Init $apr_patch_dir Success."
	else
		echo "❌  There's no patch for $pid_low $vid"
	fi
}

init_proj_build_sfl() {
	cd $buggy_pid_vid_dir	# TODO: Enter Buggy project dir work space
	if [[ -d $compile_src_dir && -d $compile_test_dir && -d $buggy_pid_vid_dir/sfl ]]; then
		echo
		rm -rf $compile_src_dir	# FIXME: Init compile file
		rm -rf $compile_test_dir	# FIXME: Init compile tests-file
		rm -rf $buggy_pid_vid_dir/sfl		# FIXME: Init sfl file
		
		# TODO: Init buggy_pid_vid_dir
		rm -rf $buggy_pid_vid_dir/all_testcases
		rm -rf $buggy_pid_vid_dir/$vid.test
		rm -rf $buggy_pid_vid_dir/$vid.src
		rm -rf $buggy_pid_vid_dir/gzoltar.ser
		rm -rf $buggy_pid_vid_dir/all-tests.txt
		rm -rf $buggy_pid_vid_dir/failing_tests
		rm -rf $buggy_pid_vid_dir/selected_tests.txt
		rm -rf $buggy_pid_vid_dir/selected_tmp_tests.txt
		rm -rf $buggy_pid_vid_dir/test_pool.txt
		
		
		if [[ -d $compile_src_dir && -d $compile_test_dir && -d $buggy_pid_vid_dir/sfl ]]; then
			echo "❌  Error: init $compile_src_dir or $compile_test_dir or $buggy_pid_vid_dir/sfl"
		else
			echo "✅ Init $compile_src_dir Success."
			echo "✅ Init $compile_test_dir Success."
			echo "✅ Init $buggy_pid_vid_dir/sfl Success."
		fi
		cd $expr_dir	# FIXME: Return to work space (i.e: Expr_file)
		
	else
		echo "❌  Error: Not Exist $compile_src_dir or $compile_test_dir"
	fi
}

init_proj_ori_file() {
	cd $buggy_pid_vid_dir	# TODO: Enter Buggy project dir work space
	if [[ -d ${src_dir}_ori && -d ${test_dir}_ori ]]; then
		echo
		rm -rf ${src_dir}_ori
		rm -rf ${test_dir}_ori
		if [[ -d ${src_dir}_ori && -d ${test_dir}_ori ]]; then
			"❌  Error: init ${src_dir}_ori or ${test_dir}_ori"
		else
			echo "✅ Init ${src_dir}_ori Success."
			echo "✅ Init ${test_dir}_ori Success."
		fi
	fi
}

expr_fixed_dir=$expr_dir/Fixed


# TODO: We are going to exclude Mutation Part!!!!
# TODO: Mutant ID
#mut_id=$(tail -n 1 $expr_dir/Fixed/$pid_low/$vid/used_mutants.txt)

# TODO: Record stmt-susps.txt to Framework_MutID_recorder/mut
#mkdir -p $expr_dir/Fixed/$pid_low/$vid/Framework_MutID_recorder/$mut_id

# TODO: Record Framewrok Result
mkdir -p $expr_dir/Fixed/$pid_low/$vid/Framework_Result
Framework_result_dir=$expr_dir/Fixed/$pid_low/$vid/Framework_Result

record_expr_data(){
	local Patch_Dir=$1

	# FIXME: Copy-> {cycle}_stmt-susps.txt
#	cp -f $apr_final_dir/sbfl/ochiai/$pid_low/$vid/stmt-susps.txt $expr_dir/Fixed/$pid_low/$vid/Framework_MutID_recorder/$mut_id/${cycle}_stmt-susps.txt # FL Result
	cp -f $apr_final_dir/sbfl/ochiai/$pid_low/$vid/stmt-susps.txt $Framework_result_dir
	
	# TODO: Record Cycle_Patch for RQ
	if [[ -d $apr_patch_dir ]];then
#		cp -f $patch_target_path $expr_dir/Fixed/$pid_low/$vid/Framework_MutID_recorder/$mut_id/${cycle}_$patch_target
		cd $Patch_Dir
		rm -rf $Patch_Dir/$pid_low/$vid/*.diff
		mkdir -p $Framework_result_dir/${cycle}_Patch
		cp -rf $Patch_Dir $Framework_result_dir/${cycle}_Patch
		
	fi
#	echo "✅ Record to $expr_dir/Fixed/$pid_low/$vid/Framework_MutID_recorder/$mut_id/"
	echo "✅ Record to $Framework_result_dir"
	echo
}




#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Using APR(SimFix) tool process
#java -jar $simfix_apr --proj_home=$proj_dir --proj_name=$pid_low --bug_id=$vid

# TODO: Integrate patch to project source work space
# FIXME: find <$apr_final_dir>/patch/<pid>/<vid>/ -type f -exec basename {} \;
if [[ -d $apr_patch_dir ]];then

	# TODO: Record APR Tool Generated patch files count
	# Get Patch Location: /home/ncyu/SimFix/final/patch/math/35/
	amount_patch=$(ls $apr_patch_dir/$pid_low/$vid | wc -l)
	patch_file_array=($(ls $apr_patch_dir/$pid_low/$vid))
	
	# TODO: Start to Integrate Generated Patch to Project Source Path
	for ((index=0;index<amount_patch;index++))
	do
		# TODO: Get Patch Location: /home/ncyu/SimFix/final/patch/math/35/0/1_ElitisticListPopulation.java
		echo -n "Patch Location:"
		find $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]} -type f
		selected_patch_target_path=$(find $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]} -type f)
		
		# TODO: Get Patch Target: # 1_AbstractCategoryItemRenderer.java
		echo -n "Patch Target:"
		find $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]} -type f -exec basename {} \;
		patch_target=$(find $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]} -type f -exec basename {} \;)
		
		# TODO: Get Patch java information: package org.xxx.xxx.xxx
		echo -n "Patch target Path:"
		grep -E "^\s*package\s+.*;" $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]}/$patch_target | sed -E 's/^\s*package\s+([^;]+);/\1/' | tr '.' '/'
		patch_target_path=$(grep -E "^\s*package\s+.*;" $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]}/$patch_target | sed -E 's/^\s*package\s+([^;]+);/\1/' | tr '.' '/')
		
		# TODO: Format Patch Target:  # 1_AbstractCategoryItemRenderer.java -> AbstractCategoryItemRenderer.java
		echo "Formatted Target:${patch_target#*_}"
		patch_target=${patch_target#*_}	# Remove <*_>xxx.java
		
		
# <--------------------------------------Split-------------------------------------->

	
		# TODO: Project Source Target Path
		echo -n "Source target path:"
		find ${src_dir}/$patch_target_path -type f -name "$patch_target"
		source_target_path=$(find ${src_dir}/$patch_target_path -type f -name "$patch_target")


# <--------------------------------------Split-------------------------------------->

		# TODO: Using git repo. 
		cd $buggy_pid_vid_dir	
		# TODO: (for backup)
		cp $source_target_path $source_target_path.bak
		# TODO: Copy patch file to 
		cp -f $selected_patch_target_path $source_target_path
		# TODO: Diff file gen.
		git diff > $apr_patch_dir/$pid_low/$vid/$index.diff
		# TODO: Go back
		mv $source_target_path.bak $source_target_path
		# TODO: (Check) Apply the patch
		git apply --check $apr_patch_dir/$pid_low/$vid/$index.diff
		if [ $? -ne 0 ];then
			echo "❌  Patch can't used."
			exit 1
		fi
		#TODO: Apply it
		git apply $apr_patch_dir/$pid_low/$vid/$index.diff
		if [ $? -eq 0 ];then
			git checkout -b patch_${pid_low}_${vid}_${index}
			git add $source_target_path
			git commit -m "Apply patch $index"
			echo "✅ Integrate Patch #${index} Success."
			git branch -d patch_${pid_low}_${vid}_${index}
		else
			echo "❌  Patch can't used."
			exit 1
		fi	
		
		# TODO: diff -u old_file new_file > patch.diff
#		diff -u $source_target_path $selected_patch_target_path
#		diff -u $source_target_path $selected_patch_target_path > $apr_patch_dir/$pid_low/$vid/$index.diff
		echo
	done

	
	# TODO: Integrate patch file to 
#	ls $apr_patch_dir/$pid_low/$vid/*.diff | wc -l
#	amount_diff=$(ls $apr_patch_dir/$pid_low/$vid/*.diff | wc -l)

#	for ((index=0;index<amount_diff;index++))
#	do
#		selected_patch_target_path=$(find $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]} -type f)
		
#		patch_target=$(find $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]} -type f -exec basename {} \;)

#		patch_target_path=$(grep -E "^\s*package\s+.*;" $apr_patch_dir/$pid_low/$vid/${patch_file_array[$index]}/$patch_target | sed -E 's/^\s*package\s+([^;]+);/\1/' | tr '.' '/')

#		patch_target=${patch_target#*_}
		
#		source_target_path=$(find ${src_dir}/$patch_target_path -type f -name "$patch_target")
		
#		patch $source_target_path < $apr_patch_dir/$pid_low/$vid/$index.diff
#		echo
#		echo "✅ Integrate Patch: $apr_patch_dir/$pid_low/$vid/$index.diff -> $source_target_path"
#		echo
#	done

	# TODO: Record Expr Data
	record_expr_data "$apr_patch_dir"
	
	# TODO: Init APR final work space
	# Mark it cuz need to get into next cycle
#	init_apr_patch_dir
#	echo "Init <init_apr_patch_dir> echo ~"
#	echo
	
	# TODO: Init Project compile file work space
	init_proj_build_sfl
	echo "Init <init_proj_build_sfl> echo ~"
	echo
	
	# FIXME: Init Project cycle xxx_ori file(only SimFix)
	init_proj_ori_file
	echo "Init <init_proj_ori_file> echo ~"
	echo
		
else
	echo "Apr tool have no patch for $pid_low-$vid"
	> $Framework_result_dir/${cycle}_end
fi



#<------------------------------------------------------------ Split -------------------------------------------------->

#<------------------------------------------------------------ Split -------------------------------------------------->

# TODO: [Ti=T0-VTi] Didn't do, for example the selected tests only 5~10 test cases, and using command <defects4j test> cost of the time same with all_tests.




















