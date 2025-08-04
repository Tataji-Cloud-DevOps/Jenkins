pipeline {
    agent any 
    environment { 
        ENV_URL= "Pipeline.google.com"        
        SSHCRED = credentials('SSHCRED')       
    }
    options {
     buildDiscarder(logRotator(numToKeepStr: '5'))
     disableConcurrentBuilds()
     timeout(time: 1, unit: 'MINUTES')
    }
    parameters {
        string(name: 'COMPONENT',defaultValue: 'mongodb',description:'Enter the component'
        text(name: 'BIOGRAPHY', defaultValue: '', description: 'Enter some information about the person')
        booleanParam(name: 'TOGGLE', defaultValue: true, description: 'Toggle this value')
        choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')
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
                 ENV_URL= "Pipeline.google.com"  
           }
            steps {
                sh "echo Welcome Tataji"
                sh "echo ${ENV_URL}" 
                sh "env"                  s
            }
        }
        stage('Third stage') { 
            steps {
               echo "Welcome DevOps"
            }
        }
    }
}