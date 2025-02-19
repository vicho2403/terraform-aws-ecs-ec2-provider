# ----------------------------------------------------------------------------------------------------------------------
# Services
# 
# Created at: 2025-01-27
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ecs_service" "services" {
  name    = "${var.name}-service"
  cluster = var.ecs_cluster_id

  task_definition = var.task_definition_arn
  desired_count   = var.definition.desired_count

  dynamic "network_configuration" {
    for_each = contains(["awsvpc"], var.network_mode) ? ["apply"] : []

    content {
      assign_public_ip = var.definition.public
      security_groups  = length(try(var.definition.security_groups, [])) == 0 ? tolist([var.default_security_group_id]) : var.definition.security_groups
      subnets          = var.subnets
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_enabled && try(var.definition.discovery.type, "A") == "A" ? ["apply"] : []

    content {
      registry_arn = module.discovery[0].arn
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_enabled && try(var.definition.discovery.type, "A") != "A" ? ["apply"] : []

    content {
      registry_arn   = module.discovery[0].arn
      container_name = var.definition.containers[0].name
      container_port = var.definition.containers[0].port
    }
  }

  dynamic "load_balancer" {
    for_each = {
      for container in var.definition.containers : container.name => container.port if contains(keys(container), "load_balancer")
    }

    content {
      target_group_arn = var.alb_target_group_arns[load_balancer.key]
      container_name   = load_balancer.key
      container_port   = load_balancer.value
    }
  }

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    base              = var.strategy_base
    weight            = var.strategy_weight
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "${var.name}-service"
  }
}

module "discovery" {
  source = "./discovery"

  count = var.service_discovery_enabled && contains(keys(var.definition), "discovery") ? 1 : 0

  private_namespace_id = var.private_namespace_id
  name                 = var.name
  type                 = try(var.definition.discovery.type, "A")
  ttl                  = try(var.definition.discovery.ttl, 15)
}