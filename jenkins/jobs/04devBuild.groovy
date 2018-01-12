pipeline {
    agent {
        docker {
            image '10.1.12.61:5000/mavendind:1.2'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('检出配置作业') {
            steps {
                git branch: 'master', credentialsId: 'e11c379e-a04f-4880-b0b8-cf82eee2a91c', url: 'http://10.1.12.92/pengrk/jenkins-jobs.git'
                sh "cd .. ; rm -rf jenkins-job/;  mkdir -p jenkins-job/jenkins/; echo ${WORKSPACE} "
                sh "cp  -rf jenkins/*  ../jenkins-job/jenkins/ ;  ls -l ../jenkins-job/jenkins/"
            }
        }
        stage('检出代码') {
            steps {
                git branch: 'dev', credentialsId: 'e11c379e-a04f-4880-b0b8-cf82eee2a91c', url: 'http://10.1.12.92/pengrk/ms-test.git'
                sh "cp  -rf ../jenkins-job/jenkins   jenkins  ; ls -l jenkins/"
            }
        }

        stage("构建JAR包") {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }

        stage('单元测试') {
            steps {
                sh 'mvn test'
            }
//            post {
//                always {
//                    junit 'target/surefire-reports/*.xml'
//                }
//            }
        }


        stage("静态代码检测") {
            steps {
                //sh ' mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.90:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597'
                sh 'mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true  ;   mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.90:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597            '

            }
//            post {
//                always {
//                    junit 'target/surefire-reports/*.xml'
//                }
//            }
        }

        stage("初始化环境变量") {
            steps {
                sh ' chmod 777 ./jenkins/scripts/init.sh ; ./jenkins/scripts/init.sh '
            }
        }

        stage('构建Docker镜像') {
            steps {
                sh ' chmod 777 ./jenkins/scripts/dockerbuild.sh ; ./jenkins/scripts/dockerbuild.sh '
            }
        }

        stage('构建k8s配置') {
            steps {
                sshagent(['c1f710ff-ca06-4e79-9043-1d112ddfe4ce']) {
                    sh ' chmod 777 ./jenkins/scripts/k8sconfig.sh ; ./jenkins/scripts/k8sconfig.sh'
                }
            }
        }

        stage('部署镜像到k8s') {
            steps {
                sshagent(['c1f710ff-ca06-4e79-9043-1d112ddfe4ce']) {
                    sh ' chmod 777 ./jenkins/scripts/k8sdeployhostNetwork.sh; ./jenkins/scripts/k8sdeployhostNetwork.sh '
                }
            }
        }


        stage('自动化接口测试') {
            agent {
                docker {
                    image '10.1.12.61:5000/newman'
                    reuseNode true
                }
            }
            steps {
                // working directory will be /var/jenkins_home/workspace/ms-echo-dev-host-network not /var/jenkins_home/workspace/ms-echo-dev-host-network@2
                // ${WORKSPACE%%@*}
                sh ' newman --version ;  chmod 777  ./jenkins/scripts/k8sdeployhostNetworkAutoTest.sh ; ./jenkins/scripts/k8sdeployhostNetworkAutoTest.sh '

            }
        }

    }
}

