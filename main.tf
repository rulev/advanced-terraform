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

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1000
    to_port     = 2000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

## WEB1
resource "aws_instance" "web-instances" {
  # ami             = data.aws_ami.debian-11.id
  count = 1

  ami                         = var.ami-id
  instance_type               = var.environment-machine-type[var.target-environment]
  security_groups             = [aws_security_group.default.name]
  subnet_id                   = aws_subnet.subnet-1.id
  key_name                    = aws_key_pair.ec2-kp.key_name

  tags = {
    Name        = "web${count.index}"
    environment = var.environment-map[var.target-environment]
  }
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
