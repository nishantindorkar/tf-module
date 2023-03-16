locals {
  alb_name = format("%s-%s-%s", var.appname, var.env, "application")
  nlb_name = format("%s-%s-%s", var.appname, var.env, "network")
  #account_id = data.aws_caller_identity.current.account_id
  #user_name = data.aws_caller_identity.current.user_id
}
resource "random_string" "rand" {
  length = 3
  special = false
  upper = false
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "bucket-${random_string.rand.id}-${var.appname}-${var.env}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "s3-bucket" {
  bucket = aws_s3_bucket.s3-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket.s3-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowLBLogs"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.s3-bucket.arn}",
          "${aws_s3_bucket.s3-bucket.arn}/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current" {}
resource "aws_lb" "alb" {
  #count                      = var.type == "application" ? 1 : 0
  name                       = local.alb_name
  internal                   = var.internal
  load_balancer_type         = var.type
  security_groups            = [var.security_group_id]
  subnets                    = var.vpc_public
  enable_deletion_protection = false
  tags = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "app-lb") })
  access_logs {
    bucket  = aws_s3_bucket.s3-bucket.id
    prefix  = "lb-logs"
    enabled = true
  }
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
  autoscaling_group_name = var.autoscaling_group_name 
  lb_target_group_arn   = aws_lb_target_group.alb-tg.arn
}
