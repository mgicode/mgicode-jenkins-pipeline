#FROM registry.cn-hangzhou.aliyuncs.com/prk/centos7_jdk1.8
FROM 10.1.12.41:5000/centos7_jdk1.8
WORKDIR  /

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8
#解决时区的问题
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


ADD startup.sh  /startup.sh
#jenkins的构建时其相对路径有问题，采用绝对路径
#{{JAR_ROOT_PATH}}/
ADD  {{JAR_NAME}}.jar  /{{JAR_NAME}}.jar

RUN chmod +x /startup.sh
RUN chmod +x /{{JAR_NAME}}.jar

ENTRYPOINT /startup.sh
