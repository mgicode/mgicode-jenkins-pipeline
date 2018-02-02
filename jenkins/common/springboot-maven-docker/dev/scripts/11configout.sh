#!/usr/bin/env bash
echo  -e "\n\n\n##################################################################"
echo  -e "##################### 备份配置脚本  start ################################"

#在父目录下创建jenkins-job项目
cd ..
rm -rf jenkins-job/
mkdir -p jenkins-job/jenkins/

echo "项目目录：${WORKSPACE}  $(pwd)"

#回到当前项目
cd ${WORKSPACE}
cp  -rf jenkins/*  ../jenkins-job/jenkins/ ;
ls -l ../jenkins-job/jenkins/


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

#getdir ../jenkins-job/jenkins/

echo  -e "##################### 备份配置脚本  end ################################"
echo  -e "###########################################################\n\n\n"
