output "ssh_info" {
  description = "Instruction to ssh to EC2 instance"
  value       = "ssh -i ${local.pem_file} ec2-user@${aws_instance.ec2_instance_docker_enabled.public_ip}"
}
