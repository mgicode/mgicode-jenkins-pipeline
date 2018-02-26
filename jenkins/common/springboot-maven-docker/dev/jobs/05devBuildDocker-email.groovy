pipeline {
    environment {
        //该变量使用不了
        DOCKER_IMAGES_BASE_URL = "10.1.12.41:5000"

        CONFIG_CREDENTIALSID = '1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CONFIG_GIT_URL = 'http://10.1.12.35/pengrk/jenkins-jobs.git'

        SCRIPT_BASE_PATH = "./jenkins/common/springboot-maven-docker/dev/scripts"
        SCRIPT_CONFIG_BASE_PATH = "../jenkins-job/jenkins/common/springboot-maven-docker/dev/scripts"

        //这个需要根据不同的项目进行不同的修改
        CODE_CREDENTIALSID = '1a9c014b-0747-465f-b786-1fb2334f5d7f'
        CODE_GIT_URL = 'http://10.1.12.146/MPS/EV/mps-micro-employeeveh.git'

        //IP不同，其生成jenkins的id不一样
        DOCKER_HOST_SSH_CREDENTIALSID = "06a9cda9-9af2-4d31-b8ca-2563c55d02ac"

        EMAIL_RECEIVE="pengrenkui@seassoon.com"
        EMAIL_CC=""
        EMAIL_SEND="message@seassoon.com"
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
                git branch: 'dev', credentialsId: env.CODE_CREDENTIALSID, url: env.CODE_GIT_URL
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
                sshagent([env.DOCKER_HOST_SSH_CREDENTIALSID]) {
                    // sshagent(["06a9cda9-9af2-4d31-b8ca-2563c55d02ac"]) {
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
    //https://jenkinsci.github.io/jira-steps-plugin/steps/project/
    post {

        failure {
            // sh "export"
            mail bcc: "",mimeType: "text/html", body: "构建失败，请访问<a href=${RUN_DISPLAY_URL}> ${RUN_DISPLAY_URL} </a> 查看结果!", cc: "", from: env.EMAIL_SEND, replyTo: '', subject: "${BUILD_TAG} - Build # ${BUILD_NUMBER} 构建失败 ", to: env.EMAIL_RECEIVE

        }
        unstable {
            // sh "export"
            mail bcc: '',mimeType: 'text/html', body: ' 构建不稳定，请访问<a href="${RUN_DISPLAY_URL}"> ${RUN_DISPLAY_URL} </a> 查看结果!', cc: env.EMAIL_CC, from: env.EMAIL_SEND, replyTo: '', subject:"${BUILD_TAG} - Build # ${BUILD_NUMBER} 构建不稳定", to: env.EMAIL_RECEIVE

        }
        aborted {
            //  sh "export"
            mail bcc: "",mimeType: "text/html", body: "构建aborted，请访问<a href=${RUN_DISPLAY_URL}> ${RUN_DISPLAY_URL} </a> 查看结果!", cc: env.EMAIL_CC, from: env.EMAIL_SEND, replyTo: '', subject: "${BUILD_TAG} - Build # ${BUILD_NUMBER} 构建aborted", to:env.EMAIL_RECEIVE
        }
        success {
            //   sh "export"
            mail bcc: "",mimeType: "text/html", body: "构建成功，请访问<a href=${RUN_DISPLAY_URL}> ${RUN_DISPLAY_URL} </a> 查看结果!", cc: env.EMAIL_CC, from: env.EMAIL_SEND, replyTo: '', subject: "${BUILD_TAG} - Build # ${BUILD_NUMBER} 构建成功", to: env.EMAIL_RECEIVE


        }
        // always {
        //sh "export"
        //mail bcc: "",mimeType: "text/html", body: "构建完成，请访问<a href=${RUN_DISPLAY_URL}> ${RUN_DISPLAY_URL} </a> 查看结果!", cc: "pengrenkui@seassoon.com", from: "message@seassoon.com", replyTo: '', subject: "${BUILD_TAG} - Build # ${BUILD_NUMBER} 构建完成", to: "pengrenkui@seassoon.com"
        // mail bcc: '',mimeType: 'text/html', body: ' 构建完成，请访问<a href="${RUN_DISPLAY_URL}"> ${RUN_DISPLAY_URL} </a> 查看结果!', cc: 'pengrenkui@seassoon.com', from: 'message@seassoon.com', replyTo: '', subject: '${BUILD_TAG} - Build # ${BUILD_NUMBER} 完成', to: 'pengrenkui@seassoon.com'
        // }
    }
}

