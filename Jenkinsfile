pipeline {
    agent any 
    environment { 
        ENV URL = "Pipeline.google.com"        
        SSHCRED = credentials('SSHCRED')       
    }
    options {
     buildDiscarder(logRotator(numToKeepStr: '5'))
     disableConcurrentBuilds()
    }
    stages {
        stage('First stage') { 
            steps {
               sh "echo Welcome world!" 
               sh "echo ${ENV_URL}"
            }
        }
        stage('Second stage') { 
             environment { 
                 ENV URL = "Pipeline.google.com"   
           }
            steps {
                sh "echo Welcome Tataji"
                sh "echo ${ENV_URL}" 
                sh "env"                  
            }
        }
        stage('Third stage') { 
            steps {
               echo "Welcome DevOps"
            }
        }
    }
}