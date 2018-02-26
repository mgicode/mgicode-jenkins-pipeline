#!/usr/bin/env bash

echo  -e "\n\n\n##################################################################"
echo  -e "#####################  autoTest  start ################################"

source $(pwd)/init_var.sh
export

init_after_autoTest_config="${projectConfigDir}/init_after_autoTest.properties"
#if [ -d "$init_after_autoTest_config" ]; then
IFS='='
while read k v
do
 if [[ "$k" =~ ^# ]]
 then
      echo " export $k=${v}"
 else
      echo " export $k=${v} " >> ${rootDir}/init_var.sh
      echo " export $k=${v}"
 fi
done < $init_after_autoTest_config
#fi

source   ${rootDir}/init_var.sh
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


sleep 20
curl http://$dockerServerIP:$dockerServerPort/

echo  -e "\n\n#### 执行批量测试\n"
newman run  ${projectAutoTestDir}/*_collection.json  --environment ${targetEnvironment}

echo  -e "##################### autoTest end ################################"
echo  -e "\n\n\n################################################################\n"

