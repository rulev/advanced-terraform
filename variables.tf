### VARIABLES
#variable "project-id" {
#  type = string
#}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "zone" {
  type    = string
  default = "us-west-2b"
}

variable "subnet-name" {
  type    = string
  default = "subnet1"
}

variable "subnet-cidr" {
  type    = string
  default = "172.31.64.0/20"
}

variable "key-name" {
  type    = string
  default = "rulezz-ec2-kp"
}

variable "public-key" {
  type = string
  sensitive = true
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}

variable "ami-id" {
  type    = string
  default = "ami-0c1b4dff690b5d229"
}

variable "fw-port-map" {
  type = map(list(number))
  default = {
    "r1" = [80, 80]
    "r2" = [8080, 8080]
    "r3" = [1000, 2000]
    "r4" = [22, 22]
  }
}

variable "fw-port-list" {
  type = list(list(number))
  default = [
    [80, 80],
    [8080, 8080],
    [1000, 2000],
    [22, 22],
  ]
}

variable "fw-port-obj" {
  type = list(object({
    type = string
    low = number
    high = number
    proto = string
    cidr = list(string)
  }))

  default = [
    {type = "ingress", low = 0, high = 0, proto = "icmp", cidr = [ "0.0.0.0/0" ]},
    {type = "ingress", low = 80, high = 80, proto = "tcp", cidr = [ "0.0.0.0/0" ]},
    {type = "ingress", low = 8080, high = 8080, proto = "tcp", cidr = [ "0.0.0.0/0" ]},
    {type = "egress", low = 0, high = 0, proto = "-1", cidr = [ "0.0.0.0/0" ]},
  ]
}

variable "target-environment" {
  default = "DEV"
}

variable "environment-list" {
  type = list(string)
  default = ["DEV","QA","STAGE","PROD"]
}

variable "environment-map" {
  type = map(string)
  default = {
    "DEV" = "dev",
    "QA" = "qa",
    "STAGE" = "stage",
    "PROD" = "prod"
  }
}

variable "environment-machine-type" {
  type = map(string)
  default = {
    "DEV" = "t2-micro",
    "QA" = "t2-micro",
    "STAGE" = "t2-micro",
    "PROD" = "t2-small"
  }
}

variable "environment-instance-settings" {
  type = map(object({machine-type=string, labels=map(string)}))
  default = {
    "DEV" = {
      machine-type = "t2-micro"
      labels = {
        environment = "dev"
      }
    },
   "QA" = {
      machine-type = "t2-micro"
      labels = {
        environment = "qa"
      }
    },
    "STAGE" = {
      machine-type = "t2-micro"
      labels = {
        environment = "stage"
      }
    },
    "PROD" = {
      machine-type = "t2-small"
      labels = {
        environment = "prod"
      }
    }
  }
}