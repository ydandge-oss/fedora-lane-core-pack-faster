output "public_ip" {
  value = aws_instance.fl_poc.public_ip
}

output "public_dns" {
  value = aws_instance.fl_poc.public_dns
}

output "instance_id" {
  value = aws_instance.fl_poc.id
}

output "ssh_example" {
  value = "ssh -i <your-private-key.pem> ec2-user@${aws_instance.fl_poc.public_ip}"
}

output "health_url" {
  value = "http://${aws_instance.fl_poc.public_ip}:8080/health"
}

output "site_label" {
  value = "aws-${var.aws_region}"
}
