# ----------------------------------------------------------------------------------------------------------------------
# ECS Capacity Provider
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_capacity_provider" "this" {
  name = "${var.project_name}-${var.environment}-ecs-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.asg_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = var.max_scaling
      minimum_scaling_step_size = var.min_scaling
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-ec2-capacity-provider"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    base              = var.strategy_base
    weight            = var.strategy_weight
  }
}