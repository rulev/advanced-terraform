### OUTPUTS ###
output "nginx-public-ip" {
  value = aws_instance.nginx_instance.public_ip
}

output "web-private-ips" {
  value = aws_instance.web-instances[*].public_ip
}