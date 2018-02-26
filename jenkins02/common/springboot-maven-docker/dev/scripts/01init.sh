#!/usr/bin/env bash
#set -xv
#不加上/usr/bin/env bash 找不到source

echo  -e "\n\n\n##################################################################"
echo  -e "##################### init  start ################################"

ENV_DEPLOY="dev"
ENV_BUILD="springboot-maven-docker"

jarName=`mvn help:evaluate -Dexpression=project.name | grep "^[^\[]"`
jarVersion=`mvn help:evaluate -Dexpression=project.version | grep "^[^\[]"`
jarNameVersionOrig=${jarName}-${jarVersion}
jarNameVersion=$(echo $jarNameVersionOrig | tr '[A-Z]' '[a-z]')

jarNameLower=$(echo $jarName | tr '[A-Z]' '[a-z]')
jarVersionLower=$(echo $jarVersion | tr '[A-Z]' '[a-z]')

dockerName=${jarNameVersion}
dockerVersion=${jarVersion}

rootDir=$(pwd)
targetPath=${rootDir}/target

projectConfigBaseDir=$rootDir/jenkins/$jarNameLower/$jarVersionLower/${ENV_DEPLOY}/${ENV_BUILD}
projectConfigDir=${projectConfigBaseDir}/config
projectAutoTestDir=${projectConfigBaseDir}/autoTestData

commonConfigBaseDir=$rootDir/jenkins/common/${ENV_BUILD}/${ENV_DEPLOY}

#mkdir -p ${targetPath}
cat > ${rootDir}/jenkins/init_var.sh <<EOF
EOF

#读取通用文件
init_before_config="${commonConfigBaseDir}/config/init_before_config.properties"
echo "init_before_config :$init_before_config"
if [ -f "$init_before_config" ]; then
  echo "${init_before_config}的内容:"
  cat $init_before_config
  echo  -e "\n*********************"
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
  echo "emit:${k}"
  else
      echo " export $k=${v} " >> ${rootDir}/jenkins/init_var.sh
      echo " export $k=${v}"
   fi
 done < $init_before_config
fi


echo  -e "\n ***********************************\n"

#在init之前进行不同项目的初始化，可以进行项目变量定义
init_before_config="${projectConfigDir}/init_before_config.properties"
echo "init_before_config :$init_before_config"

if [ -f "$init_before_config" ]; then
echo "${init_before_config}的内容:"
cat $init_before_config
echo  -e "\n*********************"
while read line
do
  line=${line// /}
  echo "$line"
  k=${line%=*}
  v=${line#*=}
  if [ -z "$k" ]
  then
    echo ""
  elif [ $(echo $k | grep "^#")  != ""  ]
  then
   echo ${line}
  else
      echo " export $k=${v} " >> ${rootDir}/jenkins/init_var.sh
      echo " export $k=${v}"
   fi
done < $init_before_config
fi

source   ${rootDir}/jenkins/init_var.sh

echo  -e "\n ***********************************\n"


dockerPath="${dockerImageAddr}/${dockerName}:${dockerVersion}"

echo " export jarName=${jarName}  " >> ${rootDir}/jenkins/init_var.sh
echo  "  export jarVersion=${jarVersion} " >> ${rootDir}/jenkins/init_var.sh
echo  "  export jarNameLower=${jarNameLower}  ">> ${rootDir}/jenkins/init_var.sh
echo  " export jarVersionLower=${jarVersionLower}  " >> ${rootDir}/jenkins/init_var.sh
echo  "  export jarNameVersion=${jarNameVersion}  " >> ${rootDir}/jenkins/init_var.sh
echo  "  export jarNameVersionOrig=${jarNameVersionOrig}  " >> ${rootDir}/jenkins/init_var.sh

echo  " export projectConfigDir=${projectConfigDir}  ">> ${rootDir}/jenkins/init_var.sh
echo  "  export projectConfigBaseDir=${projectConfigBaseDir} " >> ${rootDir}/jenkins/init_var.sh
echo  "  export projectAutoTestDir=${projectAutoTestDir} " >> ${rootDir}/jenkins/init_var.sh

echo  "  export commonConfigBaseDir=${commonConfigBaseDir} " >> ${rootDir}/jenkins/init_var.sh
echo  "  export rootDir=${rootDir} " >> ${rootDir}/jenkins/init_var.sh
echo  "  export targetPath=${targetPath} " >> ${rootDir}/jenkins/init_var.sh
echo  "  export dockerName=${dockerName}" >> ${rootDir}/jenkins/init_var.sh
echo  "  export dockerVersion=${dockerVersion} " >> ${rootDir}/jenkins/init_var.sh
echo  "  export dockerPath=${dockerPath}" >> ${rootDir}/jenkins/init_var.sh

echo  "${rootDir}/jenkins/init_var.sh 内容"
cat  ${rootDir}/jenkins/init_var.sh
#3.3 创建安装的shell
chmod 777  ${rootDir}/jenkins/init_var.sh

source   ${rootDir}/jenkins/init_var.sh



echo  -e "\n ***********************************\n"

#在init之前进行不同项目的初始化，可以进行项目变量定义
init_after_config="${projectConfigDir}/init_after_config.properties"

if [ -f "$init_after_config" ]; then
IFS='='
while read k v
do
  line=${line// /}
  echo "$line"
  k=${line%=*}
  v=${line#*=}
  if [ -z "$k" ]
  then
    echo ""
  elif [ $(echo $k | grep "^#")  != ""  ]
  then
   echo ${line}
  else
      echo " export $k=${v}" >> ${rootDir}/jenkins/init_var.sh
      echo " export $k=${v}"
   fi
done < $init_after_config
fi

source   ${rootDir}/jenkins/init_var.sh
export


echo  -e "###################### init end ######################################"
echo  -e "######################################################################\n\n\n"



#>>/etc/profile
#export NODE_ADMIN_IP="10.1.12.70"
#编辑/etc/profile修改全局环境变量
#编辑.bash_profile修改当前用户的环境变量
#修改完成之后source一下即可生效，例如source ~/.bash_profile


#echo ${str// /}
#echo $str | sed 's/ //g'
#echo $str | tr -d " "