variable "my_ip" {
  description = "Enter your Dev Environment IP ('curl ifconfig.me' is one way to obtain it):"
  type        = string
}

variable "ami_id" {
  description = "AMI used for the EC2 instances"
  type        = string
  default     = "ami-0aa7d40eeae50c9a9"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "tags_docker_instance" {
  description = "Tags for Docker enabled instance"
  type        = map(string)
  default = {
    Name = "docker-instance"
  }
}

variable "tags_docker_general_sg" {
  description = "Tags for general SG for Docker Instance"
  type        = map(string)
  default = {
    Name = "docker-general-sg"
  }
}
