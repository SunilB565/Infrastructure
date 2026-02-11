variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "task_cpu" {
  type = string
}

variable "task_memory" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "execution_role_arn" {
  type    = string
  default = null
}

variable "task_role_arn" {
  type    = string
  default = null
}

variable "container_environment" {
  type    = map(string)
  default = {}
}

variable "container_secrets" {
  type    = map(string)
  default = {}
}

variable "health_check_path" {
  type    = string
  default = "/api/v1/health"
}

output "target_group_arn" {
  value = aws_lb_target_group.service.arn
}
