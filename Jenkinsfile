pipeline {
    agent any 
    environment { 
        ENV_URL= "Pipeline.google.com"        # Global Variable : All the stages of the pipeline can inherit this
        SSHCRED = credentials('SSHCRED')       # The secret manager has run at the the top of the pipeline
    }
    options { buildDiscarder(logRotator(numToKeepStr: '5')) }
    stages {
        stage('First stage') { 
            steps {
               sh "echo Welcome world!" 
               sh "echo ${ENV_URL}"
            }
        }
        stage('Second stage') { 
             environment { 
                 ENV_URL= "Pipeline.google.com"  # Local Variable :Scope of the local variable is confined to this stage only
           }
            steps {
                sh "echo Welcome Tataji"
                sh "echo ${ENV_URL}" 
                sh "env"                  # Environment variables
            }
        }
        stage('Third stage') { 
            steps {
               echo "Welcome DevOps"
            }
        }
    }
}