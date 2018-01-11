#!/usr/bin/env bash

echo  -e "\n\n\n##################################\n"
echo  -e "#### k8sAuth #######\n\n\n"

source $(pwd)/target/init_var.sh
echo "auth......"

export
#判断是否能登陆，如果能的话，那么就不需要使用expect,按道理讲用不上啊？
ssh -o NumberOfPasswordPrompts=0  $k8sUser@$k8sAddr "date"
if [ $? -eq 0 ];then
       echo "$i" >> 2.txt
else

    if [ -d "~/.ssh/id_rsa.pub" ] ; then
      rm -rf ~/.ssh/*
    fi

    ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa
    echo -e  "\nssh-keygen生成的文件###########\n"
    ls -la  ~/.ssh/

    #expect中不能直接使用~
    rsaPath=~
    sleep 1
   # 2、进行ssh免证登录,ssh-copy-id到需要免登录的机器上
   expect -c "
    set timeout 5
    spawn ssh-copy-id -i  $rsaPath/.ssh/id_rsa.pub $k8sUser@$k8sAddr
    expect {
      "*yes/no" { send "yes\\r"; exp_continue}
      "*INFO:" { exp_continue }
      "*ERROR:" { exp_continue }
      "*again" { send "$k8sPwd\\r";  }
      "*assword:" { send "$k8sPwd\\r" }
     }
     expect eof
     exit
     #expect进程要退出，不然在循环中再次运行报错
  "
   #该时间需要足够长，不然spawn执行的命令的伪线程还没有关闭，那么第二次就会connect refused!
  echo "sleep: 10"
   sleep 10

fi

echo  -e "\n\n\n##################################\n"
echo  -e "#### k8sAuth #######\n\n\n"
