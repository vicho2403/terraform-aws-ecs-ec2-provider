# ----------------------------------------------------------------------------------------------------------------------
# ECS Cluster with task definitions and services
# 
# Created at: 2025-01-27
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-cluster-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster-ecs"
  }
}

module "autoscaling_group" {
  source = "./autoscaling_group"

  vpc_id           = var.vpc_id
  subnets          = var.public_subnets
  load_balancer_sg = try(aws_security_group.load_balancer_sg[0].id, "")
  ecs_cluster_name = aws_ecs_cluster.this.name
  asg_max_size     = var.asg_max_size
  asg_min_size     = var.asg_min_size
  project_name     = var.project_name
  instance_type    = var.node_instance_type
  environment      = var.environment
  instance_key     = var.instance_key
  public           = var.public
}

module "capacity_provider" {
  source = "./ecs_capacity_provider"

  project_name     = var.project_name
  ecs_cluster_name = aws_ecs_cluster.this.name
  asg_arn          = module.autoscaling_group.arn
  environment      = var.environment
}

# ----------------------------------------------------------------------------------------------------------------------
# IAM Role for ECS Task Definition
# ----------------------------------------------------------------------------------------------------------------------
module "aws_iam_ecs" {
  source = "./iam"

  name   = "${var.project_name}-${var.environment}-ECSTaskExecutionRole"
  assume = "ecs-tasks"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Task Definitions
# ----------------------------------------------------------------------------------------------------------------------
module "task_definitions" {
  source = "./task_definitions"

  for_each = var.definitions

  name             = each.key
  definition       = each.value
  exec_role_arn    = module.aws_iam_ecs.role_arn
  runtime_platform = var.runtime_platform
  network_mode     = var.network_mode
  environment      = var.environment
}

# ----------------------------------------------------------------------------------------------------------------------
# Service Discovery
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_service_discovery_private_dns_namespace" "private_namespace" {
  count = var.service_discovery_enabled && local.create_private_dns ? 1 : 0

  name        = "${lower(var.project_name)}-${lower(var.environment)}"
  description = "DNS Namespace for ${var.project_name}-${var.environment}-cluster-ecs ECS cluster"
  vpc         = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Security Group for ECS Services
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "default_service_sg" {
  count = local.create_default_security_group ? 1 : 0

  name   = "${var.project_name}-${var.environment}-ecs-service-default-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = local.create_load_balancer ? ["apply"] : []

    content {
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = [try(aws_security_group.load_balancer_sg[0].id, "")]
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-service-default-sg"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Services
# ----------------------------------------------------------------------------------------------------------------------
module "services" {
  source = "./services"

  for_each = module.task_definitions

  name                      = each.value.name
  task_definition_arn       = each.value.arn
  ecs_cluster_id            = aws_ecs_cluster.this.id
  subnets                   = var.public ? var.public_subnets : var.private_subnets
  definition                = var.definitions[each.key]
  private_namespace_id      = var.service_discovery_enabled ? aws_service_discovery_private_dns_namespace.private_namespace[0].id : null
  capacity_provider_name    = module.capacity_provider.name
  default_security_group_id = local.create_default_security_group ? aws_security_group.default_service_sg[0].id : ""
  network_mode              = var.network_mode
  service_discovery_enabled = var.service_discovery_enabled
  alb_target_group_arns = {
    for key, target_group in aws_alb_target_group.alb_target_group : key => target_group.arn
  }
}