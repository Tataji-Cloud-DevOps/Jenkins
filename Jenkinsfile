pipeline {
    agent any 
    environment { 
        ENV URL = "Pipeline.google.com"        // Global Variable : All the stages of the pipeline can inherit this
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
                 ENV URL = "Pipeline.google.com"  // Local Variable :Scope of the local variable is confined to this stage only
           }
            steps {
                sh "echo Welcome Tataji"
                sh "echo ${ENV_URL}" 
            }
        }
        stage('Third stage') { 
            steps {
               echo "Welcome DevOps"
            }
        }
    }
}

