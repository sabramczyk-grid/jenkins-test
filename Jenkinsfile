pipeline {
    agent { 
        docker { 
            image 'python:3.10-slim' 
            args '--env HOME=${WORKSPACE}'
        } 
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies from requirements.txt...'
                sh 'python -m pip install -r requirements.txt'
            }
        }
        
        stage('Lint Code') { 
            steps {
                echo 'Linting code with flake8...'
                sh 'python -m flake8 helloworld.py tests/'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests with pytest...'
                sh 'python -m pytest'
            }
        }

        stage('Deploy') { 
            steps {
                echo 'Deploying the application...'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}