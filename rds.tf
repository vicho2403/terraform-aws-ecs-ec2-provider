module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-${var.environment}-postgresql-rds"

  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "venturest"
  username = "postgres"
  port     = 5432

  password = random_password.password.result
  manage_master_user_password = false

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = false

  tags = {
    Name = "${var.project_name}-${var.environment}-postgresql-rds"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "${var.project_name}-${var.environment}-rds-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!*-_=+<>?"

  lifecycle {
    ignore_changes = [override_special]
  }
}