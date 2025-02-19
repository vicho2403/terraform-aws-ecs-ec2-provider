# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "Name of the task definition"
  type        = string
}

variable "definition" {
  description = "Definition of task definition"
  type        = any
}

variable "exec_role_arn" {
  description = "Task execution role arn"
  type        = string
}

variable "runtime_platform" {
  description = "Runtime configuration for task definition"
  type = object({
    cpu_architecture        = string
    operating_system_family = string
  })
}

variable "network_mode" {
  description = "Network mode for task definition network configuration"
  type        = string
}

variable "environment" {
  type = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters are useful for additional customization. Otherwise, they default to sane values.
# ----------------------------------------------------------------------------------------------------------------------
variable "log_driver" {
  description = "Log driver"
  type        = string
  default     = "awslogs"
}

variable "task_role_arn" {
  description = "Task role arn "
  type        = string
  default     = ""
}