# ----------------------------------------------------------------------------------------------------------------------
# Set IAM Role for EC2
# ----------------------------------------------------------------------------------------------------------------------
module "ecs_node_role" {
  source = "../iam"

  name   = "${var.project_name}-${var.environment}-ECSNodeRole"
  assume = "ec2"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
  policies = ["multiple_enis"]
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project_name}-${var.environment}-ecs-node-profile"
  path = "/ecs/instance/"
  role = module.ecs_node_role.role_name

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-node-profile"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Get latest Amazon Linux 2023 AMI
# ----------------------------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Security Group for ECS Node
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "ecs_node_sg" {
  name   = "${var.project_name}-${var.environment}-ecs-node-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.load_balancer_sg != "" ? ["apply"] : []

    content {
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = [var.load_balancer_sg]
    }
  }

  lifecycle {
    ignore_changes = [ingress]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-node-sg"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Launch Template Resource
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "ecs_ec2_launch_template" {
  name                   = "${var.project_name}-${var.environment}-ecs-ec2-node"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = var.instance_type
  key_name               = var.instance_key
  vpc_security_group_ids = var.public ? [] : [aws_security_group.ecs_node_sg.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile.arn
  }

  monitoring {
    enabled = true
  }

  dynamic "network_interfaces" {
    for_each = var.public ? ["apply"] : []
    
    content {
      security_groups = [aws_security_group.ecs_node_sg.id]
      associate_public_ip_address = var.public
    }
  }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      aws ecs put-account-setting --name awsvpcTrunking --value enabled --region ${data.aws_region.current.name}
      echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;
    EOF
  )

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-ec2-node"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Auto Scaling Group
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.project_name}-${var.environment}-ecs-asg"
  vpc_zone_identifier       = var.subnets
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  protect_from_scale_in     = var.protect_from_scale_in

  launch_template {
    id      = aws_launch_template.ecs_ec2_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ecs-node-ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}