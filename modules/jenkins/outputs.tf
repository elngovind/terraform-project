output "jenkins_instance_id" {
  description = "Jenkins instance ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Jenkins public IP address"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Jenkins private IP address"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.jenkins.public_ip}"
}