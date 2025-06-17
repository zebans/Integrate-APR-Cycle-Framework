#!/bin/bash

# Teminal Window
cols=$(tput cols)
fill=$(printf '%*s' "$cols" '' | tr ' ' '=')

# Work Directory
home_dir=/home/ncyu
proj_dir=$home_dir/MyProject
expr_dir=$home_dir/Expr_file
d4j_home=$home_dir/defects4j

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



# FIXME: Project Space 
fixed_proj_dir=$proj_dir/Fixed/$pid_low
fixed_pid_vid_dir=$fixed_proj_dir/${pid_low}_${vid}_fixed

buggy_proj_dir=$proj_dir/Buggy/$pid_low
buggy_pid_vid_dir=$buggy_proj_dir/${pid_low}_${vid}_buggy

# FIXME: Gzoltar arch var.
export gzoltar_agent_jar=$home_dir/gzoltar/com.gzoltar.agent.rt/target/com.gzoltar.agent.rt-1.7.2-all.jar
export gzoltar_cli_jar=$home_dir/gzoltar/com.gzoltar.cli/target/com.gzoltar.cli-1.7.2-jar-with-dependencies.jar

# TODO: Step2: Enter Project space and Test
cd $buggy_pid_vid_dir
#defects4j test




#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Do Everthing Below !!
# TODO: Start Gzoltar sfl
echo "⚠️  export dir.bin.classes && export -p dir.bin.tests are not support d4j v1.2.0"
echo

# TODO: Using Gzoltar, Prepare Require Setting
lib_dir=$(${d4j_home}/framework/bin/defects4j export -p cp.test)

# XXX: ⚠️ compile_src_dir=$(${d4j_home}/framework/bin/defects4j export -p dir.bin.classes) #build
src_dir=$buggy_pid_vid_dir$(sed -n '1p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# /source
compile_src_dir=$(sed -n '2p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# /build
compile_src_dir=${buggy_pid_vid_dir}${compile_src_dir}

# XXX: ⚠️ test_dir=$(${d4j_home}/framework/bin/defects4j export -p dir.bin.tests) #build-tests
test_dir=$buggy_pid_vid_dir$(sed -n '3p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	#/tests
compile_test_dir=$(sed -n '4p' ~/SimFix/d4j-info/src_path/$pid_low/$vid.txt)	# /build-tests
compile_test_dir=${buggy_pid_vid_dir}${compile_test_dir}

#unit_test_file=${buggy_pid_vid_dir}/unselected_tests.txt
#relevant_tests_file=$d4j_home/framework/projects/$pid/relevant_tests/$vid
#relevant_tests=$(cat $relevant_tests_file | sed 's/$/#*/' | sed ':a;N;$!ba;s/\n/:/g')

# FIXME: Selected Test File & Unselected Test File
# TODO: To Judge Enter Cycle or not
test_pool=$buggy_pid_vid_dir/test_pool.txt
selected_test=$buggy_pid_vid_dir/selected_tests.txt
#unselected_tests=$buggy_pid_vid_dir/unselected_tests.txt

list_test_method() {
	export JAVA_HOME=$home_dir/jvm/jdk1.8.0_401
	export PATH=$JAVA_HOME/bin:$PATH
	
	local test_data=$1
	test_data=$(cat $test_data | sed 's/$/#*/' | sed ':a;N;$!ba;s/\n/:/g')
	# TODO: List Work Space Test Cases
	java -Deverbose=true -cp ${lib_dir}:${gzoltar_cli_jar} \
	 com.gzoltar.cli.Main listTestMethods \
	 ${compile_test_dir} \
	 --outputFile ${test_pool} \
	 --includes $test_data
	
	# TODO: Self-define list sbfl test (gzoltar unit_test.txt)
	#sed 's/\(.*\)::\(.*\)/JUNIT,\1#\2/' $test_data
}

ser_file=${buggy_pid_vid_dir}/gzoltar.ser

gen_ser_file() {

	local testcases=$1

	# TODO: Using Gzoltar tool with java 1.8 and backup the sfl result
	export JAVA_HOME=$home_dir/jvm/jdk1.8.0_401
	export PATH=$JAVA_HOME/bin:$PATH
	
	# TODO: Self Define Loaded Classes, Normal Classes and Inner Classes
	loaded_classes_file=$buggy_pid_vid_dir/${vid}.src
	NORMAL_CLASSES=$(cat ${loaded_classes_file} | sed 's/$/:/' | sed ':a;N;$!ba;s/\n//g')
	INNER_CLASSES=$(cat ${loaded_classes_file} | sed 's/$/$*:/' | sed ':a;N;$!ba;s/\n//g')
	LOADED_CLASSES=${NORMAL_CLASSES}${INNER_CLASSES}

	# TODO: Generate .ser file
	java -javaagent:${gzoltar_agent_jar}=destfile=${ser_file},buildlocation=${compile_src_dir},includes=${LOADED_CLASSES},excludes="",inclnolocationclasses=false,output="file" \
	  -cp ${gzoltar_cli_jar}:${lib_dir} \
	  com.gzoltar.cli.Main runTestMethods \
	  --testMethods $testcases \
	  --collectCoverage
}

sbfl_report() {
	# TODO: Using Gzoltar tool with java 1.8 and backup the sfl result
	export JAVA_HOME=$home_dir/jvm/jdk1.8.0_401
	export PATH=$JAVA_HOME/bin:$PATH
	
	# TODO: Generate report
	java -cp ${gzoltar_cli_jar}:${lib_dir} \
	  com.gzoltar.cli.Main faultLocalizationReport \
	    --buildLocation ${compile_src_dir} \
	    --granularity line \
	    --inclPublicMethods \
	    --inclStaticConstructors \
	    --inclDeprecatedMethods \
	    --dataFile ${ser_file} \
	    --outputDirectory ${buggy_pid_vid_dir} \
	    --family sfl \
	    --formula ochiai \
	    --metric entropy \
	    --formatter txt
}


> $buggy_pid_vid_dir/all_testcases	# Test cases name file
# TODO: Judge enter cycle or not

# TODO: Step3: FL
echo "✅ Enter Framework Cycle."
echo

# TODO: Prepare test cases and source class data
cd $buggy_pid_vid_dir
# XXX: This is all tests file
defects4j export -p tests.all | tee $vid.test	# Test suite

#	relevant_tests_file=/home/ncyu/defects4j/framework/projects/$pid/relevant_tests/$vid
#	cp $relevant_tests_file $vid.test
	
# TODO: Self Define the src File to Response Cycle APR Tool Patches
find $src_dir -type f -name "*.java" | sed "s|$src_dir/||; s|/|.|g; s|\.java$||" > $vid.src	# Source class
	
# TODO: Test all get coverage information
list_test_method $vid.test
gen_ser_file $test_pool
sbfl_report

if ! grep -q "-" $buggy_pid_vid_dir/sfl/txt/matrix.txt; then
    echo "⚠️  matrix.txt has no '-' (no failed test cases)."
    exit 99
fi

# TODO: Copy the script and python file to project/sfl/txt
cp $expr_dir/selection_algo.sh $buggy_pid_vid_dir/sfl/txt/
cp $expr_dir/find_representative_coverage.py $buggy_pid_vid_dir/sfl/txt/
cp $expr_dir/Jaccard_similarity.py $buggy_pid_vid_dir/sfl/txt/

# TODO: Make Test cases file
cd $buggy_pid_vid_dir/sfl/txt/
tail -n +2 tests.csv | while IFS=, read -r test_name outcome runtime stacktrace; do	# Skip header
	echo ${test_name} >> $buggy_pid_vid_dir/all_testcases
done





