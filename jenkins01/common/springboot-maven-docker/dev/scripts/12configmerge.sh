#!/usr/bin/env bash
echo  -e "\n\n\n##################################################################"
echo  -e "##################### 合并配置脚本  start ################################"

cp  -rf ../jenkins-job/jenkins   jenkins ;

function getdir(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ]
        then
            getdir $dir_or_file
        else
            echo $dir_or_file
        fi
    done
}

getdir jenkins/

echo  -e "##################### 合并配置脚本  end ################################"
echo  -e "###########################################################\n\n\n"
