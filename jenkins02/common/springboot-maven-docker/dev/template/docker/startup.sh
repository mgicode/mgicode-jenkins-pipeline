  export POD_IP=`/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print \$2}' | tr -d "addr" `
  echo -e " ############ POD_IP ######################  \n\n    $POD_IP  \n\n\n"
  echo -e " ############# MS_ALL_CONF ####################  \n\n   ${MS_ALL_CONF} \n\n\n"

  java -jar  ${MS_ALL_CONF}  /{{JAR_NAME}}.jar

