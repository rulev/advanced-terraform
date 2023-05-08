variable "instances-count" {
  type = number
  default = 1
}

variable "ami-id" {
  type = string
  default = "ami-0c1b4dff690b5d229"
}

variable "instance-type" {
  type = string
  default = "t2.micro"
}

variable "prefix" {
  type = string
  default = ""
}

variable "subnet" {
  type = string
}

variable "sg" {
  type = string
}

variable "key-name" {
  type = string
  default = ""
}

variable "env" {
  type = string
  default = "dev"
}