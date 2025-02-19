variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "asg_max_size" {
  description = "A short description"
  type = number
  default = 1
}

variable "asg_min_size" {
  description = "A short description"
  type = number
  default = 1
}

variable "definitions" {
  description = "A short description"
  type = any
}

variable "project_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}
variable "environment" {
  type = string
}

variable "node_instance_type" {
  type = string
}

variable "cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "database_cidrs" {
  type = list(string)
}

variable "instance_key" {
  type    = string
  default = ""
}

variable "public" {
  type    = bool
  default = false
}

variable "network_mode" {
  type    = string
  default = "awsvpc"
}