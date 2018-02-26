#!/usr/bin/env bash

echo  -e "\n\n\n##################################################################"
echo  -e "##################### dockerDeploy start ################################"

source $(pwd)/jenkins/init_var.sh
#export

init_after_dockerdeploy_config="${projectConfigDir}/init_after_dockerdeploy.properties"
if [ -d "$init_after_dockerdeploy_config" ]; then
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
done < $init_after_dockerdeploy_config
fi

source   ${rootDir}/jenkins/init_var.sh
#export

#ALL_CONF=`echo "${MS_ALL_CONF}" |sed "s/\//\\\\\\\\\//g"`
#MYSQL_URL=`echo "${MYSQL_URL}" |sed "s/\//\\\\\\\\\//g"`

 echo "MSNAME:${jarNameVersion}, HTTPPORT:${dockerServerPort}..."

 execScript="
  docker stop  ${jarNameVersion} ;
  docker rm ${jarNameVersion} ;
  #一定要清除原有镜像，不然不会拉
  docker rmi  -f ${dockerPath} ;
  docker run -d   --name ${jarNameVersion}  --restart=always     -p  ${dockerServerPort}:${dockerServerPort} \
    -e  MS_ALL_CONF=\"
   -Dserver.port=${dockerServerPort} \
   -Dendpoints.health.sensitive=false \
   -Dmanagement.security.enabled=false  \
   -Dspring.datasource.username=${MYSQL_USERNAME}  \
   -Dspring.datasource.password=${MYSQL_PASSWRD}   \
   -Dmanagement.health.consul.enabled=false  \
   -Dspring.cloud.consul.discovery.enabled=true   \
   -Dspring.cloud.consul.discovery.hostname=${dockerServerIP}   \
   -Dspring.cloud.consul.discovery.port=${dockerServerPort}   \
   -Dspring.cloud.consul.host=${CONSUL_IP}     \
   -Dspring.cloud.consul.port=${CONSUL_PORT}      \
   -Dspring.cloud.consul.discovery.healthCheckUrl=http://${dockerServerIP}:${dockerServerPort}/health \
    \"    ${dockerPath}
   sleep 15
   docker logs ${jarNameVersion}

  "
   #-Dspring.cloud.consul.discovery.serviceName=${jarNameLower}   \
   #-Dspring.application.name=${jarNameLower} \
  # -Dspring.datasource.url=${MYSQL_URL}   \

#-Dserver.port=8020
#--endpoints.health.sensitive=false \
#    --management.security.enabled=false  \
#    --spring.datasource.url=${MYSQL_URL}   \
#    --spring.datasource.username=${MYSQL_USERNAME}  \
#   --spring.datasource.password=${MYSQL_PASSWRD}   \
#    --management.health.consul.enabled=false  \
#   --spring.cloud.consul.discovery.enabled=true   \
#   --spring.cloud.consul.discovery.hostname=${dockerServerIP}   \
#   --spring.cloud.consul.discovery.port=${dockerServerPort}   \
#   --spring.cloud.consul.discovery.serviceName=${jarNameLower}   \
#   --spring.cloud.consul.host=${CONSUL_IP}     \
#   --spring.cloud.consul.port=${CONSUL_PORT}      \
#   --spring.cloud.consul.discovery.healthCheckUrl=http://${dockerServerIP}:${dockerServerPort}/health \



 #--spring.datasource.password=${MYSQL_PASSWRD}   \
#MYSQL_URL="jdbc:mysql://10.1.12.56:3306/RoadNet"
#MYSQL_USERNAME="design"
#MYSQL_PASSWRD="design!@#"

  # --env MS_ALL_CONF= "${ALL_CONF}"                      \
  echo "${execScript}"
  sleep 5
  ssh $dockerServerUser@$dockerServerIP "${execScript}"

 temp=$?
  if [[ $temp -ne 0 ]];
  then exit  $temp
 fi

echo  -e "##################### dockerDeploy end ################################"
echo  -e "\n\n\n################################################################\n"





#  --env MS_ALL_CONF=\"
#    --spring.application.name=${MSNAME}  \
#    --server.port=${HTTPPORT}  \
#    --tcp.port=${TCPPORT}  \
#    --endpoints.health.sensitive=false \
#    --management.security.enabled=false \
#    --management.health.consul.enabled=false \
#   --spring.cloud.consul.discovery.enabled=true  \
#   --spring.cloud.consul.discovery.hostname=${ip}  \
#   --spring.cloud.consul.discovery.port=${HTTPPORT} \
#   --spring.cloud.consul.discovery.serviceName=${MSNAME} \
#   --spring.cloud.consul.host=${consulIP}   \
#   --spring.cloud.consul.port=${consulPort}    \
#
#   --spring.cloud.consul.discovery.healthCheckUrl=http://${ip}:${HTTPPORT}/health \
#   \"