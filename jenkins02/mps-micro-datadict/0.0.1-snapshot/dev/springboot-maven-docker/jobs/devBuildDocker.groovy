pipeline {
    environment {
        //该变量使用不了
        DOCKER_IMAGES_BASE_URL = "10.1.12.41:5000"

        CONFIG_CREDENTIALSID = '1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CONFIG_GIT_URL = 'http://10.1.12.35/pengrk/jenkins-jobs.git'

        SCRIPT_BASE_PATH = "./jenkins/common/springboot-maven-docker/dev/scripts"
        SCRIPT_CONFIG_BASE_PATH="../jenkins-job/jenkins/common/springboot-maven-docker/dev/scripts"

        //这个需要根据不同的项目进行不同的修改
        CODE_CREDENTIALSID = '1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CODE_GIT_URL = 'http://10.1.12.146/MPS/SYS/Dict.git'

        //IP不同，其生成jenkins的id不一样
        DOCKER_HOST_SSH_CREDENTIALSID="06a9cda9-9af2-4d31-b8ca-2563c55d02ac"

        JIRA_URL="http://10.1.12.52:20012/"
        JIRA_ASSIGNEE_NAME="root"
        JIRA_ISSUE_PROJECT="TEST"

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
                git branch: 'master', credentialsId: env.CONFIG_CREDENTIALSID, url: env.CONFIG_GIT_URL
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
                //  git branch: 'dev', credentialsId: '1a9c014b-0747-465f-b786-1fb2334f5d7f', url: 'http://10.1.12.146/MPS/RN/RoadNet.git'
                git branch: '${gitlabSourceBranch}', credentialsId: env.CODE_CREDENTIALSID, url: env.CODE_GIT_URL
                sh 'echo  -e "##################### 检出代码  end ################################\n"'

            }
            post {
                failure {
                    sh "export"
                }
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
            post {
                failure {
                    sh "export"
                }
            }
        }

        stage("静态代码检测") {
            steps {
                sh '${SCRIPT_BASE_PATH}/03staticCheck.sh '
            }
            post {
                failure {
                    sh "export"
                }
            }
        }

        stage("构建JAR包") {
            steps {
                sh '${SCRIPT_BASE_PATH}/04buildjar.sh '
            }
            post {
                failure {
                    sh "export"
                }
            }
        }


    }
    //https://jenkinsci.github.io/jira-steps-plugin/steps/project/
    post {
        failure {
            sh "export"
        }
    }
}
