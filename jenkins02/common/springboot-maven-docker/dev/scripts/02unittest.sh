#!/usr/bin/env bash
echo  -e "\n\n\n##################################################################"
echo  -e "##################### 单元测试  start ################################"

source $(pwd)/jenkins/init_var.sh

init_after_unittest_config="${projectConfigDir}/init_after_unittest.properties"

if [ -f "$init_after_unittest_config" ]; then

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
      echo " export $k=${v}" >> ${rootDir}/jenkins/init_var.sh
      echo " export $k=${v}"
   fi
done < $init_after_unittest_config
fi

source   ${rootDir}/jenkins/init_var.sh
#export


echo -e "\n进行单元测试...\n "
echo "SONAR_IP_PORT:$SONAR_IP_PORT, SONAR_CREDENTIALSID:$SONAR_CREDENTIALSID " ;

mvn test surefire-report:report

 temp=$?
  if [[ $temp -ne 0 ]];
  then exit  $temp
 fi

echo  -e "##################### 单元测试  end ################################"
echo  -e "###########################################################\n\n\n"
