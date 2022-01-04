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

  enable_nat_gateway = true
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

# Create route53 zone
resource "aws_route53_zone" "primary" {
  name = join(".", [var.name, "local"])
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = join(".", ["@", var.name, "local"])
  type    = "CNAME"
  ttl     = "300"
  records = [module.alb.lb_dns_name]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = join(".", ["www", var.name, "local"])
  type    = "CNAME"
  ttl     = "300"
  records = [module.alb.lb_dns_name]
}

# Create self signed ssl cert
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "self_signed_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.tls_key.private_key_pem
  subject {
    common_name  = join(".", [var.name, "local"])
    organization = var.name
  }
  validity_period_hours = 12
  allowed_uses = [
    "server_auth",
  ]
}

# Import self signed ssl to acm
resource "aws_acm_certificate" "acm_cert" {
  private_key      = tls_private_key.tls_key.private_key_pem
  certificate_body = tls_self_signed_cert.self_signed_cert.cert_pem
}

# Import ssh key
resource "aws_key_pair" "ssh_key" {
  key_name   = var.name
  public_key = var.ssh_key
}

# Creat ec2 instance for testing
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = var.name
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = var.name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = element(module.vpc.private_subnets, 1)
  tags = local.tags
}

# Create Load balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"
  name               = join("-", [var.name, "alb"])
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.allow_web.id]
  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = module.ec2_instance.id
          port = 80
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate.acm_cert.id
      target_group_index = 0
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = local.tags
}