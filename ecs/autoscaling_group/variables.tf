variable "vpc_id" {
  type = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  #default = "t3.micro"
}

variable "instance_key" {
  description = "SSH key"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "project_name" {
  type = string
}

variable "subnets" {
  description = "Subnet ID to place on vpc_zone_identifier"
  type        = list(string)
}

variable "asg_min_size" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "health_check_grace_period" {
  type    = number
  default = 0
}
variable "health_check_type" {
  type    = string
  default = "EC2"
}
variable "protect_from_scale_in" {
  type    = bool
  default = false
}

variable "environment" {
  type = string
}

variable "load_balancer_sg" {
  type    = string
  default = ""
}

variable "public" {
  type = bool
  default = false
}