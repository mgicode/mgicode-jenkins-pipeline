#!/usr/bin/env bash

echo  -e "\n\n\n##################################\n"
echo  -e "#### dockerBuild  start #######\n\n\n"

source $(pwd)/target/init_var.sh
export

templateDir=${rootDir}/jenkins/template/docker

targetStartUp=${targetPath}/startup.sh
targetDockerfile=${targetPath}/Dockerfile

echo "templateDir:$templateDir, targetStartUp:$targetStartUp,targetDockerfile:$targetDockerfile"

echo  -e "\n\n#### 生成${targetStartUp}\n\n\n"
if [ -d "${targetStartUp}" ] ; then
      rm -rf ${targetStartUp}
fi
cp  ${templateDir}/startup.sh  ${targetStartUp}
sed  -i  "s/{{JAR_NAME}}/$jarNameVersionOrig/g;" ${targetStartUp}
cat ${targetStartUp}



echo  -e "\n\n#### 生成${targetDockerfile}\n\n\n"
if [ -d "${targetDockerfile}" ] ; then
      rm -rf ${targetDockerfile}
fi
cp  ${templateDir}/Dockerfile  ${targetDockerfile}
sed  -i  "s/{{JAR_NAME}}/$jarNameVersionOrig/g;" ${targetDockerfile}
cat ${targetDockerfile}


#构建docker images 并上传到docker register
echo "dockerPath:${dockerPath},targetPath:${targetPath}"
docker rmi ${dockerPath}


cd  ${targetPath}/


echo "\n\n####构建${dockerPath}\n\n\n."
docker build -t ${dockerPath}  -f ${targetDockerfile}  ${targetPath}/


echo "\n\n####上传到docker habor\n\n\n"
docker push ${dockerPath}

echo  -e "\n#### dockerBuild  end #######\n\n\n"

