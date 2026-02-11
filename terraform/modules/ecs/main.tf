# ECS Task Definition
locals {
  environment_variables = [
    for name, value in var.container_environment : {
      name  = name
      value = value
    }
  ]
  secret_variables = [
    for name, value_from in var.container_secrets : {
      name      = name
      valueFrom = value_from
    }
  ]
  effective_execution_role_arn = var.execution_role_arn != null && var.execution_role_arn != "" ? var.execution_role_arn : aws_iam_role.ecs_task_execution[0].arn
  effective_task_role_arn      = var.task_role_arn != null && var.task_role_arn != "" ? var.task_role_arn : aws_iam_role.ecs_task[0].arn
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = local.effective_execution_role_arn
  task_role_arn            = local.effective_task_role_arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = "${var.ecr_repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
    environment = local.environment_variables
    secrets     = local.secret_variables
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.service.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "service" {
  name        = "${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 30
}

# IAM Roles
resource "aws_iam_role" "ecs_task_execution" {
  count = var.execution_role_arn != null && var.execution_role_arn != "" ? 0 : 1
  name  = "${var.service_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count      = var.execution_role_arn != null && var.execution_role_arn != "" ? 0 : 1
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  count = var.task_role_arn != null && var.task_role_arn != "" ? 0 : 1
  name  = "${var.service_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

data "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"
}

data "aws_region" "current" {}
