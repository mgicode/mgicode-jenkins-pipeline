
pipeline {
    agent {
        docker {
            image '10.1.12.61:5000/maven'
            args '-v /root/.m2:/root/.m2'
        }
    }

    //
    stages {
//        stage('git') {
//            steps {
//                git branch: 'dev', credentialsId: 'e11c379e-a04f-4880-b0b8-cf82eee2a91c', url: 'http://10.1.12.92/pengrk/simple-java-maven-app-master.git'
//
//            }
//        }

        //需要安装 jenkins-gitlab-merge-request-builder-plugin,解决了多流程的问题，
        // 见https://github.com/timols/jenkins-gitlab-merge-request-builder-plugin/
        stage('git') {
            steps {
                sh "echo ${gitlabSourceBranch} "
                git branch: '${gitlabSourceBranch}', credentialsId: 'e11c379e-a04f-4880-b0b8-cf82eee2a91c', url: 'http://10.1.12.92/pengrk/ms-test.git'

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

    }
}

