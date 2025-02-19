
module "ecs" {
  source = "./ecs"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  asg_max_size = var.asg_max_size
  asg_min_size = var.asg_min_size

  definitions = var.definitions

  vpc_id          = module.vpc.vpc_id
  public          = var.public
  network_mode    = var.network_mode 
  public_subnets  = [ for subnet in module.vpc.public_subnets : subnet ]
  private_subnets = [ for subnet in module.vpc.private_subnets : subnet ]

  certificate_arn = var.certificate_arn

  node_instance_type = var.node_instance_type
  instance_key       = var.instance_key
}