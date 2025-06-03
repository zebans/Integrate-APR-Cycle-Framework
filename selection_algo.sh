#!/bin/bash

# FIXME: Before enter this script need cd to project/vid/bid/sfl/txt
# FIXME: Need cp this script to project/vid/bid/sfl/txt

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

# FIXME: Project Space 
fixed_proj_dir=$proj_dir/Fixed/$pid_low
fixed_pid_vid_dir=$fixed_proj_dir/${pid_low}_${vid}_fixed

buggy_proj_dir=$proj_dir/Buggy/$pid_low
buggy_pid_vid_dir=$buggy_proj_dir/${pid_low}_${vid}_buggy

# TODO: Enter Project sfl space
cd $buggy_pid_vid_dir/sfl/txt/

#<------------------------------------------------------------ Split -------------------------------------------------->



# TODO: Input file
spectra_file=spectra.csv
test_file=tests.csv
matrix_file=matrix.txt

rank_list_file=ochiai.ranking.csv

mkdir FTC
mkdir PTC

# TODO: Output file
stmt_file=stmt-susps.txt
top_k_stmt_file=top_k_stmt.txt  #XXX: Reduant file
repesentative_coverage=repesentative_coverage.txt #XXX: Reduant file

topk_FTC=FTC/topk_FTC.txt #XXX: Reduant file
topk_FTC_coverage=FTC/topk_FTC_coverage.txt #XXX: Reduant file
topk_FTC_info=FTC/topk_FTC_info.txt #XXX: Reduant file
FTC_coverage_similarity_results=FTC_coverage_similarity_results.txt

topk_PTC=PTC/topk_PTC.txt #XXX: Reduant file
topk_PTC_coverage=PTC/topk_PTC_coverage.txt #XXX: Reduant file
topk_PTC_info=PTC/topk_PTC_info.txt #XXX: Reduant file
PTC_coverage_similarity_results=PTC_coverage_similarity_results.txt

> $top_k_stmt_file
> $repesentative_coverage
> $topk_FTC
> $topk_FTC_coverage
> $topk_FTC_info
> $FTC_coverage_similarity_results
> $topk_PTC
> $topk_PTC_coverage
> $topk_PTC_info
> $PTC_coverage_similarity_results





#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Convert Rank list csv -> stmt_susps.txt for SimFix
sed -E '1s/.*/Statement,Suspiciousness/; s/\$/./; s/#.*:/#/; s/;/,/' $rank_list_file > $stmt_file

# TODO: Read rank list and get top_k stmt
rank_row=0
rank=0
prev_susps=""
> $top_k_stmt_file
tail -n +2 $rank_list_file | while IFS=";" read -r stmt susps; do
	((rank_row++))
	
	if [[ $susps == "0" || $susps == "0.0" ]];then
		continue
	fi
	
	# TODO:Same susps print
	if [[ $susps == $prev_susps ]]; then
		echo $stmt >> $top_k_stmt_file
		echo "$stmt, $susps"
	# TODO:Not same susps
	else
		# Rank++
		((rank++))
		# Rank > top_k; break
		if (( rank > top_k )); then
			break
		else
			# Rank <= top_k; print
			echo "🎯 Rank #$rank:"
			echo "$stmt, $susps"
			echo $stmt >> $top_k_stmt_file
			prev_susps=$susps
		fi
	fi 
done
echo



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Read top_k_stmt.txt <-> spectra.csv
exec 3< top_k_stmt.txt
exec 4< spectra.csv

read -u 4 discard_header
spectra_file_row=
while IFS= read -r top_k_stmt <&3; do
	row_index=0	# Init everytime until all top-k stmt found.
	while IFS= read -r spectra <&4; do 
		((row_index++))
		if [[ $top_k_stmt == $spectra ]]; then
			echo "✅ Match found: #$row_index:$top_k_stmt"
			spectra_file_row+=$row_index	# Store top-k stmt correspond to spectra.csv row_index
			spectra_file_row+=$'\n'	# New line 
		fi			
	done 4< spectra.csv	# Read spectra.csv again
done
echo 



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Read spectra and test file row data, skip header
# XXX: Spectra_file_row = Matrix.txt column
top_k_ftc_coverage=
> $topk_FTC
> $topk_FTC_coverage

> $topk_PTC
> $topk_PTC_coverage

exec 3< $test_file
exec 4< $matrix_file
read -u 3 discard_header # Discard header

