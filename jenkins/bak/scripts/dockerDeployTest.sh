#!/usr/bin/env bash
echo  -e "\n\n\n##################################\n"
echo  -e "#### autoTest  start #######\n"

source $(pwd)/target/init_var.sh


export

templateDir=${rootDir}/jenkins/autoTest

targetCollection=${targetPath}/ms-echo.postman_collection.json
targetEnvironment=${targetPath}/ms-echo.postman_environment.json


#ms-echo.postman_environment_template.json
echo "templateDir:$templateDir, targetCollection:$targetCollection,targetEnvironment:$targetEnvironment"

echo  -e "\n\n#### 生成${targetCollection}\n"
if [ -d "${targetCollection}" ] ; then
      rm -rf ${targetCollection}
fi
cp  ${templateDir}/ms-echo.postman_collection.json  ${targetCollection}


echo  -e "\n\n#### 生成${targetEnvironment}\n"
if [ -d "${targetEnvironment}" ] ; then
      rm -rf ${targetEnvironment}
fi
cp  ${templateDir}/ms-echo.postman_environment_template.json  ${targetEnvironment}
sed  -i  "s/{{HTTP_URL}}/$k8sAddr/g;s/{{HTTP_PORT}}/$dockerPort/g;" ${targetEnvironment}
cat ${targetEnvironment}


sleep 20
curl http://$k8sAddr:$dockerPort/hello

echo  -e "\n\n#### 执行批量测试\n"
newman run  ${targetCollection}  --environment ${targetEnvironment}


echo  -e "\n\n\n##################################\n"
echo  -e "#### autoTest finish #######\n"
