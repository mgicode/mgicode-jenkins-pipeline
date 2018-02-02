#!/usr/bin/env bash
echo  -e "\n\n\n##################################################################"
echo  -e "##################### 静态代码检测  start ################################"

source $(pwd)/jenkins/init_var.sh

init_after_staticcheck_config="${projectConfigDir}/init_after_staticcheck.properties"

if [ -f "$init_after_staticcheck_config" ]; then

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
done < $init_after_staticcheck_config
fi

source   ${rootDir}/jenkins/init_var.sh
#export


echo -e  "\n进行静态检测...\n."
echo "SONAR_IP_PORT:$SONAR_IP_PORT, SONAR_CREDENTIALSID:$SONAR_CREDENTIALSID " ;

mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent  \
install -Dmaven.test.failure.ignore=true sonar:sonar   \
-Dsonar.host.url=${SONAR_IP_PORT} -Dsonar.login=${SONAR_CREDENTIALSID}

 temp=$?
  if [[ $temp -ne 0 ]];
  then exit  $temp
  fi

echo  -e "##################### 静态代码检测  end ################################"
echo  -e "###########################################################\n\n\n"
