pipeline {
    agent {
        docker {
            image '10.1.12.61:5000/mavendind:1.2'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('检出代码') {
            steps {
                git branch: 'master', credentialsId: '0a2f41d3-8b08-4c3c-b962-2444ae0fbb22', url: 'http://10.1.12.92/pengrk/simple-java-maven-app-master.git'

            }
        }

        stage("构建JAR包") {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }

        //       stage('单元测试') {
        //          steps {
        //             sh 'mvn test'
        //         }
//            post {
//                always {
//                    junit 'target/surefire-reports/*.xml'
//                }
//            }
        //     }

        //      stage("静态代码检测") {
        //         steps {
        //             sh ' mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.90:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597'
        //         }
//            post {
//                always {
//                    junit 'target/surefire-reports/*.xml'
//                }
//            }
        //       }

        stage("初始化环境变量") {
            steps {
                sh ' chmod 777 ./jenkins/scripts/init.sh ; ./jenkins/scripts/init.sh '
            }
        }

        stage('构建Docker镜像') {
            steps {
                sshagent(['4c7efd25-a02e-422a-880d-55e0729dcd8f']) {
                    sh 'ssh -o StrictHostKeyChecking=no  root@10.1.12.70 " date" '
                }

                sh ' chmod 777 ./jenkins/scripts/dockerbuild.sh ; ./jenkins/scripts/dockerbuild.sh '
            }
        }
        stage('进行K8s免密认证') {
            steps {
                sh ' chmod 777 ./jenkins/scripts/k8sAuth.sh ; ./jenkins/scripts/k8sAuth.sh '
            }
        }
        stage('构建k8s配置') {
            steps {
                sh ' chmod 777 ./jenkins/scripts/k8sconfig.sh ; ./jenkins/scripts/k8sconfig.sh'
            }
        }
        stage('部署镜像到k8s') {
            steps {
                sh ' chmod 777 ./jenkins/scripts/k8sdeploy.sh ; ./jenkins/scripts/k8sdeploy.sh'
            }
        }

    }
}

