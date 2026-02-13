terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- AMI ---

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- SSH Key Pair ---

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cdc_prototype" {
  key_name   = "cdc-prototype-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/cdc-prototype-key.pem"
  file_permission = "0400"
}

# --- Security Group ---

resource "aws_security_group" "cdc_prototype" {
  name        = "cdc-prototype-sg"
  description = "Security group for TM Lending CDC Prototype"

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # Kafka UI
  ingress {
    description = "Kafka UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # Kafka Connect REST API
  ingress {
    description = "Kafka Connect"
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # SQL Server
  ingress {
    description = "SQL Server"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cdc-prototype-sg"
  }
}

# --- EC2 Instance ---

resource "aws_instance" "cdc_prototype" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cdc_prototype.key_name
  vpc_security_group_ids = [aws_security_group.cdc_prototype.id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  user_data = <<-USERDATA
    #!/bin/bash
    set -ex

    # Install Docker
    dnf update -y
    dnf install -y docker git
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Install Docker Compose plugin
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # Clone the repo
    cd /home/ec2-user
    git clone ${var.repo_url} tm-lending-cdc-prototype
    chown -R ec2-user:ec2-user tm-lending-cdc-prototype
    cd tm-lending-cdc-prototype

    # Create .env from example
    cp .env.example .env

    # Run setup as ec2-user (Docker needs group membership)
    sudo -u ec2-user sg docker -c "bash scripts/setup.sh"

    # Write completion marker
    echo "Setup completed at $(date)" > /home/ec2-user/setup-complete.txt
    chown ec2-user:ec2-user /home/ec2-user/setup-complete.txt
  USERDATA

  tags = {
    Name = "cdc-prototype"
  }
}
