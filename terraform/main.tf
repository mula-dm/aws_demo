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

# Create route53 zone
resource "aws_route53_zone" "primary" {
  name = join(".", [var.name, "local"])
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

# import self signed ssl to acm
resource "aws_acm_certificate" "acm_cert" {
  private_key      = tls_private_key.tls_key.private_key_pem
  certificate_body = tls_self_signed_cert.self_signed_cert.cert_pem
}

resource "aws_elb" "elb" {
  name               = join("-", [var.name, "elb"])
  availability_zones = var.availability_zones

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 443
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.acm_cert.id
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  # instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = local.tags
}