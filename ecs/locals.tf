locals {
  common_tags = {
    IaC         = "Terraform"
    Project     = var.project_name
    Environment = var.environment
  }

  # Crear SG si alguno se registra
  create_default_security_group = length([
    for key, definition in var.definitions :
    key if length(lookup(definition, "security_groups", [])) == 0
  ]) > 0

  # Crear LB si alguno se registra (existe load_balancer)
  create_load_balancer = length([
    for key, definition in var.definitions :
    key if contains(keys(definition), "load_balancer") != 0
  ]) > 0

  # Crear Namespace si alguno se registra (existe discovery)
  create_private_dns = length([
    for key, definition in var.definitions :
    key if contains(keys(definition), "discovery") != 0
  ]) > 0

  target_groups = local.create_load_balancer ? {
    for target in flatten([
      for name, service in var.definitions : [
        for container in service.containers : [
          {
            name         = container.name
            paths        = try(container.load_balancer.paths, [])
            priority     = try(container.load_balancer.priority, 0)
            health       = try(container.load_balancer.health, "/")
            network_mode = try(container.network_mode, var.network_mode)
          }
        ] if contains(keys(container), "load_balancer")
      ]
    ]) : target.name => target
  } : {}
}