row_index=0
while IFS=, read -r test_name outcome runtime stacktrace <&3 && read -r coverage <&4; do
	((row_index++))
	test_result_coverage="${coverage: -1}" # Test fail or pass to phrase the last column
	
	# FIXME: Coverd topk stmt at least 1 stmt loop
	for topk_spec_row in $spectra_file_row; do
		coverage_value=$(echo "$coverage" | \
		awk -v matrix_col="$topk_spec_row" '{print $matrix_col}')
		
		if [[ "$coverage_value" -eq 1 ]]; then
			# TODO: (Find FTC)
			if [[ $test_result_coverage == "-" ]]; then # Only failed test case
				if ! grep -q "$test_name" "$topk_FTC";then
					echo "🔍 Coverd Top-$top_k statement Failed Test <id> <name>:"
					echo "Test #$row_index: $test_name"
					echo "💾 Recording FTC..."
					echo "#$row_index:$test_name" >> $topk_FTC \
					# Record top-k stmt failed test case
					
					echo "💾 Recording coverage..."
					echo "$coverage" >> $topk_FTC_coverage \
					# Record top-k stmt failed test case coverage
				echo
				fi

			# TODO: (Find PTC)
#			elif [[ $test_result_coverage == "+" ]]; then
#				echo "🔍 Coverd Top-$top_k statement Passed Test <id> <name>:"
#				echo "Test #$row_index: $test_name"
#				echo "💾 Recording PTC..."
#				echo "#$row_index:$test_name" >> $topk_PTC
#				echo "💾 Recording coverage..."
#				echo "$coverage" >> $topk_PTC_coverage \
#				# Record top-k stmt failed test case coverage
#				echo

			fi
			break
		fi
	done
	if [[ $test_result_coverage == "+" ]]; then
		if ! grep "$test_name" "$topk_PTC";then
			#		echo "🔍 Coverd Top-$top_k statement Passed Test <id> <name>:"
			echo "Test #$row_index: $test_name"
			echo "💾 Recording PTC..."
			echo "#$row_index:$test_name" >> $topk_PTC
			echo "💾 Recording coverage..."
			echo "$coverage" >> $topk_PTC_coverage \
			# Record top-k stmt failed test case coverage
			echo
		fi
	fi
done



#<------------------------------------------------------------ Split -------------------------------------------------->

# FIXME: If there're no FTC cover top-k stmt exception
if [ ! -s "$topk_FTC_info" ];then
	echo "⚠️  Warnning: topk_FTC is Null!"
	echo "⚠️  Warnning: topk_FTC is Null!"
	echo "⚠️  Warnning: topk_FTC is Null!"
	echo
	 
	> $topk_PTC
	> $topk_PTC_coverage
	exec 3< $test_file
	exec 4< $matrix_file
	read -u 3 discard_header # Discard header

	row_index=0
	while IFS=, read -r test_name outcome runtime stacktrace <&3 && read -r coverage <&4; do
		((row_index++))
		test_result_coverage="${coverage: -1}" # Test fail or pass to phrase the last column
		
		# TODO: (Find FTC)
		if [[ $test_result_coverage == "-" ]];then
			if ! grep -q "$test_name" "$topk_FTC";then
				echo "⚠️🔍  Failed Test <id> <name>:"
				echo "Test #$row_index: $test_name"
				echo "💾 Recording FTC..."
				echo "#$row_index:$test_name" >> $topk_FTC \
				# Record top-k stmt failed test case
				
				echo "💾 Recording coverage..."
				echo "$coverage" >> $topk_FTC_coverage \
				# Record top-k stmt failed test case coverage
				echo
			fi
			# TODO: (Find PTC)
		elif [[ $test_result_coverage == "+" ]]; then
			if ! grep -q "$test_name" "$topk_FTC";then
				echo "⚠️🔍  Passed Test <id> <name>:"
				echo "Test #$row_index: $test_name"
				echo "💾 Recording PTC..."
				echo "#$row_index:$test_name" >> $topk_PTC
				echo "💾 Recording coverage..."
				echo "$coverage" >> $topk_PTC_coverage \
				# Record top-k stmt failed test case coverage
				echo
			fi
		fi
	done
fi



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Selection process (1. Intersection, 2. Similarity, 3. >=threshold j)
# TODO: Representative coverage 
#python3 find_representative_coverage.py chart 1 # XXX: <pid> <vid>
python3 find_representative_coverage.py $pid_low $vid # XXX: <pid> <vid>

