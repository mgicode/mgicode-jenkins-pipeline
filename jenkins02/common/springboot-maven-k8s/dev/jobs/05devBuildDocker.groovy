pipeline {
    environment {

        //该变量使用不了
        DOCKER_IMAGES_BASE_URL="10.1.12.41:5000"

        CONFIG_CREDENTIALSID='1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CONFIG_GIT_URL='http://10.1.12.35/pengrk/jenkins-jobs.git'

        SCRIPT_BASE_PATH="./jenkins/common/springboot-maven-docker/dev/scripts"

        //这个需要根据不同的项目进行不同的修改
        CODE_CREDENTIALSID='1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CODE_GIT_URL='http://10.1.12.35/pengrk/ms-test.git'

//        //IP不同，其生成jenkins的id不一样
//        DOCKER_HOST_SSH_CREDENTIALSID="06a9cda9-9af2-4d31-b8ca-2563c55d02ac"
//
//        SONAR_IP_PORT='http://10.1.12.40:9000'
//        SONAR_CREDENTIALSID="277a6a58a4ae62ab3cb9785a7dec54e719767597"




    }
    agent {
        docker {
            image '10.1.12.41:5000/mavendind:1.2'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('检出配置作业') {
            steps {
                sh  'echo  -e "\n\n\n##################################################################"'
                sh  'echo  -e "##################### 检出配置作业  start ################################"'

                sh "echo ${CONFIG_CREDENTIALSID}  ${CONFIG_GIT_URL} ;  rm -rf *"
                git branch: 'master', credentialsId: '1a9c014b-0747-465f-b786-1fb2334f5d7f', url: 'http://10.1.12.35/pengrk/jenkins-jobs.git'
                sh "cd .. ; rm -rf jenkins-job/;  mkdir -p jenkins-job/jenkins/; echo ${WORKSPACE} "
                sh "cp  -rf jenkins/*  ../jenkins-job/jenkins/ ;  ls -l ../jenkins-job/jenkins/"

                sh  'echo  -e "##################################################################"'
                sh  'echo  -e "##################### 检出配置作业  end ################################\n\n\n"'

            }
        }

        stage('检出代码') {
            steps {
                sh  'echo  -e "\n\n\n##################################################################"'
                sh  'echo  -e "##################### 检出代码  start ################################"'

                git branch: 'dev', credentialsId: '1a9c014b-0747-465f-b786-1fb2334f5d7f', url: 'http://10.1.12.35/pengrk/ms-test.git'
                sh "cp  -rf ../jenkins-job/jenkins   jenkins ;  ls -l jenkins/"

                sh  'echo  -e "##################################################################"'
                sh  'echo  -e "##################### 检出代码  end ################################\n\n\n"'

            }
        }

        stage("初始化环境变量") {
            steps {
                sh ' chmod 777 ${SCRIPT_BASE_PATH}/01init.sh ;  ${SCRIPT_BASE_PATH}/01init.sh '
            }
        }

        stage('单元测试') {
            steps {
                sh  'echo  -e "\n\n\n##################################################################"'
                sh  'echo  -e "##################### 单元测试  start ################################"'

                sh 'mvn test'

                sh  'echo  -e "##################################################################"'
                sh  'echo  -e "##################### 单元测试  end ################################\n\n\n"'

            }
        }

        stage("静态代码检测") {
            steps {
                sh  'echo  -e "\n\n\n##################################################################"'
                sh  'echo  -e "##################### 静态代码检测  start ################################"'

                sh 'mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true sonar:sonar  -Dsonar.host.url=http://10.1.12.40:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597'

                sh  'echo  -e "##################################################################"'
                sh  'echo  -e "##################### 单元测试  end ################################\n\n\n"'

            }
        }


        stage("构建JAR包") {
            steps {
                sh  'echo  -e "\n\n\n##################################################################"'
                sh  'echo  -e "##################### 构建JAR包  start ################################"'

                sh 'mvn -B -DskipTests clean package'

                sh  'echo  -e "##################################################################"'
                sh  'echo  -e "##################### 构建JAR包  end ################################\n\n\n"'

            }
        }

        stage('构建Docker镜像') {
            steps {
                sh ' chmod 777  ${SCRIPT_BASE_PATH}/05dockerbuild.sh ;  ${SCRIPT_BASE_PATH}/05dockerbuild.sh '
            }
        }

        stage('部署镜像到Docker') {
            steps {
                sshagent(['${DOCKER_HOST_SSH_CREDENTIALSID}']) {
                    sh ' chmod 777  ${SCRIPT_BASE_PATH}/06dockerdeploy.sh;  ${SCRIPT_BASE_PATH}/06dockerdeploy.sh '
                }
            }
        }

        stage('自动化接口测试') {
            agent {
                docker {
                    image '10.1.12.41:5000/newman'
                    reuseNode true
                }
            }
            steps {
                // working directory will be /var/jenkins_home/workspace/ms-echo-dev-host-network not /var/jenkins_home/workspace/ms-echo-dev-host-network@2
                // ${WORKSPACE%%@*}
                sh ' newman --version ;  chmod 777   ${SCRIPT_BASE_PATH}/07autoTest.sh ;  ${SCRIPT_BASE_PATH}/07autoTest.sh '

            }
        }

    }
}

