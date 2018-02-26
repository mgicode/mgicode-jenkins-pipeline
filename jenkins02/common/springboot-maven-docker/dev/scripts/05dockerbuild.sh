#!/usr/bin/env bash
echo  -e "\n\n\n##################################################################"
echo  -e "##################### dockerBuild  start ################################"

source $(pwd)/jenkins/init_var.sh
#export

init_after_dockerbuild_config="${projectConfigDir}/init_after_dockerbuild.properties"

if [ -f "$init_after_dockerbuild_config" ]; then

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
done < $init_after_dockerbuild_config
fi

source   ${rootDir}/jenkins/init_var.sh
#export

templateDir=${commonConfigBaseDir}/template/docker

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
 temp=$?
  if [[ $temp -ne 0 ]];
  then exit  $temp
 fi


echo "\n\n####上传到docker habor\n\n\n"
docker push ${dockerPath}
 temp=$?
  if [[ $temp -ne 0 ]];
  then exit  $temp
 fi


echo  -e "##################### dockerBuild  end ################################"
echo  -e "###########################################################\n\n\n"
