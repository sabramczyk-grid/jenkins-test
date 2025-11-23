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
                    args '--entrypoint=""'
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
                    // use image with SSH client
                    image 'alpine:latest' 
                } 
            }
            steps {
                script {
                    // install SSH client in container
                    sh 'apk add --no-cache openssh-client bash'
                    
                    // read server IP from file created by Terraform
                    def server_ip = readFile('server_ip.txt').trim()
                    echo "Deploying to Server IP: ${server_ip}"

                    // use sshagent with our key
                    sshagent(['ec2-ssh-key']) {
                        // 1. Turn off host checking (StrictHostKeyChecking), because IP is new
                        // 2. Copy app files
                        sh "scp -o StrictHostKeyChecking=no helloworld.py requirements.txt ec2-user@${server_ip}:/home/ec2-user/"
                        
                        // 3. Log in and start the app 
                        // - Install pip
                        // - Install requirements
                        // - Kill old app instance (if running)
                        // - Start new app in the background (nohup)
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${server_ip} '
                                sudo dnf install -y python3-pip &&
                                pip3 install -r requirements.txt &&
                                pkill -f helloworld.py || true &&
                                nohup python3 helloworld.py > flask.log 2>&1 &
                            '
                        """
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