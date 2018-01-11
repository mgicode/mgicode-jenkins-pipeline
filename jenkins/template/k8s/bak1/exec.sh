#!/usr/bin/env bash
#第一次运行
#ssh-keygen
#ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.1.12.200

#修改这两个文件
ip=10.1.12.70
svcname=sys-gateway-test


templateFileNme=k8s-template.yaml
execFileName=k8s.sh

toPath=/root/${svcname}/test/


ssh root@$ip "rm -rf  $toPath ; mkdir -p $toPath"
#复制模板和执行文件
scp $templateFileNme  root@$ip:${toPath}${templateFileNme}
scp $execFileName  root@$ip:${toPath}${execFileName}

#执行命令文件
echo  $toPath
ssh root@$ip "cd ${toPath}; chmod 777 ${execFileName} ; ./${execFileName} "
