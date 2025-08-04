pipeline {
    agent any 
    environment { 
        ENV URL = "Pipeline.google.com"        
        SSHCRED = credentials('SSHCRED')       
    }
    options {
     buildDiscarder(logRotator(numToKeepStr: '5'))
     disableConcurrentBuilds()
     timeout(time: 1, unit: 'MINUTES')
    }
    parameters {
        string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
        text(name: 'BIOGRAPHY', defaultValue: '', description: 'Enter some information about the person')
        booleanParam(name: 'TOGGLE', defaultValue: true, description: 'Toggle this value')
        choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')
    }
    tools {
        maven 'apache-maven-395'
    }
    stages {
        stage('First stage') { 
            steps {
               sh "echo Welcome world!" 
               sh "echo ${ENV_URL}"
               sh "mvn --version"
            }
        }
        stage('Second stage') { 
             environment { 
                 ENV URL = "Pipeline.google.com"  
           }
           tools {
               maven 'apache-maven-398'
    }
            steps {
                sh "echo Welcome Tataji"
                sh "echo ${ENV_URL}" 
                sh "env"                  
                sh "mvn --version"
            }
        }
        stage('Third stage') { 
            steps {
               echo "Welcome DevOps"
            }
        }
    }
}
