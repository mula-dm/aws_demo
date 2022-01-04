variable "name" {
  type    = string
  default = "demo"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zones" {
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
  ]
}

variable "vpc_private_subnets" {
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

locals {
  tags = {
    "Project"    = var.name
    "Created_By" = "Terraform"
    "Notes"      = "Do_not_edit_it_manually"
  }
}

variable "ami" {
  type    = string
  default = "ami-0001a0d1a04bfcc30"
}

variable "ssh_key" {
  type    = string
  default = ""
}

