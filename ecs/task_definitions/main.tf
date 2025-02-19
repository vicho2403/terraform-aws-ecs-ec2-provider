# ----------------------------------------------------------------------------------------------------------------------
# Task Definitions
# 
# Created at: 2025-01-27
# ----------------------------------------------------------------------------------------------------------------------
locals {
  region = data.aws_region.current.name
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-${var.environment}-task"
  cpu                      = var.definition.cpu
  memory                   = var.definition.memory
  network_mode             = try(var.definition.network_mode, var.network_mode)
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.exec_role_arn
  requires_compatibilities = try([var.definition.launch_type], [])

  runtime_platform {
    cpu_architecture        = try(var.definition.runtime_platform.cpu_architecture, var.runtime_platform.cpu_architecture)
    operating_system_family = try(var.definition.runtime_platform.operating_system_family, var.runtime_platform.operating_system_family)
  }

  container_definitions = jsonencode([for container in var.definition.containers :
    {
      name  = container.name
      image = container.image
      portMappings = [
        {
          name          = "${container.name}-${var.environment}-${container.port}-tcp"
          containerPort = container.port
          hostPort      = container.port
          protocol      = container.protocol
        }
      ],
      essential = true
      logConfiguration = {
        logDriver = var.log_driver
        options = {
          awslogs-group         = "/ecs/${var.environment}/${var.name}"
          awslogs-region        = local.region
          awslogs-stream-prefix = container.name
        }
      }
    }
  ])

  tags = {
    Name = "${var.name}-${var.environment}-task"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  count = var.log_driver == "awslogs" ? 1 : 0

  name              = "/ecs/${var.environment}/${var.name}"
  retention_in_days = 7
}