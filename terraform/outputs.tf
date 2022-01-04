output "vpc_id" {
  value       = module.vpc.vpc_id
  description = ""
}

output "sg_id" {
  value       = aws_security_group.allow_web.id
  description = ""
}


