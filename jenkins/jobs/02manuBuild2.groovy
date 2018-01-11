
pipeline {
    agent none
    stages {

        stage('git') {
             agent {
                    docker {
                         image '10.1.12.61:5000/maven'
                         args '-v /root/.m2:/root/.m2'
                         }
               }
            steps {
                git branch: 'master', credentialsId: '0a2f41d3-8b08-4c3c-b962-2444ae0fbb22', url: 'http://10.1.12.92/pengrk/simple-java-maven-app-master.git'

            }
        }
        stage('Build') {
            agent {
                    docker {
                        image '10.1.12.61:5000/maven'
                        args '-v /root/.m2:/root/.m2'
                    }

                }
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            agent {
                docker {
                    image '10.1.12.61:5000/maven'
                    args '-v /root/.m2:/root/.m2'
                }

            }
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }


       stage('StaticCheck') {
            agent {
                    docker {
                        image '10.1.12.61:5000/maven'
                        args '-v /root/.m2:/root/.m2'
                    }

                }
            steps {
                sh ' mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.90:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597'
            }
            post {
               always {
                  junit 'target/surefire-reports/*.xml'
                     }
               }
       }

       //找不到上面构建的jar
       stage('buildDocker') {

           agent {
               docker {
                   image '10.1.12.61:5000/jpetazzo/dind'
               }
           }
           steps {
                sh ' chmod 777 ./jenkins/scripts/dockerbuild.sh ; ./jenkins/scripts/dockerbuild.sh'
                }
            }
    }
}

