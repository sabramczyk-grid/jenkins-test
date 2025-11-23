terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Owner   = "sabramczyk"    
      Project = "mle-internship" 
    }
  }
}

resource "aws_security_group" "web_sg" {
  name        = "jenkins-demo-sg"
  description = "Allow SSH inbound traffic"

  # allow inbound SSH traffic from anywhere (0.0.0.0/0)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # flask port
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sabramczyk-security-group"
  }
}

# download Amazon Linux image
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

# EC2 instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "sabramczyk-key"

  tags = {
    Name = "sabramczyk-server"
  }
}

output "instance_public_ip" {
  description = "Server public IP address"
  value       = aws_instance.app_server.public_ip
}