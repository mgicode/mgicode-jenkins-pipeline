#!/usr/bin/env bash

echo  -e "\n\n\n##################################\n"
echo  -e "#### k8sConfig #######\n\n\n"
export

source $(pwd)/target/init_var.sh

configTemplateDir=${rootDir}/jenkins/template/k8s/configmap

configDir=${rootDir}/configmap
configYaml=${configDir}/config.yaml

k8sDir=/helmdata/$jarNameVersion/configmap


if [ -d "${configYaml}" ] ; then
      rm -rf ${configYaml}
fi

#rm -rf ${targetPath}/configmap/config.yaml
mkdir -p ${configDir}/
cp  ${configTemplateDir}/config.yaml  ${configYaml}

#名称中去掉小数点，如my-app-1.0-snapshot
COMMON_NAME=${jarNameVersion/./}

sed  -i  "s/{{COMMON_NAME}}/${COMMON_NAME}/g;s/{{MS_ALL_CONF}}/$MS_ALL_CONF/g;"  ${configYaml}

echo "gen ${configYaml}..."
cat ${configYaml}
sleep 5


echo "ssh upload ..."
ssh $k8sUser@$k8sAddr  "rm -rf ${k8sDir}/* ;  mkdir -p ${k8sDir}/ "

scp ${configYaml}  $k8sUser@$k8sAddr:${k8sDir}/config.yaml

ssh $k8sUser@$k8sAddr  "
        cd ${k8sDir};
        kubectl delete -f config.yaml;
        kubectl create -f config.yaml
        "

echo  -e "\n\n\n##################################\n"
echo  -e "#### k8sConfig #######\n\n\n"
