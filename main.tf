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
resource "aws_key_pair" "rulezz-ec2-kp" {
  key_name = "rulezz-ec2-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuZCC/1xyUVIrKueDGZ9YsQmo4AgP0T1Ms5JQBlCY/G3W6qjlP/sGGf1wm/6fYIbhBEvEAU9JvaAnSkMq7wyMzonqyH+/f8kTW7hwuADO0+S9Y8RF/Y3l34O0LjZneChAZ/vGSruHAo0/zrS+8yH+MkQ5Lj0C3cI6yWXqW15GoKGQDsC+TZSFfcxTCJpq66rNlVLexRX9btuxJ+rV+NDC92JcZ/QCEWZ/VDNvSvLKxRo/NBLdVp/jcmj6UTl/CO+ipAjFI8A6HOdIyldKkzO5UaGDCcMKQvFQ0uKureHZKO/lp14DUe072fLlMN6wL4EICp9Y82FPB46AOfzEN7BaF rulezz-ec2-kp"
}

## SUBNET
resource "aws_subnet" "subnet-1" {
  vpc_id     = data.aws_vpc.default_vpc.id
  cidr_block = "172.31.64.0/20"

  tags = {
    Name = "subnet1"
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
  ami                         = "ami-0c1b4dff690b5d229"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.default.name]
  subnet_id                   = aws_subnet.subnet-1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.rulezz-ec2-kp.key_name

  tags = {
    Name = "nginx-proxy"
  }
}

## WEB1
resource "aws_instance" "web1" {
  # ami             = data.aws_ami.debian-11.id
  ami                         = "ami-0c1b4dff690b5d229"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.default.name]
  subnet_id                   = aws_subnet.subnet-1.id
  key_name                    = aws_key_pair.rulezz-ec2-kp.key_name

  tags = {
    Name = "web1"
  }
}

## DB
resource "aws_instance" "mysqldb" {
  # ami             = data.aws_ami.debian-11.id
  ami                         = "ami-0c1b4dff690b5d229"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.default.name]
  subnet_id                   = aws_subnet.subnet-1.id
  key_name                    = aws_key_pair.rulezz-ec2-kp.key_name

  tags = {
    Name = "mysqldb"
  }
}
