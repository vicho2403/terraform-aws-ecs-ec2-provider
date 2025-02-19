# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------
variable "assume" {
  description = "Policy collection key described in data.tf"
  type        = string
}

variable "name" {
  description = "Name of the role which will be created"
  type        = string
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "policies" {
  type    = list(string)
  default = []
}