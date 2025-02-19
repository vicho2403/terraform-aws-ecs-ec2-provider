locals {
  common_tags = {
    Terraform   = true
    Project     = var.project_name
    Environment = var.environment
  }

  name_prefix = "${var.project_name}-${var.environment}"

  max_subnets = max(
    length(var.public_cidrs),
    length(var.private_cidrs)
  )
}