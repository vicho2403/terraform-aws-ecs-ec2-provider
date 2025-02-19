# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------
variable "name" {
  type = string
}

variable "definition" {
  description = "Definition of task definition"
  type        = any
}

variable "task_definition_arn" {
  description = "Task definition ARN"
  type        = string
}

variable "subnets" {
  description = "List of subnets"
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "private_namespace_id" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "default_security_group_id" {
  description = "Default security group ID in case the definition doesn't contains one"
  type        = string
}

variable "alb_target_group_arns" {
  description = "List of application load balancer target group ARNs"
  type        = map(string)
}

variable "network_mode" {
  type = string
}

variable "service_discovery_enabled" {
  type = bool
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters are useful for additional customization. Otherwise, they default to sane values.
# ----------------------------------------------------------------------------------------------------------------------
variable "strategy_base" {
  type    = number
  default = 1
}

variable "strategy_weight" {
  type    = number
  default = 100
}