variable "asg_arn" { # aws_autoscaling_group.ecs.arn
  type = string
}

variable "project_name" {
  type = string
}

variable "max_scaling" {
  type    = number
  default = 2
}

variable "min_scaling" {
  type    = number
  default = 1
}

variable "target_capacity" {
  type    = number
  default = 100
}

variable "ecs_cluster_name" {
  type = string
}

variable "strategy_base" {
  type    = number
  default = 1
}

variable "strategy_weight" {
  type    = number
  default = 100
}

variable "environment" {
  type = string
}