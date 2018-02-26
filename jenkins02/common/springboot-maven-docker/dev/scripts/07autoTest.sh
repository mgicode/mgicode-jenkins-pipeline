#!/usr/bin/env bash

echo  -e "\n\n\n##################################################################"
echo  -e "#####################  autoTest  start ################################"

source $(pwd)/jenkins/init_var.sh
#export

init_after_autoTest_config="${projectConfigDir}/init_after_autoTest.properties"
if [ -f "$init_after_autoTest_config" ]; then

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
done < $init_after_autoTest_config
fi

source   ${rootDir}/jenkins/init_var.sh
#export



targetEnvironment=${targetPath}/postman_environment_template.json

#ms-echo.postman_environment_template.json
echo "targetCollection:$targetCollection,targetEnvironment:$targetEnvironment"

echo  -e "\n\n#### 生成${targetEnvironment}\n"
if [ -d "${targetEnvironment}" ] ; then
      rm -rf ${targetEnvironment}
fi
cp  ${projectAutoTestDir}/postman_environment_template.json  ${targetEnvironment}
sed  -i  "s/{{HTTP_URL}}/$dockerServerIP/g;s/{{HTTP_PORT}}/$dockerServerPort/g;" ${targetEnvironment}
cat ${targetEnvironment}


sleep 50
#curl http://$dockerServerIP:$dockerServerPort/

echo  -e "\n\n#### 执行批量测试\n"
newman run  ${projectAutoTestDir}/*_collection.json  --environment ${targetEnvironment}

 temp=$?
  if [[ $temp -ne 0 ]];
  then exit  $temp
 fi

echo  -e "##################### autoTest end ################################"
echo  -e "\n\n\n################################################################\n"

