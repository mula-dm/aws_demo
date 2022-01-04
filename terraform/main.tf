# VPC
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"
  name = var.name
  cidr = var.vpc_cidr

  # The number of public subnet CIDR blocks specified in public_subnets must be greater
  # than or equal to the number of availability zones specified in var.azs.
  # This is to ensure that each NAT Gateway has a dedicated public subnet to deploy to.
  azs             = var.availability_zones

  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = local.tags
}

#Confogure security group
resource "aws_security_group" "allow_web" {
  name        = join("_", [var.name, "allow_web"])
  description = "Allow http and https inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = local.tags
}