
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
                git branch: 'master', credentialsId: '0a2f41d3-8b08-4c3c-b962-2444ae0fbb22', url: 'http://10.1.12.92/pengrk/simple-java-maven-app-master.git'

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
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
       stage('StaticCheck') {
            steps {
                sh ' mvn sonar:sonar  -Dsonar.host.url=http://10.1.12.90:9000 -Dsonar.login=277a6a58a4ae62ab3cb9785a7dec54e719767597'
            }
            post {
               always {
                  junit 'target/surefire-reports/*.xml'
                     }
               }
       }

    }
}

