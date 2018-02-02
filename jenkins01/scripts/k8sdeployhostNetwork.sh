#!/usr/bin/env bash
echo  -e "\n\n\n##################################\n"
echo  -e "#### k8sDeploy #######\n\n\n"

source $(pwd)/target/init_var.sh



HTTP_URL=${1:-10.1.12.74}
HTTP_PORT=${2:-8080}
REPEAT_COUNT=${3:-1}

#这两个地址在自动化测试时可能需要使用
echo " export HTTP_URL=${HTTP_URL} " >> ${targetPath}/init_var.sh
echo " export HTTP_PORT=${HTTP_PORT} " >> ${targetPath}/init_var.sh

source $(pwd)/target/init_var.sh
export



templateDir=${rootDir}/jenkins/template/k8s/deploy
deployTarget=${targetPath}/deploy
deployYaml=${deployTarget}/deployHostNetwork.yaml

k8sDir=/helmdata/$jarNameVersion/deploy


#COMMON_NAME=${dockerName}
#名称中去掉小数点，如my-app-1.0-snapshot
COMMON_NAME=${dockerName/./}

#k8sServiceName

echo ${dockerName//\//\\}

#修改这几个参数
IMAGES_ADDR=`echo $dockerPath |sed "s/\//\\\\\\\\\//g"`


echo  -e "\n\n\n#### 正在生成检查生成 ${deployYaml}...\n\n\n"
mkdir -p  ${deployTarget}/
cp   ${templateDir}/deployHostNetwork.yaml  ${deployYaml}
sed  -i  " s/{{HOST_IP}}/$HTTP_URL/g; s/{{SERVICE_NAME}}/$k8sServiceName/g;s/{{COMMON_NAME}}/$COMMON_NAME/g;s/{{REPEAT_COUNT}}/$REPEAT_COUNT/g;s/{{IMAGES_ADDR}}/$IMAGES_ADDR/g;s/{{HTTP_PORT}}/$HTTP_PORT/g"   ${deployYaml}

#显示生成文件
echo  -e "\n\n#### 请检查生成 ${deployYaml}\n\n\n"
cat  ${deployYaml}


echo -e "\n\n#### 删除老目录，创建新目录：${k8sDir}/"
ssh $k8sUser@$k8sAddr  " rm -rf ${k8sDir}/* ; mkdir -p ${k8sDir}/ ；ls ${k8sDir}/"


echo -e "\n\n#### 把${deployYaml}文件部署到，$k8sUser@$k8sAddr:${k8sDir}/deployHostNetwork.yaml"
scp ${deployYaml}  $k8sUser@$k8sAddr:${k8sDir}/deployHostNetwork.yaml
ssh $k8sUser@$k8sAddr  " ls  -la ${k8sDir}/ ; cat ${k8sDir}/deployHostNetwork.yaml "


echo -e "\n\n####  在$k8sUser@$k8sAddr 中 ${k8sDir}/部署deployHostNetwork.yaml "
ssh $k8sUser@$k8sAddr  " kubectl delete -f ${k8sDir}/deployHostNetwork.yaml ; kubectl create -f ${k8sDir}/deployHostNetwork.yaml ;  kubectl get all |grep '${COMMON_NAME}' "

echo  -e "\n\n\n##################################\n"
echo  -e "#### k8sDeploy #######\n\n\n"
