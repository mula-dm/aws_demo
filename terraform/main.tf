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