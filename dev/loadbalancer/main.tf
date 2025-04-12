terraform {
  backend "s3" {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/loadbalancer/terraform.tfstate" # Unique key for dev/loadbalancer state (if needed)
    region         = "us-east-1" # Or your desired region
    encrypt        = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

data "terraform_remote_state" "instances" {
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/instances/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}


resource "aws_lb" "app_lb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids # Get subnets from network state
  security_groups    = [aws_security_group.alb_sg.id]

  tags = merge(var.default_tags, { Name = "${var.prefix}-alb" })
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-alb-sg"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id # Get vpc_id from network state

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.prefix}-alb-sg" })
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id # Get vpc_id from network state
  target_type = "instance"
  tags = merge(var.default_tags, { Name = "${var.prefix}-alb-tg" })
}

resource "aws_lb_target_group_attachment" "web_server_tg_attachment" {
  count            = length(data.terraform_remote_state.instances.outputs.web_server_instance_ids) # Count from instance state output
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = element(data.terraform_remote_state.instances.outputs.web_server_instance_ids, count.index) # Get instance IDs from instance state output
  port             = 80
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}