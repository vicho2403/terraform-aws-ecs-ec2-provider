# ----------------------------------------------------------------------------------------------------------------------
# Load Balancer's Security Group
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "load_balancer_sg" {
  count = local.create_load_balancer ? 1 : 0

  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Allow incoming connections for load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Application Load Balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "application_load_balancer" {
  count = local.create_load_balancer ? 1 : 0

  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_sg[0].id]
  subnets                    = tolist(var.public_subnets)
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}
# ----------------------------------------------------------------------------------------------------------------------
# Target Group
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_alb_target_group" "alb_target_group" {
  for_each = local.target_groups

  name        = "${each.key}-${var.environment}-alb-tg"
  target_type = contains(["bridge", "host"], each.value.network_mode) ? "instance" : "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    path                = each.value.health
    timeout             = 30
    matcher             = 200
    protocol            = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${each.key}-${var.environment}-alb-tg"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Listeners
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "alb_http_listener" {
  count = local.create_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.application_load_balancer[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-http-alb-listener"
  }
}

resource "aws_lb_listener" "alb_https_listener" {
  count = local.create_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.application_load_balancer[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Project: ${var.project_name}\nEnvironment: ${var.environment}"
      status_code  = "200"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-https-alb-listener"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# 443 Listener Rules
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener_rule" "condition_based_routing" {
  for_each = local.target_groups

  listener_arn = aws_lb_listener.alb_https_listener[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group[each.key].arn
  }

  condition {
    path_pattern {
      values = length(each.value.paths) > 0 ? each.value.paths : ["/${each.key}"]
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${each.key}-listener-rules"
  }
}