output "vpc_id" {
  value       = module.vpc.vpc_id
  description = ""
}

output "subnet_id" {
  value       = module.vpc.private_subnets
  description = ""
}

output "sg_id" {
  value       = aws_security_group.allow_web.id
  description = ""
}

output "route53_zone_id" {
  value       = aws_route53_zone.primary.zone_id
  description = ""
}

output "acm_arn" {
  value       = aws_acm_certificate.acm_cert.id
  description = ""
}

output "ec2_id" {
  value       = module.ec2_instance.id
  description = ""
}

# output "elb_dns" {
#   value       = aws_elb.elb.dns_name
#   description = ""
# }
