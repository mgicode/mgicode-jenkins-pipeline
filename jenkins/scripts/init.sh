#!/usr/bin/env bash

#不加上/usr/bin/env bash 找不到source


#>>/etc/profile
#export NODE_ADMIN_IP="10.1.12.70"
#编辑/etc/profile修改全局环境变量
#编辑.bash_profile修改当前用户的环境变量
#修改完成之后source一下即可生效，例如source ~/.bash_profile

echo  -e "\n\n\n##################################\n"
echo  -e "#### init #######\n\n\n"


MS_ALL_CONF=`echo "${1}" |sed "s/\//\\\\\\\\\//g"`

k8sAddr="${2:-10.1.12.70}"
k8sUser="${3:-root}"
k8sPwd="${4:-root@123}"



jarName=`mvn help:evaluate -Dexpression=project.name | grep "^[^\[]"`
jarVersion=`mvn help:evaluate -Dexpression=project.version | grep "^[^\[]"`
jarNameVersionOrig=${jarName}-${jarVersion}
jarNameVersion=$(echo $jarNameVersionOrig | tr '[A-Z]' '[a-z]')

#[a-z0-9]([-a-z0-9]*[a-z0-9])?
k8sServiceName=$(echo $jarName | tr '[A-Z]' '[a-z]')

rootDir=$(pwd)

toPath=${rootDir}/target
targetPath=${toPath}

dockerAddr="${1:-10.1.12.61:5000}"
dockerName=${jarNameVersion}
dockerVersion=${jarVersion}
dockerPath="${dockerAddr}/${dockerName}:${dockerVersion}"


echo  -e "jarNameVersion:$jarNameVersion \n"
echo -e "根目录 : ${rootDir} \n"
echo  -e "k8sAddr:$k8sAddr,k8sUser:$k8sUser,toPath:$toPath \n "


#3.3 创建安装的shell
cat > ${targetPath}/init_var.sh <<EOF

  export jarName=${jarName}
  export jarVersion=${jarVersion}
  export jarNameVersion=${jarNameVersion}
  export jarNameVersionOrig=${jarNameVersionOrig}
  export k8sServiceName=${k8sServiceName}

  export rootDir=${rootDir}
  export toPath=${toPath}
  export targetPath=${targetPath}
  export k8sAddr=${k8sAddr}
  export k8sUser=${k8sUser}
  export k8sPwd=${k8sPwd}
  export MS_ALL_CONF=${MS_ALL_CONF}
  export dockerAddr=${dockerAddr}
  export dockerName=${dockerName}
  export dockerVersion=${dockerVersion}
  export dockerPath=${dockerPath}

EOF

chmod 777  ${targetPath}/init_var.sh


echo  -e "\n\n\n##################################\n"
echo  -e "#### init #######\n\n\n"



#echo " export jarName=${jarName} " >> ${targetPath}/init_var.sh


#source   $(pwd)/target/init_var

#echo " export jarName=${jarName} " >> /etc/profile
#echo " export jarVersion=${jarVersion} " >> /etc/profile
#echo " export jarNameVersion=${jarNameVersion} " >> /etc/profile
#echo " export rootDir=${rootDir} " >> /etc/profile
#echo " export toPath=${toPath} " >> /etc/profile
#echo " export targetPath=${targetPath} " >> /etc/profile
#
#echo " export k8sAddr=${k8sAddr} " >> /etc/profile
#echo " export k8sUser=${k8sUser} " >> /etc/profile
#echo " export k8sPwd=${k8sPwd} " >> /etc/profile
#echo " export MS_ALL_CONF=${MS_ALL_CONF} " >> /etc/profile
#
#echo " export dockerAddr=${dockerAddr} " >> /etc/profile
#echo " export dockerName=${dockerName} " >> /etc/profile
#echo " export dockerVersion=${dockerVersion} " >> /etc/profile
#echo " export dockerPath=${dockerPath} " >> /etc/profile
#
#
#source /etc/profile


#这样后面的stages取不到
#echo " export jarName=${jarName} " >> ~/.bash_profile
#echo " export jarVersion=${jarVersion} " >> ~/.bash_profile
#echo " export jarNameVersion=${jarNameVersion} " >> ~/.bash_profile
#echo " export rootDir=${rootDir} " >> ~/.bash_profile
#echo " export toPath=${toPath} " >> ~/.bash_profile
#echo " export targetPath=${targetPath} " >> ~/.bash_profile
#
#echo " export k8sAddr=${k8sAddr} " >> ~/.bash_profile
#echo " export k8sUser=${k8sUser} " >> ~/.bash_profile
#echo " export k8sPwd=${k8sPwd} " >> ~/.bash_profile
#echo " export MS_ALL_CONF=${MS_ALL_CONF} " >> ~/.bash_profile
#
#echo " export dockerAddr=${dockerAddr} " >> ~/.bash_profile
#echo " export dockerName=${dockerName} " >> ~/.bash_profile
#echo " export dockerVersion=${dockerVersion} " >> ~/.bash_profile
#echo " export dockerPath=${dockerPath} " >> ~/.bash_profile
#
#
#source ~/.bash_profile

