#
# Terraform IaC to create an EC2 instance with Docker and KIND enabled Kubernetes cluster.
# Reference - https://medium.com/the-aws-way/the-aws-way-iac-in-action-a-docker-and-kind-ready-amazon-ec2-node-a0e2d907f9ec
# Three essential commands to get started. For more see blog above.
# 1. git clone https://github.com/jdluther2020/terraform-ec2-with-docker-and-kind.git
# 2. terraform apply -auto-approve -var my_ip=$(curl -s ifconfig.me)
# 3. terraform apply -destroy -var my_ip=$(curl -s ifconfig.me)
#
# Terraform AWS Provider - https://registry.terraform.io/providers/hashicorp/aws/latest/docs
#
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Defile any local vars
locals {
  pem_file = "~/.ssh/docker-kind-kp.pem"
  key_name = "docker-kp"
}


# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      rm -rf ${local.pem_file}
      echo '${tls_private_key.rsa_key.private_key_pem}' > ${local.pem_file}
      chmod 400 ${local.pem_file}
      ls -l ${local.pem_file} > /tmp/out
    EOT
  }
}

resource "aws_security_group" "docker_general_sg" {
  name        = "docker-general-sg"
  description = "General SG for Docker Instance"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TCP"
    from_port   = 8080
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags_docker_general_sg
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2_instance_docker_enabled" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.docker_general_sg.id]
  user_data              = file("scripts/user_data.sh")
  tags                   = var.tags_docker_instance
}
