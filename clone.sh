#!/bin/bash

# Teminal Window
cols=$(tput cols)
fill=$(printf '%*s' "$cols" '' | tr ' ' '=')

# Work Directory
home_dir=/home/ncyu
proj_dir=$home_dir/MyProject
expr_dir=$home_dir/Expr_file

cd $expr_dir
if [ -d /home/ncyu/Expr_file/Integrate-APR-Cycle-Framework ];then
	rm -rf /home/ncyu/Expr_file/Integrate-APR-Cycle-Framework
fi

git clone https://github.com/zebans/Integrate-APR-Cycle-Framework.git

cd /home/ncyu/Expr_file/Integrate-APR-Cycle-Framework

cp -f * $expr_dir

cd /home/ncyu/Expr_file

chmod +x *.sh

