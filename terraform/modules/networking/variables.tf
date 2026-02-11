variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "existing_vpc_id" {
  type    = string
  default = ""
}

variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnet_ids" {
  value = local.effective_private_ids
}

output "public_subnet_ids" {
  value = local.effective_public_ids
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

output "alb_id" {
  value = aws_lb.alb.id
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_listener_arn" {
  value = aws_lb_listener.http.arn
}