# TODO: Using similarity distance to find the relevant test cases
# TODO: FTC Relevant test
#python3 similarity.py chart 1 # XXX: python similarity.py <Project_name> <Project_id> <file_name> <file_name> <PTC/FTC>"
python3 Jaccard_similarity.py $pid_low $vid $repesentative_coverage $topk_FTC_coverage FTC

# TODO: Construct data <FTC_id, coverage, simliarity>
> $topk_FTC_info
echo "🛠️  Construct Top-${top_k} Information to $topk_FTC_info"
paste $topk_FTC $topk_FTC_coverage $FTC_coverage_similarity_results | \
 while IFS=$'\t' read -r FTC_id FTC_coverage FTC_similarity; do
 	similarity_value=$(echo "$FTC_similarity" | sed 's/Similarity: //')	# Reomve "Similarity: "
	echo "$FTC_id,$FTC_coverage,$similarity_value" >> $topk_FTC_info \
	# Store the FTC information <FTC_id,coverage,similarity>
done
echo 



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Using similarity distance to find the relevant test cases
# TODO: PTC Relevant test
#python3 similarity.py chart 1 # XXX: python similarity.py <Project_name> <Project_id> <file_name> <file_name> <PTC/FTC>"
python3 Jaccard_similarity.py $pid_low $vid $repesentative_coverage $topk_PTC_coverage PTC

# TODO: Construct data <FTC_id, coverage, simliarity>
> $topk_PTC_info
echo "🛠️  Construct PTC Information to $topk_PTC_info"
paste $topk_PTC $topk_PTC_coverage $PTC_coverage_similarity_results | \
 while IFS=$'\t' read -r PTC_id PTC_coverage PTC_similarity; do
 	similarity_value=$(echo "$PTC_similarity" | sed 's/Similarity: //') # Reomve "Similarity: "
	echo "$PTC_id,$PTC_coverage,$similarity_value" >> $topk_PTC_info \
	# Store the PTC information <PTC_id,coverage,similarity>
done
echo



#<------------------------------------------------------------ Split -------------------------------------------------->


	 


# TODO: Validation test suite (VTi) for APR candidate patch, mean the test cases are relevant tests.
# FIXME: [SimFix] use purify to phrase failed test cases, but in our work we should split fail test cases and selected pass test cases, so we need to get cycle "i" failed test and put into d4j-info failed test cases

selected_tests=selected_tmp_tests.txt	# XXX: Reduant file
> ~/SimFix/final/d4j-info/failed_tests/$pid_low/$vid.txt
> $selected_tests
# TODO: Find similarity greater threshold j
while IFS=',' read -r TC_id TC_coverage TC_similarity; do
 	if (( $(echo "$TC_similarity >= $threshold_j" | bc -l) )); then
 		echo "✅ FTC Match found: $TC_id,$TC_similarity"
 		echo "$TC_id,$TC_similarity" >> $selected_tests
 		echo 
	 		
 		# TODO: SimFix failed test case format:<clazz::method>
 		echo "$TC_id" | sed -E 's/^#[0-9]+://; s/#/::/' >> ~/SimFix/final/d4j-info/failed_tests/$pid_low/$vid.txt	# FIXME: SimFix purify failed tests! [d4j-info]
 	fi
done < $topk_FTC_info



#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Find similarity greater threshold j

while IFS=',' read -r TC_id TC_coverage TC_similarity; do
 	if (( $(echo "$TC_similarity >= $threshold_j" | bc -l) )); then
 		echo "✅ PTC Match found: $TC_id,$TC_similarity"
 		echo "$TC_id,$TC_similarity" >> $selected_tests	# TODO: SimFix failed test case format:<clazz::method>
 		echo 
 	fi
done < $topk_PTC_info




#<------------------------------------------------------------ Split -------------------------------------------------->




# TODO: Move stmt_susps.txt to SimFix/final/sbfl/ochiai/<pid>/<vid>/
# TODO: Make Sure the Recursive dir. exist FIXME: chart 1 <$pid_low> <$vid>
mkdir -p ~/SimFix/final/sbfl/ochiai/$pid_low/$vid
cp -f $stmt_file ~/SimFix/final/sbfl/ochiai/$pid_low/$vid # FIXME: cp change to mv

# TODO: Move selected_tests.txt to Buggy/pid/vid/pid_vid_buggy/
cp -f $selected_tests $buggy_pid_vid_dir

# TODO: Init and Remove reduant file




















