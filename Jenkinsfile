pipeline {
    agent any

    environment {
        // set AWS region
        AWS_DEFAULT_REGION = 'eu-north-1' 
    }

    stages {
        // --- STAGE 1: CI (Python) ---
        stage('Install & Test') {
            agent { 
                docker { 
                    image 'python:3.10-slim' 
                    args '--env HOME=${WORKSPACE}' 
                } 
            }
            steps {
                sh 'python -m pip install -r requirements.txt'
                sh 'python -m flake8 helloworld.py tests/'
                sh 'python -m pytest'
            }
        }

        // --- STAGE 2: Infrastructure (Terraform) ---
        stage('Terraform Apply') {
            agent { 
                docker { 
                    image 'hashicorp/terraform:latest'
                    args '--entrypoint="" -u 0'
                } 
            }            
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                        // save IP to file to use it in the next stage
                        sh 'terraform output -raw instance_public_ip > ../server_ip.txt'
                    }
                }
            }
        }

        // --- STAGE 3: Deployment (SSH) ---
        stage('Deploy to EC2') {
            agent { 
                docker { 
                    image 'alpine:latest' 
                    args '-u 0'
                } 
            }
            steps {
                script {
                    sh 'apk add --no-cache openssh-client bash'
                    
                    def server_ip = readFile('server_ip.txt').trim()
                    echo "Deploying to Server IP: ${server_ip}"

                    // 1. Tworzymy skrypt deployu lokalnie
                    // To jest bezpieczniejsze niż wpisywanie komend w 'ssh'
                    sh """
                        echo '#!/bin/bash' > deploy.sh
                        echo 'sudo dnf install -y python3-pip' >> deploy.sh
                        echo 'pip3 install -r requirements.txt' >> deploy.sh
                        echo 'pkill -f helloworld.py || true' >> deploy.sh
                        echo 'nohup python3 helloworld.py > flask.log 2>&1 < /dev/null &' >> deploy.sh
                        echo 'echo "App started successfully!"' >> deploy.sh
                        echo 'exit 0' >> deploy.sh
                    """

                    sshagent(['ec2-ssh-key']) {
                        // 2. Kopiujemy pliki aplikacji ORAZ skrypt deployu
                        sh "scp -o StrictHostKeyChecking=no helloworld.py requirements.txt deploy.sh ec2-user@${server_ip}:/home/ec2-user/"
                        
                        // 3. Uruchamiamy skrypt na serwerze
                        // Dzięki temu SSH czeka tylko na koniec skryptu bash, a nie na proces Pythona
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${server_ip} 'bash deploy.sh'"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Deployment Successful! Check your AWS Console for the IP."
        }
    }
}