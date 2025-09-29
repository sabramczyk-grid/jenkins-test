pipeline {
    agent { docker { image 'python:3.10-slim' } }

    environment {
        PATH = "$HOME/.local/bin:$PATH"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies from requirements.txt...'
                sh 'pip install -r requirements.txt'
            }
        }
        
        stage('Lint Code') { 
            steps {
                echo 'Linting code with flake8...'
                sh 'flake8 .'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests with pytest...'
                sh 'pytest'
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