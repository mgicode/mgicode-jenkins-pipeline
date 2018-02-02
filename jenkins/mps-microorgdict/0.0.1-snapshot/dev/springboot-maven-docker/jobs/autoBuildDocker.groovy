pipeline {
    environment {
        //该变量使用不了
        DOCKER_IMAGES_BASE_URL = "10.1.12.41:5000"

        CONFIG_CREDENTIALSID = '1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CONFIG_GIT_URL = 'http://10.1.12.35/pengrk/jenkins-jobs.git'

        SCRIPT_BASE_PATH = "./jenkins/common/springboot-maven-docker/dev/scripts"
        SCRIPT_CONFIG_BASE_PATH="../jenkins-job/jenkins/common/springboot-maven-docker/dev/scripts"
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
                sh 'echo  -e "##################### 检出配置作业  start ################################"'
                sh "echo ${CONFIG_CREDENTIALSID}  ${CONFIG_GIT_URL} ;  rm -rf *"
                git branch: 'master', credentialsId: '1a9c014b-0747-465f-b786-1fb2334f5d7f', url: 'http://10.1.12.35/pengrk/jenkins-jobs.git'
                sh "chmod 777  ${SCRIPT_BASE_PATH}/*.sh "
                sh 'echo  -e "##################### 检出配置作业  end ################################\n\n"'

            }
        }

        stage('备份配置作业') {
            steps {
                sh "${SCRIPT_BASE_PATH}/11configout.sh"
            }
        }
        stage('检出代码') {
            steps {
                sh 'echo  -e "\n##################### 检出代码  start ################################"'
                git branch: '${gitlabSourceBranch}', credentialsId: '1a9c014b-0747-465f-b786-1fb2334f5d7f', url: 'http://10.1.12.146/MPS/SYS/Dict.git'
                sh 'echo  -e "##################### 检出代码  end ################################\n"'

            }
        }

        stage('合并配置作业') {
            steps {
                sh "${SCRIPT_CONFIG_BASE_PATH}/12configmerge.sh"
            }
        }

        stage("初始化环境变量") {
            steps {
                sh 'chmod 777  ${SCRIPT_BASE_PATH}/*.sh '
                sh '${SCRIPT_BASE_PATH}/01init.sh '
            }
        }

        stage('单元测试') {
            steps {
                sh '${SCRIPT_BASE_PATH}/02unittest.sh '
            }
        }

        stage("静态代码检测") {
            steps {
                sh '${SCRIPT_BASE_PATH}/03staticCheck.sh '
            }
        }


        stage("构建JAR包") {
            steps {
                sh '${SCRIPT_BASE_PATH}/04buildjar.sh '
            }
        }

        stage('构建Docker镜像') {
            steps {
                sh '${SCRIPT_BASE_PATH}/05dockerbuild.sh '
            }
        }

        stage('部署镜像到Docker') {
            steps {
                sshagent(['${DOCKER_HOST_SSH_CREDENTIALSID}']) {
                    sh '${SCRIPT_BASE_PATH}/06dockerdeploy.sh '
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
                sh '${SCRIPT_BASE_PATH}/07autoTest.sh '

            }
        }

    }
}

