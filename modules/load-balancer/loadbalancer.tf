locals {
  alb_name = format("%s-%s-%s", var.appname, var.env, "application")
  nlb_name = format("%s-%s-%s", var.appname, var.env, "network")
}

resource "aws_lb" "alb" {
  #count                      = var.type == "application" ? 1 : 0
  name                       = local.alb_name
  internal                   = var.internal
  load_balancer_type         = var.type
  security_groups            = [var.security_group_id]
  subnets                    = var.subnets
  enable_deletion_protection = false
  tags = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "app-lb") })
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "alb-tg" {
  name_prefix      = "alb-tg"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.autoscaling_group_name #aws_autoscaling_group.new-auto-group.name
  lb_target_group_arn   = aws_lb_target_group.alb-tg.arn
}
