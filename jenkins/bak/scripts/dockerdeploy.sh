#!/usr/bin/env bash

echo  -e "\n\n\n##################################\n"
echo  -e "#### dockerDeploy start #######\n\n\n"

source $(pwd)/target/init_var.sh
export

 echo "MSNAME:${jarNameVersion}, HTTPPORT:${dockerPort}..."
 execScript="
  docker stop  ${jarNameVersion} ;
  docker rm ${jarNameVersion} ;
  #一定要清除原有镜像，不然不会拉
  docker rmi  -f ${dockerPath} ;
  docker run -d   --name ${jarNameVersion}  --restart=always  \
   -p ${dockerPort}:${dockerPort}   ${dockerPath}
   sleep 15
   docker logs ${jarNameVersion}

  "

  echo "${execScript}"
  sleep 5
  ssh $k8sUser@$k8sAddr "${execScript}"

echo  -e "\n\n\n##################################\n"
echo  -e "#### dockerDeploy end #######\n\n\n"




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