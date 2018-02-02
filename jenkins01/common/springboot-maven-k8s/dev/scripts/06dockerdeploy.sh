#!/usr/bin/env bash

echo  -e "\n\n\n##################################################################"
echo  -e "##################### dockerDeploy start ################################"

source $(pwd)/init_var.sh
export

init_after_dockerdeploy_config="${projectConfigDir}/init_after_dockerdeploy.properties"
#if [ -d "$init_after_dockerdeploy_config" ]; then
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
done < $init_after_dockerdeploy_config
#fi

source   ${rootDir}/init_var.sh
#export

ALL_CONF=`echo "${MS_ALL_CONF}" |sed "s/\//\\\\\\\\\//g"`

 echo "MSNAME:${jarNameVersion}, HTTPPORT:${dockerServerPort}..."

 execScript="
  docker stop  ${jarNameVersion} ;
  docker rm ${jarNameVersion} ;
  #一定要清除原有镜像，不然不会拉
  docker rmi  -f ${dockerPath} ;
  docker run -d   --name ${jarNameVersion}  --restart=always  \
   --env MS_ALL_CONF= "${ALL_CONF}"                      \
   -p ${dockerServerPort}:${dockerServerPort}   ${dockerPath}
   sleep 15
   docker logs ${jarNameVersion}

  "

  echo "${execScript}"
  sleep 5
  ssh $dockerServerUser@$dockerServerIP "${execScript}"


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