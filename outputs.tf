### OUTPUTS ###
output "nginx-public-ip" {
  value = aws_instance.nginx_instance.public_ip
}
