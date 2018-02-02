pipeline {
    agent {
        docker {
            image '10.1.12.61:5000/maven'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('git') {
            steps {
                git branch: 'dev', credentialsId: 'e11c379e-a04f-4880-b0b8-cf82eee2a91c', url: 'http://10.1.12.92/pengrk/ms-test.git'

            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
//            post {
//                always {
//                    junit 'target/surefire-reports/*.xml'
//                }
//            }
        }

        //mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true

        //mvn sonar:sonar
       // mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.40:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597


       // mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent install -Dmaven.test.failure.ignore=true sonar:sonar  -Dsonar.host.url=http://10.1.12.40:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597


        stage('StaticCheck') {
            steps {
                sh ' mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.90:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597'
            }
//            post {
//               always {
//                  junit 'target/surefire-reports/*.xml'
//                     }
//               }
       }

       stage('upload') {
          steps {
               sh 'mvn deploy'
              }
          }
    }
}

