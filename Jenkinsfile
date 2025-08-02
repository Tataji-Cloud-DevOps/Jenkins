pipeline {
    agent any 
    environment { 
        URL = "Pipeline.google.com"        
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
                 URL = "stage.google.com"  
           }
            steps {
                sh "echo Welcome Tataji"
                sh "echo ${URL}" 
            }
        }
        stage('Third stage') { 
            steps {
               echo "Welcome DevOps"
            }
        }
    }
}

