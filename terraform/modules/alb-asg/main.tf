data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_lb" "web" {
  name               = "${var.group_name}-${var.environment}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.group_name}-${var.environment}-ALB"
  })
}

resource "aws_lb_target_group" "web" {
  name     = "${var.group_name}-${var.environment}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.group_name}-${var.environment}-TG"
  })
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.group_name}-${var.environment}-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.web_security_group_id]

  user_data = base64encode(templatefile("${path.module}/${var.user_data_path}", {
    environment  = var.environment
    group_name   = var.group_name
    instance_type = var.instance_type
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.group_name}-${var.environment}-ASG-Instance"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.group_name}-${var.environment}-ASG"
  min_size            = 1
  max_size            = 5
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns    = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  health_check_grace_period = 300  # 5 minutes
  default_cooldown          = 60   # 1 minute

  tag {
    key                 = "Name"
    value               = "${var.group_name}-${var.environment}-ASG"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Target Tracking Scaling Policy (Dynamic Scaling)
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.group_name}-${var.environment}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.web.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# Predictive Scaling Policy
resource "aws_autoscaling_policy" "predictive_scaling" {
  name                   = "${var.group_name}-${var.environment}-predictive-scaling"
  policy_type            = "PredictiveScaling"
  autoscaling_group_name = aws_autoscaling_group.web.name

  predictive_scaling_configuration {
    metric_specification {
      target_value = 50
      predefined_scaling_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
        resource_label         = "predefined"
      }
      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label         = "predefined"
      }
    }

    mode                         = "ForecastAndScale"
    scheduling_buffer_time       = 120
    max_capacity_breach_behavior = "IncreaseMaxCapacity"
    max_capacity_buffer          = 10
  }
}