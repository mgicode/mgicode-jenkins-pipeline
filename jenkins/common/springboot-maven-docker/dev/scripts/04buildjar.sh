#!/usr/bin/env bash

echo  -e "\n\n\n##################################################################"
echo  -e "##################### 构建JAR包  start ################################"

source $(pwd)/jenkins/init_var.sh

init_after_buildjar_config="${projectConfigDir}/init_after_buildjar.properties"

if [ -f "$init_after_buildjar_config" ]; then

while read line
do
 line=${line// /}
  echo "$line"
  k=${line%=*}
  v=${line#*=}
  if [ -z "$k" ]
  then
    echo "empty row"
  elif [ $(echo $k | grep "^#")  != ""  ]
  then
   echo ${line}
  else
      echo " export $k=${v} " >> ${rootDir}/jenkins/init_var.sh
      echo " export $k=${v}"
   fi
done < $init_after_buildjar_config
fi

source   ${rootDir}/jenkins/init_var.sh
#export


echo -e "\n进行打包构建...\n."
mvn -B -DskipTests clean package

 temp=$?
 if [[ $temp -ne 0 ]];
  then exit  $temp
 fi


echo  -e "##################### 构建JAR包  end ################################"
echo  -e "###########################################################\n\n\n"
