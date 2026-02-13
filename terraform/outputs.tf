output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.cdc_prototype.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.cdc_prototype.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.cdc_prototype.public_ip}"
}

output "kafka_ui_url" {
  description = "URL for Kafka UI"
  value       = "http://${aws_instance.cdc_prototype.public_ip}:8080"
}

output "private_key_file" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key.filename
}
