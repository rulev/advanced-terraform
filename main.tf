## AMI
data "aws_ami" "debian-11" {
  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners      = ["amazon"]
  most_recent = true
}

## VPC
data "aws_vpc" "default_vpc" {
  default = true
}

## Key pair
resource "aws_key_pair" "ec2-kp" {
  key_name   = var.key-name
  public_key = var.public-key
}

## SUBNET
resource "aws_subnet" "subnet-1" {
  vpc_id            = data.aws_vpc.default_vpc.id
  cidr_block        = var.subnet-cidr
  availability_zone = var.zone

  tags = {
    Name = var.subnet-name
  }
}

resource "aws_security_group" "default" {
  name = "test-firewall"

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 1000
  #   to_port     = 2000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

# resource "aws_security_group_rule" "ingress_rules" {
#   count = length(var.fw-port-list)
#   security_group_id = aws_security_group.default.id
#   from_port = var.fw-port-list[count.index][0]
#   to_port = var.fw-port-list[count.index][1]
#   cidr_blocks = ["0.0.0.0/0"]
#   protocol = "tcp"
#   type = "ingress"
# }

# resource "aws_security_group_rule" "extra_rules" {
#   for_each = var.fw-port-map
#   security_group_id = aws_security_group.default.id
#   description = each.key
#   from_port = each.value[0]
#   to_port = each.value[1]
#   cidr_blocks = ["0.0.0.0/0"]
#   protocol = "tcp"
#   type = "ingress"
# }

resource "aws_security_group_rule" "combined_rules" {
  count = length(var.fw-port-obj)
  security_group_id = aws_security_group.default.id
  type = var.fw-port-obj[count.index].type
  from_port = var.fw-port-obj[count.index].low
  to_port = var.fw-port-obj[count.index].high
  cidr_blocks = var.fw-port-obj[count.index].cidr
  protocol = var.fw-port-obj[count.index].proto
}

### COMPUTE
## NGINX PROXY
resource "aws_instance" "nginx_instance" {
  # ami             = data.aws_ami.debian-11.id
  ami                         = var.ami-id
  instance_type               = var.environment-machine-type[var.target-environment]
  security_groups             = [aws_security_group.default.name]
  subnet_id                   = aws_subnet.subnet-1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2-kp.key_name

  tags = {
    Name        = "nginx-proxy"
    environment = var.environment-map[var.target-environment]
  }
}

## WEB
module "web_nst" {
  source = "./modules/web-instances"
  subnet = aws_subnet.subnet-1.id
  sg = aws_security_group.default.name
  key-name = aws_key_pair.ec2-kp.key_name
}

## DB
resource "aws_instance" "mysqldb" {
  # ami             = data.aws_ami.debian-11.id
  ami                         = var.ami-id
  instance_type               = var.environment-machine-type[var.target-environment]
  security_groups             = [aws_security_group.default.name]
  subnet_id                   = aws_subnet.subnet-1.id
  key_name                    = aws_key_pair.ec2-kp.key_name

  tags = {
    Name        = "mysqldb"
    environment = var.environment-map[var.target-environment]
  }
}
