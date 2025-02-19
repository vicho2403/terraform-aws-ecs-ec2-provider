# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------
variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "private_subnets" {
  description = "List of subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of subnets"
  type        = list(string)
}

variable "definitions" {
  description = "List of ECS task definitions"
  type        = any
}

variable "vpc_id" {
  description = "ID of the VPC where this resource will be allocated"
  type        = string
}

variable "asg_min_size" {
  description = "Autoscaling group min sizevalue"
  type        = number
}

variable "asg_max_size" {
  description = "Autoscaling group max size"
  type        = number
}

variable "node_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "certificate_arn" {
  description = "SSL certificate ARN"
  type        = string
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters are useful for additional customization. Otherwise, they default to sane values.
# ----------------------------------------------------------------------------------------------------------------------
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "network_mode" {
  description = "Network mode for task definition network configuration"
  type        = string
  default     = "awsvpc"
}

variable "runtime_platform" {
  description = "Runtime configuration for task definition"
  type = object({
    cpu_architecture        = string
    operating_system_family = string
  })
  default = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

variable "service_discovery_enabled" {
  description = "Choose wheter service discovery service is enabled or not"
  type        = bool
  default     = false
}

variable "instance_key" {
  description = "SSH key name"
  type        = string
  default     = ""
}

variable "public" {
  type    = bool
  default = false
}