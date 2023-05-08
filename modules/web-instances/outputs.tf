output "web-private-ips" {
  value = aws_instance.web-instances[*].public_ip
}