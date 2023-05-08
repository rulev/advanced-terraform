locals {
  prefix = var.prefix != ""? "${var.prefix}-": ""
}

## WEB
resource "aws_instance" "web-instances" {
  count = var.instances-count

  ami                         = var.ami-id
  instance_type               = var.instance-type
  security_groups             = [var.sg]
  subnet_id                   = var.subnet
  key_name                    = var.key-name

  tags = {
    Name        = "${local.prefix}web${count.index}"
    environment = var.env
  }
}
