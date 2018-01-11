#!/usr/bin/env bash

#Uploading: http://10.1.12.28:8081/repository/distributionRepo/com/sirius/sys-gateway-springboot/0.0.1/sys-gateway-springboot-0.0.1.jar
#修改这几个参数
COMMON_NAME="sys-gateway-test"
JAR_ADDR=http://10.1.12.77:8081/repository/distributionRepo/com/sirius/sys-gateway-springboot/0.0.1/
JAR_NAME=sys-gateway-springboot-0.0.1.jar

IMAGES_ADDR=10.1.12.61:5000/centos7_jdk1.8
HTTP_PORT=8080
THRIFT_PORT=8081

REPEAT_COUNT=1

JAR_ADDR1=`echo $JAR_ADDR |sed "s/\//\\\\\\\\\//g"`
IMAGES_ADDR1=`echo $IMAGES_ADDR |sed "s/\//\\\\\\\\\//g"`


kubectl get all |grep "${COMMON_NAME}"
echo "k8s中目前存在相关的服务： $COMMON_NAME,请稍等..."
sleep 5

echo "\n\n\n正在生成检查生成 $COMMON_NAME.yaml...\n\n\n"
cp k8s-template.yaml  $COMMON_NAME.yaml
sed  -i  "s/{{COMMON_NAME}}/$COMMON_NAME/g;s/{{JAR_ADDR}}/$JAR_ADDR1/g;s/{{JAR_NAME}}/$JAR_NAME/g;s/{{REPEAT_COUNT}}/$REPEAT_COUNT/g;s/{{IMAGES_ADDR}}/$IMAGES_ADDR1/g;s/{{HTTP_PORT}}/$HTTP_PORT/g;s/{{THRIFT_PORT}}/$THRIFT_PORT/g"   $COMMON_NAME.yaml

#显示生成文件
cat $COMMON_NAME.yaml
echo "\n\n\n请检查生成 $COMMON_NAME.yaml\n\n\n"
sleep 5


kubectl  delete -f  $COMMON_NAME.yaml

kubectl create -f  $COMMON_NAME.yaml
kubectl get all |grep "${COMMON_NAME}"



#网上查了一下，原来是mac的sed对\n的处理和linux不一样
#解决办法：1.brew install gnu-sed --with-default-names