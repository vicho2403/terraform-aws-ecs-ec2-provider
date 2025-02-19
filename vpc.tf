module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "${local.name_prefix}"
  cidr = var.cidr

  azs              = [ for index in range(local.max_subnets) : element(local.azs, index) ]
  private_subnets  = var.private_cidrs
  public_subnets   = var.public_cidrs
  database_subnets = var.database_cidrs

  create_database_subnet_group = true

  default_vpc_name            = "${local.name_prefix}-default-vpc"
  default_route_table_name    = "${local.name_prefix}-default-rtb"
  default_security_group_name = "${local.name_prefix}-default-sg"

  create_igw = true
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name        = "${local.name_prefix}-vpc-endpoints"
  security_group_description = "VPC endpoint security group"
  
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags            = { Name = "${local.name_prefix}-s3-vpce" }
    }
  }
}